import 'package:material_ui/material_ui.dart';

import '../../data/backend.dart';
import '../../data/models.dart';
import '../common.dart';
import 'driver_review.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  ReviewStatus? _filter = ReviewStatus.pending;
  String _query = '';
  List<DriverSummary> _drivers = [];
  bool _loading = true;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _drivers = await Backend.instance.listDrivers(status: _filter);
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) setState(() => _loading = false);
  }

  List<DriverSummary> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _drivers;
    return _drivers.where((d) {
      final hay = [d.fullName, d.driver['phone'], d.driver['email'], ...d.plates].whereType<String>().join(' ').toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final list = _list(context, wide);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.admin),
        actions: [
          const LanguageMenu(),
          IconButton(tooltip: l.logout, onPressed: Backend.instance.signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: wide
          ? Row(children: [
              SizedBox(width: 380, child: list),
              const VerticalDivider(width: 1),
              Expanded(
                child: _selected == null
                    ? Center(child: Icon(Icons.badge_outlined, size: 72, color: Theme.of(context).colorScheme.outlineVariant))
                    : DriverReview(key: ValueKey(_selected), driverId: _selected!, onChanged: _load),
              ),
            ])
          : list,
    );
  }

  Widget _list(BuildContext context, bool wide) {
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
          for (final f in <ReviewStatus?>[ReviewStatus.pending, ReviewStatus.approved, ReviewStatus.rejected, null])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(switch (f) {
                  ReviewStatus.pending => l.statusPending,
                  ReviewStatus.approved => l.statusApproved,
                  ReviewStatus.rejected => l.statusRejected,
                  null => l.all,
                }),
                selected: _filter == f,
                onSelected: (_) {
                  setState(() => _filter = f);
                  _load();
                },
              ),
            ),
        ]),
      ),
      const SizedBox(height: 8),
      if (_loading) const LinearProgressIndicator(minHeight: 2) else const SizedBox(height: 2),
      Expanded(
        child: items.isEmpty && !_loading
            ? Center(child: Text(l.noDrivers))
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final d = items[i];
                    return ListTile(
                      selected: wide && d.id == _selected,
                      leading: CircleAvatar(child: Text(d.fullName.isEmpty ? '?' : d.fullName.characters.first)),
                      title: Text(d.fullName.isEmpty ? '—' : d.fullName),
                      subtitle: Text([d.driver['phone'], ...d.plates].whereType<String>().join(' · ')),
                      trailing: StatusChip(d.status, dense: true),
                      onTap: () {
                        if (wide) {
                          setState(() => _selected = d.id);
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: Text(d.fullName)),
                              body: DriverReview(driverId: d.id, onChanged: _load),
                            ),
                          ));
                        }
                      },
                    );
                  },
                ),
              ),
      ),
    ]);
  }
}
