import 'dart:async';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database.dart';

/// Service to sync global content (admin exercises/templates) to normal users
class GlobalContentSyncService {
  GlobalContentSyncService(this._supabase, this._db);
  final SupabaseClient _supabase;
  final AppDatabase _db;

  /// Sync global exercises from Supabase to local database
  Future<void> syncGlobalExercises() async {
    try {
      print('🌍 Syncing global exercises from Supabase...');

      // First, let's check if we can access the exercises table
      print('🔍 Checking Supabase connection and permissions...');
      
      // Fetch global exercises from Supabase
      // Note: We'll fetch all exercises since the user_id column may not exist yet
      final globalExercises = await _supabase
          .from('exercises')
          .select()
          .order('name');

      print('📊 Found ${globalExercises.length} exercises in Supabase');
      
      if (globalExercises.isEmpty) {
        print('⚠️ No exercises found in Supabase. Check:');
        print('   1. Are you logged in?');
        print('   2. Do you have read permissions on exercises table?');
        print('   3. Are there actually exercises in the table?');
        return;
      }

      // Show first few exercises for debugging
      print('📋 First few exercises:');
      for (int i = 0; i < (globalExercises.length > 3 ? 3 : globalExercises.length); i++) {
        final exercise = globalExercises[i];
        print('   ${i + 1}. ${exercise['name']} (ID: ${exercise['id']})');
      }

      int syncedCount = 0;
      int errorCount = 0;
      
      for (final exercise in globalExercises) {
        try {
          print('🔄 Syncing exercise: ${exercise['name']}');
          
          // Debug progression relationships
          if (exercise['parent_exercise_id'] != null) {
            print('   📋 Parent: ${exercise['parent_exercise_id']} | Variant: ${exercise['variant_type']}');
          }
          
          // Convert to local format and insert/update
          final companion = ExercisesCompanion.insert(
            id: exercise['id'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
            userId: const Value(null), // Global exercise
            name: exercise['name'] ?? 'Unknown Exercise',
            primaryMuscleGroup: exercise['primary_muscle_group'] ?? 'other',
            secondaryMuscleGroups: _convertToStringList(exercise['secondary_muscle_groups']),
            equipment: _convertToStringList(exercise['equipment']).isNotEmpty 
                ? _convertToStringList(exercise['equipment']).first 
                : 'none',
            instructions: exercise['instructions'] ?? 'No instructions provided',
            tags: _convertToStringList(exercise['tags']),
            aliases: Value(_convertToStringList(exercise['aliases']).isNotEmpty 
                ? _convertToStringList(exercise['aliases'])
                : null),
            isBodyweight: Value(exercise['is_bodyweight'] ?? false),
            exerciseType: Value(exercise['exercise_type'] ?? 'weight_reps'),
            category: Value(exercise['category'] ?? 'strength'),
            parentExerciseId: Value(exercise['parent_exercise_id'] as String?),
            variantType: Value(exercise['variant_type'] as String?),
            difficulty: Value(exercise['difficulty'] ?? 'intermediate'),
            createdAt: Value(exercise['created_at'] != null
                ? DateTime.parse(exercise['created_at'])
                : DateTime.now()),
            updatedAt: Value(exercise['updated_at'] != null
                ? DateTime.parse(exercise['updated_at'])
                : DateTime.now()),
          );

          await _db.into(_db.exercises).insertOnConflictUpdate(companion);
          syncedCount++;
          print('   ✅ Synced successfully');
        } catch (e) {
          errorCount++;
          print('   ❌ Error syncing exercise ${exercise['id']}: $e');
          print('   📋 Exercise data: ${exercise.toString()}');
        }
      }

      print('📊 Sync Summary:');
      print('   ✅ Successfully synced: $syncedCount');
      print('   ❌ Errors: $errorCount');
      print('   📊 Total processed: ${globalExercises.length}');
      
      if (syncedCount > 0) {
        print('✅ Synced $syncedCount global exercises from Supabase');
      } else {
        print('⚠️ No exercises were synced. Check the errors above.');
      }
    } catch (e) {
      print('❌ Error syncing global exercises: $e');
      print('🔍 Debug info:');
      print('   - Supabase client: Available');
      print('   - Database: Available');
      print('   - Error type: ${e.runtimeType}');
      print('   - Error details: $e');
      // Don't throw - sync errors shouldn't break the app
    }
  }

  /// Sync global templates from Supabase to local database
  Future<void> syncGlobalTemplates() async {
    try {
      print('🌍 Syncing global templates from Supabase...');

      // Fetch global templates from Supabase
      // Note: We'll fetch all templates since the user_id column may not exist yet
      final globalTemplates = await _supabase
          .from('workout_templates')
          .select()
          .order('name');

      print('📊 Found ${globalTemplates.length} templates in Supabase');
      
      if (globalTemplates.isEmpty) {
        print('⚠️ No templates found in Supabase. Check:');
        print('   1. Are you logged in?');
        print('   2. Do you have read permissions on workout_templates table?');
        print('   3. Are there actually templates in the table?');
        return;
      }

      // Show first few templates for debugging
      print('📋 First few templates:');
      for (int i = 0; i < (globalTemplates.length > 3 ? 3 : globalTemplates.length); i++) {
        final template = globalTemplates[i];
        print('   ${i + 1}. ${template['name']} (ID: ${template['id']})');
      }

      int syncedCount = 0;
      int errorCount = 0;
      
      for (final template in globalTemplates) {
        try {
          print('🔄 Syncing template: ${template['name']}');
          
          // Convert to local format and insert/update
          final companion = WorkoutTemplatesCompanion.insert(
            id: template['id'] ?? 'unknown_template_${DateTime.now().millisecondsSinceEpoch}',
            userId: const Value('00000000-0000-0000-0000-000000000000'), // System UUID for global templates
            name: template['name'] ?? 'Unknown Template',
            description: Value(template['description']),
            folderId: Value(template['folder_id']),
            exerciseIds: Value(
              List<String>.from(template['exercise_ids'] ?? []),
            ),
            tags: List<String>.from(template['tags'] ?? []),
            category: Value(template['category']),
            estimatedDurationMinutes: Value(template['estimated_duration_minutes']),
            isDefault: Value(template['is_default'] ?? false),
            sortOrder: Value(template['sort_order'] ?? 0),
            createdAt: Value(template['created_at'] != null
                ? DateTime.parse(template['created_at'])
                : DateTime.now()),
            updatedAt: Value(template['updated_at'] != null
                ? DateTime.parse(template['updated_at'])
                : DateTime.now()),
          );

          await _db.into(_db.workoutTemplates).insertOnConflictUpdate(companion);
          syncedCount++;
          print('   ✅ Synced successfully');
        } catch (e) {
          errorCount++;
          print('   ❌ Error syncing template ${template['id']}: $e');
          print('   📋 Template data: ${template.toString()}');
        }
      }

      print('📊 Template Sync Summary:');
      print('   ✅ Successfully synced: $syncedCount');
      print('   ❌ Errors: $errorCount');
      print('   📊 Total processed: ${globalTemplates.length}');
      
      if (syncedCount > 0) {
        print('✅ Synced $syncedCount global templates from Supabase');
      } else {
        print('⚠️ No templates were synced. Check the errors above.');
      }
    } catch (e) {
      print('❌ Error syncing global templates: $e');
      print('🔍 Debug info:');
      print('   - Supabase client: Available');
      print('   - Database: Available');
      print('   - Error type: ${e.runtimeType}');
      print('   - Error details: $e');
      // Don't throw - sync errors shouldn't break the app
    }
  }

  /// Full sync - sync all global content
  Future<void> syncAllGlobalContent() async {
    print('🌍 Starting global content sync...');
    
    try {
      // Add timeout to prevent hanging
      await Future.any([
        _performSync(),
        Future.delayed(const Duration(seconds: 30), () => throw TimeoutException('Sync timeout')),
      ]);
      print('✅ Global content sync completed');
    } catch (e) {
      print('❌ Global content sync failed: $e');
      // Don't rethrow - let the UI handle the error gracefully
    }
  }

  Future<void> _performSync() async {
    await syncGlobalExercises();
    await syncGlobalTemplates();
  }

  /// Check if global content needs updating
  Future<bool> needsGlobalContentUpdate() async {
    try {
      // Get last sync timestamp from local storage
      final lastSync = await _getLastSyncTimestamp();
      if (lastSync == null) return true; // First time sync

      // Check if there are newer exercises
      final newerExercises = await _supabase
          .from('exercises')
          .select('updated_at')
          .gt('updated_at', lastSync.toIso8601String())
          .limit(1);

      if (newerExercises.isNotEmpty) return true;

      // Check if there are newer templates
      final newerTemplates = await _supabase
          .from('workout_templates')
          .select('updated_at')
          .gt('updated_at', lastSync.toIso8601String())
          .limit(1);

      return newerTemplates.isNotEmpty;
    } catch (e) {
      print('⚠️ Error checking global content updates: $e');
      return false; // Don't sync if we can't check
    }
  }

  /// Get last sync timestamp from local storage
  Future<DateTime?> _getLastSyncTimestamp() async {
    try {
      // This would need to be implemented with SharedPreferences
      // For now, return null to always sync
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Helper method to safely convert dynamic arrays to String lists
  List<String> _convertToStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    if (data is String) {
      return [data];
    }
    return [];
  }

}
