import 'package:material_ui/material_ui.dart';

import '../../data/backend.dart';
import '../../data/models.dart';
import '../common.dart';

/// Admin view of one driver: details, vehicles and documents to approve or reject.
class DriverReview extends StatefulWidget {
  const DriverReview({super.key, required this.driverId, required this.onChanged});
  final String driverId;
  final VoidCallback onChanged;

  @override
  State<DriverReview> createState() => _DriverReviewState();
}

class _DriverReviewState extends State<DriverReview> {
  Map<String, dynamic>? _driver;
  List<Map<String, dynamic>> _vehicles = [];
  List<DocRecord> _docs = [];
  Map<String, DocType> _types = {};
  bool _loading = true;

  Backend get _api => Backend.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Future.wait([
        _api.getDriver(widget.driverId),
        _api.listVehicles(widget.driverId),
        _api.listDocuments(widget.driverId),
        _api.listDocTypes(),
      ]);
      _driver = r[0] as Map<String, dynamic>?;
      _vehicles = r[1] as List<Map<String, dynamic>>;
      _docs = r[2] as List<DocRecord>;
      _types = {for (final t in r[3] as List<DocType>) t.code: t};
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<String?> _askReason() {
    final c = TextEditingController();
    final l = context.l10n;
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.reject),
        content: SizedBox(
          width: 420,
          child: TextField(controller: c, autofocus: true, maxLines: 3, decoration: InputDecoration(labelText: l.rejectReason)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(l.reject)),
        ],
      ),
    );
  }

  Future<void> _setDriver(ReviewStatus s) async {
    String? note;
    if (s == ReviewStatus.rejected) {
      note = await _askReason();
      if (note == null) return;
    }
    try {
      await _api.setDriverStatus(widget.driverId, s, note: note);
      await _load();
      widget.onChanged();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _setDoc(DocRecord d, ReviewStatus s) async {
    String? note;
    if (s == ReviewStatus.rejected) {
      note = await _askReason();
      if (note == null) return;
    }
    try {
      await _api.setDocumentStatus(d.id, s, note: note);
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    final d = _driver;
    if (d == null) return Center(child: Text(l.noDrivers));
    final status = parseStatus(d['status']);
    final name = '${d['first_name'] ?? ''} ${d['last_name'] ?? ''}'.trim();

    Widget info(String label, Object? value) {
      final text = value is List ? value.join(', ') : value?.toString();
      if (text == null || text.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 170, child: Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: SelectableText(text)),
        ]),
      );
    }

    final driverDocs = _docs.where((x) => x.vehicleId == null).toList();
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [
        CircleAvatar(
          radius: 32,
          child: d['profile_photo_path'] == null
              ? Text(name.isEmpty ? '?' : name.characters.first, style: const TextStyle(fontSize: 24))
              : ClipOval(child: SizedBox(width: 64, height: 64, child: StoredImage(path: d['profile_photo_path'] as String))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              StatusChip(status),
              if (dateText(d['created_at']) case final date?) Text(l.registeredOn(date), style: theme.textTheme.bodySmall),
            ]),
          ]),
        ),
      ]),
      if ((d['review_note'] as String? ?? '').isNotEmpty) ...[
        const SizedBox(height: 12),
        Text('${l.reviewNote}: ${d['review_note']}', style: TextStyle(color: theme.colorScheme.error)),
      ],
      const SizedBox(height: 16),
      Wrap(spacing: 12, runSpacing: 8, children: [
        FilledButton.icon(
          onPressed: status == ReviewStatus.approved ? null : () => _setDriver(ReviewStatus.approved),
          style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
          icon: const Icon(Icons.check),
          label: Text(l.approve),
        ),
        OutlinedButton.icon(
          onPressed: status == ReviewStatus.rejected ? null : () => _setDriver(ReviewStatus.rejected),
          style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
          icon: const Icon(Icons.close),
          label: Text(l.reject),
        ),
      ]),
      SectionTitle(l.personalInfo),
      info(l.dateOfBirth, dateText(d['date_of_birth'])),
      info(l.phone, d['phone']),
      info(l.email, d['email']),
      info(l.citizenship, d['citizenship']),
      info(l.address, [d['address'], d['city'], d['country']].where((e) => e != null && '$e'.isNotEmpty).join(', ')),
      SectionTitle(l.driversLicense),
      info(l.licenseNumber, d['license_number']),
      info(l.licenseCategories, d['license_categories']),
      info(l.licenseCountry, d['license_country']),
      info(l.issuedAt, dateText(d['license_issued_at'])),
      info(l.expiresAt, dateText(d['license_expires_at'])),
      SectionTitle(l.passport),
      info(l.passportNumber, d['passport_number']),
      info(l.expiresAt, dateText(d['passport_expires_at'])),
      SectionTitle(l.documents),
      _docGrid(driverDocs),
      for (final v in _vehicles) ...[
        SectionTitle('${v['kind'] == 'truck' ? l.truck : l.trailer}: ${v['plate_number']}'),
        info(l.make, [v['make'], v['model'], v['year']].where((e) => e != null).join(' ')),
        info(l.plateCountry, v['plate_country']),
        info(l.vin, v['vin']),
        info(l.trailerType, v['trailer_type']),
        const SizedBox(height: 8),
        _docGrid(_docs.where((x) => x.vehicleId == v['id']).toList()),
      ],
    ]);
  }

  Widget _docGrid(List<DocRecord> docs) {
    final l = context.l10n;
    final theme = Theme.of(context);
    if (docs.isEmpty) return Text(l.notUploaded, style: TextStyle(color: theme.colorScheme.outline));
    return Wrap(spacing: 12, runSpacing: 12, children: [
      for (final doc in docs)
        SizedBox(
          width: 220,
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: InkWell(
                  onTap: doc.isImage ? () => showFullImage(context, doc.storagePath) : null,
                  child: StoredImage(path: doc.storagePath, isImage: doc.isImage),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_types[doc.type]?.label(context.lang) ?? doc.type,
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  StatusChip(doc.status, dense: true),
                  if ((doc.reviewNote ?? '').isNotEmpty)
                    Padding(padding: const EdgeInsets.only(top: 4), child: Text(doc.reviewNote!, style: theme.textTheme.bodySmall)),
                  const SizedBox(height: 4),
                  Row(children: [
                    IconButton(
                      tooltip: l.approve,
                      color: Colors.green.shade700,
                      onPressed: doc.status == ReviewStatus.approved ? null : () => _setDoc(doc, ReviewStatus.approved),
                      icon: const Icon(Icons.check_circle_outline),
                    ),
                    IconButton(
                      tooltip: l.reject,
                      color: theme.colorScheme.error,
                      onPressed: doc.status == ReviewStatus.rejected ? null : () => _setDoc(doc, ReviewStatus.rejected),
                      icon: const Icon(Icons.cancel_outlined),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
    ]);
  }
}
