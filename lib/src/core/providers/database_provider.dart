import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';

final databaseProvider = Provider<AppDatabase?>((ref) {
  if (kIsWeb) {
    // Return null for web platform since SQLite is not supported
    return null;
  }
  throw UnimplementedError('Database provider must be overridden');
});