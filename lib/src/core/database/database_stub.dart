// Stub file for web platform - database not available on web
// Web platform uses Supabase directly

class AppDatabase {
  // Stub implementation for web
  AppDatabase();
  
  static AppDatabase forTesting() {
    throw UnsupportedError('Database not available on web platform');
  }
}
