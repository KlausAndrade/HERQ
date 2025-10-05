import 'dart:math';

import '../../../../core/config/mock_data_config.dart';
import '../../domain/models/ai_models.dart';

/// AI coaching service with mock ML-powered recommendations for Phase 3
class AICoachingService {
  AICoachingService();

  final _random = Random();

  /// Generate workout recommendations based on user history and preferences
  Future<List<WorkoutRecommendation>> getWorkoutRecommendations(
    String userId, {
    List<String>? preferredMuscleGroups,
    List<String>? availableEquipment,
    int? maxDuration,
  }) async {
    await Future.delayed(Duration(milliseconds: MockDataConfig.aiCoachingParams['mlProcessingDelayMs'])); // Simulate ML processing

    final recommendations = <WorkoutRecommendation>[
      WorkoutRecommendation(
        id: 'rec_1',
        name: 'Upper Body Power',
        description: 'Focus on compound movements for upper body strength',
        exercises: [
          RecommendedExercise(
            exerciseId: 'bench_press',
            name: 'Bench Press',
            sets: 4,
            reps: '5-6',
            weight: 185.0,
            rpe: 8,
            restSeconds: 180,
            notes: 'Focus on controlled eccentric',
          ),
          RecommendedExercise(
            exerciseId: 'bent_over_row',
            name: 'Bent Over Row',
            sets: 4,
            reps: '6-8',
            weight: 155.0,
            rpe: 7,
            restSeconds: 150,
          ),
          RecommendedExercise(
            exerciseId: 'overhead_press',
            name: 'Overhead Press',
            sets: 3,
            reps: '8-10',
            weight: 95.0,
            rpe: 8,
            restSeconds: 120,
          ),
        ],
        estimatedDuration: 45,
        difficulty: Difficulty.intermediate,
        targetMuscleGroups: ['chest', 'back', 'shoulders', 'triceps'],
        reasoning: 'Based on your recent progress, this workout will help build upper body strength while maintaining proper volume for recovery.',
        confidence: 0.85,
        requiredEquipment: ['barbell', 'bench', 'plates'],
      ),
      WorkoutRecommendation(
        id: 'rec_2',
        name: 'Lower Body Hypertrophy',
        description: 'High volume lower body workout for muscle growth',
        exercises: [
          RecommendedExercise(
            exerciseId: 'squat',
            name: 'Back Squat',
            sets: 4,
            reps: '8-12',
            weight: 225.0,
            rpe: 7,
            restSeconds: 120,
          ),
          RecommendedExercise(
            exerciseId: 'romanian_deadlift',
            name: 'Romanian Deadlift',
            sets: 3,
            reps: '10-12',
            weight: 185.0,
            rpe: 8,
            restSeconds: 90,
          ),
          RecommendedExercise(
            exerciseId: 'leg_press',
            name: 'Leg Press',
            sets: 3,
            reps: '12-15',
            weight: 315.0,
            rpe: 7,
            restSeconds: 90,
          ),
        ],
        estimatedDuration: 50,
        difficulty: Difficulty.intermediate,
        targetMuscleGroups: ['quadriceps', 'hamstrings', 'glutes'],
        reasoning: 'Your squat volume has been consistent. Time to focus on hypertrophy adaptations.',
        confidence: 0.78,
        requiredEquipment: ['barbell', 'squat_rack', 'leg_press'],
      ),
    ];

    return recommendations;
  }

  /// Get progressive overload suggestions for specific exercises
  Future<List<ProgressiveOverloadSuggestion>> getProgressiveOverloadSuggestions(
    String userId,
    String exerciseId,
  ) async {
    await Future.delayed(Duration(milliseconds: (MockDataConfig.aiCoachingParams['mlProcessingDelayMs'] * 0.75).round()));

    // Mock suggestions based on exercise performance patterns
    return [
      ProgressiveOverloadSuggestion(
        exerciseId: exerciseId,
        currentWeight: 185.0,
        currentReps: 8,
        currentSets: 3,
        suggestedWeight: 190.0,
        suggestedReps: 8,
        suggestedSets: 3,
        reasoning: 'Your last 3 sessions show consistent performance at current weight. Time for a 2.5% increase.',
        confidence: 0.82,
        timeframe: 'Next workout',
      ),
      ProgressiveOverloadSuggestion(
        exerciseId: exerciseId,
        currentWeight: 185.0,
        currentReps: 8,
        currentSets: 3,
        suggestedWeight: 185.0,
        suggestedReps: 10,
        suggestedSets: 3,
        reasoning: 'Alternative: Increase reps to build work capacity before adding weight.',
        confidence: 0.75,
        timeframe: 'This week',
      ),
    ];
  }

  /// Analyze user's recovery state and provide recommendations
  Future<RecoveryAnalysis> getRecoveryAnalysis(String userId) async {
    await Future.delayed(Duration(milliseconds: (MockDataConfig.aiCoachingParams['mlProcessingDelayMs'] * 0.875).round()));

    // Mock recovery analysis based on workout frequency and volume
    final fatigueLevel = FatigueLevel.values[_random.nextInt(FatigueLevel.values.length)];
    final recoveryScore = 0.3 + (_random.nextDouble() * 0.7); // 0.3 to 1.0

    final recommendations = <RecoveryRecommendation>[];
    
    if (recoveryScore < 0.6) {
      recommendations.addAll([
        RecoveryRecommendation(
          type: RecoveryType.sleep,
          title: 'Prioritize Sleep',
          description: 'Aim for 7-9 hours of quality sleep. Your recovery score suggests sleep quality may be impacting performance.',
          priority: Priority.high,
        ),
        RecoveryRecommendation(
          type: RecoveryType.rest,
          title: 'Consider Active Recovery',
          description: 'Take a lighter day with walking, stretching, or mobility work.',
          priority: Priority.medium,
        ),
      ]);
    }

    if (fatigueLevel == FatigueLevel.high || fatigueLevel == FatigueLevel.severe) {
      recommendations.add(
        RecoveryRecommendation(
          type: RecoveryType.nutrition,
          title: 'Focus on Nutrition',
          description: 'Ensure adequate protein intake (1.6-2.2g/kg bodyweight) and stay hydrated.',
          priority: Priority.high,
        ),
      );
    }

    // Always include some general recommendations
    recommendations.addAll([
      RecoveryRecommendation(
        type: RecoveryType.hydration,
        title: 'Stay Hydrated',
        description: 'Aim for at least 35ml per kg of bodyweight daily.',
        priority: Priority.medium,
      ),
      RecoveryRecommendation(
        type: RecoveryType.stretching,
        title: 'Dynamic Warm-up',
        description: 'Include 5-10 minutes of dynamic stretching before your next workout.',
        priority: Priority.low,
      ),
    ]);

    String nextWorkoutSuggestion;
    switch (fatigueLevel) {
      case FatigueLevel.low:
        nextWorkoutSuggestion = 'You\'re ready for a challenging workout. Consider progressive overload.';
        break;
      case FatigueLevel.moderate:
        nextWorkoutSuggestion = 'Moderate intensity workout recommended. Focus on technique.';
        break;
      case FatigueLevel.high:
        nextWorkoutSuggestion = 'Light workout or active recovery. Listen to your body.';
        break;
      case FatigueLevel.severe:
        nextWorkoutSuggestion = 'Rest day recommended. Focus on recovery strategies.';
        break;
    }

    return RecoveryAnalysis(
      userId: userId,
      analysisDate: DateTime.now(),
      fatigueLevel: fatigueLevel,
      recoveryScore: recoveryScore,
      recommendations: recommendations,
      nextWorkoutSuggestion: nextWorkoutSuggestion,
      sleepQuality: 0.4 + (_random.nextDouble() * 0.6), // 0.4 to 1.0
      stressLevel: _random.nextDouble(), // 0.0 to 1.0
      nutritionScore: 0.5 + (_random.nextDouble() * 0.5), // 0.5 to 1.0
    );
  }

  /// Get general AI suggestions for the user
  Future<List<AISuggestion>> getGeneralSuggestions(String userId) async {
    await Future.delayed(Duration(milliseconds: (MockDataConfig.aiCoachingParams['mlProcessingDelayMs'] * 0.625).round()));

    final suggestions = <AISuggestion>[
      AISuggestion(
        id: 'sugg_1',
        type: SuggestionType.exerciseSubstitution,
        title: 'Exercise Substitution',
        description: 'Try incline dumbbell press instead of flat bench to target upper chest',
        confidence: 0.75,
        createdAt: DateTime.now(),
        exerciseId: 'bench_press',
        reasoning: 'Your chest development could benefit from more upper chest emphasis based on your training history.',
      ),
      AISuggestion(
        id: 'sugg_2',
        type: SuggestionType.formTip,
        title: 'Form Improvement',
        description: 'Focus on slower eccentric phase (3-4 seconds) during squats for better muscle activation',
        confidence: 0.68,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        exerciseId: 'squat',
        reasoning: 'Research shows controlled eccentrics improve strength gains and reduce injury risk.',
      ),
      AISuggestion(
        id: 'sugg_3',
        type: SuggestionType.nutritionTip,
        title: 'Post-Workout Nutrition',
        description: 'Consider consuming 20-30g protein within 2 hours post-workout for optimal recovery',
        confidence: 0.85,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        reasoning: 'Your workout frequency suggests optimizing recovery nutrition could enhance performance.',
      ),
    ];

    return suggestions;
  }

  /// Get exercise substitutions for equipment limitations or injuries
  Future<List<String>> getExerciseSubstitutions(
    String exerciseId, {
    List<String>? availableEquipment,
    List<String>? limitedBodyParts,
  }) async {
    await Future.delayed(Duration(milliseconds: (MockDataConfig.aiCoachingParams['mlProcessingDelayMs'] * 0.5).round()));

    // Mock substitution logic
    final substitutions = <String, List<String>>{
      'bench_press': [
        'Dumbbell Bench Press',
        'Push-ups',
        'Incline Dumbbell Press',
        'Chest Dips',
      ],
      'squat': [
        'Goblet Squat',
        'Bulgarian Split Squat',
        'Leg Press',
        'Lunges',
      ],
      'deadlift': [
        'Romanian Deadlift',
        'Trap Bar Deadlift',
        'Single Leg Deadlift',
        'Hip Thrust',
      ],
    };

    return substitutions[exerciseId] ?? ['No substitutions available'];
  }

  /// Analyze workout data to detect patterns and suggest optimizations
  Future<List<AISuggestion>> analyzeWorkoutPatterns(String userId) async {
    await Future.delayed(Duration(milliseconds: (MockDataConfig.aiCoachingParams['mlProcessingDelayMs'] * 1.125).round()));

    // Mock pattern analysis
    return [
      AISuggestion(
        id: 'pattern_1',
        type: SuggestionType.deloadSuggestion,
        title: 'Deload Week Recommended',
        description: 'Your performance has plateaued over the last 3 weeks. Consider a deload week.',
        confidence: 0.78,
        createdAt: DateTime.now(),
        reasoning: 'Performance metrics show signs of accumulated fatigue. A deload week can help break through plateaus.',
        metadata: {
          'plateau_duration': 3,
          'volume_trend': 'declining',
          'strength_trend': 'stagnant',
        },
      ),
      AISuggestion(
        id: 'pattern_2',
        type: SuggestionType.workoutRecommendation,
        title: 'Increase Training Frequency',
        description: 'Consider adding one more leg day per week for better lower body development.',
        confidence: 0.71,
        createdAt: DateTime.now(),
        reasoning: 'Your upper body is progressing faster than lower body. Frequency increase could help balance development.',
        metadata: {
          'current_frequency': 2,
          'suggested_frequency': 3,
          'muscle_group': 'legs',
        },
      ),
    ];
  }
}