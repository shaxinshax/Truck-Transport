
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'backend.dart';
import 'models.dart';

/// In-memory backend with sample drivers, used for previews when the app is
/// started without Supabase settings. Nothing is saved between runs.
class DemoBackend implements Backend {
  DemoBackend() {
    _seed();
  }

  final _user = ValueNotifier<AppUser?>(null);
  final _drivers = <String, Map<String, dynamic>>{};
  final _vehicles = <String, Map<String, dynamic>>{};
  final _docs = <DocRecord>[];
  final _files = <String, Uint8List>{};
  final _assetFiles = <String, String>{};
  int _seq = 0;

  String _id() => 'demo-${++_seq}';
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 250));

  @override
  ValueListenable<AppUser?> get user => _user;

  @override
  bool get isDemo => true;

  static const demoAdminEmail = 'admin@demo.app';

  // ---------- Auth ----------
  @override
  Future<void> sendPhoneCode(String phone) => _delay();

  @override
  Future<void> verifyPhoneCode(String phone, String code) async {
    await _delay();
    _user.value = AppUser(id: 'user-$phone', phone: phone);
  }

  @override
  Future<bool> signUpWithEmail(String email, String password) async {
    await signInWithEmail(email, password);
    return false;
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _delay();
    final admin = email.toLowerCase() == demoAdminEmail;
    _user.value = AppUser(id: admin ? 'admin' : 'user-$email', email: email, isAdmin: admin);
  }

  @override
  Future<void> signOut() async => _user.value = null;

  // ---------- Driver data ----------
  @override
  Future<Map<String, dynamic>?> getDriver(String driverId) async {
    await _delay();
    final d = _drivers[driverId];
    return d == null ? null : Map.of(d);
  }

  @override
  Future<void> saveDriver(Map<String, dynamic> driver) async {
    await _delay();
    final id = driver['id'] as String;
    _drivers[id] = {
      'created_at': DateTime.now().toIso8601String(),
      ...?_drivers[id],
      ...driver,
      'status': 'pending',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> listVehicles(String driverId) async {
    await _delay();
    return [for (final v in _vehicles.values) if (v['driver_id'] == driverId) Map.of(v)];
  }

  @override
  Future<void> saveVehicle(Map<String, dynamic> vehicle) async {
    await _delay();
    final id = vehicle['id'] as String? ?? _id();
    _vehicles[id] = {...?_vehicles[id], ...vehicle, 'id': id, 'status': 'pending'};
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    await _delay();
    _vehicles.remove(vehicleId);
    _docs.removeWhere((d) => d.vehicleId == vehicleId);
  }

  // ---------- Documents ----------
  @override
  Future<List<DocType>> listDocTypes() async => demoDocTypes;

  @override
  Future<List<DocRecord>> listDocuments(String driverId) async {
    await _delay();
    return _docs.where((d) => d.driverId == driverId).toList();
  }

  @override
  Future<DocRecord> uploadDocument({
    required String driverId,
    String? vehicleId,
    required String type,
    required PickedFile file,
  }) async {
    await _delay();
    final path = '$driverId/${_id()}.${extensionFor(file)}';
    _files[path] = file.bytes;
    final doc = DocRecord(
      id: _id(),
      driverId: driverId,
      vehicleId: vehicleId,
      type: type,
      storagePath: path,
      mimeType: file.mimeType,
    );
    _docs.add(doc);
    return doc;
  }

  @override
  Future<void> deleteDocument(DocRecord doc) async {
    await _delay();
    _docs.removeWhere((d) => d.id == doc.id);
    _files.remove(doc.storagePath);
  }

  @override
  Future<String> uploadProfilePhoto(String driverId, PickedFile file) async {
    final path = '$driverId/${_id()}.${extensionFor(file)}';
    _files[path] = file.bytes;
    return path;
  }

  @override
  Future<Uint8List?> downloadFile(String storagePath) async {
    if (_files[storagePath] case final bytes?) return bytes;
    final asset = _assetFiles[storagePath];
    if (asset == null) return null;
    final data = await rootBundle.load(asset);
    return data.buffer.asUint8List();
  }

  // ---------- Admin ----------
  @override
  Future<List<DriverSummary>> listDrivers({ReviewStatus? status}) async {
    await _delay();
    final list = [
      for (final d in _drivers.values)
        if (status == null || d['status'] == status.name)
          DriverSummary(
            driver: Map.of(d),
            plates: [
              for (final v in _vehicles.values)
                if (v['driver_id'] == d['id']) v['plate_number'] as String
            ],
          )
    ];
    list.sort((a, b) => (b.driver['created_at'] as String).compareTo(a.driver['created_at'] as String));
    return list;
  }

  @override
  Future<void> setDriverStatus(String driverId, ReviewStatus status, {String? note}) async {
    await _delay();
    _drivers[driverId]?.addAll({'status': status.name, 'review_note': note});
  }

  @override
  Future<void> setDocumentStatus(String docId, ReviewStatus status, {String? note}) async {
    await _delay();
    for (final d in _docs) {
      if (d.id == docId) {
        d.status = status;
        d.reviewNote = note;
      }
    }
  }

  // ---------- Sample data ----------
  void _seedDoc(String driverId, String type, String asset, {String? vehicleId, ReviewStatus status = ReviewStatus.pending, String? note}) {
    final path = '$driverId/${_id()}.png';
    _assetFiles[path] = 'assets/demo/$asset';
    _docs.add(DocRecord(
      id: _id(),
      driverId: driverId,
      vehicleId: vehicleId,
      type: type,
      storagePath: path,
      mimeType: 'image/png',
      status: status,
      reviewNote: note,
    ));
  }

  void _seed() {
    final now = DateTime.now();
    String daysAgo(int d) => now.subtract(Duration(days: d)).toIso8601String();

    _drivers['d1'] = {
      'id': 'd1', 'first_name': 'Giorgi', 'last_name': 'Beridze', 'date_of_birth': '1986-04-12',
      'phone': '+995 555 12 34 56', 'citizenship': 'GE', 'city': 'Tbilisi', 'country': 'GE',
      'address': '12 Rustaveli Ave', 'license_number': 'GE1234567', 'license_categories': ['B', 'C', 'CE'],
      'license_country': 'GE', 'license_issued_at': '2015-06-01', 'license_expires_at': '2027-06-01',
      'passport_number': '15AB12345', 'passport_expires_at': '2029-03-10',
      'status': 'pending', 'created_at': daysAgo(0),
    };
    _vehicles['v1'] = {'id': 'v1', 'driver_id': 'd1', 'kind': 'truck', 'make': 'Volvo', 'model': 'FH 500',
      'year': 2019, 'plate_number': 'AB-123-CD', 'plate_country': 'GE', 'status': 'pending'};
    _seedDoc('d1', 'driver_license_front', 'license.png');
    _seedDoc('d1', 'truck_photo', 'truck.png', vehicleId: 'v1');
    _seedDoc('d1', 'truck_plate_photo', 'plate_ge.png', vehicleId: 'v1');

    _drivers['d2'] = {
      'id': 'd2', 'first_name': 'Mehmet', 'last_name': 'Yılmaz', 'date_of_birth': '1980-09-30',
      'phone': '+90 532 111 22 33', 'citizenship': 'TR', 'city': 'İstanbul', 'country': 'TR',
      'license_number': 'TR987654', 'license_categories': ['C', 'CE'], 'license_country': 'TR',
      'status': 'approved', 'created_at': daysAgo(3),
    };
    _vehicles['v2'] = {'id': 'v2', 'driver_id': 'd2', 'kind': 'truck', 'make': 'Mercedes-Benz', 'model': 'Actros',
      'year': 2021, 'plate_number': '34 ABC 123', 'plate_country': 'TR', 'status': 'approved'};
    _seedDoc('d2', 'driver_license_front', 'license.png', status: ReviewStatus.approved);
    _seedDoc('d2', 'truck_plate_photo', 'plate_tr.png', vehicleId: 'v2', status: ReviewStatus.approved);

    _drivers['d3'] = {
      'id': 'd3', 'first_name': 'Иван', 'last_name': 'Петров', 'phone': '+7 900 123 45 67',
      'citizenship': 'RU', 'city': 'Москва', 'country': 'RU', 'license_categories': ['C'],
      'status': 'rejected', 'review_note': 'Фото удостоверения нечитаемое, загрузите заново.',
      'created_at': daysAgo(6),
    };
    _seedDoc('d3', 'driver_license_front', 'license.png', status: ReviewStatus.rejected, note: 'Blurry photo');
  }
}

const demoDocTypes = <DocType>[
  DocType(code: 'driver_license_front', required: true, hasExpiry: true, sortOrder: 10, labels: {'en': "Driver's license (front)", 'ru': 'Водительское удостоверение (лицевая сторона)', 'ka': 'მართვის მოწმობა (წინა მხარე)', 'tr': 'Ehliyet (ön yüz)'}),
  DocType(code: 'driver_license_back', required: true, sortOrder: 20, labels: {'en': "Driver's license (back)", 'ru': 'Водительское удостоверение (обратная сторона)', 'ka': 'მართვის მოწმობა (უკანა მხარე)', 'tr': 'Ehliyet (arka yüz)'}),
  DocType(code: 'passport', required: true, hasExpiry: true, sortOrder: 30, labels: {'en': 'Passport or ID card', 'ru': 'Паспорт или удостоверение личности', 'ka': 'პასპორტი ან პირადობის მოწმობა', 'tr': 'Pasaport veya kimlik kartı'}),
  DocType(code: 'medical_certificate', hasExpiry: true, sortOrder: 40, labels: {'en': 'Medical certificate', 'ru': 'Медицинская справка', 'ka': 'სამედიცინო ცნობა', 'tr': 'Sağlık raporu'}),
  DocType(code: 'insurance', hasExpiry: true, sortOrder: 50, labels: {'en': 'Insurance', 'ru': 'Страховка', 'ka': 'დაზღვევა', 'tr': 'Sigorta'}),
  DocType(code: 'other', sortOrder: 90, labels: {'en': 'Other document', 'ru': 'Другой документ', 'ka': 'სხვა დოკუმენტი', 'tr': 'Diğer belge'}),
  DocType(code: 'truck_photo', forVehicle: 'truck', required: true, sortOrder: 10, labels: {'en': 'Truck photo', 'ru': 'Фото грузовика', 'ka': 'სატვირთოს ფოტო', 'tr': 'Kamyon fotoğrafı'}),
  DocType(code: 'truck_plate_photo', forVehicle: 'truck', required: true, sortOrder: 20, labels: {'en': 'License plate photo', 'ru': 'Фото номерного знака', 'ka': 'სახელმწიფო ნომრის ფოტო', 'tr': 'Plaka fotoğrafı'}),
  DocType(code: 'truck_registration', forVehicle: 'truck', required: true, sortOrder: 30, labels: {'en': 'Vehicle registration certificate', 'ru': 'Свидетельство о регистрации ТС', 'ka': 'ავტომობილის რეგისტრაციის მოწმობა', 'tr': 'Araç ruhsatı'}),
  DocType(code: 'trailer_photo', forVehicle: 'trailer', sortOrder: 10, labels: {'en': 'Trailer photo', 'ru': 'Фото прицепа', 'ka': 'მისაბმელის ფოტო', 'tr': 'Dorse fotoğrafı'}),
  DocType(code: 'trailer_plate_photo', forVehicle: 'trailer', sortOrder: 20, labels: {'en': 'License plate photo', 'ru': 'Фото номерного знака', 'ka': 'სახელმწიფო ნომრის ფოტო', 'tr': 'Plaka fotoğrafı'}),
  DocType(code: 'trailer_registration', forVehicle: 'trailer', sortOrder: 30, labels: {'en': 'Trailer registration certificate', 'ru': 'Свидетельство о регистрации прицепа', 'ka': 'მისაბმელის რეგისტრაციის მოწმობა', 'tr': 'Dorse ruhsatı'}),
];
