import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import 'exercise_web_provider.dart';

/// Unified exercise provider that works on both web and mobile
final exercisesUnifiedProvider = FutureProvider<List<dynamic>>((ref) async {
  if (kIsWeb) {
    // Web: Fetch from Supabase
    return ref.watch(exercisesWebProvider.future);
  } else {
    // Mobile: Fetch from local database
    final database = ref.read(databaseProvider);
    if (database == null) return [];

    final currentUserId = ref.read(currentUserProvider)?.id;

    // Use rawQuery to avoid Drift operator issues
    final result = currentUserId != null
        ? await database.customSelect(
            'SELECT * FROM exercises WHERE user_id IS NULL OR user_id = ?',
            variables: [Variable<String>(currentUserId)],
          ).get()
        : await database
            .customSelect(
              'SELECT * FROM exercises WHERE user_id IS NULL',
            )
            .get();

    return result.map((row) => database.exercises.map(row.data)).toList();
  }
});

/// Unified exercise search provider (works on both platforms)
final exerciseSearchUnifiedProvider =
    FutureProvider.family<List<dynamic>, String>((ref, query) async {
  if (kIsWeb) {
    // Web: Fetch from Supabase
    final supabase = ref.watch(supabaseClientProvider);

    if (query.isEmpty) {
      final data = await supabase.from('exercises').select().order('name');
      return List<Map<String, dynamic>>.from(data);
    }

    // Search by name, category, or primary_muscle_group
    final data = await supabase
        .from('exercises')
        .select()
        .or('name.ilike.%$query%,category.ilike.%$query%,primary_muscle_group.ilike.%$query%')
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  } else {
    // Mobile: Use existing provider
    final database = ref.read(databaseProvider);
    if (database == null) return [];

    final currentUserId = ref.read(currentUserProvider)?.id;

    if (query.isEmpty) {
      final result = currentUserId != null
          ? await database.customSelect(
              'SELECT * FROM exercises WHERE user_id IS NULL OR user_id = ?',
              variables: [Variable<String>(currentUserId)],
            ).get()
          : await database
              .customSelect(
                'SELECT * FROM exercises WHERE user_id IS NULL',
              )
              .get();
      return result.map((row) => database.exercises.map(row.data)).toList();
    }

    // Search logic for mobile
    final q = '%${query.toLowerCase()}%';
    final userFilter = currentUserId != null
        ? 'user_id IS NULL OR user_id = ?'
        : 'user_id IS NULL';

    final variables = currentUserId != null
        ? [
            Variable<String>(q),
            Variable<String>(q),
            Variable<String>(q),
            Variable<String>(q),
            Variable<String>(currentUserId)
          ]
        : [
            Variable<String>(q),
            Variable<String>(q),
            Variable<String>(q),
            Variable<String>(q)
          ];

    final rows = await database
        .customSelect(
          'SELECT * FROM exercises WHERE (LOWER(name) LIKE ? OR LOWER(primary_muscle_group) LIKE ? OR (aliases IS NOT NULL AND LOWER(aliases) LIKE ?) OR (tags IS NOT NULL AND LOWER(tags) LIKE ?)) AND ($userFilter) COLLATE NOCASE',
          variables: variables,
        )
        .get();

    return rows.map((r) => database.exercises.map(r.data)).toList();
  }
});

/// Unified exercise categories provider
final exerciseCategoriesUnifiedProvider =
    FutureProvider<List<String>>((ref) async {
  if (kIsWeb) {
    // Web: Fetch from Supabase
    final supabase = ref.watch(supabaseClientProvider);
    final data =
        await supabase.from('exercises').select('category').order('category');

    final categories =
        (data as List).map((e) => e['category'] as String).toSet().toList();

    final capitalizedCategories = categories
        .map((cat) => cat[0].toUpperCase() + cat.substring(1))
        .toList()
      ..sort();

    return ['All', ...capitalizedCategories];
  } else {
    // Mobile: Use existing provider
    final database = ref.read(databaseProvider);
    if (database == null) {
      return ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];
    }

    final exercises = await database.select(database.exercises).get();
    final categories = exercises.map((e) => e.category).toSet().toList();

    final capitalizedCategories = categories
        .map((cat) => cat[0].toUpperCase() + cat.substring(1))
        .toList()
      ..sort();

    return ['All', ...capitalizedCategories];
  }
});

/// Helper to convert web exercise map to Exercise object (for compatibility)
Exercise? mapToExercise(Map<String, dynamic> map) {
  try {
    print('🔍 Mapping exercise: ${map['name']}');

    // Handle equipment array - convert to comma-separated string
    String equipmentStr = '';
    if (map['equipment'] != null && map['equipment'] is List) {
      equipmentStr = (map['equipment'] as List).cast<String>().join(',');
    }

    // Handle secondary muscle groups
    List<String> secondaryMuscles = [];
    if (map['secondary_muscle_groups'] != null &&
        map['secondary_muscle_groups'] is List) {
      secondaryMuscles =
          (map['secondary_muscle_groups'] as List).cast<String>();
    }

    // Handle tags
    List<String> tagsList = [];
    if (map['tags'] != null && map['tags'] is List) {
      tagsList = (map['tags'] as List).cast<String>();
    }

    // Handle aliases
    List<String> aliasesList = [];
    if (map['aliases'] != null && map['aliases'] is List) {
      aliasesList = (map['aliases'] as List).cast<String>();
    }

    final exercise = Exercise(
      id: map['id'] as String? ??
          'unknown_${DateTime.now().millisecondsSinceEpoch}',
      userId: map['user_id'] as String?,
      name: map['name'] as String? ?? 'Unknown Exercise',
      primaryMuscleGroup: map['primary_muscle_group'] as String? ?? 'other',
      secondaryMuscleGroups: secondaryMuscles,
      equipment: equipmentStr,
      instructions: map['instructions'] as String? ?? '',
      tags: tagsList,
      aliases: aliasesList,
      isBodyweight: map['is_bodyweight'] as bool? ?? false,
      exerciseType: map['exercise_type'] as String? ?? 'weight_reps',
      category: map['category'] as String? ?? 'strength',
      difficulty: map['difficulty'] as String? ?? 'intermediate',
      parentExerciseId: map['parent_exercise_id'] as String?,
      variantType: map['variant_type'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );

    print('✅ Mapped exercise: ${exercise.name}');
    return exercise;
  } catch (e, stackTrace) {
    print('❌ Error mapping exercise: $e');
    print('   Stack: $stackTrace');
    print('   Data: $map');
    return null;
  }
}
