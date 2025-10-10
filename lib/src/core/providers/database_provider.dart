import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import '../database/database.dart' if (dart.library.html) '../database/database_stub.dart';

final databaseProvider = Provider<AppDatabase?>((ref) {
  if (kIsWeb) {
    // Return null for web platform since SQLite is not supported
    return null;
  }

  // Provide an in-memory database by default for tests and environments
  // where the provider isn't explicitly overridden. Tests should still
  // override this provider when they need a specific DB instance, but
  // this default prevents UnimplementedError when a test forgets to.
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  // Close the in-memory DB when the provider is disposed
  ref.onDispose(() async {
    try {
      await db.close();
    } catch (_) {}
  });
  return db;
});
