import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Conditional import for web storage service
import '../services/web_storage_service.dart'
    if (dart.library.io) '../services/mobile_storage_stub.dart';

/// Provider for web storage service
final webStorageServiceProvider = Provider<WebStorageService?>((ref) {
  if (kIsWeb && WebStorageService.isSupported) {
    return WebStorageService();
  }
  return null;
});

/// Provider for checking if web storage is available
final webStorageAvailableProvider = Provider<bool>((ref) {
  return kIsWeb && WebStorageService.isSupported;
});

/// Provider for storage information
final storageInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  if (!kIsWeb || !WebStorageService.isSupported) {
    return {'supported': false, 'platform': 'non-web'};
  }
  return WebStorageService.getStorageInfo();
});

/// State notifier for managing web storage operations
class WebStorageNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  WebStorageNotifier() : super(const AsyncValue.loading()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      if (!kIsWeb || !WebStorageService.isSupported) {
        state = const AsyncValue.data({'supported': false});
        return;
      }

      // Initialize default data if needed
      await WebStorageService.initializeDefaultData();

      // Load current storage info
      final info = WebStorageService.getStorageInfo();
      state = AsyncValue.data(info);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Save workout session to storage
  Future<bool> saveWorkoutSession(Map<String, dynamic> session) async {
    if (!kIsWeb || !WebStorageService.isSupported) return false;

    try {
      final sessions = await WebStorageService.getWorkoutSessions();
      sessions.add(session);
      final success = await WebStorageService.saveWorkoutSessions(sessions);

      if (success) {
        // Update storage info
        final info = WebStorageService.getStorageInfo();
        state = AsyncValue.data(info);
      }

      return success;
    } catch (e) {
      debugPrint('Error saving workout session: $e');
      return false;
    }
  }

  /// Save custom exercise to storage
  Future<bool> saveCustomExercise(Map<String, dynamic> exercise) async {
    if (!kIsWeb || !WebStorageService.isSupported) return false;

    try {
      final exercises = await WebStorageService.getExercises();

      // Check if exercise already exists and update, or add new
      final existingIndex =
          exercises.indexWhere((e) => e['id'] == exercise['id']);
      if (existingIndex >= 0) {
        exercises[existingIndex] = exercise;
      } else {
        exercises.add(exercise);
      }

      final success = await WebStorageService.saveExercises(exercises);

      if (success) {
        final info = WebStorageService.getStorageInfo();
        state = AsyncValue.data(info);
      }

      return success;
    } catch (e) {
      debugPrint('Error saving exercise: $e');
      return false;
    }
  }

  /// Save workout template to storage
  Future<bool> saveTemplate(Map<String, dynamic> template) async {
    if (!kIsWeb || !WebStorageService.isSupported) return false;

    try {
      final templates = await WebStorageService.getTemplates();

      // Check if template already exists and update, or add new
      final existingIndex =
          templates.indexWhere((t) => t['id'] == template['id']);
      if (existingIndex >= 0) {
        templates[existingIndex] = template;
      } else {
        templates.add(template);
      }

      final success = await WebStorageService.saveTemplates(templates);

      if (success) {
        final info = WebStorageService.getStorageInfo();
        state = AsyncValue.data(info);
      }

      return success;
    } catch (e) {
      debugPrint('Error saving template: $e');
      return false;
    }
  }

  /// Update user preferences
  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    if (!kIsWeb || !WebStorageService.isSupported) return false;

    try {
      final currentPrefs = await WebStorageService.getUserPreferences();
      final updatedPrefs = {...currentPrefs, ...preferences};

      final success = await WebStorageService.saveUserPreferences(updatedPrefs);

      if (success) {
        final info = WebStorageService.getStorageInfo();
        state = AsyncValue.data(info);
      }

      return success;
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      return false;
    }
  }

  /// Clear all storage data
  Future<bool> clearAllData() async {
    if (!kIsWeb || !WebStorageService.isSupported) return false;

    try {
      final success = await WebStorageService.clearAll();

      if (success) {
        // Reinitialize with default data
        await WebStorageService.initializeDefaultData();
        final info = WebStorageService.getStorageInfo();
        state = AsyncValue.data(info);
      }

      return success;
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      return false;
    }
  }

  /// Export all data
  Future<Map<String, dynamic>?> exportData() async {
    if (!kIsWeb || !WebStorageService.isSupported) return null;

    try {
      return await WebStorageService.exportAllData();
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return null;
    }
  }

  /// Import data
  Future<bool> importData(Map<String, dynamic> data) async {
    if (!kIsWeb || !WebStorageService.isSupported) return false;

    try {
      final success = await WebStorageService.importData(data);

      if (success) {
        final info = WebStorageService.getStorageInfo();
        state = AsyncValue.data(info);
      }

      return success;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  /// Refresh storage info
  Future<void> refresh() async {
    await _loadInitialData();
  }
}

/// Provider for web storage state management
final webStorageProvider =
    StateNotifierProvider<WebStorageNotifier, AsyncValue<Map<String, dynamic>>>(
        (ref) {
  return WebStorageNotifier();
});

/// Provider for workout sessions from web storage
final webWorkoutSessionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  if (!kIsWeb || !WebStorageService.isSupported) return [];
  return WebStorageService.getWorkoutSessions();
});

/// Provider for exercises from web storage
final webExercisesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  if (!kIsWeb || !WebStorageService.isSupported) return [];
  return WebStorageService.getExercises();
});

/// Provider for templates from web storage
final webTemplatesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  if (!kIsWeb || !WebStorageService.isSupported) return [];
  return WebStorageService.getTemplates();
});

/// Provider for user preferences from web storage
final webUserPreferencesProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  if (!kIsWeb || !WebStorageService.isSupported) return {};
  return WebStorageService.getUserPreferences();
});

/// Provider for personal records from web storage
final webPersonalRecordsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  if (!kIsWeb || !WebStorageService.isSupported) return [];
  return WebStorageService.getPersonalRecords();
});
