import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the chosen UI language. null = follow the device language.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController._() : super(null);
  static final instance = LocaleController._();

  static const languages = {
    'en': 'English',
    'ru': 'Русский',
    'ka': 'ქართული',
    'tr': 'Türkçe',
  };

  Future<void> load() async {
    try {
      final code = (await SharedPreferences.getInstance()).getString('language');
      if (code != null && languages.containsKey(code)) value = Locale(code);
    } catch (_) {}
  }

  Future<void> set(String code) async {
    value = Locale(code);
    try {
      await (await SharedPreferences.getInstance()).setString('language', code);
    } catch (_) {}
  }
}
