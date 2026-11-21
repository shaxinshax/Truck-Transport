import 'package:material_ui/material_ui.dart';

import '../../data/backend.dart';
import '../../data/models.dart';

/// Loads and keeps the signed-in driver's profile, vehicles and documents.
class DriverData extends ChangeNotifier {
  DriverData(this.user);

  final AppUser user;
  Backend get api => Backend.instance;

  Map<String, dynamic>? driver;
  List<Map<String, dynamic>> vehicles = [];
  List<DocRecord> documents = [];
  List<DocType> docTypes = [];
  bool loading = true;
  Object? error;

  bool get hasProfile => driver != null;
  ReviewStatus get status => parseStatus(driver?['status']);

  List<DocType> get driverDocTypes => docTypes.where((t) => t.forVehicle == null).toList();
  List<DocType> vehicleDocTypes(String kind) => docTypes.where((t) => t.forVehicle == kind).toList();

  DocRecord? latest(String type, {String? vehicleId}) {
    DocRecord? found;
    for (final d in documents) {
      if (d.type == type && d.vehicleId == vehicleId) found = d;
    }
    return found;
  }

  int get missingRequired {
    var n = driverDocTypes.where((t) => t.required && latest(t.code) == null).length;
    for (final v in vehicles) {
      n += vehicleDocTypes(v['kind'] as String).where((t) => t.required && latest(t.code, vehicleId: v['id'] as String) == null).length;
    }
    return n;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        api.getDriver(user.id),
        api.listVehicles(user.id),
        api.listDocuments(user.id),
        api.listDocTypes(),
      ]);
      driver = results[0] as Map<String, dynamic>?;
      vehicles = results[1] as List<Map<String, dynamic>>;
      documents = results[2] as List<DocRecord>;
      docTypes = [...results[3] as List<DocType>]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } catch (e) {
      error = e;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> saveDriver(Map<String, dynamic> values) async {
    await api.saveDriver({...?driver, ...values, 'id': user.id});
    driver = await api.getDriver(user.id);
    notifyListeners();
  }

  Future<void> saveVehicle(Map<String, dynamic> v) async {
    await api.saveVehicle({...v, 'driver_id': user.id});
    vehicles = await api.listVehicles(user.id);
    notifyListeners();
  }

  Future<void> deleteVehicle(String id) async {
    await api.deleteVehicle(id);
    vehicles = await api.listVehicles(user.id);
    documents = await api.listDocuments(user.id);
    notifyListeners();
  }

  Future<void> upload(String type, PickedFile file, {String? vehicleId}) async {
    final old = latest(type, vehicleId: vehicleId);
    await api.uploadDocument(driverId: user.id, vehicleId: vehicleId, type: type, file: file);
    if (old != null) await api.deleteDocument(old);
    documents = await api.listDocuments(user.id);
    notifyListeners();
  }

  Future<void> deleteDoc(DocRecord doc) async {
    await api.deleteDocument(doc);
    documents = await api.listDocuments(user.id);
    notifyListeners();
  }
}
