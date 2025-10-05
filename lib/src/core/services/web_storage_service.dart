import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Web storage service using localStorage for persistent data storage
/// This service provides a unified interface for storing workout data on web platforms
class WebStorageService {
  static const String _keyPrefix = 'gymai_';
  static const String _workoutSessionsKey = '${_keyPrefix}workout_sessions';
  static const String _exercisesKey = '${_keyPrefix}exercises';
  static const String _templatesKey = '${_keyPrefix}templates';
  static const String _userPreferencesKey = '${_keyPrefix}user_preferences';
  static const String _personalRecordsKey = '${_keyPrefix}personal_records';
  static const String _appMetadataKey = '${_keyPrefix}app_metadata';

  /// Check if localStorage is available
  static bool get isSupported {
    if (!kIsWeb) return false;
    try {
      final storage = html.window.localStorage;
      // Test if we can write to localStorage
      storage['_test'] = 'test';
      storage.remove('_test');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get storage usage information
  static Map<String, dynamic> getStorageInfo() {
    if (!isSupported) return {'supported': false};
    
    final storage = html.window.localStorage;
    int totalSize = 0;
    final keys = <String>[];
    
    // Iterate through localStorage keys
    storage.keys.forEach((key) {
      if (key.startsWith(_keyPrefix)) {
        keys.add(key);
        totalSize += (storage[key]?.length ?? 0);
      }
    });
    
    return {
      'supported': true,
      'totalSize': totalSize,
      'keyCount': keys.length,
      'keys': keys,
      'estimatedMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
    };
  }

  /// Store workout sessions
  static Future<bool> saveWorkoutSessions(List<Map<String, dynamic>> sessions) async {
    return _saveJson(_workoutSessionsKey, sessions);
  }

  /// Retrieve workout sessions
  static Future<List<Map<String, dynamic>>> getWorkoutSessions() async {
    final data = _getJson(_workoutSessionsKey);
    return data is List ? List<Map<String, dynamic>>.from(data) : [];
  }

  /// Store exercises
  static Future<bool> saveExercises(List<Map<String, dynamic>> exercises) async {
    return _saveJson(_exercisesKey, exercises);
  }

  /// Retrieve exercises
  static Future<List<Map<String, dynamic>>> getExercises() async {
    final data = _getJson(_exercisesKey);
    return data is List ? List<Map<String, dynamic>>.from(data) : [];
  }

  /// Store workout templates
  static Future<bool> saveTemplates(List<Map<String, dynamic>> templates) async {
    return _saveJson(_templatesKey, templates);
  }

  /// Retrieve workout templates
  static Future<List<Map<String, dynamic>>> getTemplates() async {
    final data = _getJson(_templatesKey);
    return data is List ? List<Map<String, dynamic>>.from(data) : [];
  }

  /// Store user preferences
  static Future<bool> saveUserPreferences(Map<String, dynamic> preferences) async {
    return _saveJson(_userPreferencesKey, preferences);
  }

  /// Retrieve user preferences
  static Future<Map<String, dynamic>> getUserPreferences() async {
    final data = _getJson(_userPreferencesKey);
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  /// Store personal records
  static Future<bool> savePersonalRecords(List<Map<String, dynamic>> records) async {
    return _saveJson(_personalRecordsKey, records);
  }

  /// Retrieve personal records
  static Future<List<Map<String, dynamic>>> getPersonalRecords() async {
    final data = _getJson(_personalRecordsKey);
    return data is List ? List<Map<String, dynamic>>.from(data) : [];
  }

  /// Store app metadata (last sync, version, etc.)
  static Future<bool> saveAppMetadata(Map<String, dynamic> metadata) async {
    final currentMetadata = await getAppMetadata();
    final updatedMetadata = {
      ...currentMetadata,
      ...metadata,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    return _saveJson(_appMetadataKey, updatedMetadata);
  }

  /// Retrieve app metadata
  static Future<Map<String, dynamic>> getAppMetadata() async {
    final data = _getJson(_appMetadataKey);
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  /// Clear all stored data
  static Future<bool> clearAll() async {
    if (!isSupported) return false;
    
    try {
      final storage = html.window.localStorage;
      final keysToRemove = <String>[];
      
      // Collect keys that start with our prefix
      storage.keys.forEach((key) {
        if (key.startsWith(_keyPrefix)) {
          keysToRemove.add(key);
        }
      });
      
      // Remove collected keys
      for (final key in keysToRemove) {
        storage.remove(key);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error clearing localStorage: $e');
      return false;
    }
  }

  /// Clear specific data type
  static Future<bool> clearDataType(String dataType) async {
    switch (dataType.toLowerCase()) {
      case 'workouts':
        return _removeKey(_workoutSessionsKey);
      case 'exercises':
        return _removeKey(_exercisesKey);
      case 'templates':
        return _removeKey(_templatesKey);
      case 'preferences':
        return _removeKey(_userPreferencesKey);
      case 'records':
        return _removeKey(_personalRecordsKey);
      case 'metadata':
        return _removeKey(_appMetadataKey);
      default:
        return false;
    }
  }

  /// Export all data as JSON
  static Future<Map<String, dynamic>> exportAllData() async {
    if (!isSupported) return {};
    
    return {
      'workoutSessions': await getWorkoutSessions(),
      'exercises': await getExercises(),
      'templates': await getTemplates(),
      'userPreferences': await getUserPreferences(),
      'personalRecords': await getPersonalRecords(),
      'appMetadata': await getAppMetadata(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// Import data from JSON
  static Future<bool> importData(Map<String, dynamic> data) async {
    if (!isSupported) return false;
    
    try {
      // Validate data structure
      if (!_validateImportData(data)) {
        throw ArgumentError('Invalid import data structure');
      }
      
      // Import each data type
      if (data.containsKey('workoutSessions')) {
        await saveWorkoutSessions(List<Map<String, dynamic>>.from(data['workoutSessions']));
      }
      
      if (data.containsKey('exercises')) {
        await saveExercises(List<Map<String, dynamic>>.from(data['exercises']));
      }
      
      if (data.containsKey('templates')) {
        await saveTemplates(List<Map<String, dynamic>>.from(data['templates']));
      }
      
      if (data.containsKey('userPreferences')) {
        await saveUserPreferences(Map<String, dynamic>.from(data['userPreferences']));
      }
      
      if (data.containsKey('personalRecords')) {
        await savePersonalRecords(List<Map<String, dynamic>>.from(data['personalRecords']));
      }
      
      // Update metadata with import info
      await saveAppMetadata({
        'lastImport': DateTime.now().toIso8601String(),
        'importVersion': data['version'] ?? 'unknown',
      });
      
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  /// Initialize default data
  static Future<void> initializeDefaultData() async {
    if (!isSupported) return;
    
    // Check if data already exists
    final metadata = await getAppMetadata();
    if (metadata.containsKey('initialized')) return;
    
    // Default exercises
    const defaultExercises = [
      {
        'id': 'bench_press',
        'name': 'Bench Press',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['shoulders', 'triceps'],
        'equipment': 'barbell',
        'instructions': 'Lie on bench, lower bar to chest, press up',
        'tags': ['compound', 'upper_body'],
        'isBodyweight': false,
        'createdAt': '2025-10-05T00:00:00.000Z',
      },
      {
        'id': 'squat',
        'name': 'Back Squat',
        'primaryMuscleGroup': 'legs',
        'secondaryMuscleGroups': ['glutes', 'core'],
        'equipment': 'barbell',
        'instructions': 'Stand with feet shoulder-width apart, squat down keeping chest up',
        'tags': ['compound', 'lower_body'],
        'isBodyweight': false,
        'createdAt': '2025-10-05T00:00:00.000Z',
      },
      {
        'id': 'deadlift',
        'name': 'Deadlift',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['legs', 'glutes', 'core'],
        'equipment': 'barbell',
        'instructions': 'Stand over bar, grip and lift keeping back straight',
        'tags': ['compound', 'full_body'],
        'isBodyweight': false,
        'createdAt': '2025-10-05T00:00:00.000Z',
      },
    ];
    
    // Default templates
    const defaultTemplates = [
      {
        'id': 'push_day',
        'name': 'Push Day',
        'description': 'Chest, shoulders, and triceps workout',
        'exerciseIds': ['bench_press'],
        'tags': ['push', 'upper_body'],
        'estimatedDurationMinutes': 60, // Using reasonable default since we need const here
        'isDefault': true,
        'createdAt': '2025-10-05T00:00:00.000Z',
      },
    ];
    
    // Default preferences from app configuration
    final defaultPreferences = {
      'units': 'metric', // 'metric' or 'imperial'
      'theme': 'dark', // 'light', 'dark', or 'system' - matching new default
      'restTimerDefault': AppConfig.defaultRestTimerSeconds,
      'soundEnabled': true,
      'vibrationsEnabled': true,
      'weekStartsOn': 1, // Monday = 1, Sunday = 0
      'chartWeeksToShow': AppConfig.defaultChartWeeks,
      'chartMonthsToShow': AppConfig.defaultChartMonths,
      'maxWorkoutDurationHours': AppConfig.maxWorkoutDurationHours,
      'maxSetsPerExercise': AppConfig.maxSets,
      'autoSaveInterval': AppConfig.autoSaveIntervalSeconds,
    };
    
    // Save default data
    await saveExercises(defaultExercises);
    await saveTemplates(defaultTemplates);
    await saveUserPreferences(defaultPreferences);
    
    // Mark as initialized
    await saveAppMetadata({
      'initialized': true,
      'initializedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    });
  }

  // Private helper methods
  static bool _saveJson(String key, dynamic data) {
    if (!isSupported) return false;
    
    try {
      final jsonString = jsonEncode(data);
      html.window.localStorage[key] = jsonString;
      return true;
    } catch (e) {
      debugPrint('Error saving to localStorage: $e');
      return false;
    }
  }

  static dynamic _getJson(String key) {
    if (!isSupported) return null;
    
    try {
      final jsonString = html.window.localStorage[key];
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error reading from localStorage: $e');
      return null;
    }
  }

  static bool _removeKey(String key) {
    if (!isSupported) return false;
    
    try {
      html.window.localStorage.remove(key);
      return true;
    } catch (e) {
      debugPrint('Error removing from localStorage: $e');
      return false;
    }
  }

  static bool _validateImportData(Map<String, dynamic> data) {
    // Basic validation - ensure required fields exist and are correct types
    final validKeys = [
      'workoutSessions',
      'exercises', 
      'templates',
      'userPreferences',
      'personalRecords',
      'appMetadata'
    ];
    
    for (final key in data.keys) {
      if (!validKeys.contains(key) && key != 'exportedAt' && key != 'version') {
        return false;
      }
    }
    
    return true;
  }
}