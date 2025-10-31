import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/unified_storage_service.dart';

/// Provider for managing per-exercise rest timer preferences
final exerciseTimerPreferencesProvider =
    StateNotifierProvider<ExerciseTimerPreferencesNotifier, Map<String, int>>((
      ref,
    ) {
      final storage = ref.watch(unifiedStorageProvider);
      return ExerciseTimerPreferencesNotifier(storage, ref);
    });

class ExerciseTimerPreferencesNotifier extends StateNotifier<Map<String, int>> {
  ExerciseTimerPreferencesNotifier(this._storage, this._ref) : super({}) {
    _loadPreferences();
  }
  final UnifiedStorageService _storage;
  final Ref _ref;
  static const String _keyPrefix = 'exercise_timer_';

  Future<void> _loadPreferences() async {
    try {
      // Load all exercise timer preferences from storage
      final prefs = await _storage.getUserPreferences();
      final timerPrefs = <String, int>{};

      for (final entry in prefs.entries) {
        if (entry.key.startsWith(_keyPrefix)) {
          final exerciseId = entry.key.substring(_keyPrefix.length);
          if (entry.value is int) {
            timerPrefs[exerciseId] = entry.value as int;
          }
        }
      }

      state = timerPrefs;
    } catch (e) {
      // Ignore errors and keep empty state
      state = {};
    }
  }

  /// Get rest timer for a specific exercise (returns null if not set)
  int? getTimerForExercise(String exerciseId) => state[exerciseId];

  /// Set rest timer preference for a specific exercise
  Future<void> setTimerForExercise(String exerciseId, int seconds) async {
    await _storage.updatePreferences({'$_keyPrefix$exerciseId': seconds});
    state = {...state, exerciseId: seconds};
    // Invalidate preferences to refresh
    _ref.invalidate(userPreferencesProvider);
  }

  /// Remove timer preference for a specific exercise
  Future<void> removeTimerForExercise(String exerciseId) async {
    await _storage.updatePreferences({'$_keyPrefix$exerciseId': null});
    final newState = Map<String, int>.from(state);
    newState.remove(exerciseId);
    state = newState;
    _ref.invalidate(userPreferencesProvider);
  }

  /// Get timer for exercise with fallback to default
  int getTimerWithDefault(String exerciseId, {int defaultSeconds = 90}) =>
      state[exerciseId] ?? defaultSeconds;
}
