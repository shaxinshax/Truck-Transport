import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

import '../l10n/gen/app_localizations.dart';
import 'backend.dart';
import 'models.dart';

/// Builds one ZIP file with everything drivers sent, ready to open on a PC:
///
///   TD_drivers_2026-11-24/
///     drivers.xlsx                  (sheet "Drivers" + sheet "Vehicles")
///     01_Giorgi_Beridze/
///       Profile photo.jpg
///       Driver's license (front).jpg
///       Truck AB-123-CD/
///         License plate photo.jpg
class DriverExport {
  DriverExport(this.l, this.lang);
  final AppLocalizations l;
  final String lang;
  Backend get _api => Backend.instance;

  static String folderName() => 'TD_drivers_${_day(DateTime.now())}';

  /// [driverIds] limits the export to some drivers (null = everyone).
  Future<Uint8List> build({List<String>? driverIds, void Function(double)? onProgress}) async {
    final types = {for (final t in await _api.listDocTypes()) t.code: t};
    var drivers = await _api.listDrivers();
    if (driverIds != null) drivers = drivers.where((d) => driverIds.contains(d.id)).toList();
    drivers.sort((a, b) => (a.driver['created_at'] ?? '').toString().compareTo((b.driver['created_at'] ?? '').toString()));

    final root = folderName();
    final zip = Archive();
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    final ds = excel[l.drivers];
    final vs = excel[l.vehicles];
    final rs = excel[l.routes];
    if (defaultSheet != null) excel.delete(defaultSheet);

    final bold = CellStyle(bold: true, backgroundColorHex: ExcelColor.fromHexString('#DCE6F5'));
    void header(Sheet s, List<String> titles) {
      s.appendRow([for (final t in titles) TextCellValue(t)]);
      for (var i = 0; i < titles.length; i++) {
        s.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = bold;
        s.setColumnWidth(i, 22);
      }
    }

    header(ds, ['№', l.firstName, l.lastName, 'Status', l.phone, l.email, l.dateOfBirth, l.citizenship,
      l.address, l.city, l.country, l.licenseNumber, l.licenseCategories, l.licenseCountry,
      '${l.driversLicense}: ${l.issuedAt}', '${l.driversLicense}: ${l.expiresAt}',
      l.passportNumber, '${l.passport}: ${l.expiresAt}', l.reviewNote, l.vehicles, l.documents, 'Folder']);
    header(vs, ['№', l.firstName, l.lastName, '${l.truck} / ${l.trailer}', l.plateNumber, l.plateCountry, l.make, l.model,
      l.year, l.vin, l.trailerType, 'Status', 'Folder']);

    header(rs, ['№', l.firstName, l.lastName, l.phone, l.fromCity, l.country, l.toCity, l.country, l.departAt,
      l.arriveFrom, l.arriveTo, l.truck, l.freeForCargoShort, l.routeStatus, l.note]);

    for (var i = 0; i < drivers.length; i++) {
      onProgress?.call(i / drivers.length);
      final s = drivers[i];
      final d = s.driver;
      final num = (i + 1).toString().padLeft(2, '0');
      final folder = '$num ${_safe(s.fullName.isEmpty ? (d['phone'] ?? d['email'] ?? s.id).toString() : s.fullName)}';
      final vehicles = await _api.listVehicles(s.id);
      final docs = await _api.listDocuments(s.id);
      for (final r in await _api.listRoutes(driverId: s.id)) {
        rs.appendRow([
          TextCellValue(num), _t(d['first_name']), _t(d['last_name']), _t(d['phone']),
          _t(r['from_city']), _t(r['from_country']), _t(r['to_city']), _t(r['to_country']),
          _t(_dateTime(r['depart_at'])), _t(_dateTime(r['arrive_from'])), _t(_dateTime(r['arrive_to'])),
          _t(r['plate']), TextCellValue(r['free_for_cargo'] == true ? '✓' : ''),
          TextCellValue(_routeStatus(parseRouteStatus(r['status']))), _t(r['note']),
        ]);
      }
      final used = <String>{};

      Future<void> addFile(String dir, String name, String path, {String? fallbackExt}) async {
        final bytes = await _api.downloadFile(path);
        if (bytes == null) return;
        final ext = _ext(path) ?? fallbackExt ?? 'jpg';
        var file = '$root/$folder/${dir.isEmpty ? '' : '$dir/'}${_safe(name)}';
        var candidate = '$file.$ext';
        for (var n = 2; used.contains(candidate); n++) {
          candidate = '$file ($n).$ext';
        }
        used.add(candidate);
        zip.addFile(ArchiveFile(candidate, bytes.length, bytes));
      }

      if (d['profile_photo_path'] case final String p) await addFile('', l.profilePhoto, p);
      for (final doc in docs) {
        final label = types[doc.type]?.label(lang) ?? doc.type;
        var dir = '';
        if (doc.vehicleId != null) {
          final v = vehicles.where((v) => v['id'] == doc.vehicleId).firstOrNull;
          dir = _safe('${v?['kind'] == 'trailer' ? l.trailer : l.truck} ${v?['plate_number'] ?? ''}'.trim());
        }
        await addFile(dir, label, doc.storagePath, fallbackExt: doc.isImage ? 'jpg' : 'pdf');
      }

      ds.appendRow([
        TextCellValue(num), _t(d['first_name']), _t(d['last_name']), TextCellValue(_status(s.status)),
        _t(d['phone']), _t(d['email']), _t(_date(d['date_of_birth'])), _t(d['citizenship']),
        _t(d['address']), _t(d['city']), _t(d['country']), _t(d['license_number']),
        _t(d['license_categories']), _t(d['license_country']), _t(_date(d['license_issued_at'])),
        _t(_date(d['license_expires_at'])), _t(d['passport_number']), _t(_date(d['passport_expires_at'])),
        _t(d['review_note']), _t(vehicles.map((v) => v['plate_number']).whereType<String>().join(', ')),
        IntCellValue(docs.length), TextCellValue(folder),
      ]);
      for (final v in vehicles) {
        vs.appendRow([
          TextCellValue(num), _t(d['first_name']), _t(d['last_name']),
          TextCellValue(v['kind'] == 'trailer' ? l.trailer : l.truck), _t(v['plate_number']),
          _t(v['plate_country']), _t(v['make']), _t(v['model']), _t(v['year']), _t(v['vin']),
          _t(v['trailer_type']), TextCellValue(_status(parseStatus(v['status']))), TextCellValue(folder),
        ]);
      }
    }

    final xlsx = excel.encode()!;
    zip.addFile(ArchiveFile('$root/drivers.xlsx', xlsx.length, xlsx));
    onProgress?.call(1);
    return Uint8List.fromList(ZipEncoder().encode(zip)!);
  }

  String _status(ReviewStatus s) => switch (s) {
        ReviewStatus.pending => l.statusPending,
        ReviewStatus.approved => l.statusApproved,
        ReviewStatus.rejected => l.statusRejected,
      };

  String _routeStatus(RouteStatus s) => switch (s) {
        RouteStatus.planned => l.routePlanned,
        RouteStatus.on_the_way => l.routeOnTheWay,
        RouteStatus.done => l.routeDone,
        RouteStatus.cancelled => l.routeCancelled,
      };

  static String? _dateTime(Object? v) {
    final d = DateTime.tryParse(v?.toString() ?? '')?.toLocal();
    if (d == null) return null;
    return '${_date(d.toIso8601String())} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static CellValue _t(Object? v) =>
      TextCellValue(v == null ? '' : (v is List ? v.join(', ') : v.toString()));

  static String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String? _date(Object? v) {
    final d = DateTime.tryParse(v?.toString() ?? '');
    if (d == null) return v?.toString();
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  static String? _ext(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot > 0 && dot < name.length - 1 ? name.substring(dot + 1).toLowerCase() : null;
  }

  /// Removes characters Windows does not allow in file names.
  static String _safe(String s) => s.replaceAll(RegExp(r'[\\/:*?"<>|\n\r\t]'), '').trim();
}
