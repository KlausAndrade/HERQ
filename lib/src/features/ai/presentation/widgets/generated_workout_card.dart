import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../workout/presentation/providers/template_providers.dart';

/// Widget to display a generated workout with save and start actions
class GeneratedWorkoutCard extends HookConsumerWidget {
  const GeneratedWorkoutCard({
    super.key,
    required this.workoutData,
    this.onSave,
    this.onStart,
  });

  final Map<String, dynamic> workoutData;
  final VoidCallback? onSave;
  final VoidCallback? onStart;

  /// Safely parse an integer from dynamic value
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = workoutData['name'] as String? ?? 'Generated Workout';
    final description = workoutData['description'] as String? ?? '';
    final estimatedDuration = _parseInt(workoutData['estimatedDuration']) ?? 60;
    final exercises = workoutData['exercises'] as List<dynamic>? ?? [];
    final difficulty = workoutData['difficulty'] as String? ?? 'intermediate';
    final targetMuscleGroups = workoutData['targetMuscleGroups'] as List<dynamic>? ?? [];
    final reasoning = workoutData['reasoning'] as String? ?? '';
    final confidence = (workoutData['confidence'] as num?)?.toDouble() ?? 0.8;

    // Debug: Check if reasoning is present
    print('🔍 GeneratedWorkoutCard - Reasoning: "$reasoning"');
    print('🔍 GeneratedWorkoutCard - Reasoning length: ${reasoning.length}');
    print('🔍 GeneratedWorkoutCard - Reasoning isEmpty: ${reasoning.isEmpty}');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Difficulty tag above title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getDifficultyColor(difficulty)
                    .withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                difficulty.toUpperCase(),
                style: TextStyle(
                  color: _getDifficultyColor(difficulty),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            
            // Title (no truncation)
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Description
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 8),
            
            // Metadata row
            Wrap(
              spacing: 4,
              runSpacing: 2,
              children: [
                _buildMetadataChip(Icons.schedule, '${estimatedDuration}min'),
                _buildMetadataChip(Icons.fitness_center, '${exercises.length} exercises'),
                _buildMetadataChip(Icons.psychology, '${(confidence * 100).round()}% match', Colors.green),
              ],
            ),
            
            // Target muscle groups
            if (targetMuscleGroups.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Target: ${targetMuscleGroups.join(', ')}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Groq reasoning (no truncation)
            if (reasoning.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.psychology, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reasoning,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // All exercises (no hiding)
            Text(
              'Exercises (${exercises.length}):',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            ...exercises.map((exercise) => _buildCompactExerciseItem(context, exercise)),
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _saveAsTemplate(context, ref),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(S.of(context)!.saveAsTemplate, style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _startWorkout(context, ref),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(S.of(context)!.startWorkout, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataChip(IconData icon, String text, [Color? color]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[300])!.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color ?? Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactExerciseItem(BuildContext context, dynamic exercise) {
    final name = exercise['name'] as String? ?? 'Unknown Exercise';
    final sets = exercise['sets'] as List<dynamic>? ?? [];
    final exerciseType = exercise['exerciseType'] as String? ?? 'weightReps';
    final equipmentUsed = exercise['equipmentUsed'] as String? ?? '';
    final restTimerSeconds = _parseInt(exercise['restTimerSeconds']) ?? 0;
    final notes = exercise['notes'] as String? ?? '';

    // Extract weight and reps from the first working set
    String weightRepsInfo = '';
    if (sets.isNotEmpty) {
      final firstSet = sets.first;
      final weight = firstSet['weight'] as num? ?? 0;
      final reps = firstSet['reps'] as num? ?? 0;
      
      if (exerciseType == 'weightReps' && weight > 0) {
        weightRepsInfo = '${weight}kg × ${reps} reps';
      } else if (exerciseType == 'bodyweightReps') {
        weightRepsInfo = '${reps} reps';
      } else if (exerciseType == 'duration') {
        final duration = firstSet['durationSeconds'] as num? ?? 0;
        weightRepsInfo = '${duration}s';
      } else {
        weightRepsInfo = '${reps} reps';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (equipmentUsed.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    equipmentUsed,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (sets.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${sets.length} sets • $weightRepsInfo • ${_formatRestTime(restTimerSeconds)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              notes,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 9,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }


  String _formatRestTime(int seconds) {
    if (seconds == 0) return 'No rest';
    if (seconds < 60) return '${seconds}s rest';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) return '${minutes}m rest';
    return '${minutes}m ${remainingSeconds}s rest';
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Future<void> _saveAsTemplate(BuildContext context, WidgetRef ref) async {
    try {
      // Create a workout template from the generated workout
      final templateId = 'ai_gen_${DateTime.now().millisecondsSinceEpoch}';
      
      // Extract exercise IDs safely
      final exercises = workoutData['exercises'] as List<dynamic>? ?? [];
      print('🔍 _saveAsTemplate - Raw exercises: ${exercises.length}');
      for (int i = 0; i < exercises.length; i++) {
        final exercise = exercises[i];
        print('🔍 Exercise $i: id=${exercise['id']}, name=${exercise['name']}');
      }
      
      final exerciseIds = exercises
          .map((e) => e['id'] as String? ?? e['exerciseId'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      
      print('🔍 _saveAsTemplate - Extracted exerciseIds: $exerciseIds');
      print('🔍 _saveAsTemplate - Unique exerciseIds: ${exerciseIds.toSet().toList()}');
      
      // Ensure unique exercise IDs to prevent duplicates
      final uniqueExerciseIds = exerciseIds.toSet().toList();
      print('🔍 _saveAsTemplate - Using unique exerciseIds: $uniqueExerciseIds');
      
      // Validate that exercise IDs exist in database
      final database = ref.read(databaseProvider);
      if (database != null) {
        final allExercises = await database.select(database.exercises).get();
        final validExerciseIds = <String>[];
        final invalidExerciseIds = <String>[];
        
        for (final exerciseId in uniqueExerciseIds) {
          final exerciseExists = allExercises.any((e) => e.id == exerciseId);
          if (exerciseExists) {
            validExerciseIds.add(exerciseId);
          } else {
            invalidExerciseIds.add(exerciseId);
          }
        }
        
        print('🔍 _saveAsTemplate - Valid exerciseIds: $validExerciseIds');
        print('🔍 _saveAsTemplate - Invalid exerciseIds: $invalidExerciseIds');
        
        if (invalidExerciseIds.isNotEmpty) {
          print('⚠️ _saveAsTemplate - Some exercise IDs from AI do not exist in database!');
        }
        
        // Use only valid exercise IDs
        if (validExerciseIds.isNotEmpty) {
          uniqueExerciseIds.clear();
          uniqueExerciseIds.addAll(validExerciseIds);
          print('🔍 _saveAsTemplate - Using only valid exerciseIds: $uniqueExerciseIds');
        }
      }
      
      final template = WorkoutTemplate(
        id: templateId,
        userId: 'default_user', // TODO: Replace with actual user ID
        name: workoutData['name'] as String? ?? S.of(context)!.aiGeneratedWorkoutCreated,
        description: workoutData['description'] as String? ?? '',
        category: workoutData['category'] as String? ?? S.of(context)!.aiGenerated,
        sortOrder: 0,
        exerciseIds: uniqueExerciseIds,
        tags: ['ai_generated'],
        estimatedDurationMinutes: _parseInt(workoutData['estimatedDuration']) ?? 60,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the template
      final templateActions = ref.read(templateActionsProvider);
      final success = await templateActions.createTemplate(template);

      if (success && context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Template saved successfully!',
              body: 'Your AI-generated workout has been saved as a template.',
            )
            .catchError((_) {});

        onSave?.call();
      } else if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: S.of(context)!.failedToSaveTemplate,
              body: S.of(context)!.pleaseTryAgain,
            )
            .catchError((_) {});
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error saving template: $e',
              body: '',
            )
            .catchError((_) {});
      }
    }
  }

  Future<void> _startWorkout(BuildContext context, WidgetRef ref) async {
    try {
      // Create a workout template first
      final templateId = 'ai_gen_${DateTime.now().millisecondsSinceEpoch}';
      
      // Extract exercise IDs safely
      final exercises = workoutData['exercises'] as List<dynamic>? ?? [];
      print('🔍 _startWorkout - Raw exercises: ${exercises.length}');
      for (int i = 0; i < exercises.length; i++) {
        final exercise = exercises[i];
        print('🔍 Exercise $i: id=${exercise['id']}, name=${exercise['name']}');
      }
      
      final exerciseIds = exercises
          .map((e) => e['id'] as String? ?? e['exerciseId'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      
      print('🔍 _startWorkout - Extracted exerciseIds: $exerciseIds');
      print('🔍 _startWorkout - Unique exerciseIds: ${exerciseIds.toSet().toList()}');
      
      // Ensure unique exercise IDs to prevent duplicates
      final uniqueExerciseIds = exerciseIds.toSet().toList();
      print('🔍 _startWorkout - Using unique exerciseIds: $uniqueExerciseIds');
      
      // Validate that exercise IDs exist in database
      final database = ref.read(databaseProvider);
      if (database != null) {
        final allExercises = await database.select(database.exercises).get();
        final validExerciseIds = <String>[];
        final invalidExerciseIds = <String>[];
        
        for (final exerciseId in uniqueExerciseIds) {
          final exerciseExists = allExercises.any((e) => e.id == exerciseId);
          if (exerciseExists) {
            validExerciseIds.add(exerciseId);
          } else {
            invalidExerciseIds.add(exerciseId);
          }
        }
        
        print('🔍 _startWorkout - Valid exerciseIds: $validExerciseIds');
        print('🔍 _startWorkout - Invalid exerciseIds: $invalidExerciseIds');
        
        if (invalidExerciseIds.isNotEmpty) {
          print('⚠️ _startWorkout - Some exercise IDs from AI do not exist in database!');
        }
        
        // Use only valid exercise IDs
        if (validExerciseIds.isNotEmpty) {
          uniqueExerciseIds.clear();
          uniqueExerciseIds.addAll(validExerciseIds);
          print('🔍 _startWorkout - Using only valid exerciseIds: $uniqueExerciseIds');
        }
      }
      
      final template = WorkoutTemplate(
        id: templateId,
        userId: 'default_user', // TODO: Replace with actual user ID
        name: workoutData['name'] as String? ?? S.of(context)!.aiGeneratedWorkoutCreated,
        description: workoutData['description'] as String? ?? '',
        category: workoutData['category'] as String? ?? S.of(context)!.aiGenerated,
        sortOrder: 0,
        exerciseIds: uniqueExerciseIds,
        tags: ['ai_generated'],
        estimatedDurationMinutes: _parseInt(workoutData['estimatedDuration']) ?? 60,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the template
      final templateActions = ref.read(templateActionsProvider);
      final success = await templateActions.createTemplate(template);

      if (success && context.mounted) {
        print('🔍 _startWorkout - Template created successfully, navigating to active workout');
        print('🔍 _startWorkout - Template ID: $templateId');
        
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: S.of(context)!.startingAiGeneratedWorkout,
              body: '',
            )
            .catchError((_) {});

        // Navigate to active workout
        print('🔍 _startWorkout - Navigating to: /active-workout?templateId=$templateId');
        context.go('/active-workout?templateId=$templateId');
        onStart?.call();
      } else if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: S.of(context)!.failedToStartWorkout,
              body: S.of(context)!.pleaseTryAgain,
            )
            .catchError((_) {});
      }
    } catch (e) {
      print('🔍 _startWorkout - Error occurred: $e');
      print('🔍 _startWorkout - Error type: ${e.runtimeType}');
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error starting workout: $e',
              body: '',
            )
            .catchError((_) {});
      }
    }
  }
}
