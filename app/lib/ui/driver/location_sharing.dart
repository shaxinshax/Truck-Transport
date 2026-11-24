import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/backend.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common.dart';

/// Sends the driver's position to the server while "Share my location" is on.
/// On Android it keeps running in the background with a small notification.
class LocationSharing extends ChangeNotifier {
  LocationSharing._();
  static final instance = LocationSharing._();
  static const _prefKey = 'share_location';
  static const _minInterval = Duration(seconds: 30);

  StreamSubscription<Position>? _sub;
  DateTime? lastSent;
  bool get isOn => _sub != null;

  LocationSettings _settings(AppLocalizations l) {
    if (kIsWeb) return const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100);
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          intervalDuration: _minInterval,
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: l.trackingNotifTitle,
            notificationText: l.trackingNotifText,
            enableWakeLock: true,
            setOngoing: true,
          ),
        ),
      TargetPlatform.iOS || TargetPlatform.macOS => AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          activityType: ActivityType.automotiveNavigation,
          showBackgroundLocationIndicator: true,
        ),
      _ => const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100),
    };
  }

  /// Returns an error text for the driver, or null when sharing started.
  Future<String?> start(AppLocalizations l) async {
    if (isOn) return null;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return l.locationOff;
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return l.locationDenied;
      _sub = Geolocator.getPositionStream(locationSettings: _settings(l)).listen(_send, onError: (_) {});
      notifyListeners();
      final now = await Geolocator.getCurrentPosition();
      await _send(now, force: true);
      (await SharedPreferences.getInstance()).setBool(_prefKey, true);
      return null;
    } catch (e) {
      await _sub?.cancel();
      _sub = null;
      notifyListeners();
      return l.errorGeneric('$e');
    }
  }

  Future<void> _send(Position p, {bool force = false}) async {
    if (!force && lastSent != null && DateTime.now().difference(lastSent!) < _minInterval) return;
    lastSent = DateTime.now();
    notifyListeners();
    try {
      await Backend.instance.updateMyLocation(
        lat: p.latitude,
        lng: p.longitude,
        speedKmh: p.speed >= 0 ? p.speed * 3.6 : null,
        heading: p.heading >= 0 ? p.heading : null,
      );
    } catch (_) {}
  }

  Future<void> stop() async {
    await pause();
    try {
      await Backend.instance.stopSharingLocation();
    } catch (_) {}
    (await SharedPreferences.getInstance()).setBool(_prefKey, false);
  }

  /// Stops sending without changing the saved choice (used on logout / close).
  Future<void> pause() async {
    await _sub?.cancel();
    _sub = null;
    notifyListeners();
  }

  /// Turns sharing back on after an app restart if the driver left it on.
  Future<void> resume(AppLocalizations l) async {
    try {
      if ((await SharedPreferences.getInstance()).getBool(_prefKey) ?? false) await start(l);
    } catch (_) {}
  }
}

/// The on/off card at the top of the driver's Routes tab.
class LocationShareCard extends StatelessWidget {
  const LocationShareCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = LocationSharing.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: s.isOn ? Colors.green.withValues(alpha: 0.10) : null,
        child: SwitchListTile(
          value: s.isOn,
          secondary: Icon(s.isOn ? Icons.my_location : Icons.location_disabled, color: s.isOn ? Colors.green : null),
          title: Text(l.shareLocation, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(s.isOn && s.lastSent != null
              ? '${l.shareLocationInfo}\n${l.lastSeen(TimeOfDay.fromDateTime(s.lastSent!).format(context))}'
              : l.shareLocationInfo),
          onChanged: (v) async {
            if (v) {
              final err = await s.start(l);
              if (err != null && context.mounted) showInfo(context, err);
            } else {
              await s.stop();
            }
          },
        ),
      ),
    );
  }
}
