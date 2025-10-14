/// Mobile storage stub that replaces web storage service on mobile platforms
/// This provides empty implementations for web-specific functionality
class WebStorageService {
  /// Check if localStorage is available (always false on mobile)
  static bool get isSupported => false;

  /// Initialize the storage service (no-op on mobile)
  static Future<void> initialize() async {
    // No initialization needed on mobile
  }

  /// Initialize default data (no-op on mobile)
  static Future<void> initializeDefaultData() async {
    // No initialization needed on mobile
  }

  /// Clear all stored data (no-op on mobile)
  static Future<bool> clear() async => true;

  /// Clear all stored data (alias for clear)
  static Future<bool> clearAll() async => true;

  /// Get total storage usage (always 0 on mobile)
  static Future<int> getStorageUsage() async => 0;

  /// Get storage quota (always 0 on mobile)
  static Future<int> getStorageQuota() async => 0;

  /// Get storage info (always empty on mobile)
  static Map<String, dynamic> getStorageInfo() =>
      {'supported': false, 'platform': 'mobile'};

  /// Get workout sessions (always empty on mobile)
  static Future<List<Map<String, dynamic>>> getWorkoutSessions() async => [];

  /// Save workout sessions (no-op on mobile)
  static Future<bool> saveWorkoutSessions(
          List<Map<String, dynamic>> sessions) async =>
      true;

  /// Get exercises (always empty on mobile)
  static Future<List<Map<String, dynamic>>> getExercises() async => [];

  /// Save exercises (no-op on mobile)
  static Future<bool> saveExercises(
          List<Map<String, dynamic>> exercises) async =>
      true;

  /// Get templates (always empty on mobile)
  static Future<List<Map<String, dynamic>>> getTemplates() async => [];

  /// Save templates (no-op on mobile)
  static Future<bool> saveTemplates(
          List<Map<String, dynamic>> templates) async =>
      true;

  /// Get user preferences (always empty on mobile)
  static Future<Map<String, dynamic>> getUserPreferences() async => {};

  /// Save user preferences (no-op on mobile)
  static Future<bool> saveUserPreferences(
          Map<String, dynamic> preferences) async =>
      true;

  /// Get personal records (always empty on mobile)
  static Future<List<Map<String, dynamic>>> getPersonalRecords() async => [];

  /// Save personal records (no-op on mobile)
  static Future<bool> savePersonalRecords(
          List<Map<String, dynamic>> records) async =>
      true;

  /// Get app metadata (always empty on mobile)
  static Future<Map<String, dynamic>> getAppMetadata() async => {};

  /// Save app metadata (no-op on mobile)
  static Future<bool> saveAppMetadata(Map<String, dynamic> metadata) async =>
      true;

  /// Export all data (always empty on mobile)
  static Future<Map<String, dynamic>> exportAllData() async => {};

  /// Import data (no-op on mobile)
  static Future<bool> importData(Map<String, dynamic> data) async => true;

  /// Check data integrity (always true on mobile)
  static Future<bool> checkDataIntegrity() async => true;

  /// Backup data (no-op on mobile)
  static Future<bool> backupData() async => true;

  /// Restore from backup (no-op on mobile)
  static Future<bool> restoreFromBackup() async => true;

  /// Migrate data (no-op on mobile)
  static Future<bool> migrateData(String fromVersion, String toVersion) async =>
      true;
}
