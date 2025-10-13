import 'package:drift/drift.dart';

// Web stub: returns a simple in-memory QueryExecutor that doesn't rely on
// dart:ffi. This is intentionally minimal and some features (like migrations
// or large seeding) are no-ops on web. If your app requires full DB on web,
// consider using sembast or an indexedDB-backed adapter.
QueryExecutor openConnection() => throw UnsupportedError('SQLite is not supported on web in this build.');
