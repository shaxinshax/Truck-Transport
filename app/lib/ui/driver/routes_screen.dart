import 'package:material_ui/material_ui.dart';

import '../../data/models.dart';
import '../common.dart';
import '../routes_ui.dart';
import 'driver_data.dart';
import 'driver_home.dart';
import 'location_sharing.dart';

/// Driver's own trips: where they go and when they arrive / are free.
class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key, required this.data});
  final DriverData data;

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  List<Map<String, dynamic>>? _routes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await widget.data.api.listRoutes(driverId: widget.data.user.id);
      if (mounted) setState(() => _routes = r);
    } catch (e) {
      if (mounted) {
        setState(() => _routes = []);
        showError(context, e);
      }
    }
  }

  Future<void> _edit([Map<String, dynamic>? route]) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => RouteEditor(driverId: widget.data.user.id, vehicles: widget.data.vehicles, route: route),
    ));
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final routes = _routes;
    final active = routes?.where((r) {
      final s = parseRouteStatus(r['status']);
      return s == RouteStatus.planned || s == RouteStatus.on_the_way;
    }).toList();
    final past = routes?.where((r) => !(active?.contains(r) ?? false)).toList();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Constrained(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            StatusBanner(data: widget.data),
            if (widget.data.hasProfile) ...[
              const LocationShareCard(),
              FilledButton.icon(
                onPressed: () => _edit(),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                icon: const Icon(Icons.add_road),
                label: Text(l.addRoute),
              ),
              const SizedBox(height: 16),
              if (routes == null)
                const Center(child: CircularProgressIndicator())
              else if (routes.isEmpty)
                Padding(padding: const EdgeInsets.all(24), child: Text(l.noRoutes, textAlign: TextAlign.center))
              else ...[
                for (final r in active!) RouteCard(route: r, onTap: () => _edit(r)),
                if (past!.isNotEmpty) ...[
                  const Divider(height: 32),
                  for (final r in past) Opacity(opacity: 0.6, child: RouteCard(route: r, onTap: () => _edit(r))),
                ],
              ],
            ],
          ]),
        ),
      ]),
    );
  }
}
