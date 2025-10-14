import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../../../core/services/groq_service.dart';
import '../../domain/models/ai_models.dart';

/// AI coaching service powered by Groq LLM
class GroqAICoachingService {
  final GroqService _groqService;
  final AppDatabase _database;

  GroqAICoachingService(this._groqService, this._database);

  /// Generate workout recommendations based on user history
  Future<List<WorkoutRecommendation>> getWorkoutRecommendations(
    String userId, {
    List<String>? preferredMuscleGroups,
    List<String>? availableEquipment,
    int? maxDuration,
  }) async {
    try {
      // Get recent workout history
      final workoutHistory = await (_database.select(_database.workoutSessions)
            ..orderBy([(w) => OrderingTerm.desc(w.startedAt)])
            ..limit(10))
          .get();

      // Get user's PRs
      final prs = await (_database.select(_database.personalRecords)
            ..orderBy([(pr) => OrderingTerm.desc(pr.achievedAt)])
            ..limit(20))
          .get();

      final systemPrompt =
          '''You are an expert fitness coach and exercise physiologist. 
You create personalized workout programs based on user data, exercise science principles, and progressive overload.
Consider recovery, muscle balance, and individual goals.''';

      final userPrompt =
          '''Create 2-3 workout recommendations based on this data:

Recent Workouts (last 10):
${_formatWorkoutHistory(workoutHistory)}

Personal Records:
${_formatPRs(prs)}

Preferences:
${preferredMuscleGroups != null ? '- Preferred muscle groups: ${preferredMuscleGroups.join(", ")}' : ''}
${availableEquipment != null ? '- Available equipment: ${availableEquipment.join(", ")}' : ''}
${maxDuration != null ? '- Max duration: $maxDuration minutes' : ''}

Respond with JSON array of workout recommendations:
[{
  "id": "rec_1",
  "name": "Workout name",
  "description": "Brief description",
  "exercises": [{
    "exerciseId": "exercise_id",
    "name": "Exercise name",
    "sets": 3,
    "reps": "8-12",
    "weight": 100.0,
    "rpe": 7,
    "restSeconds": 90,
    "notes": "Form tips"
  }],
  "estimatedDuration": 45,
  "difficulty": "intermediate",
  "targetMuscleGroups": ["chest", "triceps"],
  "reasoning": "Why this workout",
  "confidence": 0.85,
  "requiredEquipment": ["barbell", "bench"]
}]''';

      final response = await _groqService.chatJson(
        prompt: userPrompt,
        systemPrompt: systemPrompt,
      );

      final jsonData = jsonDecode(response) as List;
      return jsonData
          .map((json) => WorkoutRecommendation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to generate workout recommendations: $e');
    }
  }

  /// Get progressive overload suggestions
  Future<List<ProgressiveOverloadSuggestion>> getProgressiveOverloadSuggestions(
    String userId,
    String exerciseId,
  ) async {
    try {
      // Get exercise history
      final exercise = await (_database.select(_database.exercises)
            ..where((e) => e.id.equals(exerciseId)))
          .getSingleOrNull();

      if (exercise == null) {
        throw Exception('Exercise not found');
      }

      // Get recent PRs for this exercise
      final prs = await (_database.select(_database.personalRecords)
            ..where((pr) => pr.exerciseId.equals(exerciseId))
            ..orderBy([(pr) => OrderingTerm.desc(pr.achievedAt)])
            ..limit(5))
          .get();

      final systemPrompt =
          '''You are a strength coach specializing in progressive overload.
Provide evidence-based recommendations for increasing weight, reps, or volume safely.''';

      final userPrompt = '''Suggest progressive overload for this exercise:

Exercise: ${exercise.name}
Type: ${exercise.exerciseType}
Recent PRs:
${prs.map((pr) => '- ${pr.weight}kg x ${pr.reps} reps on ${pr.achievedAt.toString().split(' ')[0]}').join('\n')}

Provide 2-3 progressive overload options in JSON:
[{
  "exerciseId": "$exerciseId",
  "currentWeight": ${prs.firstOrNull?.weight ?? 0},
  "currentReps": ${prs.firstOrNull?.reps ?? 8},
  "currentSets": 3,
  "suggestedWeight": 0.0,
  "suggestedReps": 0,
  "suggestedSets": 0,
  "reasoning": "Why this progression",
  "confidence": 0.85,
  "timeframe": "Next workout"
}]''';

      final response = await _groqService.chatJson(
        prompt: userPrompt,
        systemPrompt: systemPrompt,
      );

      final jsonData = jsonDecode(response) as List;
      return jsonData
          .map((json) => ProgressiveOverloadSuggestion.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to generate overload suggestions: $e');
    }
  }

  /// Analyze recovery and provide recommendations
  Future<RecoveryAnalysis> getRecoveryAnalysis(String userId) async {
    try {
      // Get recent workouts
      final recentWorkouts = await (_database.select(_database.workoutSessions)
            ..orderBy([(w) => OrderingTerm.desc(w.startedAt)])
            ..limit(7))
          .get();

      final systemPrompt = '''You are a sports recovery specialist.
Analyze workout patterns and provide evidence-based recovery recommendations.''';

      final userPrompt = '''Analyze recovery needs based on recent training:

Last 7 Workouts:
${recentWorkouts.map((w) => '- ${w.startedAt.toString().split(' ')[0]}: ${(w.totalDurationSeconds ?? 0) ~/ 60} min').join('\n')}

Total workouts this week: ${recentWorkouts.where((w) => w.startedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length}

Provide recovery analysis in JSON:
{
  "userId": "$userId",
  "analysisDate": "${DateTime.now().toIso8601String()}",
  "fatigueLevel": "moderate",
  "recoveryScore": 0.7,
  "recommendations": [{
    "type": "sleep",
    "title": "Recommendation title",
    "description": "Detailed advice",
    "priority": "high"
  }],
  "nextWorkoutSuggestion": "Training advice",
  "sleepQuality": 0.7,
  "stressLevel": 0.3,
  "nutritionScore": 0.8
}''';

      final response = await _groqService.chatJson(
        prompt: userPrompt,
        systemPrompt: systemPrompt,
      );

      final jsonData = jsonDecode(response);
      return RecoveryAnalysis.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to analyze recovery: $e');
    }
  }

  /// Get general AI coaching suggestions
  Future<List<AISuggestion>> getGeneralSuggestions(String userId) async {
    try {
      final workouts = await (_database.select(_database.workoutSessions)
            ..orderBy([(w) => OrderingTerm.desc(w.startedAt)])
            ..limit(5))
          .get();

      final systemPrompt = '''You are a comprehensive fitness coach.
Provide actionable, personalized fitness suggestions based on training data.''';

      final userPrompt =
          '''Provide 3-5 coaching suggestions based on recent training:

Recent Activity:
${workouts.map((w) => '- ${w.name} on ${w.startedAt.toString().split(' ')[0]}').join('\n')}

Generate suggestions in JSON array:
[{
  "id": "sugg_1",
  "type": "form_tip",
  "title": "Suggestion title",
  "description": "Detailed advice",
  "confidence": 0.8,
  "createdAt": "${DateTime.now().toIso8601String()}",
  "reasoning": "Why this suggestion"
}]''';

      final response = await _groqService.chatJson(
        prompt: userPrompt,
        systemPrompt: systemPrompt,
      );

      final jsonData = jsonDecode(response) as List;
      return jsonData.map((json) => AISuggestion.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to generate suggestions: $e');
    }
  }

  /// Get exercise substitutions
  Future<List<String>> getExerciseSubstitutions(
    String exerciseId, {
    List<String>? availableEquipment,
    List<String>? limitedBodyParts,
  }) async {
    try {
      final exercise = await (_database.select(_database.exercises)
            ..where((e) => e.id.equals(exerciseId)))
          .getSingleOrNull();

      if (exercise == null) {
        return ['No substitutions available'];
      }

      final systemPrompt = '''You are an exercise science expert.
Suggest equivalent exercises that target the same muscle groups.''';

      final userPrompt = '''Find substitutions for: ${exercise.name}

Primary muscle: ${exercise.primaryMuscleGroup}
${availableEquipment != null ? 'Available equipment: ${availableEquipment.join(", ")}' : ''}
${limitedBodyParts != null ? 'Avoid: ${limitedBodyParts.join(", ")}' : ''}

List 3-5 substitute exercises (just names, one per line).''';

      final response = await _groqService.chat(
        prompt: userPrompt,
        systemPrompt: systemPrompt,
      );

      return response
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(5)
          .toList();
    } catch (e) {
      return ['Error getting substitutions: $e'];
    }
  }

  String _formatWorkoutHistory(List<WorkoutSession> workouts) {
    if (workouts.isEmpty) return 'No recent workouts';
    return workouts
        .map((w) =>
            '- ${w.name} (${(w.totalDurationSeconds ?? 0) ~/ 60} min) on ${w.startedAt.toString().split(' ')[0]}')
        .join('\n');
  }

  String _formatPRs(List<PersonalRecord> prs) {
    if (prs.isEmpty) return 'No personal records yet';
    return prs
        .map((pr) =>
            '- ${pr.exerciseId}: ${pr.weight}kg x ${pr.reps} (${pr.achievedAt.toString().split(' ')[0]})')
        .join('\n');
  }
}
