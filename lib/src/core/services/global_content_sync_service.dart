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

      // Fetch global exercises from Supabase
      // Note: We'll fetch all exercises since the user_id column may not exist yet
      final globalExercises = await _supabase
          .from('exercises')
          .select()
          .order('name');

      int syncedCount = 0;
      for (final exercise in globalExercises) {
        try {
          // Convert to local format and insert/update
          final companion = ExercisesCompanion.insert(
            id: exercise['id'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
            userId: const Value(null), // Global exercise
            name: exercise['name'] ?? 'Unknown Exercise',
            primaryMuscleGroup: exercise['primary_muscle_group'] ?? 'other',
            secondaryMuscleGroups: List<String>.from(exercise['secondary_muscle_groups'] ?? []),
            equipment: exercise['equipment'] ?? 'none',
            instructions: exercise['instructions'] ?? 'No instructions provided',
            tags: List<String>.from(exercise['tags'] ?? []),
            aliases: Value(exercise['aliases']),
            isBodyweight: Value(exercise['is_bodyweight'] ?? false),
            exerciseType: Value(exercise['exercise_type'] ?? 'weight_reps'),
            category: Value(exercise['category'] ?? 'strength'),
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
        } catch (e) {
          print('⚠️ Error syncing exercise ${exercise['id']}: $e');
        }
      }

      print('✅ Synced $syncedCount global exercises from Supabase');
    } catch (e) {
      print('❌ Error syncing global exercises: $e');
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

      int syncedCount = 0;
      for (final template in globalTemplates) {
        try {
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
        } catch (e) {
          print('⚠️ Error syncing template ${template['id']}: $e');
        }
      }

      print('✅ Synced $syncedCount global templates from Supabase');
    } catch (e) {
      print('❌ Error syncing global templates: $e');
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

  /// Update last sync timestamp
  Future<void> _updateLastSyncTimestamp() async {
    try {
      // This would need to be implemented with SharedPreferences
      // For now, do nothing
    } catch (e) {
      // Ignore errors
    }
  }
}
