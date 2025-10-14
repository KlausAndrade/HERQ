import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herq/src/core/database/database.dart';
import 'package:herq/src/core/providers/auth_provider.dart' as auth_provider;
import 'package:herq/src/core/providers/database_provider.dart' as db_provider;

/// Simple test helper that creates an in-memory AppDatabase and returns a
/// ProviderOverride that replaces the `databaseProvider` with the in-memory
/// instance. Use this in widget tests that read the database provider.
List<Override> overrideWithTestProviders() {
  final executor = NativeDatabase.memory();
  final db = AppDatabase.forTesting(executor);

  // For widget tests we usually don't want to initialize Supabase. Instead
  // override the currentUserProvider to `null` so auth/gamification flows
  // short-circuit and do not start background timers.
  return [
    db_provider.databaseProvider.overrideWithValue(db),
    auth_provider.currentUserProvider.overrideWithValue(null),
  ];
}
