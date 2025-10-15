import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/user_context_service.dart';

// Provider for all workout templates grouped by category (with cloud sync)
final workoutTemplatesProvider =
    FutureProvider<Map<String, List<WorkoutTemplate>>>((ref) async {
  final database = ref.read(databaseProvider);
  final supabase = ref.read(supabaseClientProvider);

  if (database == null) {
    return _getDefaultTemplatesByCategory();
  }

  // 🌩️ SYNC: Fetch templates from Supabase
  try {
    final user = supabase.auth.currentUser;
    if (user != null) {
      print('☁️ Fetching templates from Supabase...');

      final cloudTemplates = await supabase
          .from('workout_templates')
          .select()
          .eq('user_id', user.id)
          .order('sort_order')
          .order('name');

      // Merge cloud templates into local database
      for (final template in cloudTemplates) {
        try {
          await database.into(database.workoutTemplates).insertOnConflictUpdate(
                WorkoutTemplate(
                  id: template['id'],
                  userId: UserContextService.instance
                      .getCurrentUserId(), // ✅ USER ISOLATION
                  name: template['name'],
                  description: template['description'],
                  category: template['folder_id'] ?? 'Custom',
                  sortOrder:
                      template['sort_order'] ?? 0, // Use cloud sort order
                  exerciseIds:
                      List<String>.from(template['exercise_ids'] ?? []),
                  tags: const [],
                  isDefault: false,
                  createdAt: template['created_at'] != null
                      ? DateTime.parse(template['created_at'])
                      : DateTime.now(),
                  updatedAt: template['updated_at'] != null
                      ? DateTime.parse(template['updated_at'])
                      : DateTime.now(),
                ),
              );
        } catch (e) {
          print('⚠️ Error syncing template ${template['id']}: $e');
        }
      }

      print('✅ Synced ${cloudTemplates.length} templates from cloud');
    }
  } catch (e) {
    print('⚠️ Template sync failed, using local data: $e');
  }

  final templates = await (database.select(database.workoutTemplates)
        ..orderBy([
          (tbl) => OrderingTerm.asc(tbl.category),
          (tbl) => OrderingTerm.asc(tbl.sortOrder),
          (tbl) => OrderingTerm.asc(tbl.name),
        ]))
      .get();

  // Group templates by category
  final groupedTemplates = <String, List<WorkoutTemplate>>{};
  for (final template in templates) {
    final category = template.category;
    if (!groupedTemplates.containsKey(category)) {
      groupedTemplates[category] = [];
    }
    groupedTemplates[category]!.add(template);
  }

  // Add default templates if no templates exist
  if (groupedTemplates.isEmpty) {
    return _getDefaultTemplatesByCategory();
  }

  return groupedTemplates;
});

// Provider for templates in a specific category
final templatesByCategoryProvider =
    FutureProvider.family<List<WorkoutTemplate>, String>((ref, category) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return _getDefaultTemplates().where((t) => t.category == category).toList();
  }

  final templates = await (database.select(database.workoutTemplates)
        ..where((tbl) => tbl.category.equals(category))
        ..orderBy([
          (tbl) => OrderingTerm.asc(tbl.sortOrder),
          (tbl) => OrderingTerm.asc(tbl.name),
        ]))
      .get();

  return templates;
});

// Provider for template categories
final templateCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [
      'Push Pull Legs',
      'Full Body',
      'Upper Lower',
      'PHUL',
      'Strength',
      'Bodybuilding',
      'Custom',
    ];
  }

  final results = await database
      .customSelect(
        'SELECT DISTINCT category FROM workout_templates ORDER BY category',
      )
      .get();

  final categories =
      results.map((row) => row.read<String>('category')).toList();

  // Add default categories if none exist
  if (categories.isEmpty) {
    return [
      'Push Pull Legs',
      'Full Body',
      'Upper Lower',
      'PHUL',
      'Strength',
      'Bodybuilding',
      'Custom',
    ];
  }

  return categories;
});

// Template management actions
final templateActionsProvider = Provider<TemplateActions>(
  (ref) => TemplateActions(
    ref.read(databaseProvider),
    ref.read(supabaseClientProvider),
  ),
);

class TemplateActions {
  TemplateActions(this._database, this._supabase);

  final AppDatabase? _database;
  final SupabaseClient _supabase;

  Future<bool> createTemplate(WorkoutTemplate template) async {
    if (_database == null) return false;

    try {
      // Save to local database
      await _database!.into(_database!.workoutTemplates).insert(template);

      // 🌩️ Sync to Supabase
      try {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          await _supabase.from('workout_templates').insert({
            'id': template.id,
            'user_id': user.id,
            'name': template.name,
            'description': template.description,
            'exercise_ids': template.exerciseIds,
            'created_at': template.createdAt.toIso8601String(),
            'updated_at': template.updatedAt.toIso8601String(),
          });
          print('✅ Template synced to Supabase');
        }
      } catch (syncError) {
        print('⚠️ Template cloud sync failed: $syncError');
        // Don't fail the operation if sync fails
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTemplate(WorkoutTemplate template) async {
    if (_database == null) return false;

    try {
      // Update local database
      await _database!.update(_database!.workoutTemplates).replace(template);

      // 🌩️ Sync to Supabase
      try {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          await _supabase.from('workout_templates').update({
            'name': template.name,
            'description': template.description,
            'exercise_ids': template.exerciseIds,
            'updated_at': template.updatedAt.toIso8601String(),
          }).eq('id', template.id);
          print('✅ Template update synced to Supabase');
        }
      } catch (syncError) {
        print('⚠️ Template update sync failed: $syncError');
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTemplate(String templateId) async {
    if (_database == null) return false;

    try {
      // Delete from local database
      await (_database!.delete(_database!.workoutTemplates)
            ..where((tbl) => tbl.id.equals(templateId)))
          .go();

      // 🌩️ Sync to Supabase
      try {
        await _supabase.from('workout_templates').delete().eq('id', templateId);
        print('✅ Template deletion synced to Supabase');
      } catch (syncError) {
        print('⚠️ Template deletion sync failed: $syncError');
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> duplicateTemplate(String templateId, String newName) async {
    if (_database == null) return false;

    try {
      final original = await (_database!.select(_database!.workoutTemplates)
            ..where((tbl) => tbl.id.equals(templateId)))
          .getSingleOrNull();

      if (original == null) return false;

      final duplicate = WorkoutTemplate(
        id: const Uuid().v4(),
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: newName,
        description: original.description,
        category: original.category,
        sortOrder: original.sortOrder,
        exerciseIds: original.exerciseIds,
        tags: original.tags,
        estimatedDurationMinutes: original.estimatedDurationMinutes,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _database!.into(_database!.workoutTemplates).insert(duplicate);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> moveTemplate(
    String templateId,
    String newCategory,
    int newSortOrder,
  ) async {
    if (_database == null) return false;

    try {
      await (_database!.update(_database!.workoutTemplates)
            ..where((tbl) => tbl.id.equals(templateId)))
          .write(
        WorkoutTemplatesCompanion(
          category: Value(newCategory),
          sortOrder: Value(newSortOrder),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> renameTemplate(String templateId, String newName) async {
    if (_database == null) return false;

    try {
      await (_database!.update(_database!.workoutTemplates)
            ..where((tbl) => tbl.id.equals(templateId)))
          .write(
        WorkoutTemplatesCompanion(
          name: Value(newName),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> initializeDefaultTemplates() async {
    if (_database == null) return false;

    try {
      final templates = _getDefaultTemplates();
      for (final template in templates) {
        await _database!
            .into(_database!.workoutTemplates)
            .insertOnConflictUpdate(template);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reorder templates within a category
  Future<bool> reorderTemplates(
    List<WorkoutTemplate> templates,
    String? category,
  ) async {
    if (_database == null) return false;

    try {
      // Update sortOrder for each template
      for (int i = 0; i < templates.length; i++) {
        final sortValue = category == null ? (i * 2) + 1 : i;
        await (_database!.update(_database!.workoutTemplates)
              ..where((tbl) => tbl.id.equals(templates[i].id)))
            .write(
          WorkoutTemplatesCompanion(
            sortOrder: Value(sortValue),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // 🌩️ Sync to Supabase
        try {
          final user = _supabase.auth.currentUser;
          if (user != null) {
            await _supabase.from('workout_templates').update({
              'sort_order': sortValue,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('id', templates[i].id);
          }
        } catch (syncError) {
          print('⚠️ Template reorder sync failed: $syncError');
        }
      }
      return true;
    } catch (e) {
      print('❌ Template reorder failed: $e');
      return false;
    }
  }

  Future<void> updateTemplateSortOrders(Map<String, int> orders) async {
    if (_database == null || orders.isEmpty) return;

    final now = DateTime.now();
    for (final entry in orders.entries) {
      await (_database!.update(_database!.workoutTemplates)
            ..where((tbl) => tbl.id.equals(entry.key)))
          .write(
        WorkoutTemplatesCompanion(
          sortOrder: Value(entry.value),
          updatedAt: Value(now),
        ),
      );

      try {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          await _supabase.from('workout_templates').update({
            'sort_order': entry.value,
            'updated_at': now.toIso8601String(),
          }).eq('id', entry.key);
        }
      } catch (syncError) {
        print('⚠️ Template sort update sync failed: $syncError');
      }
    }
  }

  /// Reorder folders
  Future<bool> reorderFolders(List<TemplateFolder> folders) async {
    if (_database == null) return false;

    try {
      // Update sortOrder for each folder
      for (int i = 0; i < folders.length; i++) {
        final sortValue = i * 2;
        await (_database!.update(_database!.templateFolders)
              ..where((tbl) => tbl.id.equals(folders[i].id)))
            .write(
          TemplateFoldersCompanion(
            sortOrder: Value(sortValue),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // 🌩️ Sync to Supabase if needed
        try {
          final user = _supabase.auth.currentUser;
          if (user != null) {
            await _supabase.from('template_folders').update({
              'sort_order': sortValue,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('id', folders[i].id);
          }
        } catch (syncError) {
          print('⚠️ Folder reorder sync failed: $syncError');
        }
      }
      return true;
    } catch (e) {
      print('❌ Folder reorder failed: $e');
      return false;
    }
  }
}

// Helper functions for default templates
Map<String, List<WorkoutTemplate>> _getDefaultTemplatesByCategory() {
  final templates = _getDefaultTemplates();
  final grouped = <String, List<WorkoutTemplate>>{};

  for (final template in templates) {
    if (!grouped.containsKey(template.category)) {
      grouped[template.category] = [];
    }
    grouped[template.category]!.add(template);
  }

  return grouped;
}

List<WorkoutTemplate> _getDefaultTemplates() => [
      // Push Pull Legs (3-day, 6-day)
      WorkoutTemplate(
        id: 'ppl_push',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Push Day',
        description: 'Chest, shoulders, and triceps focused workout',
        category: 'Push Pull Legs',
        sortOrder: 1,
        exerciseIds: [
          'bench_press',
          'incline_dumbbell_press',
          'overhead_press',
          'lateral_raises',
          'tricep_dips',
          'close_grip_bench_press',
        ],
        tags: ['chest', 'shoulders', 'triceps', 'push'],
        estimatedDurationMinutes: 75,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'ppl_pull',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Pull Day',
        description: 'Back and biceps focused workout',
        category: 'Push Pull Legs',
        sortOrder: 2,
        exerciseIds: [
          'deadlift',
          'pull_ups',
          'barbell_rows',
          'lat_pulldowns',
          'face_pulls',
          'barbell_curls',
          'hammer_curls',
        ],
        tags: ['back', 'biceps', 'pull'],
        estimatedDurationMinutes: 75,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'ppl_legs',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Leg Day',
        description: 'Lower body and core focused workout',
        category: 'Push Pull Legs',
        sortOrder: 3,
        exerciseIds: [
          'squats',
          'romanian_deadlift',
          'leg_press',
          'leg_curls',
          'calf_raises',
          'walking_lunges',
          'planks',
        ],
        tags: ['legs', 'glutes', 'calves', 'core'],
        estimatedDurationMinutes: 80,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Full Body Programs (2-day, 3-day)
      WorkoutTemplate(
        id: 'full_body_a',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Full Body A',
        description: 'Complete full body workout with compound movements',
        category: 'Full Body',
        sortOrder: 1,
        exerciseIds: [
          'squats',
          'bench_press',
          'barbell_rows',
          'overhead_press',
          'deadlift',
          'planks',
        ],
        tags: ['full_body', 'compound', 'strength'],
        estimatedDurationMinutes: 60,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'full_body_b',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Full Body B',
        description:
            'Alternative full body workout with different exercise selection',
        category: 'Full Body',
        sortOrder: 2,
        exerciseIds: [
          'deadlift',
          'incline_dumbbell_press',
          'pull_ups',
          'dumbbell_shoulder_press',
          'leg_press',
          'dumbbell_curls',
        ],
        tags: ['full_body', 'compound', 'dumbbells'],
        estimatedDurationMinutes: 60,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'full_body_c',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Full Body C',
        description: 'Third variation for full body routine',
        category: 'Full Body',
        sortOrder: 3,
        exerciseIds: [
          'front_squats',
          'dumbbell_bench_press',
          'seated_cable_rows',
          'lateral_raises',
          'romanian_deadlift',
          'tricep_dips',
        ],
        tags: ['full_body', 'variation', 'accessories'],
        estimatedDurationMinutes: 55,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Upper Lower Split (4-day)
      WorkoutTemplate(
        id: 'upper_lower_upper',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Upper Body',
        description: 'Upper body focused workout for upper/lower split',
        category: 'Upper Lower',
        sortOrder: 1,
        exerciseIds: [
          'bench_press',
          'pull_ups',
          'overhead_press',
          'barbell_rows',
          'incline_dumbbell_press',
          'barbell_curls',
          'tricep_dips',
        ],
        tags: ['upper_body', 'chest', 'back', 'shoulders', 'arms'],
        estimatedDurationMinutes: 70,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'upper_lower_lower',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Lower Body',
        description: 'Lower body focused workout for upper/lower split',
        category: 'Upper Lower',
        sortOrder: 2,
        exerciseIds: [
          'squats',
          'romanian_deadlift',
          'leg_press',
          'leg_curls',
          'calf_raises',
          'walking_lunges',
          'planks',
          'leg_extensions',
        ],
        tags: ['lower_body', 'legs', 'glutes', 'calves'],
        estimatedDurationMinutes: 70,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // PHUL (Power Hypertrophy Upper Lower)
      WorkoutTemplate(
        id: 'phul_upper_power',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Upper Power',
        description:
            'Upper body power training with heavy weights and low reps',
        category: 'PHUL',
        sortOrder: 1,
        exerciseIds: [
          'barbell_bench_press',
          'weighted_pull_ups',
          'overhead_press',
          'barbell_rows',
          'close_grip_bench_press',
          'barbell_curls',
        ],
        tags: ['power', 'upper_body', 'strength', 'heavy'],
        estimatedDurationMinutes: 65,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'phul_lower_power',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Lower Power',
        description:
            'Lower body power training with heavy weights and low reps',
        category: 'PHUL',
        sortOrder: 2,
        exerciseIds: [
          'squats',
          'deadlift',
          'front_squats',
          'leg_curls',
          'calf_raises',
        ],
        tags: ['power', 'lower_body', 'strength', 'heavy'],
        estimatedDurationMinutes: 65,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'phul_upper_hypertrophy',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Upper Hypertrophy',
        description:
            'Upper body hypertrophy training with moderate weights and higher reps',
        category: 'PHUL',
        sortOrder: 3,
        exerciseIds: [
          'incline_dumbbell_press',
          'lat_pulldowns',
          'dumbbell_shoulder_press',
          'seated_cable_rows',
          'dumbbell_flyes',
          'lateral_raises',
          'dumbbell_curls',
          'tricep_extensions',
        ],
        tags: ['hypertrophy', 'upper_body', 'volume', 'muscle_building'],
        estimatedDurationMinutes: 80,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'phul_lower_hypertrophy',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Lower Hypertrophy',
        description:
            'Lower body hypertrophy training with moderate weights and higher reps',
        category: 'PHUL',
        sortOrder: 4,
        exerciseIds: [
          'leg_press',
          'romanian_deadlift',
          'leg_extensions',
          'leg_curls',
          'walking_lunges',
          'calf_raises',
          'bulgarian_split_squats',
        ],
        tags: ['hypertrophy', 'lower_body', 'volume', 'muscle_building'],
        estimatedDurationMinutes: 75,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Strength Programs (5/3/1 style)
      WorkoutTemplate(
        id: 'strength_squat_day',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Squat Focus',
        description: 'Strength training focused on squat progression',
        category: 'Strength',
        sortOrder: 1,
        exerciseIds: [
          'squats',
          'front_squats',
          'leg_press',
          'leg_curls',
          'calf_raises',
          'planks',
        ],
        tags: ['strength', 'squat', 'progressive_overload'],
        estimatedDurationMinutes: 60,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'strength_bench_day',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Bench Focus',
        description: 'Strength training focused on bench press progression',
        category: 'Strength',
        sortOrder: 2,
        exerciseIds: [
          'bench_press',
          'incline_bench_press',
          'dumbbell_press',
          'tricep_dips',
          'overhead_press',
        ],
        tags: ['strength', 'bench_press', 'progressive_overload'],
        estimatedDurationMinutes: 55,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'strength_deadlift_day',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Deadlift Focus',
        description: 'Strength training focused on deadlift progression',
        category: 'Strength',
        sortOrder: 3,
        exerciseIds: [
          'deadlift',
          'romanian_deadlift',
          'barbell_rows',
          'pull_ups',
          'barbell_curls',
        ],
        tags: ['strength', 'deadlift', 'progressive_overload'],
        estimatedDurationMinutes: 55,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'strength_press_day',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Press Focus',
        description: 'Strength training focused on overhead press progression',
        category: 'Strength',
        sortOrder: 4,
        exerciseIds: [
          'overhead_press',
          'bench_press',
          'dumbbell_shoulder_press',
          'lateral_raises',
          'tricep_extensions',
        ],
        tags: ['strength', 'overhead_press', 'progressive_overload'],
        estimatedDurationMinutes: 50,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Bodybuilding Programs
      WorkoutTemplate(
        id: 'bb_chest_triceps',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Chest & Triceps',
        description: 'Bodybuilding focused chest and triceps workout',
        category: 'Bodybuilding',
        sortOrder: 1,
        exerciseIds: [
          'bench_press',
          'incline_dumbbell_press',
          'dumbbell_flyes',
          'cable_crossovers',
          'tricep_dips',
          'tricep_extensions',
          'close_grip_bench_press',
        ],
        tags: ['bodybuilding', 'chest', 'triceps', 'isolation'],
        estimatedDurationMinutes: 85,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'bb_back_biceps',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Back & Biceps',
        description: 'Bodybuilding focused back and biceps workout',
        category: 'Bodybuilding',
        sortOrder: 2,
        exerciseIds: [
          'pull_ups',
          'barbell_rows',
          'lat_pulldowns',
          'seated_cable_rows',
          'face_pulls',
          'barbell_curls',
          'hammer_curls',
          'preacher_curls',
        ],
        tags: ['bodybuilding', 'back', 'biceps', 'isolation'],
        estimatedDurationMinutes: 85,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'bb_shoulders',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Shoulders',
        description: 'Bodybuilding focused shoulder workout',
        category: 'Bodybuilding',
        sortOrder: 3,
        exerciseIds: [
          'overhead_press',
          'dumbbell_shoulder_press',
          'lateral_raises',
          'rear_delt_flyes',
          'upright_rows',
          'shrugs',
        ],
        tags: ['bodybuilding', 'shoulders', 'delts', 'isolation'],
        estimatedDurationMinutes: 70,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WorkoutTemplate(
        id: 'bb_legs_glutes',
        userId:
            UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
        name: 'Legs & Glutes',
        description: 'Bodybuilding focused legs and glutes workout',
        category: 'Bodybuilding',
        sortOrder: 4,
        exerciseIds: [
          'squats',
          'leg_press',
          'leg_extensions',
          'leg_curls',
          'romanian_deadlift',
          'hip_thrusts',
          'calf_raises',
          'walking_lunges',
        ],
        tags: ['bodybuilding', 'legs', 'glutes', 'isolation'],
        estimatedDurationMinutes: 90,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
