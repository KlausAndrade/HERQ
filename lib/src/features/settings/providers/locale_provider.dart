import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app locale
final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());

/// Notifier for managing locale state with persistence
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }
  static const String _localeKey = 'app_locale';

  /// Load saved locale from SharedPreferences or auto-detect from system
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);

      if (savedLocaleCode != null) {
        // Use saved locale if available
        state = Locale(savedLocaleCode);
        print('📱 Loaded saved locale: $savedLocaleCode');
      } else {
        // Auto-detect from system locale
        final systemLocale = PlatformDispatcher.instance.locale;
        final supportedLocaleCodes = ['en', 'pt', 'es'];

        if (supportedLocaleCodes.contains(systemLocale.languageCode)) {
          state = Locale(systemLocale.languageCode);
          print('📱 Auto-detected system locale: ${systemLocale.languageCode}');
        } else {
          // Default to English if system locale is not supported
          state = const Locale('en');
          print(
            '📱 Using default locale: en (system locale ${systemLocale.languageCode} not supported)',
          );
        }
      }
    } catch (e) {
      print('❌ Error loading locale: $e');
      state = const Locale('en');
    }
  }

  /// Set locale and persist to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      state = locale;
      print('✅ Locale changed to: ${locale.languageCode}');
    } catch (e) {
      print('❌ Error saving locale: $e');
    }
  }

  /// Get display name for a locale
  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Get all supported locales
  static List<Locale> get supportedLocales => const [
        Locale('en'),
        Locale('pt'),
        Locale('es'),
      ];
}
