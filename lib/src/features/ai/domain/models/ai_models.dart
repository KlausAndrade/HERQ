import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_models.g.dart';

@JsonSerializable()
class AISuggestion extends Equatable {
  const AISuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.createdAt,
    this.workoutId,
    this.exerciseId,
    this.reasoning,
    this.metadata,
    this.actionable = true,
  });

  factory AISuggestion.fromJson(Map<String, dynamic> json) =>
      _$AISuggestionFromJson(json);

  final String id;
  final SuggestionType type;
  final String title;
  final String description;
  final double confidence; // 0.0 to 1.0
  final DateTime createdAt;
  final String? workoutId;
  final String? exerciseId;
  final String? reasoning;
  final Map<String, dynamic>? metadata;
  final bool actionable;
  Map<String, dynamic> toJson() => _$AISuggestionToJson(this);

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    description,
    confidence,
    createdAt,
    workoutId,
    exerciseId,
    reasoning,
    metadata,
    actionable,
  ];
}

enum SuggestionType {
  @JsonValue('workout_recommendation')
  workoutRecommendation,
  @JsonValue('exercise_substitution')
  exerciseSubstitution,
  @JsonValue('progressive_overload')
  progressiveOverload,
  @JsonValue('recovery_advice')
  recoveryAdvice,
  @JsonValue('form_tip')
  formTip,
  @JsonValue('deload_suggestion')
  deloadSuggestion,
  @JsonValue('nutrition_tip')
  nutritionTip,
}

@JsonSerializable()
class WorkoutRecommendation extends Equatable {
  const WorkoutRecommendation({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.estimatedDuration,
    required this.difficulty,
    required this.targetMuscleGroups,
    required this.reasoning,
    required this.confidence,
    this.requiredEquipment,
    this.alternatives,
  });

  factory WorkoutRecommendation.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRecommendationFromJson(json);

  final String id;
  final String name;
  final String description;
  final List<RecommendedExercise> exercises;
  final int estimatedDuration; // minutes
  final Difficulty difficulty;
  final List<String> targetMuscleGroups;
  final String reasoning;
  final double confidence;
  final List<String>? requiredEquipment;
  final List<String>? alternatives;
  Map<String, dynamic> toJson() => _$WorkoutRecommendationToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    exercises,
    estimatedDuration,
    difficulty,
    targetMuscleGroups,
    reasoning,
    confidence,
    requiredEquipment,
    alternatives,
  ];
}

enum Difficulty {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

@JsonSerializable()
class RecommendedExercise extends Equatable {
  const RecommendedExercise({
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.rpe,
    this.restSeconds,
    this.notes,
    this.substitutions,
  });

  factory RecommendedExercise.fromJson(Map<String, dynamic> json) =>
      _$RecommendedExerciseFromJson(json);

  final String exerciseId;
  final String name;
  final int sets;
  final String reps; // e.g., "8-12", "5", "AMRAP"
  final double? weight;
  final int? rpe;
  final int? restSeconds;
  final String? notes;
  final List<String>? substitutions;
  Map<String, dynamic> toJson() => _$RecommendedExerciseToJson(this);

  @override
  List<Object?> get props => [
    exerciseId,
    name,
    sets,
    reps,
    weight,
    rpe,
    restSeconds,
    notes,
    substitutions,
  ];
}

@JsonSerializable()
class ProgressiveOverloadSuggestion extends Equatable {
  const ProgressiveOverloadSuggestion({
    required this.exerciseId,
    required this.currentWeight,
    required this.currentReps,
    required this.currentSets,
    required this.suggestedWeight,
    required this.suggestedReps,
    required this.suggestedSets,
    required this.reasoning,
    required this.confidence,
    this.timeframe,
  });

  factory ProgressiveOverloadSuggestion.fromJson(Map<String, dynamic> json) =>
      _$ProgressiveOverloadSuggestionFromJson(json);

  final String exerciseId;
  final double currentWeight;
  final int currentReps;
  final int currentSets;
  final double suggestedWeight;
  final int suggestedReps;
  final int suggestedSets;
  final String reasoning;
  final double confidence;
  final String? timeframe;
  Map<String, dynamic> toJson() => _$ProgressiveOverloadSuggestionToJson(this);

  @override
  List<Object?> get props => [
    exerciseId,
    currentWeight,
    currentReps,
    currentSets,
    suggestedWeight,
    suggestedReps,
    suggestedSets,
    reasoning,
    confidence,
    timeframe,
  ];
}

@JsonSerializable()
class RecoveryAnalysis extends Equatable {
  const RecoveryAnalysis({
    required this.userId,
    required this.analysisDate,
    required this.fatigueLevel,
    required this.recoveryScore,
    required this.recommendations,
    required this.nextWorkoutSuggestion,
    this.sleepQuality,
    this.stressLevel,
    this.nutritionScore,
  }); // 0.0 to 1.0

  factory RecoveryAnalysis.fromJson(Map<String, dynamic> json) =>
      _$RecoveryAnalysisFromJson(json);

  final String userId;
  final DateTime analysisDate;
  final FatigueLevel fatigueLevel;
  final double recoveryScore; // 0.0 to 1.0
  final List<RecoveryRecommendation> recommendations;
  final String nextWorkoutSuggestion;
  final double? sleepQuality; // 0.0 to 1.0
  final double? stressLevel; // 0.0 to 1.0
  final double? nutritionScore;
  Map<String, dynamic> toJson() => _$RecoveryAnalysisToJson(this);

  @override
  List<Object?> get props => [
    userId,
    analysisDate,
    fatigueLevel,
    recoveryScore,
    recommendations,
    nextWorkoutSuggestion,
    sleepQuality,
    stressLevel,
    nutritionScore,
  ];
}

enum FatigueLevel {
  @JsonValue('low')
  low,
  @JsonValue('moderate')
  moderate,
  @JsonValue('high')
  high,
  @JsonValue('severe')
  severe,
}

@JsonSerializable()
class RecoveryRecommendation extends Equatable {
  const RecoveryRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
  });

  factory RecoveryRecommendation.fromJson(Map<String, dynamic> json) =>
      _$RecoveryRecommendationFromJson(json);

  final RecoveryType type;
  final String title;
  final String description;
  final Priority priority;
  Map<String, dynamic> toJson() => _$RecoveryRecommendationToJson(this);

  @override
  List<Object?> get props => [type, title, description, priority];
}

enum RecoveryType {
  @JsonValue('rest')
  rest,
  @JsonValue('sleep')
  sleep,
  @JsonValue('nutrition')
  nutrition,
  @JsonValue('hydration')
  hydration,
  @JsonValue('stretching')
  stretching,
  @JsonValue('massage')
  massage,
}

enum Priority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}
