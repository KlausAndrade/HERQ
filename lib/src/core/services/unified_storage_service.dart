import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../providers/database_provider.dart';
// Conditional import for web storage service
import '../services/web_storage_service.dart' if (dart.library.io) '../services/mobile_storage_stub.dart';

/// Unified storage interface that works across platforms
abstract class UnifiedStorageService {
  Future<List<Map<String, dynamic>>> getWorkoutSessions();
  Future<bool> saveWorkoutSession(Map<String, dynamic> session);
  Future<List<Map<String, dynamic>>> getExercises();
  Future<bool> saveExercise(Map<String, dynamic> exercise);
  Future<List<Map<String, dynamic>>> getTemplates();
  Future<bool> saveTemplate(Map<String, dynamic> template);
  Future<Map<String, dynamic>> getUserPreferences();
  Future<bool> updatePreferences(Map<String, dynamic> preferences);
  Future<bool> clearAllData();
  Future<Map<String, dynamic>?> exportData();
  Future<bool> importData(Map<String, dynamic> data);
}

/// Mobile implementation using Drift database
class MobileStorageService implements UnifiedStorageService {
  final AppDatabase database;
  
  MobileStorageService(this.database);

  @override
  Future<List<Map<String, dynamic>>> getWorkoutSessions() async {
    final sessions = await database.select(database.workoutSessions).get();
    return sessions.map((s) => s.toJson()).toList();
  }

  @override
  Future<bool> saveWorkoutSession(Map<String, dynamic> session) async {
    try {
      // Convert to database companion object and insert
      // This would need proper mapping from Map to WorkoutSessionsCompanion
      return true; // Placeholder
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getExercises() async {
    final exercises = await database.select(database.exercises).get();
    return exercises.map((e) => e.toJson()).toList();
  }

  @override
  Future<bool> saveExercise(Map<String, dynamic> exercise) async {
    try {
      // Convert and insert exercise
      return true; // Placeholder
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTemplates() async {
    final templates = await database.select(database.workoutTemplates).get();
    return templates.map((t) => t.toJson()).toList();
  }

  @override
  Future<bool> saveTemplate(Map<String, dynamic> template) async {
    try {
      // Convert and insert template
      return true; // Placeholder
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('gymai_user_preferences');
      
      if (prefsJson != null) {
        return Map<String, dynamic>.from(jsonDecode(prefsJson));
      }
      
      // Return default preferences if none exist
      return {
        'theme': 'dark', // Match our new default
        'units': 'metric',
        'defaultRestTimer': 120,
        'weekStartsOn': 1,
        'chartWeeksToShow': 12,
        'chartMonthsToShow': 6,
        'maxWorkoutDurationHours': 6,
        'maxSetsPerExercise': 10,
        'autoSaveInterval': 30,
      };
    } catch (e) {
      debugPrint('Error getting user preferences: $e');
      return {};
    }
  }

  @override
  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPrefs = await getUserPreferences();
      final updatedPrefs = {...currentPrefs, ...preferences};
      
      final success = await prefs.setString(
        'gymai_user_preferences', 
        jsonEncode(updatedPrefs)
      );
      
      return success;
    } catch (e) {
      debugPrint('Error updating user preferences: $e');
      return false;
    }
  }

  @override
  Future<bool> clearAllData() async {
    try {
      await database.transaction(() async {
        await database.delete(database.workoutSessions).go();
        await database.delete(database.setEntries).go();
        await database.delete(database.personalRecords).go();
        // Keep default exercises and templates
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> exportData() async {
    try {
      return {
        'workoutSessions': await getWorkoutSessions(),
        'exercises': await getExercises(),
        'templates': await getTemplates(),
        'userPreferences': await getUserPreferences(),
        'exportedAt': DateTime.now().toIso8601String(),
        'platform': 'mobile',
        'version': '1.0.0',
      };
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      // Import data to database
      return true; // Placeholder
    } catch (e) {
      return false;
    }
  }
}

/// Web implementation using localStorage
class WebStorageServiceImpl implements UnifiedStorageService {
  @override
  Future<List<Map<String, dynamic>>> getWorkoutSessions() async {
    return WebStorageService.getWorkoutSessions();
  }

  @override
  Future<bool> saveWorkoutSession(Map<String, dynamic> session) async {
    final sessions = await getWorkoutSessions();
    sessions.add(session);
    return WebStorageService.saveWorkoutSessions(sessions);
  }

  @override
  Future<List<Map<String, dynamic>>> getExercises() async {
    return WebStorageService.getExercises();
  }

  @override
  Future<bool> saveExercise(Map<String, dynamic> exercise) async {
    final exercises = await getExercises();
    final existingIndex = exercises.indexWhere((e) => e['id'] == exercise['id']);
    
    if (existingIndex >= 0) {
      exercises[existingIndex] = exercise;
    } else {
      exercises.add(exercise);
    }
    
    return WebStorageService.saveExercises(exercises);
  }

  @override
  Future<List<Map<String, dynamic>>> getTemplates() async {
    return WebStorageService.getTemplates();
  }

  @override
  Future<bool> saveTemplate(Map<String, dynamic> template) async {
    final templates = await getTemplates();
    final existingIndex = templates.indexWhere((t) => t['id'] == template['id']);
    
    if (existingIndex >= 0) {
      templates[existingIndex] = template;
    } else {
      templates.add(template);
    }
    
    return WebStorageService.saveTemplates(templates);
  }

  @override
  Future<Map<String, dynamic>> getUserPreferences() async {
    return WebStorageService.getUserPreferences();
  }

  @override
  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    final currentPrefs = await getUserPreferences();
    final updatedPrefs = {...currentPrefs, ...preferences};
    return WebStorageService.saveUserPreferences(updatedPrefs);
  }

  @override
  Future<bool> clearAllData() async {
    final success = await WebStorageService.clearAll();
    if (success) {
      await WebStorageService.initializeDefaultData();
    }
    return success;
  }

  @override
  Future<Map<String, dynamic>?> exportData() async {
    return WebStorageService.exportAllData();
  }

  @override
  Future<bool> importData(Map<String, dynamic> data) async {
    return WebStorageService.importData(data);
  }
}

/// Provider for unified storage service
final unifiedStorageProvider = Provider<UnifiedStorageService>((ref) {
  if (kIsWeb) {
    return WebStorageServiceImpl();
  } else {
    final database = ref.watch(databaseProvider);
    if (database != null) {
      return MobileStorageService(database);
    }
    throw StateError('Database not available on mobile platform');
  }
});

/// Helper extension for easy data access
extension UnifiedStorageHelper on WidgetRef {
  UnifiedStorageService get storage => read(unifiedStorageProvider);
  
  Future<List<Map<String, dynamic>>> getWorkouts() => storage.getWorkoutSessions();
  Future<List<Map<String, dynamic>>> getExercises() => storage.getExercises();
  Future<List<Map<String, dynamic>>> getTemplates() => storage.getTemplates();
  Future<Map<String, dynamic>> getPreferences() => storage.getUserPreferences();
}