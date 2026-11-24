import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'backend.dart';
import 'models.dart';

const _bucket = 'driver-files';

class SupabaseBackend implements Backend {
  SupabaseBackend._(this._db) {
    _db.auth.onAuthStateChange.listen((_) => _refreshUser());
    _refreshUser();
  }

  static Future<SupabaseBackend> init({required String url, required String anonKey}) async {
    await Supabase.initialize(url: url, publishableKey: anonKey);
    return SupabaseBackend._(Supabase.instance.client);
  }

  final SupabaseClient _db;
  final _user = ValueNotifier<AppUser?>(null);
  final _unread = ValueNotifier<int>(0);
  RealtimeChannel? _channel;

  @override
  ValueListenable<AppUser?> get user => _user;

  @override
  bool get isDemo => false;

  Future<void> _refreshUser() async {
    final u = _db.auth.currentUser;
    if (u == null) {
      _user.value = null;
      _unread.value = 0;
      await _channel?.unsubscribe();
      _channel = null;
      return;
    }
    var admin = false;
    try {
      admin = await _db.rpc('is_admin') as bool? ?? false;
    } catch (_) {}
    _user.value = AppUser(id: u.id, email: u.email, phone: u.phone, isAdmin: admin);
    _listenNotifications(u.id);
  }

  void _listenNotifications(String userId) {
    _channel?.unsubscribe();
    _channel = _db
        .channel('notifications-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
          callback: (_) => _refreshUnread(),
        )
        .subscribe();
    _refreshUnread();
  }

  Future<void> _refreshUnread() async {
    try {
      final rows = await _db.from('notifications').select('id').isFilter('read_at', null);
      _unread.value = rows.length;
    } catch (_) {}
  }

  // ---------- Auth ----------
  @override
  Future<void> sendPhoneCode(String phone, {bool whatsapp = false}) =>
      _db.auth.signInWithOtp(phone: phone, channel: whatsapp ? OtpChannel.whatsapp : OtpChannel.sms);

  @override
  Future<void> verifyPhoneCode(String phone, String code) async {
    await _db.auth.verifyOTP(phone: phone, token: code, type: OtpType.sms);
  }

  @override
  Future<bool> signUpWithEmail(String email, String password) async {
    final res = await _db.auth.signUp(email: email, password: password);
    return res.session == null;
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _db.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _db.auth.signOut();

  // ---------- Driver data ----------
  @override
  Future<Map<String, dynamic>?> getDriver(String driverId) =>
      _db.from('drivers').select().eq('id', driverId).maybeSingle();

  @override
  Future<void> saveDriver(Map<String, dynamic> driver) async {
    final row = Map<String, dynamic>.of(driver)
      ..removeWhere((k, _) => const {'created_at', 'updated_at', 'reviewed_by', 'reviewed_at'}.contains(k));
    await _db.from('drivers').upsert(row);
  }

  @override
  Future<List<Map<String, dynamic>>> listVehicles(String driverId) =>
      _db.from('vehicles').select().eq('driver_id', driverId).order('created_at');

  @override
  Future<void> saveVehicle(Map<String, dynamic> vehicle) async {
    final row = Map<String, dynamic>.of(vehicle)..removeWhere((k, _) => k == 'created_at' || k == 'updated_at');
    await _db.from('vehicles').upsert(row);
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    final docs = await _db.from('documents').select('storage_path').eq('vehicle_id', vehicleId);
    final paths = [for (final d in docs) d['storage_path'] as String];
    if (paths.isNotEmpty) await _db.storage.from(_bucket).remove(paths);
    await _db.from('vehicles').delete().eq('id', vehicleId);
  }

  // ---------- Documents ----------
  @override
  Future<List<DocType>> listDocTypes() async {
    final rows = await _db.from('document_types').select().eq('active', true).order('sort_order');
    return rows.map(DocType.fromMap).toList();
  }

  @override
  Future<List<DocRecord>> listDocuments(String driverId) async {
    final rows = await _db.from('documents').select().eq('driver_id', driverId).order('created_at');
    return rows.map(DocRecord.fromMap).toList();
  }

  String _newPath(String driverId, PickedFile file) {
    final r = Random.secure();
    final id = List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    return '$driverId/$id.${extensionFor(file)}';
  }

  @override
  Future<DocRecord> uploadDocument({
    required String driverId,
    String? vehicleId,
    required String type,
    required PickedFile file,
  }) async {
    final path = _newPath(driverId, file);
    await _db.storage.from(_bucket).uploadBinary(path, file.bytes,
        fileOptions: FileOptions(contentType: file.mimeType));
    final row = await _db
        .from('documents')
        .insert({
          'driver_id': driverId,
          'vehicle_id': vehicleId,
          'type': type,
          'storage_path': path,
          'mime_type': file.mimeType,
          'size_bytes': file.bytes.length,
        })
        .select()
        .single();
    return DocRecord.fromMap(row);
  }

  @override
  Future<void> deleteDocument(DocRecord doc) async {
    await _db.storage.from(_bucket).remove([doc.storagePath]);
    await _db.from('documents').delete().eq('id', doc.id);
  }

  @override
  Future<String> uploadProfilePhoto(String driverId, PickedFile file) async {
    final path = _newPath(driverId, file);
    await _db.storage.from(_bucket).uploadBinary(path, file.bytes,
        fileOptions: FileOptions(contentType: file.mimeType));
    return path;
  }

  @override
  Future<Uint8List?> downloadFile(String storagePath) async {
    try {
      return await _db.storage.from(_bucket).download(storagePath);
    } catch (_) {
      return null;
    }
  }

  // ---------- Routes ----------
  @override
  Future<List<Map<String, dynamic>>> listRoutes({String? driverId}) async {
    var q = _db.from('routes').select('*, drivers(first_name, last_name, phone), vehicles(plate_number)');
    if (driverId != null) q = q.eq('driver_id', driverId);
    final rows = await q.order('arrive_from', ascending: true, nullsFirst: false);
    return [
      for (final r in rows)
        {
          ...Map<String, dynamic>.of(r)..remove('drivers')..remove('vehicles'),
          'driver_name': '${r['drivers']?['first_name'] ?? ''} ${r['drivers']?['last_name'] ?? ''}'.trim(),
          'driver_phone': r['drivers']?['phone'],
          'plate': r['vehicles']?['plate_number'],
        }
    ];
  }

  @override
  Future<void> saveRoute(Map<String, dynamic> route) async {
    final row = Map<String, dynamic>.of(route)
      ..removeWhere((k, _) => const {'created_at', 'updated_at', 'driver_name', 'driver_phone', 'plate'}.contains(k));
    await _db.from('routes').upsert(row);
  }

  @override
  Future<void> deleteRoute(String routeId) => _db.from('routes').delete().eq('id', routeId);

  // ---------- Live location ----------
  @override
  Future<void> updateMyLocation({required double lat, required double lng, double? speedKmh, double? heading}) async {
    await _db.from('driver_locations').upsert({
      'driver_id': _db.auth.currentUser!.id,
      'lat': lat,
      'lng': lng,
      'speed_kmh': speedKmh,
      'heading': heading,
      'sharing': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> stopSharingLocation() async {
    await _db.from('driver_locations').update({'sharing': false}).eq('driver_id', _db.auth.currentUser!.id);
  }

  @override
  Future<List<Map<String, dynamic>>> listLiveLocations() async {
    final rows = await _db
        .from('driver_locations')
        .select('*, drivers(first_name, last_name, phone, vehicles(plate_number, kind))')
        .eq('sharing', true);
    return [
      for (final r in rows)
        {
          ...Map<String, dynamic>.of(r)..remove('drivers'),
          'driver_name': '${r['drivers']?['first_name'] ?? ''} ${r['drivers']?['last_name'] ?? ''}'.trim(),
          'driver_phone': r['drivers']?['phone'],
          'plate': [
            for (final v in (r['drivers']?['vehicles'] as List? ?? const []))
              if (v['kind'] == 'truck') v['plate_number']
          ].join(', '),
        }
    ];
  }

  // ---------- Notifications ----------
  @override
  ValueListenable<int> get unreadNotifications => _unread;

  @override
  Future<List<AppNotification>> listNotifications() async {
    final rows = await _db.from('notifications').select().order('created_at', ascending: false).limit(100);
    return [for (final r in rows) AppNotification.fromMap(r)];
  }

  @override
  Future<void> markNotificationsRead() async {
    await _db.from('notifications').update({'read_at': DateTime.now().toUtc().toIso8601String()}).isFilter('read_at', null);
    _unread.value = 0;
  }

  // ---------- Admin ----------
  @override
  Future<List<DriverSummary>> listDrivers({ReviewStatus? status}) async {
    var q = _db.from('drivers').select('*, vehicles(plate_number)');
    if (status != null) q = q.eq('status', status.name);
    final rows = await q.order('created_at', ascending: false);
    return [
      for (final r in rows)
        DriverSummary(
          driver: Map<String, dynamic>.of(r)..remove('vehicles'),
          plates: [for (final v in (r['vehicles'] as List? ?? const [])) v['plate_number'] as String],
        )
    ];
  }

  Map<String, dynamic> _review(ReviewStatus status, String? note) => {
        'status': status.name,
        'review_note': note,
        'reviewed_by': _db.auth.currentUser?.id,
        'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      };

  @override
  Future<void> setDriverStatus(String driverId, ReviewStatus status, {String? note}) async {
    await _db.from('drivers').update(_review(status, note)).eq('id', driverId);
  }

  @override
  Future<void> setDocumentStatus(String docId, ReviewStatus status, {String? note}) async {
    await _db.from('documents').update(_review(status, note)).eq('id', docId);
  }
}
