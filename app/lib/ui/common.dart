
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;
import 'package:material_ui/material_ui.dart';

import '../data/backend.dart';
import '../data/models.dart';
import '../l10n/gen/app_localizations.dart';
import 'locale_controller.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get lang => Localizations.localeOf(this).languageCode;
}

class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: context.l10n.language,
      onSelected: LocaleController.instance.set,
      itemBuilder: (_) => [
        for (final e in LocaleController.languages.entries)
          CheckedPopupMenuItem(value: e.key, checked: e.key == context.lang, child: Text(e.value)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.language),
          const SizedBox(width: 6),
          Text(MediaQuery.sizeOf(context).width < 600
              ? context.lang.toUpperCase()
              : LocaleController.languages[context.lang] ?? ''),
        ]),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key, this.dense = false});
  final ReviewStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (label, color, icon) = switch (status) {
      ReviewStatus.pending => (l.statusPending, Colors.orange, Icons.hourglass_top),
      ReviewStatus.approved => (l.statusApproved, Colors.green, Icons.check_circle),
      ReviewStatus.rejected => (l.statusRejected, Colors.red, Icons.cancel),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 6 : 10, vertical: dense ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: dense ? 14 : 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: dense ? 12 : 13, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

void showError(BuildContext context, Object error) {
  if (!context.mounted) return;
  var msg = error.toString();
  if (msg.length > 200) msg = msg.substring(0, 200);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric(msg))));
}

void showInfo(BuildContext context, String text) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

const maxUploadBytes = 10 * 1024 * 1024;

bool get cameraAvailable =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

String _mimeFor(String name) {
  final n = name.toLowerCase();
  if (n.endsWith('.png')) return 'image/png';
  if (n.endsWith('.pdf')) return 'application/pdf';
  if (n.endsWith('.heic')) return 'image/heic';
  return 'image/jpeg';
}

/// Takes a photo with the camera (phones only), images are shrunk to save data.
Future<PickedFile?> takePhoto() async {
  final x = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 2000, imageQuality: 80);
  if (x == null) return null;
  return PickedFile(bytes: await x.readAsBytes(), name: x.name, mimeType: _mimeFor(x.name));
}

/// Picks an image or PDF from the device.
Future<PickedFile?> chooseFile({bool imagesOnly = false}) async {
  final f = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: imagesOnly ? const ['jpg', 'jpeg', 'png', 'heic'] : const ['jpg', 'jpeg', 'png', 'heic', 'pdf'],
    compressionQuality: 80,
  );
  if (f == null) return null;
  return PickedFile(bytes: await f.xFile.readAsBytes(), name: f.name, mimeType: _mimeFor(f.name));
}

/// Loads a stored file and shows it as an image, or a file icon for PDFs.
class StoredImage extends StatelessWidget {
  const StoredImage({super.key, required this.path, this.isImage = true, this.fit = BoxFit.cover});
  final String path;
  final bool isImage;
  final BoxFit fit;

  static final _cache = <String, Future<Uint8List?>>{};

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!isImage) {
      return ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.picture_as_pdf, size: 40, color: scheme.primary),
      );
    }
    return FutureBuilder<Uint8List?>(
      future: _cache.putIfAbsent(path, () => Backend.instance.downloadFile(path)),
      builder: (context, snap) {
        if (snap.data case final bytes?) return Image.memory(bytes, fit: fit, gaplessPlayback: true);
        return ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: snap.connectionState == ConnectionState.done
              ? Icon(Icons.image_not_supported_outlined, color: scheme.outline)
              : const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        );
      },
    );
  }
}

Future<void> showFullImage(BuildContext context, String path) {
  return showDialog(
    context: context,
    builder: (c) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        InteractiveViewer(child: StoredImage(path: path, fit: BoxFit.contain)),
        Positioned(right: 4, top: 4, child: IconButton.filledTonal(onPressed: () => Navigator.pop(c), icon: const Icon(Icons.close))),
      ]),
    ),
  );
}

/// Centers content and limits its width on large screens (PC, tablets).
class Constrained extends StatelessWidget {
  const Constrained({super.key, required this.child, this.maxWidth = 760});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) =>
      Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      );
}

String? dateText(Object? iso) {
  if (iso == null) return null;
  final d = DateTime.tryParse(iso.toString());
  if (d == null) return null;
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
