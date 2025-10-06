import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/preferences_provider.dart';

/// Workout settings model
class WorkoutSettings {
  final int defaultRestTimerSeconds;
  final String weightUnit; // 'kg' or 'lb'
  final bool hapticFeedback;
  final bool autoStartRestTimer;
  final bool showExerciseVideos;

  const WorkoutSettings({
    this.defaultRestTimerSeconds = 120, // 2 minutes
    this.weightUnit = 'kg',
    this.hapticFeedback = true,
    this.autoStartRestTimer = true,
    this.showExerciseVideos = true,
  });

  WorkoutSettings copyWith({
    int? defaultRestTimerSeconds,
    String? weightUnit,
    bool? hapticFeedback,
    bool? autoStartRestTimer,
    bool? showExerciseVideos,
  }) {
    return WorkoutSettings(
      defaultRestTimerSeconds:
          defaultRestTimerSeconds ?? this.defaultRestTimerSeconds,
      weightUnit: weightUnit ?? this.weightUnit,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      autoStartRestTimer: autoStartRestTimer ?? this.autoStartRestTimer,
      showExerciseVideos: showExerciseVideos ?? this.showExerciseVideos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultRestTimerSeconds': defaultRestTimerSeconds,
      'weightUnit': weightUnit,
      'hapticFeedback': hapticFeedback,
      'autoStartRestTimer': autoStartRestTimer,
      'showExerciseVideos': showExerciseVideos,
    };
  }

  factory WorkoutSettings.fromJson(Map<String, dynamic> json) {
    return WorkoutSettings(
      defaultRestTimerSeconds: json['defaultRestTimerSeconds'] as int? ?? 120,
      weightUnit: json['weightUnit'] as String? ?? 'kg',
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      autoStartRestTimer: json['autoStartRestTimer'] as bool? ?? true,
      showExerciseVideos: json['showExerciseVideos'] as bool? ?? true,
    );
  }
}

/// Provider for workout settings
final workoutSettingsProvider =
    StateNotifierProvider<WorkoutSettingsNotifier, WorkoutSettings>((ref) {
  return WorkoutSettingsNotifier(ref);
});

/// Notifier for workout settings
class WorkoutSettingsNotifier extends StateNotifier<WorkoutSettings> {
  final Ref _ref;

  WorkoutSettingsNotifier(this._ref) : super(const WorkoutSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await _ref.read(userPreferencesProvider.future);
      final workoutPrefs = prefs['workoutSettings'] as Map<String, dynamic>?;

      if (workoutPrefs != null) {
        state = WorkoutSettings.fromJson(workoutPrefs);
      }
    } catch (e) {
      // Keep default settings if loading fails
    }
  }

  Future<void> _saveSettings() async {
    final prefsService = _ref.read(preferencesUpdateProvider);
    await prefsService.updatePreferences({
      'workoutSettings': state.toJson(),
    });
  }

  Future<void> setDefaultRestTimer(int seconds) async {
    state = state.copyWith(defaultRestTimerSeconds: seconds);
    await _saveSettings();
  }

  Future<void> setWeightUnit(String unit) async {
    state = state.copyWith(weightUnit: unit);
    await _saveSettings();
  }

  Future<void> setHapticFeedback(bool enabled) async {
    state = state.copyWith(hapticFeedback: enabled);
    await _saveSettings();
  }

  Future<void> setAutoStartRestTimer(bool enabled) async {
    state = state.copyWith(autoStartRestTimer: enabled);
    await _saveSettings();
  }

  Future<void> setShowExerciseVideos(bool enabled) async {
    state = state.copyWith(showExerciseVideos: enabled);
    await _saveSettings();
  }

  String getFormattedRestTime() {
    final minutes = state.defaultRestTimerSeconds ~/ 60;
    final seconds = state.defaultRestTimerSeconds % 60;

    if (seconds == 0) {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (minutes == 0) {
      return '$seconds seconds';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String getWeightUnitDisplay() {
    return state.weightUnit == 'kg' ? 'Kilograms (kg)' : 'Pounds (lb)';
  }
}
