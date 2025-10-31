import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/unified_storage_service.dart';

/// Provider for managing per-exercise variant preferences (equipment and variant type)
final exerciseVariantPreferencesProvider =
    StateNotifierProvider<
      ExerciseVariantPreferencesNotifier,
      Map<String, ExerciseVariantPreference>
    >((ref) {
      final storage = ref.watch(unifiedStorageProvider);
      return ExerciseVariantPreferencesNotifier(storage, ref);
    });

class ExerciseVariantPreference {
  const ExerciseVariantPreference({
    required this.equipmentUsed,
    this.variantType,
  });

  final String equipmentUsed;
  final String? variantType;

  Map<String, dynamic> toJson() => {
    'equipmentUsed': equipmentUsed,
    'variantType': variantType,
  };

  factory ExerciseVariantPreference.fromJson(Map<String, dynamic> json) =>
      ExerciseVariantPreference(
        equipmentUsed: json['equipmentUsed'] as String,
        variantType: json['variantType'] as String?,
      );
}

class ExerciseVariantPreferencesNotifier
    extends StateNotifier<Map<String, ExerciseVariantPreference>> {
  ExerciseVariantPreferencesNotifier(this._storage, this._ref) : super({}) {
    _loadPreferences();
  }
  final UnifiedStorageService _storage;
  final Ref _ref;
  static const String _keyPrefix = 'exercise_variant_';

  Future<void> _loadPreferences() async {
    try {
      // Load all exercise variant preferences from storage
      final prefs = await _storage.getUserPreferences();
      final variantPrefs = <String, ExerciseVariantPreference>{};

      for (final entry in prefs.entries) {
        if (entry.key.startsWith(_keyPrefix)) {
          final exerciseId = entry.key.substring(_keyPrefix.length);
          if (entry.value is Map<String, dynamic>) {
            try {
              variantPrefs[exerciseId] = ExerciseVariantPreference.fromJson(
                Map<String, dynamic>.from(entry.value as Map),
              );
            } catch (e) {
              // Skip invalid entries
              print('⚠️ Invalid variant preference for $exerciseId: $e');
            }
          }
        }
      }

      state = variantPrefs;
    } catch (e) {
      // Ignore errors and keep empty state
      state = {};
    }
  }

  /// Get variant preference for a specific exercise
  ExerciseVariantPreference? getVariantForExercise(String exerciseId) =>
      state[exerciseId];

  /// Set variant preference for a specific exercise
  Future<void> setVariantForExercise(
    String exerciseId,
    String equipmentUsed,
    String? variantType,
  ) async {
    final preference = ExerciseVariantPreference(
      equipmentUsed: equipmentUsed,
      variantType: variantType,
    );

    await _storage.updatePreferences({
      '$_keyPrefix$exerciseId': preference.toJson(),
    });

    state = {...state, exerciseId: preference};
    // Invalidate preferences to refresh
    _ref.invalidate(userPreferencesProvider);
  }

  /// Remove variant preference for a specific exercise
  Future<void> removeVariantForExercise(String exerciseId) async {
    final newState = Map<String, ExerciseVariantPreference>.from(state);
    newState.remove(exerciseId);
    state = newState;

    // Remove from storage
    final prefs = await _storage.getUserPreferences();
    prefs.remove('$_keyPrefix$exerciseId');
    await _storage.updatePreferences(prefs);

    _ref.invalidate(userPreferencesProvider);
  }

  /// Get variant for exercise with fallback to defaults
  ExerciseVariantPreference getVariantWithDefault(
    String exerciseId,
    String defaultEquipment, {
    String? defaultVariant,
  }) {
    final saved = state[exerciseId];
    if (saved != null) {
      return saved;
    }
    return ExerciseVariantPreference(
      equipmentUsed: defaultEquipment,
      variantType: defaultVariant,
    );
  }
}
