import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';

/// Service to sync local SQLite exercises to Supabase
class ExerciseSyncService {
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
          await supabase.from('exercises').upsert({
            'id': exercise.id,
            'user_id': user.id,
            'name': exercise.name,
            'primary_muscle_group': exercise.primaryMuscleGroup,
            'secondary_muscle_groups': exercise.secondaryMuscleGroups,
            'equipment': exercise.equipment.isEmpty ? [] : [exercise.equipment], // Convert string to array
            'instructions': exercise.instructions,
            'tags': exercise.tags,
            'aliases': exercise.aliases,
            'is_bodyweight': exercise.isBodyweight,
            'exercise_type': exercise.exerciseType,
            'category': exercise.category,
            'difficulty': exercise.difficulty,
            'parent_exercise_id': exercise.parentExerciseId,
            'variant_type': exercise.variantType,
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
  static Future<void> syncLocalTemplatesToSupabase(WidgetRef ref) async {
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
          // ✅ Direct mapping - column names now match Supabase exactly!
          await supabase.from('workout_templates').upsert({
            'id': template.id,
            'user_id': user.id,
            'name': template.name,
            'description': template.description,
            'category': template.category,
            'folder_id': template.folderId,
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
  static Future<void> syncLocalFoldersToSupabase(WidgetRef ref) async {
    print('🔄 Starting local folders sync to Supabase...');
    
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
      // Get all folders from local database
      final folders = await database.select(database.templateFolders).get();
      print('📱 Found ${folders.length} folders in local database');
      
      if (folders.isEmpty) {
        print('⚠️ No folders found in local database');
        return;
      }
      
      int syncedCount = 0;
      int failedCount = 0;
      
      // Upload to Supabase
      for (final folder in folders) {
        try {
          // ✅ Direct mapping - column names now match Supabase exactly!
          await supabase.from('template_folders').upsert({
            'id': folder.id,
            'user_id': user.id,
            'name': folder.name,
            'description': folder.description,
            'color': folder.color,
            'is_expanded': folder.isExpanded,
            'sort_order': folder.sortOrder,
            'created_at': folder.createdAt.toIso8601String(),
            'updated_at': folder.updatedAt.toIso8601String(),
          });
          syncedCount++;
          print('✅ Synced folder: ${folder.name}');
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
      print('❌ Folder sync failed: $e');
    }
  }
}
