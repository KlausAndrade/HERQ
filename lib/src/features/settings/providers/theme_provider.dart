import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/preferences_provider.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._ref) : super(ThemeMode.dark) {
    _loadThemeFromPreferences();
  }
  final Ref _ref;

  Future<void> _loadThemeFromPreferences() async {
    try {
      final preferences = await _ref.read(userPreferencesProvider.future);
      final themeString = preferences['theme'] as String? ?? 'dark';
      final themeMode = _stringToThemeMode(themeString);
      state = themeMode;
    } catch (e) {
      // If loading fails, keep the default dark theme
      state = ThemeMode.dark;
    }
  }

  ThemeMode _stringToThemeMode(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    // Persist the theme choice
    try {
      final updateService = _ref.read(preferencesUpdateProvider);
      await updateService.updateTheme(_themeModeToString(mode));
    } catch (e) {
      // If saving fails, the theme change is still applied locally
      // The user will see the change but it won't persist across app restarts
    }
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }
}

/// Provider for theme variant selection (Default vs HERQ)
final themeVariantProvider =
    StateNotifierProvider<ThemeVariantNotifier, String>(
        ThemeVariantNotifier.new);

class ThemeVariantNotifier extends StateNotifier<String> {
  ThemeVariantNotifier(this._ref) : super('herq') {
    _loadThemeVariantFromPreferences();
  }
  final Ref _ref;

  Future<void> _loadThemeVariantFromPreferences() async {
    try {
      final preferences = await _ref.read(userPreferencesProvider.future);
      final variant = preferences['themeVariant'] as String? ?? 'herq';
      state = variant;
    } catch (e) {
      // If loading fails, keep the default HERQ theme
      state = 'herq';
    }
  }

  Future<void> setThemeVariant(String variant) async {
    state = variant;

    // Persist the theme variant choice
    try {
      final updateService = _ref.read(preferencesUpdateProvider);
      await updateService.updatePreferences({'themeVariant': variant});
    } catch (e) {
      // If saving fails, the theme change is still applied locally
      // The user will see the change but it won't persist across app restarts
    }
  }
}
