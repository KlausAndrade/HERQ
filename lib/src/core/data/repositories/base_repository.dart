import 'package:flutter/foundation.dart';
import '../dto/workout_dto.dart';

/// Base repository interface for workout data operations
///
/// Implementations:
/// - Mobile/Desktop: Uses local Drift database with background sync
/// - Web: Uses Supabase directly (no local database)
abstract class WorkoutRepository {
  /// Watch all workout sessions (sorted by date, newest first)
  Stream<List<WorkoutSessionDto>> watchWorkoutSessions();

  /// Get all workout sessions
  Future<List<WorkoutSessionDto>> getWorkoutSessions();

  /// Get a single workout session by ID
  Future<WorkoutSessionDto?> getWorkoutSessionById(String id);

  /// Create a new workout session
  Future<WorkoutSessionDto> createWorkoutSession(WorkoutSessionDto session);

  /// Update an existing workout session
  Future<void> updateWorkoutSession(WorkoutSessionDto session);

  /// Delete a workout session
  Future<void> deleteWorkoutSession(String id);

  /// Get set entries for a workout session
  Future<List<SetEntryDto>> getSetEntriesBySession(String sessionId);

  /// Watch set entries for a workout session
  Stream<List<SetEntryDto>> watchSetEntriesBySession(String sessionId);

  /// Create a new set entry
  Future<SetEntryDto> createSetEntry(SetEntryDto entry);

  /// Update a set entry
  Future<void> updateSetEntry(SetEntryDto entry);

  /// Delete a set entry
  Future<void> deleteSetEntry(String id);

  /// Get all workout templates
  Future<List<WorkoutTemplateDto>> getWorkoutTemplates();

  /// Watch all workout templates
  Stream<List<WorkoutTemplateDto>> watchWorkoutTemplates();

  /// Get a workout template by ID
  Future<WorkoutTemplateDto?> getWorkoutTemplateById(String id);

  /// Create a new workout template
  Future<WorkoutTemplateDto> createWorkoutTemplate(WorkoutTemplateDto template);

  /// Update a workout template
  Future<void> updateWorkoutTemplate(WorkoutTemplateDto template);

  /// Delete a workout template
  Future<void> deleteWorkoutTemplate(String id);
}

/// Base repository interface for exercise data operations
abstract class ExerciseRepository {
  /// Watch all exercises
  Stream<List<ExerciseDto>> watchExercises();

  /// Get all exercises
  Future<List<ExerciseDto>> getExercises();

  /// Get an exercise by ID
  Future<ExerciseDto?> getExerciseById(String id);

  /// Search exercises by name or muscle group
  Future<List<ExerciseDto>> searchExercises(String query);

  /// Create a custom exercise
  Future<ExerciseDto> createExercise(ExerciseDto exercise);

  /// Update an exercise
  Future<void> updateExercise(ExerciseDto exercise);

  /// Delete a custom exercise
  Future<void> deleteExercise(String id);

  /// Get favorite exercise IDs
  Future<List<String>> getFavoriteExerciseIds();

  /// Add exercise to favorites
  Future<void> addToFavorites(String exerciseId);

  /// Remove exercise from favorites
  Future<void> removeFromFavorites(String exerciseId);
}

/// Platform detection utility
class RepositoryPlatform {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb;
}
