import 'package:material_ui/material_ui.dart';

import '../data/backend.dart';
import '../data/models.dart';
import '../l10n/gen/app_localizations.dart';
import 'common.dart';

String routeStatusLabel(AppLocalizations l, RouteStatus s) => switch (s) {
      RouteStatus.planned => l.routePlanned,
      RouteStatus.on_the_way => l.routeOnTheWay,
      RouteStatus.done => l.routeDone,
      RouteStatus.cancelled => l.routeCancelled,
    };

Color routeStatusColor(RouteStatus s) => switch (s) {
      RouteStatus.planned => Colors.blue,
      RouteStatus.on_the_way => Colors.orange,
      RouteStatus.done => Colors.green,
      RouteStatus.cancelled => Colors.grey,
    };

String? dateTimeText(Object? iso) {
  final d = DateTime.tryParse(iso?.toString() ?? '')?.toLocal();
  if (d == null) return null;
  return '${dateText(d.toIso8601String())} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// "24.11.2026 10:00 – 18:00", or with two dates when the window spans days.
String? arrivalText(Object? from, Object? to) {
  final a = DateTime.tryParse(from?.toString() ?? '')?.toLocal();
  final b = DateTime.tryParse(to?.toString() ?? '')?.toLocal();
  if (a == null && b == null) return null;
  if (a == null || b == null) return dateTimeText(a?.toIso8601String() ?? b!.toIso8601String());
  final sameDay = a.year == b.year && a.month == b.month && a.day == b.day;
  final t = '${b.hour.toString().padLeft(2, '0')}:${b.minute.toString().padLeft(2, '0')}';
  return '${dateTimeText(a.toIso8601String())} – ${sameDay ? t : dateTimeText(b.toIso8601String())}';
}

String _place(Object? city, Object? country) =>
    [city, country].where((e) => e != null && '$e'.isNotEmpty).join(', ');

/// One trip: from → to, dates, truck, status. [showDriver] for the admin list.
class RouteCard extends StatelessWidget {
  const RouteCard({super.key, required this.route, this.showDriver = false, this.onTap});
  final Map<String, dynamic> route;
  final bool showDriver;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final status = parseRouteStatus(route['status']);
    final color = routeStatusColor(status);
    Widget line(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ]),
        );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (showDriver)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  [route['driver_name'], route['driver_phone']].where((e) => e != null && '$e'.isNotEmpty).join(' · '),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
                  Text(_place(route['from_city'], route['from_country']), style: theme.textTheme.titleMedium),
                  Icon(Icons.arrow_forward, size: 20, color: theme.colorScheme.primary),
                  Text(_place(route['to_city'], route['to_country']),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(routeStatusLabel(l, status), style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ]),
            if (dateTimeText(route['depart_at']) case final t?) line(Icons.logout, '${l.departAt}: $t'),
            if (arrivalText(route['arrive_from'], route['arrive_to']) case final t?) line(Icons.flag_outlined, '${l.arrival}: $t'),
            if (route['plate'] != null) line(Icons.local_shipping_outlined, route['plate'] as String),
            if (route['free_for_cargo'] == true && status != RouteStatus.done && status != RouteStatus.cancelled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  avatar: const Icon(Icons.inventory_2_outlined, size: 18, color: Colors.green),
                  label: Text(l.freeForCargoShort),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if ((route['note'] as String? ?? '').isNotEmpty) line(Icons.notes, route['note'] as String),
          ]),
        ),
      ),
    );
  }
}

/// Add or edit a route. Returns true when something was saved or deleted.
class RouteEditor extends StatefulWidget {
  const RouteEditor({super.key, required this.driverId, required this.vehicles, this.route});
  final String driverId;
  final List<Map<String, dynamic>> vehicles;
  final Map<String, dynamic>? route;

  @override
  State<RouteEditor> createState() => _RouteEditorState();
}

class _RouteEditorState extends State<RouteEditor> {
  final _form = GlobalKey<FormState>();
  late final Map<String, dynamic> _r = {...?widget.route};
  late final _c = {
    for (final k in ['from_city', 'from_country', 'to_city', 'to_country', 'note'])
      k: TextEditingController(text: _r[k]?.toString() ?? ''),
  };
  var _busy = false;

  bool get _isNew => widget.route == null;

  @override
  void initState() {
    super.initState();
    if (_isNew) {
      _r['free_for_cargo'] = true;
      final trucks = widget.vehicles.where((v) => v['kind'] == 'truck');
      if (trucks.isNotEmpty) _r['vehicle_id'] = trucks.first['id'];
    }
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(String key, {String? after}) async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_r[key]?.toString() ?? '')?.toLocal() ??
        DateTime.tryParse(_r[after]?.toString() ?? '')?.toLocal() ??
        DateTime(now.year, now.month, now.day, 9);
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(current));
    if (!mounted) return;
    final t = time ?? TimeOfDay.fromDateTime(current);
    setState(() => _r[key] = DateTime(date.year, date.month, date.day, t.hour, t.minute).toUtc().toIso8601String());
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await Backend.instance.saveRoute({
        ..._r,
        for (final e in _c.entries) e.key: e.value.text.trim().isEmpty ? null : e.value.text.trim(),
        'driver_id': widget.driverId,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Backend.instance.deleteRoute(_r['id'] as String);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget text(String key, String label, {bool required = false, IconData? icon}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: _c[key],
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: required ? '$label *' : label, prefixIcon: icon == null ? null : Icon(icon)),
            validator: required ? (v) => (v ?? '').trim().isEmpty ? l.required : null : null,
          ),
        );
    Widget date(String key, String label, IconData icon, {String? after}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _pick(key, after: after),
            child: InputDecorator(
              decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
              child: Text(dateTimeText(_r[key]) ?? l.notSet),
            ),
          ),
        );
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.addRoute : l.editRoute),
        actions: [if (!_isNew) IconButton(tooltip: l.delete, onPressed: _delete, icon: const Icon(Icons.delete_outline))],
      ),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Constrained(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(flex: 3, child: text('from_city', l.fromCity, required: true, icon: Icons.trip_origin)),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: text('from_country', l.country)),
              ]),
              Row(children: [
                Expanded(flex: 3, child: text('to_city', l.toCity, required: true, icon: Icons.place_outlined)),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: text('to_country', l.country)),
              ]),
              date('depart_at', l.departAt, Icons.logout),
              date('arrive_from', l.arriveFrom, Icons.flag_outlined, after: 'depart_at'),
              date('arrive_to', l.arriveTo, Icons.flag, after: 'arrive_from'),
              if (widget.vehicles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String?>(
                    initialValue: _r['vehicle_id'] as String?,
                    decoration: InputDecoration(labelText: l.truck, prefixIcon: const Icon(Icons.local_shipping_outlined)),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l.notSet)),
                      for (final v in widget.vehicles)
                        DropdownMenuItem(value: v['id'] as String, child: Text('${v['plate_number']} ${v['make'] ?? ''}'.trim())),
                    ],
                    onChanged: (v) => setState(() => _r['vehicle_id'] = v),
                  ),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _r['free_for_cargo'] == true,
                onChanged: (v) => setState(() => _r['free_for_cargo'] = v),
                title: Text(l.freeForCargo),
                secondary: const Icon(Icons.inventory_2_outlined),
              ),
              if (!_isNew)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: DropdownButtonFormField<RouteStatus>(
                    initialValue: parseRouteStatus(_r['status']),
                    decoration: InputDecoration(labelText: l.routeStatus),
                    items: [for (final s in RouteStatus.values) DropdownMenuItem(value: s, child: Text(routeStatusLabel(l, s)))],
                    onChanged: (s) => setState(() => _r['status'] = s?.name),
                  ),
                ),
              text('note', l.note, icon: Icons.notes),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busy ? null : _save,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: _busy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Text(l.save),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
