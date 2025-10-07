/// Database library with conditional exports for cross-platform support
/// 
/// On native platforms (mobile/desktop): Uses SQLite with Drift
/// On web platform: Uses stub (app relies on Supabase directly)
library database;

export 'database/database.dart'
    if (dart.library.html) 'database/database_stub.dart';
