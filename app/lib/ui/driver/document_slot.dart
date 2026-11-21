import 'package:material_ui/material_ui.dart';

import '../../data/models.dart';
import '../common.dart';
import 'driver_data.dart';

/// One document or photo the driver can upload, replace or delete.
class DocumentSlot extends StatefulWidget {
  const DocumentSlot({super.key, required this.data, required this.type, this.vehicleId});
  final DriverData data;
  final DocType type;
  final String? vehicleId;

  @override
  State<DocumentSlot> createState() => _DocumentSlotState();
}

class _DocumentSlotState extends State<DocumentSlot> {
  var _busy = false;

  Future<void> _upload(Future<PickedFile?> Function() pick) async {
    try {
      final f = await pick();
      if (f == null) return;
      if (!mounted) return;
      if (f.bytes.length > maxUploadBytes) {
        showInfo(context, context.l10n.fileTooLarge);
        return;
      }
      setState(() => _busy = true);
      await widget.data.upload(widget.type.code, f, vehicleId: widget.vehicleId);
      if (mounted) showInfo(context, context.l10n.uploaded);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final doc = widget.data.latest(widget.type.code, vehicleId: widget.vehicleId);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 88,
              height: 66,
              child: doc == null
                  ? ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.add_photo_alternate_outlined, color: theme.colorScheme.outline),
                    )
                  : InkWell(
                      onTap: doc.isImage ? () => showFullImage(context, doc.storagePath) : null,
                      child: StoredImage(path: doc.storagePath, isImage: doc.isImage),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.type.label(context.lang), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                if (doc != null) StatusChip(doc.status, dense: true)
                else Text(l.notUploaded, style: TextStyle(color: theme.colorScheme.outline)),
                if (widget.type.required && doc == null)
                  Text('• ${l.requiredMark}', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
              ]),
              if (doc?.status == ReviewStatus.rejected && (doc?.reviewNote ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('${l.reviewNote}: ${doc!.reviewNote}', style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 8),
              if (_busy)
                const LinearProgressIndicator()
              else
                Wrap(spacing: 8, runSpacing: 4, children: [
                  if (cameraAvailable)
                    FilledButton.tonalIcon(
                      onPressed: () => _upload(takePhoto),
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: Text(l.takePhoto),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => _upload(chooseFile),
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(doc == null ? l.chooseFile : l.replace),
                  ),
                  if (doc != null && doc.status != ReviewStatus.approved)
                    IconButton(
                      tooltip: l.delete,
                      onPressed: () async {
                        setState(() => _busy = true);
                        try {
                          await widget.data.deleteDoc(doc);
                        } catch (e) {
                          if (context.mounted) showError(context, e);
                        }
                        if (mounted) setState(() => _busy = false);
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
