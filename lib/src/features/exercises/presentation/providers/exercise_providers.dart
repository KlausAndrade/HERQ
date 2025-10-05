import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';

// Provider for all exercises
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return []; // Return empty list for web
  }
  
  final exercises = await database.select(database.exercises).get();
  print('DEBUG: Found ${exercises.length} exercises in database');
  return exercises;
});

// Provider for exercises filtered by muscle group
final exercisesByMuscleGroupProvider = FutureProvider.family<List<Exercise>, String?>((ref, muscleGroup) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return []; // Return empty list for web
  }
  
  if (muscleGroup == null || muscleGroup.isEmpty || muscleGroup == 'All') {
    return await database.select(database.exercises).get();
  }
  
  return await (database.select(database.exercises)
    ..where((tbl) => tbl.primaryMuscleGroup.equals(muscleGroup.toLowerCase()))).get();
});

// Provider for searching exercises
final exerciseSearchProvider = FutureProvider.family<List<Exercise>, String>((ref, query) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return []; // Return empty list for web
  }
  
  if (query.isEmpty) {
    return await database.select(database.exercises).get();
  }
  
  // Use SQL LIKE operator for text search
  return await (database.select(database.exercises)
    ..where((tbl) => tbl.name.like('%$query%'))).get();
});

// Provider for a single exercise by ID
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>((ref, exerciseId) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return null; // Return null for web
  }
  
  final results = await (database.select(database.exercises)
    ..where((tbl) => tbl.id.equals(exerciseId))).get();
  
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
  final capitalizedGroups = muscleGroups
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
  final categories = exercises
      .map((e) => e.category)
      .toSet()
      .toList();
  
  final capitalizedCategories = categories
      .map((cat) => cat[0].toUpperCase() + cat.substring(1))
      .toList()
    ..sort();
  
  return ['All', ...capitalizedCategories];
});

// Provider for exercise variants by parent exercise ID
final exerciseVariantsProvider = FutureProvider.family<List<Exercise>, String>((ref, parentId) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }
  
  return await (database.select(database.exercises)
    ..where((tbl) => tbl.parentExerciseId.equals(parentId))
    ..orderBy([(tbl) => OrderingTerm(expression: tbl.difficulty)])).get();
});

// Provider for exercise progression chain (parent + all variants)
final exerciseProgressionChainProvider = FutureProvider.family<List<Exercise>, String>((ref, exerciseId) async {
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
  final variants = await ref.read(exerciseVariantsProvider(parentId).future);
  
  // Return parent + variants, sorted by difficulty
  final allExercises = [parent, ...variants];
  allExercises.sort((a, b) {
    const difficultyOrder = ['beginner', 'intermediate', 'advanced', 'expert'];
    final aIndex = difficultyOrder.indexOf(a.difficulty);
    final bIndex = difficultyOrder.indexOf(b.difficulty);
    return aIndex.compareTo(bIndex);
  });
  
  return allExercises;
});

// Provider for exercises filtered by category
final exercisesByCategoryProvider = FutureProvider.family<List<Exercise>, String?>((ref, category) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }
  
  if (category == null || category.isEmpty || category == 'All') {
    return await database.select(database.exercises).get();
  }
  
  return await (database.select(database.exercises)
    ..where((tbl) => tbl.category.equals(category.toLowerCase()))).get();
});

// Provider for parent exercises only (no variants)
final parentExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }
  
  return await (database.select(database.exercises)
    ..where((tbl) => tbl.parentExerciseId.isNull())).get();
});

// Provider for exercises grouped by parent (for progression view)
final exerciseProgressionsProvider = FutureProvider<Map<Exercise, List<Exercise>>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return {};
  }
  
  final parentExercises = await ref.read(parentExercisesProvider.future);
  final progressionsMap = <Exercise, List<Exercise>>{};
  
  for (final parent in parentExercises) {
    final variants = await ref.read(exerciseVariantsProvider(parent.id).future);
    if (variants.isNotEmpty) {
      progressionsMap[parent] = variants;
    }
  }
  
  return progressionsMap;
});