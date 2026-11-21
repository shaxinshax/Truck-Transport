import 'package:material_ui/material_ui.dart';

import '../../data/backend.dart';
import '../../data/models.dart';
import '../common.dart';
import 'documents_screen.dart';
import 'driver_data.dart';
import 'profile_screen.dart';
import 'vehicles_screen.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key, required this.user});
  final AppUser user;

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  late final data = DriverData(widget.user)..load();
  var _tab = 0;

  @override
  void dispose() {
    data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final destinations = [
      (Icons.person_outline, Icons.person, l.profile),
      (Icons.local_shipping_outlined, Icons.local_shipping, l.vehicles),
      (Icons.folder_outlined, Icons.folder, l.documents),
    ];
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final wide = MediaQuery.sizeOf(context).width >= 840;
        Widget body;
        if (data.loading && data.driver == null && data.docTypes.isEmpty) {
          body = const Center(child: CircularProgressIndicator());
        } else if (data.error != null) {
          body = Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l.errorGeneric('${data.error}'))));
        } else {
          body = switch (_tab) {
            0 => ProfileScreen(data: data),
            1 => VehiclesScreen(data: data),
            _ => DocumentsScreen(data: data),
          };
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(destinations[_tab].$3),
            actions: [
              if (data.hasProfile && wide) Padding(padding: const EdgeInsets.only(right: 8), child: StatusChip(data.status)),
              const LanguageMenu(),
              IconButton(tooltip: l.logout, onPressed: Backend.instance.signOut, icon: const Icon(Icons.logout)),
            ],
          ),
          body: wide
              ? Row(children: [
                  NavigationRail(
                    selectedIndex: _tab,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: (i) => setState(() => _tab = i),
                    destinations: [
                      for (final d in destinations)
                        NavigationRailDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: Text(d.$3)),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ])
              : body,
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _tab,
                  onDestinationSelected: (i) => setState(() => _tab = i),
                  destinations: [
                    for (final d in destinations)
                      NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
                  ],
                ),
        );
      },
    );
  }
}

/// Banner explaining the review state, shown at the top of the driver screens.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.data});
  final DriverData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!data.hasProfile) {
      return _banner(context, Icons.info_outline, Colors.blue, l.completeProfileFirst);
    }
    final note = data.driver?['review_note'] as String?;
    final missing = data.missingRequired;
    return Column(children: [
      switch (data.status) {
        ReviewStatus.pending => _banner(context, Icons.hourglass_top, Colors.orange, l.statusPendingInfo),
        ReviewStatus.approved => _banner(context, Icons.check_circle, Colors.green, l.statusApprovedInfo),
        ReviewStatus.rejected => _banner(context, Icons.error_outline, Colors.red,
            '${l.statusRejectedInfo}${note == null || note.isEmpty ? '' : '\n${l.reviewNote}: $note'}'),
      },
      if (missing > 0) _banner(context, Icons.upload_file, Colors.deepOrange, l.missingRequired(missing)),
    ]);
  }

  Widget _banner(BuildContext context, IconData icon, Color color, String text) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ]),
      );
}
