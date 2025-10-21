import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/groq_provider.dart';
import '../../data/services/ai_coaching_service.dart';
import '../../data/services/groq_ai_coaching_service.dart';
import '../../domain/models/ai_models.dart';

/// Helper function to get user-friendly error messages
String getAiErrorMessage(String error) {
  if (error.contains('Rate limit exceeded')) {
    return 'AI service is busy. Please wait a moment and try again.';
  } else if (error.contains('Failed to parse AI response')) {
    return 'AI returned invalid data. Please try again.';
  } else if (error.contains('Invalid API key')) {
    return 'AI service configuration error. Please contact support.';
  } else if (error.contains('Request timed out')) {
    return 'Request timed out. Please try again.';
  } else if (error.contains('No workout history')) {
    return 'No workout history found. Please complete some workouts first.';
  } else if (error.contains('Folder not found')) {
    return 'Workout folder not found. Please refresh and try again.';
  } else if (error.contains('No templates found')) {
    return 'No workout templates found in this folder.';
  }
  return error; // Return original error if no match
}

// State management for applied and dismissed suggestions
final appliedSuggestionsProvider = StateProvider<Set<String>>((ref) => {});
final dismissedSuggestionsProvider = StateProvider<Set<String>>((ref) => {});
final appliedProgressSuggestionsProvider =
    StateProvider<Set<String>>((ref) => {});

// Mock service provider (fallback)
final aiCoachingServiceProvider =
    Provider<AICoachingService>((ref) => AICoachingService());

// Groq AI service provider (real AI)
final groqAICoachingServiceProvider = Provider<GroqAICoachingService?>((ref) {
  final groqService = ref.watch(groqServiceProvider);
  final database = ref.watch(databaseProvider);

  // Return null if database is not available (e.g., on web platform)
  if (database == null) return null;

  return GroqAICoachingService(groqService, database);
});

// Groq-powered workout recommendations provider
final groqWorkoutRecommendationsProvider = FutureProvider.family<
    List<WorkoutRecommendation>,
    WorkoutRecommendationParams>((ref, params) async {
  final aiService = ref.read(groqAICoachingServiceProvider);
  if (aiService == null) {
    // Fallback to mock if Groq service unavailable
    final mockService = ref.read(aiCoachingServiceProvider);
    return mockService.getWorkoutRecommendations(
      params.userId,
      preferredMuscleGroups: params.preferredMuscleGroups,
      availableEquipment: params.availableEquipment,
      maxDuration: params.maxDuration,
    );
  }
  return aiService.getWorkoutRecommendations(
    params.userId,
    preferredMuscleGroups: params.preferredMuscleGroups,
    availableEquipment: params.availableEquipment,
    maxDuration: params.maxDuration,
  );
});

// Groq-powered progressive overload suggestions provider
final groqProgressiveOverloadProvider = FutureProvider.family<
    List<ProgressiveOverloadSuggestion>,
    ProgressiveOverloadParams>((ref, params) async {
  final aiService = ref.read(groqAICoachingServiceProvider);
  if (aiService == null) {
    // Fallback to mock if Groq service unavailable
    final mockService = ref.read(aiCoachingServiceProvider);
    return mockService.getProgressiveOverloadSuggestions(
      params.userId,
      params.exerciseId,
    );
  }
  return aiService.getProgressiveOverloadSuggestions(
    params.userId,
    params.exerciseId,
  );
});

// Groq-powered recovery analysis provider
final groqRecoveryAnalysisProvider =
    FutureProvider.family<RecoveryAnalysis, String>((ref, userId) async {
  final aiService = ref.read(groqAICoachingServiceProvider);
  if (aiService == null) {
    // Fallback to mock if Groq service unavailable
    final mockService = ref.read(aiCoachingServiceProvider);
    return mockService.getRecoveryAnalysis(userId);
  }
  return aiService.getRecoveryAnalysis(userId);
});

// Groq-powered general AI suggestions provider
final groqAISuggestionsProvider =
    FutureProvider.family<List<AISuggestion>, String>((ref, userId) async {
  final aiService = ref.read(groqAICoachingServiceProvider);
  if (aiService == null) {
    // Fallback to mock if Groq service unavailable
    final mockService = ref.read(aiCoachingServiceProvider);
    return mockService.getGeneralSuggestions(userId);
  }
  return aiService.getGeneralSuggestions(userId);
});

// Groq-powered exercise substitutions provider
final groqExerciseSubstitutionsProvider =
    FutureProvider.family<List<String>, ExerciseSubstitutionParams>(
        (ref, params) async {
  final aiService = ref.read(groqAICoachingServiceProvider);
  if (aiService == null) {
    // Fallback to mock if Groq service unavailable
    final mockService = ref.read(aiCoachingServiceProvider);
    return mockService.getExerciseSubstitutions(
      params.exerciseId,
      availableEquipment: params.availableEquipment,
      limitedBodyParts: params.limitedBodyParts,
    );
  }
  return aiService.getExerciseSubstitutions(
    params.exerciseId,
    availableEquipment: params.availableEquipment,
    limitedBodyParts: params.limitedBodyParts,
  );
});

// Workout recommendations provider (fallback to mock if Groq fails)
final workoutRecommendationsProvider = FutureProvider.family<
    List<WorkoutRecommendation>,
    WorkoutRecommendationParams>((ref, params) async {
  ref.keepAlive();
  print('🔄 Loading workout recommendations...');
  try {
    final aiService = ref.read(groqAICoachingServiceProvider);
    if (aiService != null) {
      final result = await aiService.getWorkoutRecommendations(
        params.userId,
        preferredMuscleGroups: params.preferredMuscleGroups,
        availableEquipment: params.availableEquipment,
        maxDuration: params.maxDuration,
      );
      print('✅ Groq workout recommendations loaded: ${result.length}');
      return result;
    }
    throw Exception('Groq service unavailable');
  } catch (e) {
    print('⚠️ Groq failed, using mock service: $e');
    // Fallback to mock service if Groq fails
    final mockService = ref.read(aiCoachingServiceProvider);
    final result = await mockService.getWorkoutRecommendations(
      params.userId,
      preferredMuscleGroups: params.preferredMuscleGroups,
      availableEquipment: params.availableEquipment,
      maxDuration: params.maxDuration,
    );
    print('✅ Mock workout recommendations loaded: ${result.length}');
    return result;
  }
});

// Progressive overload suggestions provider (fallback to mock if Groq fails)
final progressiveOverloadProvider = FutureProvider.family<
    List<ProgressiveOverloadSuggestion>,
    ProgressiveOverloadParams>((ref, params) async {
  try {
    final aiService = ref.read(groqAICoachingServiceProvider);
    if (aiService != null) {
      return await aiService.getProgressiveOverloadSuggestions(
        params.userId,
        params.exerciseId,
      );
    }
    throw Exception('Groq service unavailable');
  } catch (e) {
    // Fallback to mock service if Groq fails
    final mockService = ref.read(aiCoachingServiceProvider);
    return mockService.getProgressiveOverloadSuggestions(
      params.userId,
      params.exerciseId,
    );
  }
});

// Recovery analysis provider (fallback to mock if Groq fails)
// Using keepAlive to cache results and prevent different scores on each load
final recoveryAnalysisProvider =
    FutureProvider.family<RecoveryAnalysis, String>((ref, userId) async {
  // Keep the result alive to prevent regenerating random data
  ref.keepAlive();

  try {
    final aiService = ref.read(groqAICoachingServiceProvider);
    if (aiService != null) {
      return await aiService.getRecoveryAnalysis(userId);
    }
    throw Exception('Groq service unavailable');
  } catch (e) {
    // Fallback to mock service if Groq fails
    final mockService = ref.read(aiCoachingServiceProvider);
    return mockService.getRecoveryAnalysis(userId);
  }
});

// General AI suggestions provider (fallback to mock if Groq fails)
final aiSuggestionsProvider =
    FutureProvider.family<List<AISuggestion>, String>((ref, userId) async {
  try {
    final aiService = ref.read(groqAICoachingServiceProvider);
    if (aiService != null) {
      return await aiService.getGeneralSuggestions(userId);
    }
    throw Exception('Groq service unavailable');
  } catch (e) {
    // Fallback to mock service if Groq fails
    final mockService = ref.read(aiCoachingServiceProvider);
    return mockService.getGeneralSuggestions(userId);
  }
});

// Exercise substitutions provider (fallback to mock if Groq fails)
final exerciseSubstitutionsProvider =
    FutureProvider.family<List<String>, ExerciseSubstitutionParams>(
        (ref, params) async {
  try {
    final aiService = ref.read(groqAICoachingServiceProvider);
    if (aiService != null) {
      return await aiService.getExerciseSubstitutions(
        params.exerciseId,
        availableEquipment: params.availableEquipment,
        limitedBodyParts: params.limitedBodyParts,
      );
    }
    throw Exception('Groq service unavailable');
  } catch (e) {
    // Fallback to mock service if Groq fails
    final mockService = ref.read(aiCoachingServiceProvider);
    return mockService.getExerciseSubstitutions(
      params.exerciseId,
      availableEquipment: params.availableEquipment,
      limitedBodyParts: params.limitedBodyParts,
    );
  }
});

// Workout pattern analysis provider
final workoutPatternAnalysisProvider =
    FutureProvider.family<List<AISuggestion>, String>((ref, userId) async {
  final aiService = ref.read(aiCoachingServiceProvider);
  return aiService.analyzeWorkoutPatterns(userId);
});

// Generate next workout provider (fallback to mock if Groq fails)
final generateNextWorkoutProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, bool>((ref, isAdminMode) async {
  final userId = isAdminMode ? null : 'default_user'; // Admin mode = system-wide, User mode = user-specific
  
  try {
    final aiService = ref.read(groqAICoachingServiceProvider);
    if (aiService != null) {
      final result = await aiService.generateNextWorkout(userId ?? 'default_user');
      print('✅ Groq next workout generated (Real API)');
      return result;
    }
    throw Exception('Groq service unavailable');
  } catch (e) {
    print('❌ Groq failed: $e');
    throw Exception(getAiErrorMessage(e.toString()));
  }
});

// Optimize workout folder provider (NO fallback to mock - show real errors)
final optimizeFolderProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, folderId) async {
  try {
    final aiService = ref.read(groqAICoachingServiceProvider);
    if (aiService != null) {
      final result = await aiService.optimizeWorkoutFolder(folderId);
      print('✅ Groq folder optimized (Real API)');
      return result;
    }
    throw Exception('Groq service unavailable');
  } catch (e) {
    print('❌ Groq failed: $e');
    throw Exception(getAiErrorMessage(e.toString()));
  }
});

// Parameter class for evaluate progress
class EvaluateProgressParams {
  const EvaluateProgressParams({
    required this.isAdminMode,
    required this.languageCode,
  });
  
  final bool isAdminMode;
  final String languageCode;
}

// Evaluate progress provider - AI analyzes user's training history
final evaluateProgressProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, EvaluateProgressParams>((ref, params) async {
  final userId = params.isAdminMode ? null : 'default_user';
  
  try {
    final aiService = ref.read(groqAICoachingServiceProvider);
    if (aiService != null) {
      final result = await aiService.evaluateProgress(
        userId ?? 'default_user',
        languageCode: params.languageCode,
      );
      print('✅ Progress evaluation completed (Real API)');
      return result;
    }
    throw Exception('Groq service unavailable');
  } catch (e) {
    print('❌ Progress evaluation failed: $e');
    throw Exception(getAiErrorMessage(e.toString()));
  }
});

// AI actions provider for user interactions (with Groq fallback)
final aiActionsProvider = Provider<AIActions>(
  (ref) => AIActions(
    ref.read(groqAICoachingServiceProvider),
    ref.read(aiCoachingServiceProvider),
  ),
);

class AIActions {
  AIActions(this._groqService, this._mockService);

  final GroqAICoachingService? _groqService;
  final AICoachingService _mockService;

  Future<List<WorkoutRecommendation>> getPersonalizedWorkouts(
    String userId, {
    List<String>? muscleGroups,
    List<String>? equipment,
    int? duration,
  }) async {
    try {
      if (_groqService != null) {
        return await _groqService!.getWorkoutRecommendations(
          userId,
          preferredMuscleGroups: muscleGroups,
          availableEquipment: equipment,
          maxDuration: duration,
        );
      }
      throw Exception('Groq service unavailable');
    } catch (e) {
      return _mockService.getWorkoutRecommendations(
        userId,
        preferredMuscleGroups: muscleGroups,
        availableEquipment: equipment,
        maxDuration: duration,
      );
    }
  }

  Future<RecoveryAnalysis> analyzeRecovery(String userId) async {
    try {
      if (_groqService != null) {
        return await _groqService!.getRecoveryAnalysis(userId);
      }
      throw Exception('Groq service unavailable');
    } catch (e) {
      return _mockService.getRecoveryAnalysis(userId);
    }
  }

  Future<List<String>> findAlternativeExercises(
    String exerciseId, {
    List<String>? equipment,
    List<String>? limitations,
  }) async {
    try {
      if (_groqService != null) {
        return await _groqService!.getExerciseSubstitutions(
          exerciseId,
          availableEquipment: equipment,
          limitedBodyParts: limitations,
        );
      }
      throw Exception('Groq service unavailable');
    } catch (e) {
      return _mockService.getExerciseSubstitutions(
        exerciseId,
        availableEquipment: equipment,
        limitedBodyParts: limitations,
      );
    }
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

  WorkoutRecommendationParams copyWith({
    List<String>? preferredMuscleGroups,
    List<String>? availableEquipment,
    int? maxDuration,
  }) =>
      WorkoutRecommendationParams(
        userId: userId,
        preferredMuscleGroups:
            preferredMuscleGroups ?? this.preferredMuscleGroups,
        availableEquipment: availableEquipment ?? this.availableEquipment,
        maxDuration: maxDuration ?? this.maxDuration,
      );

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
      _listHash(preferredMuscleGroups) ^
      _listHash(availableEquipment) ^
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

  int _listHash(List<String>? list) {
    if (list == null) return 0;
    return Object.hashAll(list);
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
