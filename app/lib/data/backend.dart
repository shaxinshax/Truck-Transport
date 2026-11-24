
import 'package:flutter/foundation.dart';

import 'models.dart';

/// Everything the UI needs from the server. [SupabaseBackend] talks to the real
/// server; [DemoBackend] keeps sample data in memory for previews.
abstract class Backend {
  static late Backend instance;

  ValueListenable<AppUser?> get user;
  bool get isDemo;

  // Auth
  /// [whatsapp] sends the code as a WhatsApp message instead of an SMS.
  Future<void> sendPhoneCode(String phone, {bool whatsapp = false});
  Future<void> verifyPhoneCode(String phone, String code);

  /// Returns true when the user must confirm their email before signing in.
  Future<bool> signUpWithEmail(String email, String password);
  Future<void> signInWithEmail(String email, String password);
  Future<void> signOut();

  // Driver data
  Future<Map<String, dynamic>?> getDriver(String driverId);
  Future<void> saveDriver(Map<String, dynamic> driver);
  Future<List<Map<String, dynamic>>> listVehicles(String driverId);
  Future<void> saveVehicle(Map<String, dynamic> vehicle);
  Future<void> deleteVehicle(String vehicleId);

  // Documents
  Future<List<DocType>> listDocTypes();
  Future<List<DocRecord>> listDocuments(String driverId);
  Future<DocRecord> uploadDocument({
    required String driverId,
    String? vehicleId,
    required String type,
    required PickedFile file,
  });
  Future<void> deleteDocument(DocRecord doc);
  Future<String> uploadProfilePhoto(String driverId, PickedFile file);
  Future<Uint8List?> downloadFile(String storagePath);

  // Routes (trip planning). [driverId] null = all drivers (admins only);
  // admin rows also carry 'driver_name', 'driver_phone' and 'plate'.
  Future<List<Map<String, dynamic>>> listRoutes({String? driverId});
  Future<void> saveRoute(Map<String, dynamic> route);
  Future<void> deleteRoute(String routeId);

  // Live location. Drivers send their latest position; admins read all of them.
  // Admin rows also carry 'driver_name', 'driver_phone' and 'plate'.
  Future<void> updateMyLocation({required double lat, required double lng, double? speedKmh, double? heading});
  Future<void> stopSharingLocation();
  Future<List<Map<String, dynamic>>> listLiveLocations();

  // Notifications for the signed-in user
  ValueListenable<int> get unreadNotifications;
  Future<List<AppNotification>> listNotifications();
  Future<void> markNotificationsRead();

  // Admin
  Future<List<DriverSummary>> listDrivers({ReviewStatus? status});
  Future<void> setDriverStatus(String driverId, ReviewStatus status, {String? note});
  Future<void> setDocumentStatus(String docId, ReviewStatus status, {String? note});
}

String extensionFor(PickedFile f) {
  final dot = f.name.lastIndexOf('.');
  if (dot >= 0 && dot < f.name.length - 1) return f.name.substring(dot + 1).toLowerCase();
  return switch (f.mimeType) {
    'image/png' => 'png',
    'application/pdf' => 'pdf',
    _ => 'jpg',
  };
}
