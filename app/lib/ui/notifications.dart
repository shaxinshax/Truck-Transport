import 'package:material_ui/material_ui.dart';

import '../data/backend.dart';
import '../data/models.dart';
import '../l10n/gen/app_localizations.dart';
import 'common.dart';
import 'routes_ui.dart';

/// Bell icon with the number of unread notifications.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Backend.instance.unreadNotifications,
      builder: (context, n, _) => IconButton(
        tooltip: context.l10n.notifications,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        icon: Badge(
          isLabelVisible: n > 0,
          label: Text(n > 99 ? '99+' : '$n'),
          child: Icon(n > 0 ? Icons.notifications_active : Icons.notifications_none),
        ),
      ),
    );
  }
}

(IconData, Color, String, String?) describeNotification(AppLocalizations l, AppNotification n) {
  final d = n.data;
  String? join(List<Object?> parts) {
    final s = parts.where((e) => e != null && '$e'.isNotEmpty).join(' · ');
    return s.isEmpty ? null : s;
  }

  return switch (n.kind) {
    'driver_approved' => (Icons.check_circle, Colors.green, l.notifDriverApproved, l.statusApprovedInfo),
    'driver_rejected' => (Icons.error_outline, Colors.red, l.notifDriverRejected, d['note'] as String?),
    'doc_rejected' => (Icons.description_outlined, Colors.red, l.notifDocRejected, d['note'] as String?),
    'new_driver' => (Icons.person_add_alt_1, Colors.blue, l.notifNewDriver, d['name'] as String?),
    'new_route' => (
        Icons.alt_route,
        Colors.indigo,
        l.notifNewRoute,
        join([d['name'], '${d['from'] ?? ''} – ${d['to'] ?? ''}', if (dateTimeText(d['arrive_from']) case final t?) '${l.arrival}: $t']),
      ),
    _ => (Icons.notifications_none, Colors.grey, n.kind, null),
  };
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await Backend.instance.listNotifications();
      if (mounted) setState(() => _items = items);
      await Backend.instance.markNotificationsRead();
    } catch (e) {
      if (mounted) {
        setState(() => _items = []);
        showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: Text(l.notifications)),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(child: Text(l.noNotifications))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      final (icon, color, title, body) = describeNotification(l, n);
                      return ListTile(
                        tileColor: n.readAt == null ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35) : null,
                        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
                        title: Text(title, style: TextStyle(fontWeight: n.readAt == null ? FontWeight.w700 : FontWeight.w500)),
                        subtitle: body == null ? null : Text(body),
                        trailing: Text(dateTimeText(n.createdAt.toIso8601String()) ?? '', style: theme.textTheme.bodySmall),
                      );
                    },
                  ),
                ),
    );
  }
}
