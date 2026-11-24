import 'package:material_ui/material_ui.dart';

import '../../data/backend.dart';
import '../../data/models.dart';
import '../common.dart';
import '../routes_ui.dart';
import 'driver_review.dart';

enum _Filter { upcoming, freeForCargo, all }

/// All drivers' trips, soonest arrival first.
class AdminRoutes extends StatefulWidget {
  const AdminRoutes({super.key});

  @override
  State<AdminRoutes> createState() => _AdminRoutesState();
}

class _AdminRoutesState extends State<AdminRoutes> {
  List<Map<String, dynamic>>? _routes;
  var _filter = _Filter.upcoming;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Backend.instance.listRoutes();
      if (mounted) setState(() => _routes = r);
    } catch (e) {
      if (mounted) {
        setState(() => _routes = []);
        showError(context, e);
      }
    }
  }

  bool _active(Map<String, dynamic> r) {
    final s = parseRouteStatus(r['status']);
    return s == RouteStatus.planned || s == RouteStatus.on_the_way;
  }

  List<Map<String, dynamic>> get _visible {
    final q = _query.trim().toLowerCase();
    return (_routes ?? const []).where((r) {
      final ok = switch (_filter) {
        _Filter.upcoming => _active(r),
        _Filter.freeForCargo => _active(r) && r['free_for_cargo'] == true,
        _Filter.all => true,
      };
      if (!ok) return false;
      if (q.isEmpty) return true;
      final hay = [r['driver_name'], r['driver_phone'], r['plate'], r['from_city'], r['to_city'], r['from_country'], r['to_country']]
          .whereType<String>()
          .join(' ')
          .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  void _openDriver(Map<String, dynamic> r) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(r['driver_name'] as String? ?? '')),
        body: DriverReview(driverId: r['driver_id'] as String, onChanged: _load),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = _visible;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: TextField(
          decoration: InputDecoration(hintText: l.search, prefixIcon: const Icon(Icons.search), isDense: true),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          for (final f in _Filter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(switch (f) {
                  _Filter.upcoming => l.upcoming,
                  _Filter.freeForCargo => l.freeForCargoShort,
                  _Filter.all => l.all,
                }),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: _routes == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: items.isEmpty
                    ? ListView(children: [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l.noRoutes)))])
                    : ListView(padding: const EdgeInsets.all(12), children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: Column(children: [
                              for (final r in items) RouteCard(route: r, showDriver: true, onTap: () => _openDriver(r)),
                            ]),
                          ),
                        ),
                      ]),
              ),
      ),
    ]);
  }
}
