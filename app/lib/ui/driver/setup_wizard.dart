import 'package:material_ui/material_ui.dart';

import '../common.dart';
import 'document_slot.dart';
import 'driver_data.dart';

/// Shown right after the first login: 3 short steps instead of a long form.
/// Everything else (license details, passport, trailer...) can be added later
/// from the normal Profile / Vehicles / Documents tabs.
class SetupWizard extends StatefulWidget {
  const SetupWizard({super.key, required this.data, required this.onDone});
  final DriverData data;
  final VoidCallback onDone;

  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  static const _total = 3;
  final _form = GlobalKey<FormState>();
  late final _first = TextEditingController(text: widget.data.driver?['first_name'] as String? ?? '');
  late final _last = TextEditingController(text: widget.data.driver?['last_name'] as String? ?? '');
  late final _phone = TextEditingController(text: widget.data.driver?['phone'] as String? ?? widget.data.user.phone ?? '');
  final _plate = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  late int _step = widget.data.hasProfile ? (widget.data.vehicles.isEmpty ? 1 : 2) : 0;
  var _busy = false;

  DriverData get data => widget.data;

  @override
  void dispose() {
    for (final c in [_first, _last, _phone, _plate, _make, _model]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _v(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _next() async {
    if (!(_form.currentState?.validate() ?? true)) return;
    setState(() => _busy = true);
    try {
      if (_step == 0) {
        await data.saveDriver({
          'first_name': _first.text.trim(),
          'last_name': _last.text.trim(),
          'phone': _v(_phone.text),
          'email': data.driver?['email'] ?? data.user.email,
          'preferred_language': context.lang,
        });
      } else if (_step == 1) {
        await data.saveVehicle({
          'kind': 'truck',
          'plate_number': _plate.text.trim().toUpperCase(),
          'make': _v(_make.text),
          'model': _v(_model.text),
        });
      }
      if (_step == _total - 1) {
        if (mounted) showInfo(context, context.l10n.setupDoneInfo);
        widget.onDone();
      } else {
        setState(() => _step++);
      }
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
    final titles = [l.stepAboutYou, l.stepTruck, l.stepPhotos];
    return Scaffold(
      appBar: AppBar(
        title: Text(l.setupTitle),
        actions: [
          const LanguageMenu(),
          IconButton(tooltip: l.logout, onPressed: data.api.signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.stepOf(_step + 1, _total), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 4),
                  Text(titles[_step], style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(value: (_step + 1) / _total, minHeight: 8),
                  ),
                ]),
              ),
              Expanded(
                child: Form(
                  key: _form,
                  child: ListenableBuilder(
                    listenable: data,
                    builder: (context, _) => ListView(padding: const EdgeInsets.all(20), children: switch (_step) {
                      0 => _aboutYou(context),
                      1 => _truck(context),
                      _ => _photos(context),
                    }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(children: [
                  if (_step > 0)
                    TextButton(onPressed: _busy ? null : () => setState(() => _step--), child: Text(l.back)),
                  if (_step == 1)
                    TextButton(onPressed: _busy ? null : () => setState(() => _step++), child: Text(l.skip)),
                  const Spacer(),
                  FilledButton(
                    onPressed: _busy ? null : _next,
                    style: FilledButton.styleFrom(minimumSize: const Size(140, 52)),
                    child: _busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                        : Text(_step == _total - 1 ? l.finish : l.next),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
          {bool required = false, TextInputType? keyboard, TextCapitalization caps = TextCapitalization.words}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          textCapitalization: caps,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(labelText: required ? '$label *' : label, prefixIcon: Icon(icon)),
          validator: required ? (v) => (v ?? '').trim().isEmpty ? context.l10n.required : null : null,
        ),
      );

  List<Widget> _aboutYou(BuildContext context) {
    final l = context.l10n;
    return [
      _field(_first, l.firstName, Icons.person_outline, required: true),
      _field(_last, l.lastName, Icons.badge_outlined, required: true),
      _field(_phone, l.phone, Icons.phone, keyboard: TextInputType.phone, caps: TextCapitalization.none),
    ];
  }

  List<Widget> _truck(BuildContext context) {
    final l = context.l10n;
    final existing = data.vehicles.where((v) => v['kind'] == 'truck').firstOrNull;
    if (existing != null && _plate.text.isEmpty) {
      _plate.text = existing['plate_number'] as String? ?? '';
      _make.text = existing['make'] as String? ?? '';
      _model.text = existing['model'] as String? ?? '';
    }
    return [
      const Center(child: Icon(Icons.local_shipping, size: 64)),
      const SizedBox(height: 16),
      _field(_plate, l.plateNumber, Icons.pin_outlined, required: true, caps: TextCapitalization.characters),
      _field(_make, l.make, Icons.factory_outlined),
      _field(_model, l.model, Icons.directions_car_outlined),
    ];
  }

  List<Widget> _photos(BuildContext context) {
    final l = context.l10n;
    final truck = data.vehicles.where((v) => v['kind'] == 'truck').firstOrNull;
    return [
      Text(l.stepPhotosHint, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 16),
      for (final t in data.driverDocTypes.where((t) => t.required)) DocumentSlot(data: data, type: t),
      if (truck != null)
        for (final t in data.vehicleDocTypes('truck').where((t) => t.required))
          DocumentSlot(data: data, type: t, vehicleId: truck['id'] as String),
    ];
  }
}
