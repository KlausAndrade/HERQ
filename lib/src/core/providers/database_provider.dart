import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../database/database.dart';
import '../database/database_helper_native.dart'
    if (dart.library.html) '../database/database_helper_stub.dart';

final databaseProvider = Provider<AppDatabase?>((ref) {
  if (kIsWeb) {
    return null;
  }

  final executor = createInMemoryExecutor();
  // ignore: unnecessary_null_comparison
  if (executor == null) return null;

  final db = AppDatabase.forTesting(executor);
  ref.onDispose(() async {
    try {
      await db.close();
    } catch (_) {}
  });
  return db;
});
