/// Exercise type constants and configuration for dynamic workout inputs
library;

/// Enum representing different exercise types
enum ExerciseType {
  weightReps('weight_reps'),
  bodyweightReps('bodyweight_reps'),
  weightedBodyweight('weighted_bodyweight'),
  assistedBodyweight('assisted_bodyweight'),
  duration('duration'),
  durationWeight('duration_weight'),
  distanceDuration('distance_duration'),
  weightDistance('weight_distance');

  const ExerciseType(this.value);
  final String value;

  /// Parse exercise type from string value
  static ExerciseType fromString(String value) {
    return ExerciseType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ExerciseType.weightReps, // Default
    );
  }
}

/// Configuration for each exercise type defining required fields and labels
class ExerciseTypeConfig {
  final ExerciseType type;
  final List<ExerciseField> requiredFields;
  final String displayName;
  final String description;

  const ExerciseTypeConfig({
    required this.type,
    required this.requiredFields,
    required this.displayName,
    required this.description,
  });

  /// Get field labels for this exercise type
  List<String> get fieldLabels {
    return requiredFields.map((field) => field.label).toList();
  }

  /// Check if this type requires a specific field
  bool requiresField(ExerciseField field) {
    return requiredFields.contains(field);
  }

  /// Get configuration for a specific exercise type
  static ExerciseTypeConfig getConfig(ExerciseType type) {
    return _configs[type]!;
  }

  /// Get configuration from string value
  static ExerciseTypeConfig fromString(String value) {
    final type = ExerciseType.fromString(value);
    return getConfig(type);
  }

  static final Map<ExerciseType, ExerciseTypeConfig> _configs = {
    ExerciseType.weightReps: ExerciseTypeConfig(
      type: ExerciseType.weightReps,
      requiredFields: [ExerciseField.weight, ExerciseField.reps],
      displayName: 'Weight & Reps',
      description: 'Standard weighted exercise with repetitions',
    ),
    ExerciseType.bodyweightReps: ExerciseTypeConfig(
      type: ExerciseType.bodyweightReps,
      requiredFields: [ExerciseField.reps],
      displayName: 'Bodyweight Reps',
      description: 'Bodyweight exercise with repetitions only',
    ),
    ExerciseType.weightedBodyweight: ExerciseTypeConfig(
      type: ExerciseType.weightedBodyweight,
      requiredFields: [ExerciseField.addedWeight, ExerciseField.reps],
      displayName: 'Weighted Bodyweight',
      description: 'Bodyweight exercise with additional weight',
    ),
    ExerciseType.assistedBodyweight: ExerciseTypeConfig(
      type: ExerciseType.assistedBodyweight,
      requiredFields: [ExerciseField.assistanceWeight, ExerciseField.reps],
      displayName: 'Assisted Bodyweight',
      description: 'Bodyweight exercise with assistance',
    ),
    ExerciseType.duration: ExerciseTypeConfig(
      type: ExerciseType.duration,
      requiredFields: [ExerciseField.duration],
      displayName: 'Duration',
      description: 'Time-based exercise (holds, planks, etc.)',
    ),
    ExerciseType.durationWeight: ExerciseTypeConfig(
      type: ExerciseType.durationWeight,
      requiredFields: [ExerciseField.duration, ExerciseField.weight],
      displayName: 'Duration & Weight',
      description: 'Weighted carry or hold for time',
    ),
    ExerciseType.distanceDuration: ExerciseTypeConfig(
      type: ExerciseType.distanceDuration,
      requiredFields: [ExerciseField.distance, ExerciseField.duration],
      displayName: 'Distance & Duration',
      description: 'Cardio exercises with distance and time',
    ),
    ExerciseType.weightDistance: ExerciseTypeConfig(
      type: ExerciseType.weightDistance,
      requiredFields: [ExerciseField.weight, ExerciseField.distance],
      displayName: 'Weight & Distance',
      description: 'Weighted carries for distance',
    ),
  };

  /// Get all available exercise type configurations
  static List<ExerciseTypeConfig> get allConfigs {
    return _configs.values.toList();
  }
}

/// Enum representing different fields that can be tracked
enum ExerciseField {
  weight('KG', 'Weight'),
  reps('REPS', 'Reps'),
  duration('TIME', 'Duration'),
  distance('M', 'Distance'),
  assistanceWeight('ASSIST', 'Assistance'),
  addedWeight('+KG', 'Added Weight');

  const ExerciseField(this.label, this.fullName);
  final String label;
  final String fullName;

  /// Get hint text for input field
  String get hintText {
    switch (this) {
      case ExerciseField.weight:
        return 'kg';
      case ExerciseField.reps:
        return 'reps';
      case ExerciseField.duration:
        return 'secs';
      case ExerciseField.distance:
        return 'meters';
      case ExerciseField.assistanceWeight:
        return 'kg';
      case ExerciseField.addedWeight:
        return 'kg';
    }
  }

  /// Get placeholder for empty value
  String get placeholder {
    return '-';
  }
}

/// Helper extension for formatting distance
extension DistanceFormatter on double {
  /// Format distance in meters, converting to km if >= 1000m
  String formatDistance() {
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(2)} km';
    } else {
      return '${toStringAsFixed(0)} m';
    }
  }
}

/// Helper extension for formatting duration
extension DurationFormatter on int {
  /// Format duration in seconds to MM:SS format
  String formatDuration() {
    final minutes = this ~/ 60;
    final seconds = this % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

