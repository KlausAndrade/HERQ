import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/unified_storage_service.dart';

/// Provider for user preferences
final userPreferencesProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final storage = ref.read(unifiedStorageProvider);
  return storage.getUserPreferences();
});

/// Provider for updating user preferences
final preferencesUpdateProvider = Provider<PreferencesUpdateService>(
  PreferencesUpdateService.new,
);

/// Service for updating preferences and refreshing providers
class PreferencesUpdateService {
  PreferencesUpdateService(this._ref);
  final Ref _ref;

  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    final storage = _ref.read(unifiedStorageProvider);
    final success = await storage.updatePreferences(preferences);

    if (success) {
      // Refresh the preferences provider to notify listeners
      _ref.invalidate(userPreferencesProvider);
    }

    return success;
  }

  Future<bool> updateTheme(String theme) async =>
      updatePreferences({'theme': theme});

  Future<bool> updateUnits(String units) async =>
      updatePreferences({'units': units});

  Future<bool> updateRestTimer(int seconds) async =>
      updatePreferences({'defaultRestTimer': seconds});
}
