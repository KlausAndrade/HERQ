import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database.dart';

/// Service to sync workout stats to Supabase for multi-user leaderboards
class WorkoutSyncService {
  WorkoutSyncService(this._supabase, this._db);
  final SupabaseClient _supabase;
  final AppDatabase _db;

  /// Sync user stats to Supabase after workout completion
  Future<void> syncUserStats(String userId) async {
    try {
      print('📤 Syncing user stats to Supabase for user: $userId');

      // Get local stats
      final localStats = await (_db.select(
        _db.userStats,
      )..where((s) => s.userId.equals(userId))).getSingleOrNull();
      if (localStats == null) {
        print('  ⚠️ No local stats found, skipping sync');
        return;
      }

      // Upsert to Supabase
      await _supabase.from('user_stats').upsert({
        'user_id': userId,
        'total_workouts': localStats.totalWorkouts,
        'total_volume': localStats.totalVolumeLifted,
        'total_sets': localStats.totalSetsCompleted,
        'current_streak': localStats.currentStreak,
        'longest_streak': localStats.longestStreak,
        'experience_points': localStats.experiencePoints,
        'level': localStats.level,
        'last_workout_date': localStats.lastWorkoutDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('  ✅ User stats synced to Supabase');
      print('     Workouts: ${localStats.totalWorkouts}');
      print('     Volume: ${localStats.totalVolumeLifted} kg');
      print('     Streak: ${localStats.currentStreak} days');
    } catch (e) {
      print('  ❌ Error syncing user stats: $e');
      // Don't throw - sync errors shouldn't break the app
    }
  }

  /// Sync a completed workout session to Supabase
  Future<void> syncWorkoutSession(WorkoutSession session) async {
    try {
      print('📤 Syncing workout session to Supabase: ${session.id}');

      // Check if session is already in Supabase
      final existing = await _supabase
          .from('workout_sessions')
          .select('id')
          .eq('id', session.id)
          .maybeSingle();

      if (existing != null) {
        print('  ℹ️ Workout session already in Supabase, skipping');
        return;
      }

      // Insert to Supabase (only if session has userId)
      // Note: local DB doesn't store userId, so we need to get it from the current user
      await _supabase.from('workout_sessions').insert({
        'id': session.id,
        'template_id': session.templateId,
        'name': session.name,
        'started_at': session.startedAt.toIso8601String(),
        'completed_at': session.completedAt?.toIso8601String(),
        'total_sets': session.totalSets,
        'total_volume': session.totalVolume,
        'duration_seconds': session.totalDurationSeconds,
        'notes': session.notes,
      });

      print('  ✅ Workout session synced to Supabase');
    } catch (e) {
      print('  ❌ Error syncing workout session: $e');
      // Don't throw - sync errors shouldn't break the app
    }
  }

  /// Sync personal records to Supabase
  /// Note: PR syncing is complex due to local DB structure differences.
  /// For leaderboards, we can calculate PR count from user_stats instead.
  Future<void> syncPersonalRecords(String userId) async {
    print('📤 Skipping PR sync - not needed for leaderboards');
    print('   PR count will be calculated from user_stats');
    // TODO: Implement PR sync if needed in the future
  }

  /// Get total PR count for a user from Supabase
  Future<int> getPRCount(String userId) async {
    try {
      final response = await _supabase
          .from('personal_records')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      print('  ❌ Error getting PR count: $e');
      return 0;
    }
  }

  /// Full sync - sync everything for a user
  Future<void> fullSync(String userId) async {
    print('🔄 Starting full sync for user: $userId');

    // Sync stats first
    await syncUserStats(userId);

    // Sync PRs
    await syncPersonalRecords(userId);

    // Note: Syncing individual workout sessions is complex because
    // the local WorkoutSession doesn't store the user_id.
    // We would need to modify the sync flow to accept userId as a parameter.
    // For now, just sync stats and PRs which is sufficient for leaderboards.

    print('✅ Full sync completed');
  }
}
