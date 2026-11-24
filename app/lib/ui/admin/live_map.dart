import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/backend.dart';
import '../common.dart';
import '../routes_ui.dart';
import 'driver_review.dart';

/// Map with the latest position of every driver who shares their location.
class LiveMap extends StatefulWidget {
  const LiveMap({super.key});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  final _map = MapController();
  List<Map<String, dynamic>> _trucks = [];
  Timer? _timer;
  var _fitted = false;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final t = await Backend.instance.listLiveLocations();
      if (!mounted) return;
      setState(() => _trucks = t);
      _fit();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  LatLng _pos(Map<String, dynamic> t) => LatLng((t['lat'] as num).toDouble(), (t['lng'] as num).toDouble());

  void _fit() {
    if (_fitted || !_ready || _trucks.isEmpty) return;
    _fitted = true;
    if (_trucks.length == 1) {
      _map.move(_pos(_trucks.first), 9);
    } else {
      _map.fitCamera(CameraFit.coordinates(
        coordinates: [for (final t in _trucks) _pos(t)],
        padding: const EdgeInsets.all(70),
        maxZoom: 10,
      ));
    }
  }

  void _show(Map<String, dynamic> t) {
    final l = context.l10n;
    final speed = (t['speed_kmh'] as num?)?.round();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t['driver_name'] as String? ?? '', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            if ((t['plate'] as String? ?? '').isNotEmpty) Text('🚚 ${t['plate']}'),
            if (t['driver_phone'] != null) SelectableText('📞 ${t['driver_phone']}'),
            if (speed != null) Text(l.speedKmh('$speed')),
            if (dateTimeText(t['updated_at']) case final time?) Text(l.lastSeen(time)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text(t['driver_name'] as String? ?? '')),
                    body: DriverReview(driverId: t['driver_id'] as String, onChanged: () {}),
                  ),
                ));
              },
              icon: const Icon(Icons.badge_outlined),
              label: Text(l.profile),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Stack(children: [
      FlutterMap(
        mapController: _map,
        options: MapOptions(
          initialCenter: const LatLng(41.7, 41.0),
          initialZoom: 5,
          onMapReady: () {
            _ready = true;
            _fit();
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.truckdrivers.truck_driver_app',
          ),
          MarkerLayer(markers: [
            for (final t in _trucks)
              Marker(
                point: _pos(t),
                width: 140,
                height: 64,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => _show(t),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                      ),
                      child: Text(
                        (t['plate'] as String? ?? '').isNotEmpty ? t['plate'] as String : t['driver_name'] as String? ?? '',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: ((t['speed_kmh'] as num?) ?? 0) > 3 ? Colors.orange.shade700 : const Color(0xFF1F5FAD),
                      child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                    ),
                  ]),
                ),
              ),
          ]),
          const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
        ],
      ),
      if (_trucks.isEmpty)
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(l.noLiveTrucks, textAlign: TextAlign.center))),
        ),
      Positioned(
        right: 16,
        bottom: 40,
        child: FloatingActionButton.small(heroTag: 'refresh-map', onPressed: _load, child: const Icon(Icons.refresh)),
      ),
    ]);
  }
}
