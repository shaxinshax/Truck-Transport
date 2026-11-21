import 'package:material_ui/material_ui.dart';

import '../data/backend.dart';
import '../data/demo_backend.dart';
import 'common.dart';

enum _Method { phone, email }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _method = _Method.phone;
  var _codeSent = false;
  var _signUp = false;
  var _busy = false;

  Backend get _api => Backend.instance;

  Future<void> _run(Future<void> Function() action) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _normalizedPhone => _phone.text.replaceAll(RegExp(r'[\s\-()]'), '');

  Future<void> _submit() => _run(() async {
        if (_method == _Method.phone) {
          if (!_codeSent) {
            await _api.sendPhoneCode(_normalizedPhone);
            setState(() => _codeSent = true);
          } else {
            await _api.verifyPhoneCode(_normalizedPhone, _code.text.trim());
          }
        } else if (_signUp) {
          final needsConfirm = await _api.signUpWithEmail(_email.text.trim(), _password.text);
          if (needsConfirm && mounted) {
            showInfo(context, context.l10n.checkEmail);
            setState(() => _signUp = false);
          }
        } else {
          await _api.signInWithEmail(_email.text.trim(), _password.text);
        }
      });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [LanguageMenu(), SizedBox(width: 8)]),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Icon(Icons.local_shipping_rounded, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(l.appTitle, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 28),
                  SegmentedButton<_Method>(
                    segments: [
                      ButtonSegment(value: _Method.phone, icon: const Icon(Icons.phone_iphone), label: Text(l.loginWithPhone)),
                      ButtonSegment(value: _Method.email, icon: const Icon(Icons.alternate_email), label: Text(l.loginWithEmail)),
                    ],
                    selected: {_method},
                    onSelectionChanged: (s) => setState(() => _method = s.first),
                  ),
                  const SizedBox(height: 24),
                  if (_method == _Method.phone) ..._phoneFields(context) else ..._emailFields(context),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: _busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                        : Text(_method == _Method.phone
                            ? (_codeSent ? l.verify : l.sendCode)
                            : (_signUp ? l.signUp : l.signIn)),
                  ),
                  if (_method == _Method.email)
                    TextButton(
                      onPressed: () => setState(() => _signUp = !_signUp),
                      child: Text(_signUp ? l.haveAccount : l.noAccount),
                    ),
                  if (_method == _Method.phone && _codeSent)
                    TextButton(
                      onPressed: () => setState(() {
                        _codeSent = false;
                        _code.clear();
                      }),
                      child: Text(l.changeNumber),
                    ),
                  if (_api.isDemo)
                    _DemoCard(onAdmin: () async {
                      setState(() => _busy = true);
                      try {
                        await _api.signInWithEmail(DemoBackend.demoAdminEmail, 'demo1234');
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      }
                      if (mounted) setState(() => _busy = false);
                    }),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _phoneFields(BuildContext context) {
    final l = context.l10n;
    return [
      TextFormField(
        controller: _phone,
        enabled: !_codeSent,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        decoration: InputDecoration(labelText: l.phone, hintText: l.phoneHint, prefixIcon: const Icon(Icons.phone)),
        validator: (v) => RegExp(r'^\+\d{8,15}$').hasMatch((v ?? '').replaceAll(RegExp(r'[\s\-()]'), '')) ? null : l.invalidPhone,
      ),
      if (_codeSent) ...[
        const SizedBox(height: 12),
        Text(l.codeSent(_phone.text)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _code,
          autofocus: true,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          decoration: InputDecoration(labelText: l.smsCode, prefixIcon: const Icon(Icons.sms_outlined)),
          validator: (v) => (v ?? '').trim().length >= 4 ? null : l.required,
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
    ];
  }

  List<Widget> _emailFields(BuildContext context) {
    final l = context.l10n;
    return [
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: InputDecoration(labelText: l.email, prefixIcon: const Icon(Icons.email_outlined)),
        validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim()) ? null : l.invalidEmail,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _password,
        obscureText: true,
        autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
        decoration: InputDecoration(labelText: l.password, prefixIcon: const Icon(Icons.lock_outline)),
        validator: (v) => (v ?? '').length >= 8 ? null : l.passwordTooShort,
        onFieldSubmitted: (_) => _submit(),
      ),
    ];
  }
}

/// Only shown in demo mode (no server connected). English only on purpose.
class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.onAdmin});
  final VoidCallback onAdmin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 24),
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Preview mode', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onTertiaryContainer)),
          const SizedBox(height: 4),
          Text('Sample data, nothing is saved. Any phone number and any SMS code work.',
              style: TextStyle(color: scheme.onTertiaryContainer)),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: onAdmin, icon: const Icon(Icons.admin_panel_settings_outlined), label: const Text('Open the admin panel')),
        ]),
      ),
    );
  }
}
