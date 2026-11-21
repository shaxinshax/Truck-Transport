import 'package:material_ui/material_ui.dart';

import '../../data/models.dart';
import '../common.dart';
import 'document_slot.dart';
import 'driver_data.dart';
import 'driver_home.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key, required this.data});
  final DriverData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Constrained(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            StatusBanner(data: data),
            if (data.hasProfile) ...[
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(
                  onPressed: () => _edit(context, {'kind': 'truck'}),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: Text(l.addTruck),
                ),
                OutlinedButton.icon(
                  onPressed: () => _edit(context, {'kind': 'trailer'}),
                  icon: const Icon(Icons.rv_hookup),
                  label: Text(l.addTrailer),
                ),
              ]),
              const SizedBox(height: 16),
              if (data.vehicles.isEmpty)
                Padding(padding: const EdgeInsets.all(24), child: Text(l.noVehicles, textAlign: TextAlign.center)),
              for (final v in data.vehicles) _VehicleCard(data: data, vehicle: v, onEdit: () => _edit(context, v)),
            ],
          ]),
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, Map<String, dynamic> vehicle) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _VehicleDialog(vehicle: vehicle),
    );
    if (result == null) return;
    try {
      await data.saveVehicle(result);
      if (context.mounted) showInfo(context, context.l10n.saved);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.data, required this.vehicle, required this.onEdit});
  final DriverData data;
  final Map<String, dynamic> vehicle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final kind = vehicle['kind'] as String;
    final title = [vehicle['make'], vehicle['model'], vehicle['year']].where((e) => e != null && '$e'.isNotEmpty).join(' ');
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(kind == 'truck' ? Icons.local_shipping : Icons.rv_hookup, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(kind == 'truck' ? l.truck : l.trailer, style: theme.textTheme.labelMedium),
                Text(title.isEmpty ? '—' : title, style: theme.textTheme.titleMedium),
              ]),
            ),
            _PlateBadge(vehicle['plate_number'] as String? ?? ''),
            PopupMenuButton<String>(
              onSelected: (a) async {
                if (a == 'edit') onEdit();
                if (a == 'delete') {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      content: Text(l.deleteConfirm),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
                        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.delete)),
                      ],
                    ),
                  );
                  if (ok == true) {
                    try {
                      await data.deleteVehicle(vehicle['id'] as String);
                    } catch (e) {
                      if (context.mounted) showError(context, e);
                    }
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l.edit)),
                PopupMenuItem(value: 'delete', child: Text(l.delete)),
              ],
            ),
          ]),
          const SizedBox(height: 4),
          Align(alignment: Alignment.centerLeft, child: StatusChip(parseStatus(vehicle['status']), dense: true)),
          SectionTitle(l.vehicleDocuments),
          for (final t in data.vehicleDocTypes(kind))
            DocumentSlot(key: ValueKey('${vehicle['id']}-${t.code}'), data: data, type: t, vehicleId: vehicle['id'] as String),
        ]),
      ),
    );
  }
}

class _PlateBadge extends StatelessWidget {
  const _PlateBadge(this.plate);
  final String plate;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black87, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(plate, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, letterSpacing: 1)),
      );
}

class _VehicleDialog extends StatefulWidget {
  const _VehicleDialog({required this.vehicle});
  final Map<String, dynamic> vehicle;

  @override
  State<_VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<_VehicleDialog> {
  final _form = GlobalKey<FormState>();
  static const _keys = ['make', 'model', 'year', 'plate_number', 'plate_country', 'vin', 'trailer_type'];
  late final _c = {for (final k in _keys) k: TextEditingController(text: widget.vehicle[k]?.toString() ?? '')};

  bool get _truck => widget.vehicle['kind'] == 'truck';

  String? _clean(String key, String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    return key == 'plate_number' || key == 'vin' ? t.toUpperCase() : t;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget field(String k, String label, {bool required = false, TextInputType? kb}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: _c[k],
            keyboardType: kb,
            textCapitalization: k == 'plate_number' || k == 'vin' ? TextCapitalization.characters : TextCapitalization.words,
            decoration: InputDecoration(labelText: required ? '$label *' : label),
            validator: (v) {
              if (required && (v ?? '').trim().isEmpty) return l.required;
              if (k == 'year' && (v ?? '').isNotEmpty && int.tryParse(v!) == null) return l.year;
              return null;
            },
          ),
        );
    return AlertDialog(
      title: Text(widget.vehicle['id'] == null ? (_truck ? l.addTruck : l.addTrailer) : (_truck ? l.truck : l.trailer)),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              field('plate_number', l.plateNumber, required: true),
              field('plate_country', l.plateCountry),
              field('make', l.make),
              field('model', l.model),
              field('year', l.year, kb: TextInputType.number),
              if (_truck) field('vin', l.vin) else field('trailer_type', l.trailerType),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(context, {
              ...widget.vehicle,
              for (final e in _c.entries)
                e.key: e.key == 'year'
                    ? int.tryParse(e.value.text.trim())
                    : _clean(e.key, e.value.text),
            });
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}
