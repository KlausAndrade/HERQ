import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/workout_sync_service.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

/// Provider for the workout sync service
final workoutSyncServiceProvider = Provider<WorkoutSyncService?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final db = ref.watch(databaseProvider);
  
  if (db == null) return null;
  
  return WorkoutSyncService(supabase, db);
});

/// Auto-sync provider - triggers sync when workout is completed
final autoSyncProvider = FutureProvider.family<void, String>((ref, userId) async {
  final syncService = ref.watch(workoutSyncServiceProvider);
  
  if (syncService == null) {
    print('⚠️ Sync service not available, skipping auto-sync');
    return;
  }
  
  print('🔄 Auto-syncing stats for user: $userId');
  await syncService.syncUserStats(userId);
});

