import 'package:material_ui/material_ui.dart';

import '../common.dart';
import 'driver_data.dart';
import 'driver_home.dart';

const licenseCategoryOptions = ['B', 'C1', 'C', 'C1E', 'CE', 'D'];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.data});
  final DriverData data;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  static const _textKeys = [
    'first_name', 'last_name', 'phone', 'email', 'citizenship', 'address', 'city', 'country',
    'license_number', 'license_country', 'passport_number',
  ];
  static const _dateKeys = ['date_of_birth', 'license_issued_at', 'license_expires_at', 'passport_expires_at'];

  late final Map<String, TextEditingController> _c = {
    for (final k in _textKeys) k: TextEditingController(text: widget.data.driver?[k]?.toString() ?? _default(k)),
  };
  late final Map<String, String?> _dates = {for (final k in _dateKeys) k: widget.data.driver?[k] as String?};
  late Set<String> _categories = {...((widget.data.driver?['license_categories'] as List?) ?? const []).cast<String>()};
  late String? _photo = widget.data.driver?['profile_photo_path'] as String?;
  var _busy = false;

  String _default(String k) => switch (k) {
        'phone' => widget.data.user.phone ?? '',
        'email' => widget.data.user.email ?? '',
        _ => '',
      };

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await widget.data.saveDriver({
        for (final e in _c.entries) e.key: e.value.text.trim().isEmpty ? null : e.value.text.trim(),
        ..._dates,
        'license_categories': _categories.toList(),
        'profile_photo_path': _photo,
        'preferred_language': context.lang,
      });
      if (mounted) showInfo(context, context.l10n.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final f = cameraAvailable ? await takePhoto() : await chooseFile(imagesOnly: true);
      if (f == null) return;
      final path = await widget.data.api.uploadProfilePhoto(widget.data.user.id, f);
      setState(() => _photo = path);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _pickDate(String key) async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_dates[key] ?? '') ??
        (key == 'date_of_birth' ? DateTime(now.year - 30) : now);
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year + 20),
    );
    if (d != null) setState(() => _dates[key] = d.toIso8601String().substring(0, 10));
  }

  Widget _text(String key, String label, {bool required = false, TextInputType? keyboard, IconData? icon}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: _c[key],
          keyboardType: keyboard,
          textCapitalization: keyboard == null ? TextCapitalization.words : TextCapitalization.none,
          decoration: InputDecoration(labelText: required ? '$label *' : label, prefixIcon: icon == null ? null : Icon(icon)),
          validator: required ? (v) => (v ?? '').trim().isEmpty ? context.l10n.required : null : null,
        ),
      );

  Widget _date(String key, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _pickDate(key),
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.event)),
            isEmpty: _dates[key] == null,
            child: Text(dateText(_dates[key]) ?? ''),
          ),
        ),
      );

  /// Two fields side by side on wide screens, stacked on phones.
  Widget _pair(Widget a, Widget b) => LayoutBuilder(
        builder: (context, c) => c.maxWidth < 520
            ? Column(children: [a, b])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: a),
                const SizedBox(width: 12),
                Expanded(child: b),
              ]),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Constrained(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              StatusBanner(data: widget.data),
              Center(
                child: Column(children: [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: scheme.primaryContainer,
                      child: _photo == null
                          ? Icon(Icons.add_a_photo_outlined, size: 36, color: scheme.onPrimaryContainer)
                          : ClipOval(child: SizedBox(width: 96, height: 96, child: StoredImage(path: _photo!))),
                    ),
                  ),
                  TextButton(onPressed: _pickPhoto, child: Text(_photo == null ? l.profilePhoto : l.changePhoto)),
                ]),
              ),
              SectionTitle(l.personalInfo),
              _pair(_text('first_name', l.firstName, required: true), _text('last_name', l.lastName, required: true)),
              _pair(_date('date_of_birth', l.dateOfBirth), _text('citizenship', l.citizenship, icon: Icons.flag_outlined)),
              _pair(_text('phone', l.phone, keyboard: TextInputType.phone, icon: Icons.phone),
                  _text('email', l.email, keyboard: TextInputType.emailAddress, icon: Icons.email_outlined)),
              _text('address', l.address, icon: Icons.home_outlined),
              _pair(_text('city', l.city), _text('country', l.country)),
              SectionTitle(l.driversLicense),
              _pair(_text('license_number', l.licenseNumber, keyboard: TextInputType.text, icon: Icons.badge_outlined),
                  _text('license_country', l.licenseCountry)),
              _pair(_date('license_issued_at', l.issuedAt), _date('license_expires_at', l.expiresAt)),
              Text(l.licenseCategories, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in licenseCategoryOptions)
                  FilterChip(
                    label: Text(c),
                    selected: _categories.contains(c),
                    onSelected: (on) => setState(() => _categories = on ? {..._categories, c} : ({..._categories}..remove(c))),
                  ),
              ]),
              SectionTitle(l.passport),
              _pair(_text('passport_number', l.passportNumber, keyboard: TextInputType.text, icon: Icons.book_outlined),
                  _date('passport_expires_at', l.expiresAt)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _save,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: Text(l.save),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }
}
