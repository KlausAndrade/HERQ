import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide JsonKey;

import '../../../../core/data/dto/workout_dto.dart';
import '../../../../core/database/database.dart' if (dart.library.html) '../../../../core/database/database_stub.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/repository_providers.dart';

/// Platform-aware provider for workout sessions
/// 
/// Mobile: Uses local Drift database
/// Web: Uses Supabase through repository
final workoutSessionsProviderNew = StreamProvider<List<WorkoutSessionDto>>((ref) {
  if (kIsWeb) {
    // Web: Use repository
    final repository = ref.watch(workoutRepositoryProvider);
    if (repository == null) {
      return Stream.value([]);
    }
    return repository.watchWorkoutSessions();
  } else {
    // Mobile: Use database
    final database = ref.watch(databaseProvider);
    if (database == null) {
      return Stream.value([]);
    }

    return (database.select(database.workoutSessions)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
        .watch()
        .map((sessions) => sessions
            .map((session) => WorkoutSessionDto(
                  id: session.id,
                  templateId: session.templateId,
                  name: session.name,
                  notes: session.notes,
                  startedAt: session.startedAt,
                  completedAt: session.completedAt,
                  totalDurationSeconds: session.totalDurationSeconds,
                  totalVolume: session.totalVolume,
                  totalTonnage: session.totalTonnage,
                  totalSets: session.totalSets,
                  totalReps: session.totalReps,
                  createdAt: session.createdAt,
                  updatedAt: session.updatedAt,
                ))
            .toList());
  }
});

/// Platform-aware provider for a single workout session
final workoutSessionByIdProviderNew =
    StreamProvider.family<WorkoutSessionDto?, String>((ref, id) {
  if (kIsWeb) {
    // Web: Use repository
    final repository = ref.watch(workoutRepositoryProvider);
    if (repository == null) {
      return Stream.value(null);
    }
    return Stream.fromFuture(repository.getWorkoutSessionById(id));
  } else {
    // Mobile: Use database
    final database = ref.watch(databaseProvider);
    if (database == null) {
      return Stream.value(null);
    }

    return (database.select(database.workoutSessions)
          ..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull()
        .map((session) => session != null
            ? WorkoutSessionDto(
                id: session.id,
                templateId: session.templateId,
                name: session.name,
                notes: session.notes,
                startedAt: session.startedAt,
                completedAt: session.completedAt,
                totalDurationSeconds: session.totalDurationSeconds,
                totalVolume: session.totalVolume,
                totalTonnage: session.totalTonnage,
                totalSets: session.totalSets,
                totalReps: session.totalReps,
                createdAt: session.createdAt,
                updatedAt: session.updatedAt,
              )
            : null);
  }
});

/// Platform-aware provider for set entries in a workout
final setEntriesBySessionProviderNew =
    StreamProvider.family<List<SetEntryDto>, String>((ref, sessionId) {
  if (kIsWeb) {
    // Web: Use repository
    final repository = ref.watch(workoutRepositoryProvider);
    if (repository == null) {
      return Stream.value([]);
    }
    return repository.watchSetEntriesBySession(sessionId);
  } else {
    // Mobile: Use database
    final database = ref.watch(databaseProvider);
    if (database == null) {
      return Stream.value([]);
    }

    return (database.select(database.setEntries)
          ..where((tbl) => tbl.workoutSessionId.equals(sessionId))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.exerciseId),
            (tbl) => OrderingTerm.asc(tbl.setNumber),
          ]))
        .watch()
        .map((entries) => entries
            .map((entry) => SetEntryDto(
                  id: entry.id,
                  workoutSessionId: entry.workoutSessionId,
                  exerciseId: entry.exerciseId,
                  setNumber: entry.setNumber,
                  weight: entry.weight,
                  reps: entry.reps,
                  durationSeconds: entry.durationSeconds,
                  distance: entry.distance,
                  rpe: entry.rpe,
                  notes: entry.notes,
                  completed: true, // All entries in DB are completed
                  createdAt: entry.createdAt,
                ))
            .toList());
  }
});

/// Platform-aware provider for workout templates
final workoutTemplatesProviderNew = StreamProvider<List<WorkoutTemplateDto>>((ref) {
  if (kIsWeb) {
    // Web: Use repository
    final repository = ref.watch(workoutRepositoryProvider);
    if (repository == null) {
      return Stream.value([]);
    }
    return repository.watchWorkoutTemplates();
  } else {
    // Mobile: Use database
    final database = ref.watch(databaseProvider);
    if (database == null) {
      return Stream.value([]);
    }

    return (database.select(database.workoutTemplates)..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch()
        .map((templates) => templates
            .map((template) => WorkoutTemplateDto(
                  id: template.id,
                  name: template.name,
                  description: template.description,
                  folderId: template.folderId,
                  exerciseIds: (template.exerciseIds as List<dynamic>?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      [],
                  createdAt: template.createdAt,
                  updatedAt: template.updatedAt,
                ))
            .toList());
  }
});

/// Platform-aware provider for exercises
final exercisesProviderNew = StreamProvider<List<ExerciseDto>>((ref) {
  if (kIsWeb) {
    // Web: Use repository
    final repository = ref.watch(exerciseRepositoryProvider);
    if (repository == null) {
      return Stream.value([]);
    }
    return repository.watchExercises();
  } else {
    // Mobile: Use database
    final database = ref.watch(databaseProvider);
    if (database == null) {
      return Stream.value([]);
    }

    return (database.select(database.exercises)..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch()
        .map((exercises) => exercises
            .map((exercise) => ExerciseDto(
                  id: exercise.id,
                  name: exercise.name,
                  description: exercise.instructions, // Use instructions as description
                  primaryMuscleGroup: exercise.primaryMuscleGroup,
                  secondaryMuscleGroups: (exercise.secondaryMuscleGroups as List<dynamic>?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      [],
                  equipmentType: exercise.equipment,
                  category: exercise.category,
                  difficulty: exercise.difficulty,
                  isCustom: exercise.id.startsWith('custom_'), // Custom exercises have IDs starting with 'custom_'
                ))
            .toList());
  }
});
