import 'package:material_ui/material_ui.dart';

import 'config.dart';
import 'data/backend.dart';
import 'data/demo_backend.dart';
import 'data/supabase_backend.dart';
import 'l10n/gen/app_localizations.dart';
import 'ui/admin/admin_home.dart';
import 'ui/auth_screen.dart';
import 'ui/driver/driver_home.dart';
import 'ui/locale_controller.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Backend.instance = demoMode || supabaseUrl.isEmpty
      ? DemoBackend()
      : await SupabaseBackend.init(url: supabaseUrl, anonKey: supabaseAnonKey);
  await LocaleController.instance.load();
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance,
      builder: (context, locale, _) => MaterialApp(
        title: 'TD',
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const _Root(),
      ),
    );
  }

  ThemeData _theme(Brightness b) => ThemeData(
        brightness: b,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F5FAD), brightness: b),
        fontFamily: 'NotoSans',
        fontFamilyFallback: const ['NotoSansGeorgian'],
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      );
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Backend.instance.user,
      builder: (context, user, _) {
        if (user == null) return const AuthScreen();
        if (user.isAdmin) return AdminHome(key: ValueKey(user.id));
        return DriverHome(key: ValueKey(user.id), user: user);
      },
    );
  }
}
