import 'dart:typed_data';

enum ReviewStatus { pending, approved, rejected }

ReviewStatus parseStatus(Object? v) => ReviewStatus.values
    .firstWhere((s) => s.name == v, orElse: () => ReviewStatus.pending);

class AppUser {
  const AppUser({required this.id, this.email, this.phone, this.isAdmin = false});
  final String id;
  final String? email;
  final String? phone;
  final bool isAdmin;
}

/// A kind of document or photo. Rows come from the `document_types` table so
/// new kinds can be added without releasing a new app version.
class DocType {
  const DocType({
    required this.code,
    required this.labels,
    this.forVehicle,
    this.required = false,
    this.hasExpiry = false,
    this.sortOrder = 100,
  });

  factory DocType.fromMap(Map<String, dynamic> m) => DocType(
        code: m['code'] as String,
        labels: {
          'en': m['label_en'] as String,
          'ru': m['label_ru'] as String,
          'ka': m['label_ka'] as String,
          'tr': m['label_tr'] as String,
        },
        forVehicle: m['for_vehicle'] as String?,
        required: m['required'] as bool? ?? false,
        hasExpiry: m['has_expiry'] as bool? ?? false,
        sortOrder: m['sort_order'] as int? ?? 100,
      );

  final String code;
  final Map<String, String> labels;

  /// null = a driver document, otherwise 'truck' or 'trailer'.
  final String? forVehicle;
  final bool required;
  final bool hasExpiry;
  final int sortOrder;

  String label(String languageCode) => labels[languageCode] ?? labels['en']!;
}

class DocRecord {
  DocRecord({
    required this.id,
    required this.driverId,
    required this.type,
    required this.storagePath,
    this.vehicleId,
    this.mimeType,
    this.status = ReviewStatus.pending,
    this.reviewNote,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DocRecord.fromMap(Map<String, dynamic> m) => DocRecord(
        id: m['id'] as String,
        driverId: m['driver_id'] as String,
        vehicleId: m['vehicle_id'] as String?,
        type: m['type'] as String,
        storagePath: m['storage_path'] as String,
        mimeType: m['mime_type'] as String?,
        status: parseStatus(m['status']),
        reviewNote: m['review_note'] as String?,
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? ''),
      );

  final String id;
  final String driverId;
  final String? vehicleId;
  final String type;
  final String storagePath;
  final String? mimeType;
  ReviewStatus status;
  String? reviewNote;
  final DateTime createdAt;

  bool get isImage => (mimeType ?? '').startsWith('image/');
}

class PickedFile {
  const PickedFile({required this.bytes, required this.name, required this.mimeType});
  final Uint8List bytes;
  final String name;
  final String mimeType;
}

/// Driver row with the vehicles' plates, for the admin list.
class DriverSummary {
  DriverSummary({required this.driver, required this.plates});
  final Map<String, dynamic> driver;
  final List<String> plates;

  String get id => driver['id'] as String;
  String get fullName =>
      '${driver['first_name'] ?? ''} ${driver['last_name'] ?? ''}'.trim();
  ReviewStatus get status => parseStatus(driver['status']);
}

// Names match the database enum.
// ignore: constant_identifier_names
enum RouteStatus { planned, on_the_way, done, cancelled }

RouteStatus parseRouteStatus(Object? v) => RouteStatus.values
    .firstWhere((s) => s.name == v, orElse: () => RouteStatus.planned);

class AppNotification {
  AppNotification({required this.id, required this.kind, this.data = const {}, this.readAt, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
        id: m['id'] as String,
        kind: m['kind'] as String,
        data: Map<String, dynamic>.from(m['data'] as Map? ?? const {}),
        readAt: DateTime.tryParse(m['read_at'] as String? ?? ''),
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? ''),
      );

  final String id;
  final String kind;
  final Map<String, dynamic> data;
  DateTime? readAt;
  final DateTime createdAt;
}
