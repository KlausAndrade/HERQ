import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';

/// Service to sync local SQLite exercises to Supabase
class ExerciseSyncService {
  /// Map variant_type to Supabase allowed values
  /// Allowed: progression, regression, equipment, angle, grip, tempo, range, stability, assisted, strict
  /// 
  /// Note: Position variants (inclined, declined, suspended) are NOT stored in exercises.variant_type.
  /// They are stored in set_entries.variant_type in combined format like "weight_reps:inclined".
  /// This function only handles exercise-level variants.
  static String? _mapVariantType(String? variantType) {
    if (variantType == null || variantType.isEmpty) return null;

    // If it contains ':', it's a combined format (executionType:position) which should not
    // be stored in exercises.variant_type - it's for set_entries.variant_type
    if (variantType.contains(':')) {
      print('⚠️ Combined variant format detected (e.g., "weight_reps:inclined"). This should be in set_entries, not exercises. Setting to null.');
      return null;
    }

    // Map common invalid values to valid ones or null
    const allowedTypes = [
      'progression',
      'regression',
      'equipment',
      'angle',
      'grip',
      'tempo',
      'range',
      'stability',
      'assisted',
      'strict'
    ];

    if (allowedTypes.contains(variantType)) {
      return variantType; // Already valid
    }

    // Map invalid values to closest valid type
    switch (variantType.toLowerCase()) {
      case 'base':
      case 'stance':
      case 'weight':
        return null; // These are base exercises, not variants
      case 'unilateral':
        return 'equipment'; // Map to equipment variation
      case 'inclined':
      case 'declined':
      case 'suspended':
        // Position variants are for set_entries, not exercises
        print('⚠️ Position variant ($variantType) should be in set_entries, not exercises. Setting to null.');
        return null;
      default:
        print('⚠️ Unknown variant_type: $variantType, setting to null');
        return null;
    }
  }

  static Future<void> syncLocalExercisesToSupabase(WidgetRef ref) async {
    print('🔄 Starting local exercises sync to Supabase...');

    final database = ref.read(databaseProvider);
    if (database == null) {
      print('❌ No local database available');
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('❌ No authenticated user');
      return;
    }

    try {
      // Get all exercises from local database
      final exercises = await database.select(database.exercises).get();
      print('📱 Found ${exercises.length} exercises in local database');

      if (exercises.isEmpty) {
        print('⚠️ No exercises found in local database');
        return;
      }

      int syncedCount = 0;
      int failedCount = 0;

      // Upload to Supabase
      for (final exercise in exercises) {
        try {
          // ✅ Direct mapping - column names match, convert equipment string to array
          // Note: user_id set to null for global exercises (visible to everyone)
          // Note: variant_type 'base' is not valid in Supabase, convert to null
          // Note: exercise_type mapping to Supabase allowed values: weight_reps, time, distance, bodyweight
          String mappedExerciseType = exercise.exerciseType;
          if (mappedExerciseType == 'body_weight_reps' ||
              mappedExerciseType == 'bodyweight_reps') {
            mappedExerciseType = 'bodyweight';
          } else if (mappedExerciseType == 'duration' ||
              mappedExerciseType == 'yoga') {
            mappedExerciseType = 'time';
          } else if (mappedExerciseType == 'reps') {
            mappedExerciseType = 'weight_reps';
          }

          // Clean arrays - remove any double-encoded JSON strings
          final cleanTags = exercise.tags;
          final cleanAliases = exercise.aliases;
          final cleanSecondaryMuscles = exercise.secondaryMuscleGroups;

          await supabase.from('exercises').upsert({
            'id': exercise.id,
            'user_id': null, // Global exercises (user_id = null in SQLite)
            'name': exercise.name,
            'primary_muscle_group': exercise.primaryMuscleGroup,
            'secondary_muscle_groups': cleanSecondaryMuscles,
            'equipment': exercise.equipment.isEmpty
                ? []
                : [exercise.equipment], // Convert string to array
            'instructions': exercise.instructions,
            'tags': cleanTags,
            'aliases': cleanAliases,
            'is_bodyweight': exercise.isBodyweight,
            'exercise_type':
                mappedExerciseType, // Mapped to valid Supabase values
            'category': exercise.category,
            'difficulty': exercise.difficulty,
            'parent_exercise_id': exercise.parentExerciseId,
            // Map variant_type: only specific values allowed in Supabase
            // Allowed: progression, regression, equipment, angle, grip, tempo, range, stability, assisted, strict
            'variant_type':
                _mapVariantType(exercise.variantType), // Map or null if invalid
            'created_at': exercise.createdAt.toIso8601String(),
            'updated_at': exercise.updatedAt.toIso8601String(),
          });
          syncedCount++;
          print('✅ Synced: ${exercise.name}');
        } catch (e) {
          failedCount++;
          print('❌ Failed to sync ${exercise.name}: $e');
        }
      }

      print('🎉 Sync completed!');
      print('✅ Successfully synced: $syncedCount exercises');
      if (failedCount > 0) {
        print('❌ Failed to sync: $failedCount exercises');
      }
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }

  /// Sync local templates to Supabase
  /// folderIdMap: Map of SQLite folder ID → Supabase UUID (from folder sync)
  static Future<void> syncLocalTemplatesToSupabase(
    WidgetRef ref, {
    Map<String, String>? folderIdMap,
  }) async {
    print('🔄 Starting local templates sync to Supabase...');

    final database = ref.read(databaseProvider);
    if (database == null) {
      print('❌ No local database available');
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('❌ No authenticated user');
      return;
    }

    try {
      // Get all templates from local database
      final templates = await database.select(database.workoutTemplates).get();
      print('📱 Found ${templates.length} templates in local database');

      if (templates.isEmpty) {
        print('⚠️ No templates found in local database');
        return;
      }

      int syncedCount = 0;
      int failedCount = 0;

      // Upload to Supabase
      for (final template in templates) {
        try {
          // Map folder_id from SQLite string to Supabase UUID
          String? mappedFolderId;
          if (template.folderId != null && template.folderId!.isNotEmpty) {
            mappedFolderId = folderIdMap?[template.folderId];
            if (mappedFolderId == null) {
              print(
                  '⚠️ No folder mapping for ${template.folderId}, template will have no folder');
            }
          }

          // Insert template (let Supabase generate UUID)
          await supabase.from('workout_templates').insert({
            'user_id': user.id,
            'name': template.name,
            'description': template.description,
            'category': template.category,
            'folder_id': mappedFolderId,
            'exercise_ids': template.exerciseIds,
            'estimated_duration': template.estimatedDurationMinutes,
            'sort_order': template.sortOrder,
            'tags': template.tags,
            'is_default': template.isDefault,
            'created_at': template.createdAt.toIso8601String(),
            'updated_at': template.updatedAt.toIso8601String(),
          });
          syncedCount++;
          print('✅ Synced template: ${template.name}');
        } catch (e) {
          failedCount++;
          print('❌ Failed to sync template ${template.name}: $e');
        }
      }

      print('🎉 Template sync completed!');
      print('✅ Successfully synced: $syncedCount templates');
      if (failedCount > 0) {
        print('❌ Failed to sync: $failedCount templates');
      }
    } catch (e) {
      print('❌ Template sync failed: $e');
    }
  }

  /// Sync local template folders to Supabase
  /// Returns a map of SQLite folder ID → Supabase UUID for template mapping
  static Future<Map<String, String>> syncLocalFoldersToSupabase(
      WidgetRef ref) async {
    print('🔄 Starting local folders sync to Supabase...');

    final folderIdMap = <String, String>{}; // SQLite ID → Supabase UUID

    try {
      final database = ref.read(databaseProvider);
      if (database == null) {
        print('❌ No local database available');
        return folderIdMap;
      }

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('❌ No authenticated user');
        return folderIdMap;
      }

      // Get all folders from local database
      final folders = await database.select(database.templateFolders).get();
      print('📱 Found ${folders.length} folders in local database');

      if (folders.isEmpty) {
        print('⚠️ No folders found in local database');
        return folderIdMap;
      }

      int syncedCount = 0;
      int failedCount = 0;

      // Upload to Supabase (INSERT new folders, let Supabase generate UUIDs)
      for (final folder in folders) {
        try {
          // Insert folder and let Supabase generate UUID
          final response = await supabase
              .from('template_folders')
              .insert({
                'user_id': user.id,
                'name': folder.name,
                'description': folder.description,
                'color': folder.color, // Nullable - will use theme color in UI
                'is_expanded': folder.isExpanded,
                'sort_order': folder.sortOrder,
                'created_at': folder.createdAt.toIso8601String(),
                'updated_at': folder.updatedAt.toIso8601String(),
              })
              .select()
              .single();

          // Map SQLite ID to Supabase UUID
          final supabaseId = response['id'] as String;
          folderIdMap[folder.id] = supabaseId;

          syncedCount++;
          print('✅ Synced folder: ${folder.name} (${folder.id} → $supabaseId)');
        } catch (e) {
          failedCount++;
          print('❌ Failed to sync folder ${folder.name}: $e');
        }
      }

      print('🎉 Folder sync completed!');
      print('✅ Successfully synced: $syncedCount folders');
      if (failedCount > 0) {
        print('❌ Failed to sync: $failedCount folders');
      }
    } catch (e) {
      print('❌ Folder sync failed end: $e');
    }

    return folderIdMap;
  }
}
