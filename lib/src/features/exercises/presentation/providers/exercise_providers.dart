import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/global_content_sync_provider.dart';

// Provider for all exercises (global + user's custom exercises)
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return []; // Return empty list for web
  }

  // Check if global content sync is needed and trigger it
  final needsSync = await ref.read(needsGlobalContentSyncProvider.future);
  if (needsSync) {
    print('🌍 Global content updates available, syncing...');
    await ref
        .read(globalContentSyncTriggerProvider.notifier)
        .syncGlobalContent();
  }

  final currentUserId = ref.read(currentUserProvider)?.id;

  // Get global exercises (userId = NULL) + user's custom exercises (userId = currentUserId)
  final exercises =
      await (database.select(database.exercises)..where(
            (tbl) =>
                tbl.userId.isNull() |
                (currentUserId != null
                    ? tbl.userId.equals(currentUserId)
                    : const Constant(false)),
          ))
          .get();

  print(
    'DEBUG: Found ${exercises.length} exercises in database (global + user custom)',
  );
  return exercises;
});

// Provider for exercises filtered by muscle group
final exercisesByMuscleGroupProvider =
    FutureProvider.family<List<Exercise>, String?>((ref, muscleGroup) async {
      final database = ref.read(databaseProvider);
      if (database == null) {
        return []; // Return empty list for web
      }

      final currentUserId = ref.read(currentUserProvider)?.id;

      if (muscleGroup == null || muscleGroup.isEmpty || muscleGroup == 'All') {
        // Get global exercises (userId = NULL) + user's custom exercises (userId = currentUserId)
        return (database.select(database.exercises)..where(
              (tbl) =>
                  tbl.userId.isNull() |
                  (currentUserId != null
                      ? tbl.userId.equals(currentUserId)
                      : const Constant(false)),
            ))
            .get();
      }

      return (database.select(database.exercises)..where(
            (tbl) =>
                tbl.primaryMuscleGroup.equals(muscleGroup.toLowerCase()) &
                (tbl.userId.isNull() |
                    (currentUserId != null
                        ? tbl.userId.equals(currentUserId)
                        : const Constant(false))),
          ))
          .get();
    });

// Provider for searching exercises
final exerciseSearchProvider = FutureProvider.family<List<Exercise>, String>((
  ref,
  query,
) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return []; // Return empty list for web
  }

  final currentUserId = ref.read(currentUserProvider)?.id;

  if (query.isEmpty) {
    // Get global exercises (userId = NULL) + user's custom exercises (userId = currentUserId)
    return (database.select(database.exercises)..where(
          (tbl) =>
              tbl.userId.isNull() |
              (currentUserId != null
                  ? tbl.userId.equals(currentUserId)
                  : const Constant(false)),
        ))
        .get();
  }

  // Use SQL LIKE operator across name, aliases, tags and primary muscle group.
  // aliases and tags are stored as comma-separated strings via StringListConverter.
  final q = '%${query.toLowerCase()}%';

  // Build user filter condition
  final userFilter = currentUserId != null
      ? 'user_id IS NULL OR user_id = ?'
      : 'user_id IS NULL';

  final variables = currentUserId != null
      ? [
          Variable<String>(q),
          Variable<String>(q),
          Variable<String>(q),
          Variable<String>(q),
          Variable<String>(currentUserId),
        ]
      : [
          Variable<String>(q),
          Variable<String>(q),
          Variable<String>(q),
          Variable<String>(q),
        ];

  final rows = await database
      .customSelect(
        'SELECT * FROM exercises WHERE (LOWER(name) LIKE ? OR LOWER(primary_muscle_group) LIKE ? OR (aliases IS NOT NULL AND LOWER(aliases) LIKE ?) OR (tags IS NOT NULL AND LOWER(tags) LIKE ?)) AND ($userFilter) COLLATE NOCASE',
        variables: variables,
      )
      .get();

  // Map rows to Exercise data objects using database mapping
  final results = rows.map((r) => database.exercises.map(r.data)).toList();
  return results;
});

// Provider for a single exercise by ID
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>((
  ref,
  exerciseId,
) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return null; // Return null for web
  }

  final results = await (database.select(
    database.exercises,
  )..where((tbl) => tbl.id.equals(exerciseId))).get();

  return results.isNotEmpty ? results.first : null;
});

// Provider for unique muscle groups (for filter chips)
final muscleGroupsProvider = FutureProvider<List<String>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return ['All', 'Chest', 'Back', 'Legs', 'Shoulders']; // Fallback for web
  }

  final exercises = await database.select(database.exercises).get();
  final muscleGroups = exercises
      .map((e) => e.primaryMuscleGroup)
      .toSet()
      .toList();

  // Capitalize first letter and sort
  final capitalizedGroups =
      muscleGroups
          .map((group) => group[0].toUpperCase() + group.substring(1))
          .toList()
        ..sort();

  return ['All', ...capitalizedGroups];
});

// Provider for exercise categories
final exerciseCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return ['All', 'Strength', 'Calisthenics', 'Yoga', 'Cardio'];
  }

  final exercises = await database.select(database.exercises).get();
  final categories = exercises.map((e) => e.category).toSet().toList();

  final capitalizedCategories =
      categories.map((cat) => cat[0].toUpperCase() + cat.substring(1)).toList()
        ..sort();

  return ['All', ...capitalizedCategories];
});

// Provider for exercise variants by parent exercise ID
final exerciseVariantsProvider = FutureProvider.family<List<Exercise>, String>((
  ref,
  parentId,
) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }

  final variants = await (database.select(
    database.exercises,
  )..where((tbl) => tbl.parentExerciseId.equals(parentId))).get();

  // Sort by difficulty (basic/beginner first, expert last)
  variants.sort((a, b) {
    // Handle both 'basic' and 'beginner' as the same level
    const difficultyOrder = [
      'basic',
      'beginner',
      'intermediate',
      'advanced',
      'expert',
    ];

    // Normalize difficulty names
    String normalizeDifficulty(String difficulty) {
      switch (difficulty.toLowerCase()) {
        case 'basic':
        case 'beginner':
          return 'beginner';
        case 'intermediate':
          return 'intermediate';
        case 'advanced':
          return 'advanced';
        case 'expert':
          return 'expert';
        default:
          return 'intermediate'; // Default fallback
      }
    }

    final aNormalized = normalizeDifficulty(a.difficulty);
    final bNormalized = normalizeDifficulty(b.difficulty);

    final aIndex = difficultyOrder.indexOf(aNormalized);
    final bIndex = difficultyOrder.indexOf(bNormalized);

    // If difficulty not found, put it at the end
    final aIndexSafe = aIndex == -1 ? difficultyOrder.length : aIndex;
    final bIndexSafe = bIndex == -1 ? difficultyOrder.length : bIndex;

    return aIndexSafe.compareTo(bIndexSafe);
  });

  return variants;
});

// Provider for exercise progression chain (parent + all variants)
final exerciseProgressionChainProvider =
    FutureProvider.family<List<Exercise>, String>((ref, exerciseId) async {
      final database = ref.read(databaseProvider);
      if (database == null) {
        return [];
      }

      // Get the exercise
      final exercise = await ref.read(exerciseByIdProvider(exerciseId).future);
      if (exercise == null) return [];

      // Determine if this is a parent or variant
      final parentId = exercise.parentExerciseId ?? exerciseId;

      // Get parent exercise
      final parent = await ref.read(exerciseByIdProvider(parentId).future);
      if (parent == null) return [];

      // Get all variants
      final variants = await ref.read(
        exerciseVariantsProvider(parentId).future,
      );

      // Return parent + variants, sorted by difficulty (basic/beginner first, expert last)
      final allExercises = [parent, ...variants];
      allExercises.sort((a, b) {
        // Handle both 'basic' and 'beginner' as the same level
        const difficultyOrder = [
          'basic',
          'beginner',
          'intermediate',
          'advanced',
          'expert',
        ];

        // Normalize difficulty names
        String normalizeDifficulty(String difficulty) {
          switch (difficulty.toLowerCase()) {
            case 'basic':
            case 'beginner':
              return 'beginner';
            case 'intermediate':
              return 'intermediate';
            case 'advanced':
              return 'advanced';
            case 'expert':
              return 'expert';
            default:
              return 'intermediate'; // Default fallback
          }
        }

        final aNormalized = normalizeDifficulty(a.difficulty);
        final bNormalized = normalizeDifficulty(b.difficulty);

        final aIndex = difficultyOrder.indexOf(aNormalized);
        final bIndex = difficultyOrder.indexOf(bNormalized);

        // If difficulty not found, put it at the end
        final aIndexSafe = aIndex == -1 ? difficultyOrder.length : aIndex;
        final bIndexSafe = bIndex == -1 ? difficultyOrder.length : bIndex;

        return aIndexSafe.compareTo(bIndexSafe);
      });

      return allExercises;
    });

// Provider for exercises filtered by category
final exercisesByCategoryProvider =
    FutureProvider.family<List<Exercise>, String?>((ref, category) async {
      final database = ref.read(databaseProvider);
      if (database == null) {
        return [];
      }

      if (category == null || category.isEmpty || category == 'All') {
        return database.select(database.exercises).get();
      }

      return (database.select(
        database.exercises,
      )..where((tbl) => tbl.category.equals(category.toLowerCase()))).get();
    });

// Provider for parent exercises only (no variants)
final parentExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }

  return (database.select(
    database.exercises,
  )..where((tbl) => tbl.parentExerciseId.isNull())).get();
});

// Provider for exercises grouped by parent (for progression view)
final exerciseProgressionsProvider =
    FutureProvider<Map<Exercise, List<Exercise>>>((ref) async {
      final database = ref.read(databaseProvider);
      if (database == null) {
        return {};
      }

      final parentExercises = await ref.read(parentExercisesProvider.future);
      final progressionsMap = <Exercise, List<Exercise>>{};

      for (final parent in parentExercises) {
        final variants = await ref.read(
          exerciseVariantsProvider(parent.id).future,
        );
        if (variants.isNotEmpty) {
          progressionsMap[parent] = variants;
        }
      }

      return progressionsMap;
    });
