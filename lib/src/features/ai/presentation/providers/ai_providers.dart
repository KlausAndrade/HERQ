import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/services/ai_coaching_service.dart';
import '../../domain/models/ai_models.dart';

// Service provider
final aiCoachingServiceProvider = Provider<AICoachingService>((ref) {
  return AICoachingService();
});

// Workout recommendations provider
final workoutRecommendationsProvider = FutureProvider.family<
    List<WorkoutRecommendation>,
    WorkoutRecommendationParams>((ref, params) async {
  final aiService = ref.read(aiCoachingServiceProvider);
  return aiService.getWorkoutRecommendations(
    params.userId,
    preferredMuscleGroups: params.preferredMuscleGroups,
    availableEquipment: params.availableEquipment,
    maxDuration: params.maxDuration,
  );
});

// Progressive overload suggestions provider
final progressiveOverloadProvider = FutureProvider.family<
    List<ProgressiveOverloadSuggestion>,
    ProgressiveOverloadParams>((ref, params) async {
  final aiService = ref.read(aiCoachingServiceProvider);
  return aiService.getProgressiveOverloadSuggestions(
      params.userId, params.exerciseId);
});

// Recovery analysis provider
final recoveryAnalysisProvider =
    FutureProvider.family<RecoveryAnalysis, String>((ref, userId) async {
  final aiService = ref.read(aiCoachingServiceProvider);
  return aiService.getRecoveryAnalysis(userId);
});

// General AI suggestions provider
final aiSuggestionsProvider =
    FutureProvider.family<List<AISuggestion>, String>((ref, userId) async {
  final aiService = ref.read(aiCoachingServiceProvider);
  return aiService.getGeneralSuggestions(userId);
});

// Exercise substitutions provider
final exerciseSubstitutionsProvider =
    FutureProvider.family<List<String>, ExerciseSubstitutionParams>(
        (ref, params) async {
  final aiService = ref.read(aiCoachingServiceProvider);
  return aiService.getExerciseSubstitutions(
    params.exerciseId,
    availableEquipment: params.availableEquipment,
    limitedBodyParts: params.limitedBodyParts,
  );
});

// Workout pattern analysis provider
final workoutPatternAnalysisProvider =
    FutureProvider.family<List<AISuggestion>, String>((ref, userId) async {
  final aiService = ref.read(aiCoachingServiceProvider);
  return aiService.analyzeWorkoutPatterns(userId);
});

// AI actions provider for user interactions
final aiActionsProvider = Provider<AIActions>((ref) {
  return AIActions(ref.read(aiCoachingServiceProvider));
});

class AIActions {
  AIActions(this._aiService);

  final AICoachingService _aiService;

  Future<List<WorkoutRecommendation>> getPersonalizedWorkouts(
    String userId, {
    List<String>? muscleGroups,
    List<String>? equipment,
    int? duration,
  }) async {
    return _aiService.getWorkoutRecommendations(
      userId,
      preferredMuscleGroups: muscleGroups,
      availableEquipment: equipment,
      maxDuration: duration,
    );
  }

  Future<RecoveryAnalysis> analyzeRecovery(String userId) async {
    return _aiService.getRecoveryAnalysis(userId);
  }

  Future<List<String>> findAlternativeExercises(
    String exerciseId, {
    List<String>? equipment,
    List<String>? limitations,
  }) async {
    return _aiService.getExerciseSubstitutions(
      exerciseId,
      availableEquipment: equipment,
      limitedBodyParts: limitations,
    );
  }
}

// Helper classes for parameters
class WorkoutRecommendationParams {
  const WorkoutRecommendationParams({
    required this.userId,
    this.preferredMuscleGroups,
    this.availableEquipment,
    this.maxDuration,
  });

  final String userId;
  final List<String>? preferredMuscleGroups;
  final List<String>? availableEquipment;
  final int? maxDuration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutRecommendationParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          _listEquals(preferredMuscleGroups, other.preferredMuscleGroups) &&
          _listEquals(availableEquipment, other.availableEquipment) &&
          maxDuration == other.maxDuration;

  @override
  int get hashCode =>
      userId.hashCode ^
      (preferredMuscleGroups?.hashCode ?? 0) ^
      (availableEquipment?.hashCode ?? 0) ^
      (maxDuration?.hashCode ?? 0);

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class ProgressiveOverloadParams {
  const ProgressiveOverloadParams({
    required this.userId,
    required this.exerciseId,
  });

  final String userId;
  final String exerciseId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressiveOverloadParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          exerciseId == other.exerciseId;

  @override
  int get hashCode => userId.hashCode ^ exerciseId.hashCode;
}

class ExerciseSubstitutionParams {
  const ExerciseSubstitutionParams({
    required this.exerciseId,
    this.availableEquipment,
    this.limitedBodyParts,
  });

  final String exerciseId;
  final List<String>? availableEquipment;
  final List<String>? limitedBodyParts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSubstitutionParams &&
          runtimeType == other.runtimeType &&
          exerciseId == other.exerciseId &&
          _listEquals(availableEquipment, other.availableEquipment) &&
          _listEquals(limitedBodyParts, other.limitedBodyParts);

  @override
  int get hashCode =>
      exerciseId.hashCode ^
      (availableEquipment?.hashCode ?? 0) ^
      (limitedBodyParts?.hashCode ?? 0);

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
