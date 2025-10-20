import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../database/database.dart';

final databaseProvider = Provider<AppDatabase?>((ref) {
  if (kIsWeb) {
    return null;
  }

  // Use production database, not testing database
  final db = AppDatabase();
  ref.onDispose(() async {
    try {
      await db.close();
    } catch (_) {}
  });
  return db;
});
