// Stub file for web platform - lightweight AppDatabase facade so code that
// references AppDatabase compiles on web. The app uses Supabase for web and
// typically provides `null` for the `databaseProvider` on web, but some
// test helpers and constructors expect `AppDatabase.forTesting(...)` to exist.

class AppDatabase {
  AppDatabase();

  // Keep the same named constructor to satisfy call sites. on web this
  // returns a minimal in-memory placeholder that throws on SQL operations.
  AppDatabase.forTesting([_]) {
    // no-op
  }

  Future<void> close() async {
    // no-op on web
  }

  Future<void> seedDefaultData() async {
    // no-op on web
  }
}
