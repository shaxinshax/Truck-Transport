import 'package:material_ui/material_ui.dart';

import '../common.dart';
import 'document_slot.dart';
import 'driver_data.dart';
import 'driver_home.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key, required this.data});
  final DriverData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Constrained(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            StatusBanner(data: data),
            if (data.hasProfile)
              for (final t in data.driverDocTypes) DocumentSlot(key: ValueKey(t.code), data: data, type: t),
          ]),
        ),
      ],
    );
  }
}
