import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../../../core/services/groq_service.dart';
import '../../domain/models/ai_models.dart';
import '../constants/ai_prompts.dart';

/// AI coaching service powered by Groq LLM
class GroqAICoachingService {
  GroqAICoachingService(this._groqService, this._database);
  final GroqService _groqService;
  final AppDatabase _database;

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

      const systemPrompt = '''
You are an expert fitness coach and exercise physiologist. 
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

      const systemPrompt = '''
You are a strength coach specializing in progressive overload.
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

      const systemPrompt = '''
You are a sports recovery specialist.
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

      const systemPrompt = '''
You are a comprehensive fitness coach.
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

      const systemPrompt = '''
You are an exercise science expert.
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
        .map(
          (w) =>
              '- ${w.name} (${(w.totalDurationSeconds ?? 0) ~/ 60} min) on ${w.startedAt.toString().split(' ')[0]}',
        )
        .join('\n');
  }

  String _formatPRs(List<PersonalRecord> prs) {
    if (prs.isEmpty) return 'No personal records yet';
    return prs
        .map(
          (pr) =>
              '- ${pr.exerciseId}: ${pr.weight}kg x ${pr.reps} (${pr.achievedAt.toString().split(' ')[0]})',
        )
        .join('\n');
  }

  /// Generate next workout based on user's workout history
  Future<Map<String, dynamic>> generateNextWorkout(String userId) async {
    print('🤖 Using GROQ service for generateNextWorkout');
    try {
      // Get last 14 completed workout sessions
      final workoutHistory = await (_database.select(_database.workoutSessions)
            ..where((w) => w.completedAt.isNotNull())
            ..orderBy([(w) => OrderingTerm.desc(w.startedAt)])
            ..limit(14))
          .get();

      if (workoutHistory.isEmpty) {
        throw Exception('No workout history found. Complete some workouts first!');
      }

      // Build comprehensive workout history JSON
      final workoutHistoryData = <Map<String, dynamic>>[];
      
      for (final session in workoutHistory) {
        // Get all set entries for this session
        final setEntries = await (_database.select(_database.setEntries)
              ..where((se) => se.workoutSessionId.equals(session.id))
              ..orderBy([(se) => OrderingTerm.asc(se.exerciseId), (se) => OrderingTerm.asc(se.setNumber)]))
            .get();

        // Group sets by exercise
        final exerciseGroups = <String, List<SetEntry>>{};
        for (final set in setEntries) {
          exerciseGroups.putIfAbsent(set.exerciseId, () => []).add(set);
        }

        // Build exercise data with sets
        final exercises = <Map<String, dynamic>>[];
        for (final entry in exerciseGroups.entries) {
          final exerciseId = entry.key;
          final sets = entry.value;
          
          // Get exercise details
          final exercise = await (_database.select(_database.exercises)
                ..where((e) => e.id.equals(exerciseId)))
              .getSingleOrNull();

          if (exercise != null) {
            final exerciseSets = sets.map((set) => {
              'number': set.setNumber,
              'weight': set.weight,
              'reps': set.reps,
              'rpe': set.rpe,
              'durationSeconds': set.durationSeconds,
              'distance': set.distance,
              'assistanceWeight': set.assistanceWeight,
              'addedWeight': set.addedWeight,
              'restDurationSeconds': set.restDurationSeconds,
              'isWarmup': set.isWarmup,
              'isDropSet': set.isDropSet,
              'isFailure': set.isFailure,
              'setType': set.setType,
              'equipmentUsed': set.equipmentUsed,
              'variantType': set.variantType,
              'notes': set.notes,
            }).toList();

            exercises.add({
              'exerciseId': exerciseId,
              'name': exercise.name,
              'exerciseType': exercise.exerciseType,
              'primaryMuscleGroup': exercise.primaryMuscleGroup,
              'secondaryMuscleGroups': exercise.secondaryMuscleGroups,
              'equipment': exercise.equipment,
              'isBodyweight': exercise.isBodyweight,
              'category': exercise.category,
              'difficulty': exercise.difficulty,
              'sets': exerciseSets,
            });
          }
        }

        workoutHistoryData.add({
          'sessionId': session.id,
          'name': session.name,
          'date': session.startedAt.toIso8601String(),
          'duration': session.totalDurationSeconds,
          'totalVolume': session.totalVolume,
          'totalTonnage': session.totalTonnage,
          'totalSets': session.totalSets,
          'totalReps': session.totalReps,
          'exercises': exercises,
        });
      }

      // Get available exercises from database
      final availableExercises = await (_database.select(_database.exercises)
            ..orderBy([(e) => OrderingTerm.asc(e.name)]))
          .get();

      // Build available exercises data
      final availableExercisesData = availableExercises.map((exercise) => {
        'id': exercise.id,
        'name': exercise.name,
        'exerciseType': exercise.exerciseType,
        'primaryMuscleGroup': exercise.primaryMuscleGroup,
        'secondaryMuscleGroups': exercise.secondaryMuscleGroups,
        'equipment': exercise.equipment,
        'isBodyweight': exercise.isBodyweight,
        'category': exercise.category,
        'difficulty': exercise.difficulty,
      }).toList();

      final userPrompt = '''Generate my next workout based on this comprehensive workout history:

WORKOUT HISTORY:
${jsonEncode({'workoutHistory': workoutHistoryData})}

AVAILABLE EXERCISES (use these exercise IDs and names):
${jsonEncode({'availableExercises': availableExercisesData})}

Create a complete workout that builds on my training patterns and applies progressive overload principles. Use ONLY exercises from the available exercises list above. Use the exact exercise IDs and names provided.''';

      final response = await _groqService.chatJson(
        prompt: userPrompt,
        systemPrompt: AIPrompts.SYSTEM_PROMPT_GENERATE_NEXT_WORKOUT,
      );

      // Validate and parse JSON response
      try {
        // Clean the response string if needed
        String cleanResponse = response.trim();
        if (cleanResponse.startsWith('```json')) {
          cleanResponse = cleanResponse.replaceFirst('```json', '').replaceAll('```', '').trim();
        }
        
        final jsonData = jsonDecode(cleanResponse) as Map<String, dynamic>;
        
        // Debug: Print the parsed JSON structure
        print('Parsed JSON keys: ${jsonData.keys.toList()}');
        if (jsonData.containsKey('exercises')) {
          final exercises = jsonData['exercises'] as List<dynamic>?;
          print('Exercises count: ${exercises?.length ?? 0}');
          if (exercises != null && exercises.isNotEmpty) {
            print('First exercise: ${exercises.first}');
          }
        }
        
        // Validate required fields
        if (!jsonData.containsKey('name') || !jsonData.containsKey('exercises')) {
          print('Missing required fields. Available keys: ${jsonData.keys.toList()}');
          throw Exception('Invalid JSON structure: missing required fields');
        }
        
        // Check if exercises array is empty
        final exercises = jsonData['exercises'] as List<dynamic>?;
        if (exercises == null || exercises.isEmpty) {
          print('WARNING: Exercises array is empty or null');
          // Add a fallback exercise to prevent empty workout
          jsonData['exercises'] = [
            {
              'id': 'fallback_exercise',
              'name': 'Push-ups',
              'exerciseType': 'bodyweightReps',
              'equipmentUsed': 'bodyweight',
              'variantType': 'standard',
              'restTimerSeconds': 60,
              'notes': 'Fallback exercise - AI did not generate any exercises',
              'sets': [
                {
                  'number': 1,
                  'weight': 0,
                  'reps': 10,
                  'rpe': 7,
                  'durationSeconds': 0,
                  'distance': 0,
                  'assistanceWeight': 0,
                  'addedWeight': 0,
                  'restDurationSeconds': 60,
                  'isWarmup': false,
                  'isDropSet': false,
                  'isFailure': false,
                  'setType': 'working',
                  'equipmentUsed': 'bodyweight',
                  'variantType': 'standard',
                  'notes': 'Fallback set'
                }
              ]
            }
          ];
        }
        
        return jsonData;
      } catch (jsonError) {
        print('JSON Parse Error: $jsonError');
        print('Raw Response Length: ${response.length}');
        print('Raw Response (first 500 chars): ${response.substring(0, response.length > 500 ? 500 : response.length)}');
        throw Exception('Failed to parse AI response. Please try again.');
      }
    } catch (e) {
      throw Exception('Failed to generate next workout: $e');
    }
  }

  /// Optimize workout folder with all templates
  Future<Map<String, dynamic>> optimizeWorkoutFolder(String folderId) async {
    try {
      // Get folder details
      final folder = await (_database.select(_database.templateFolders)
            ..where((f) => f.id.equals(folderId)))
          .getSingleOrNull();

      if (folder == null) {
        throw Exception('Folder not found');
      }

      // Get all templates in this folder
      final templates = await (_database.select(_database.workoutTemplates)
            ..where((t) => t.folderId.equals(folderId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

      if (templates.isEmpty) {
        throw Exception('No templates found in this folder');
      }

      // Build comprehensive folder data with all template details
      final folderData = <Map<String, dynamic>>[];
      
      for (final template in templates) {
        // Get exercise details for each template
        final exerciseDetails = <Map<String, dynamic>>[];
        
        for (final exerciseId in template.exerciseIds) {
          final exercise = await (_database.select(_database.exercises)
                ..where((e) => e.id.equals(exerciseId)))
              .getSingleOrNull();

          if (exercise != null) {
            exerciseDetails.add({
              'id': exercise.id,
              'name': exercise.name,
              'exerciseType': exercise.exerciseType,
              'primaryMuscleGroup': exercise.primaryMuscleGroup,
              'secondaryMuscleGroups': exercise.secondaryMuscleGroups,
              'equipment': exercise.equipment,
              'instructions': exercise.instructions,
              'tags': exercise.tags,
              'isBodyweight': exercise.isBodyweight,
              'category': exercise.category,
              'difficulty': exercise.difficulty,
              'variantType': exercise.variantType,
            });
          }
        }

        folderData.add({
          'id': template.id,
          'name': template.name,
          'description': template.description,
          'category': template.category,
          'estimatedDurationMinutes': template.estimatedDurationMinutes,
          'tags': template.tags,
          'exerciseIds': template.exerciseIds,
          'exercises': exerciseDetails,
        });
      }

      final folderPayload = {
        'folder': {
          'id': folder.id,
          'name': folder.name,
          'description': folder.description,
          'color': folder.color,
          'templates': folderData,
        }
      };

      final userPrompt = '''Optimise my routine based on this folder structure:

${jsonEncode(folderPayload)}

Provide optimized versions of all templates with clear explanations of improvements.''';

      final response = await _groqService.chatJson(
        prompt: userPrompt,
        systemPrompt: AIPrompts.SYSTEM_PROMPT_OPTIMIZE_ROUTINE,
      );

      // Validate and parse JSON response
      try {
        // Clean the response string more thoroughly
        String cleanResponse = response.trim();
        
        // Remove markdown code blocks
        if (cleanResponse.startsWith('```json')) {
          cleanResponse = cleanResponse.replaceFirst('```json', '').replaceAll('```', '').trim();
        }
        if (cleanResponse.startsWith('```')) {
          cleanResponse = cleanResponse.replaceFirst('```', '').replaceAll('```', '').trim();
        }
        
        // Remove any leading/trailing text that's not JSON
        final jsonStart = cleanResponse.indexOf('{');
        final jsonEnd = cleanResponse.lastIndexOf('}');
        
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          cleanResponse = cleanResponse.substring(jsonStart, jsonEnd + 1);
        }
        
        print('Cleaned JSON response: ${cleanResponse.substring(0, cleanResponse.length > 200 ? 200 : cleanResponse.length)}...');
        
        final jsonData = jsonDecode(cleanResponse) as Map<String, dynamic>;
        
        // Validate required fields
        if (!jsonData.containsKey('folder') || !jsonData['folder'].containsKey('templates')) {
          print('Missing required fields. Available keys: ${jsonData.keys.toList()}');
          throw Exception('Invalid JSON structure: missing required fields');
        }
        
        return jsonData;
      } catch (jsonError) {
        print('JSON Parse Error: $jsonError');
        print('Raw Response Length: ${response.length}');
        print('Raw Response (first 500 chars): ${response.substring(0, response.length > 500 ? 500 : response.length)}');
        print('Cleaned Response (first 500 chars): ${cleanResponse.substring(0, cleanResponse.length > 500 ? 500 : cleanResponse.length)}');
        throw Exception('Failed to parse AI response. The AI may have returned invalid JSON. Please try again.');
      }
    } catch (e) {
      throw Exception('Failed to optimize workout folder: $e');
    }
  }
}
