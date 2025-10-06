import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/unified_storage_service.dart';

/// Provider for user preferences
final userPreferencesProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final storage = ref.read(unifiedStorageProvider);
  return await storage.getUserPreferences();
});

/// Provider for updating user preferences
final preferencesUpdateProvider = Provider<PreferencesUpdateService>((ref) {
  return PreferencesUpdateService(ref);
});

/// Service for updating preferences and refreshing providers
class PreferencesUpdateService {
  final Ref _ref;

  PreferencesUpdateService(this._ref);

  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    final storage = _ref.read(unifiedStorageProvider);
    final success = await storage.updatePreferences(preferences);

    if (success) {
      // Refresh the preferences provider to notify listeners
      _ref.invalidate(userPreferencesProvider);
    }

    return success;
  }

  Future<bool> updateTheme(String theme) async {
    return updatePreferences({'theme': theme});
  }

  Future<bool> updateUnits(String units) async {
    return updatePreferences({'units': units});
  }

  Future<bool> updateRestTimer(int seconds) async {
    return updatePreferences({'defaultRestTimer': seconds});
  }
}
