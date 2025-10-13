import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../domain/models/leaderboard_models.dart';

class LeaderboardService {
  final AppDatabase _db;

  LeaderboardService(this._db);

  /// Get leaderboard data based on type and period
  Future<Leaderboard> getLeaderboard({
    required LeaderboardType type,
    required Period period,
    String? currentUserId,
  }) async {
    final dateRange = _getDateRange(period);
    
    List<LeaderboardEntry> entries;

    switch (type) {
      case LeaderboardType.totalVolume:
        entries = await _getTotalVolumeLeaderboard(dateRange);
        break;
      case LeaderboardType.workoutCount:
        entries = await _getWorkoutCountLeaderboard(dateRange);
        break;
      case LeaderboardType.streak:
        entries = await _getStreakLeaderboard();
        break;
      case LeaderboardType.prCount:
        entries = await _getPRCountLeaderboard(dateRange);
        break;
    }

    // Find current user's entry
    LeaderboardEntry? currentUserEntry;
    if (currentUserId != null) {
      currentUserEntry = entries.firstWhere(
        (entry) => entry.userId == currentUserId,
        orElse: () => LeaderboardEntry(
          userId: currentUserId,
          displayName: 'You',
          value: 0,
          rank: entries.length + 1,
          formattedValue: '0',
        ),
      );
    }

    return Leaderboard(
      type: type,
      period: period,
      entries: entries.take(100).toList(), // Top 100
      currentUserEntry: currentUserEntry,
    );
  }

  /// Get total volume leaderboard (sum of weight × reps)
  Future<List<LeaderboardEntry>> _getTotalVolumeLeaderboard(
      (DateTime?, DateTime?) dateRange) async {
    // Local DB doesn't associate WorkoutSessions with users. We keep a
    // per-user summary in `userStats` which is the correct source for
    // aggregated leaderboards on-device.
    final users = await _db.select(_db.users).get();
    final stats = await _db.select(_db.userStats).get();

    final entries = <LeaderboardEntry>[];
    for (final s in stats) {
      User? user;
      try {
        user = users.firstWhere((u) => u.id == s.userId);
      } catch (_) {
        user = null;
      }

      final displayName = user != null ? user.displayName : s.userId;
      final avatar = user != null ? user.avatarUrl : null;

      if (s.totalVolumeLifted > 0) {
        entries.add(LeaderboardEntry(
          userId: s.userId,
          displayName: displayName,
          avatarUrl: avatar,
          value: s.totalVolumeLifted,
          rank: 0,
          formattedValue: '${s.totalVolumeLifted.toStringAsFixed(0)} kg',
        ));
      }
    }

    entries.sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        userId: entries[i].userId,
        displayName: entries[i].displayName,
        avatarUrl: entries[i].avatarUrl,
        value: entries[i].value,
        rank: i + 1,
        formattedValue: entries[i].formattedValue,
      );
    }

    return entries;
  }

  /// Get workout count leaderboard
  Future<List<LeaderboardEntry>> _getWorkoutCountLeaderboard(
      (DateTime?, DateTime?) dateRange) async {
    // Use userStats.totalWorkouts as the authoritative on-device count
    final users = await _db.select(_db.users).get();
    final stats = await _db.select(_db.userStats).get();

    final entries = <LeaderboardEntry>[];
    for (final s in stats) {
      if (s.totalWorkouts > 0) {
        User? user;
        try {
          user = users.firstWhere((u) => u.id == s.userId);
        } catch (_) {
          user = null;
        }

        entries.add(LeaderboardEntry(
          userId: s.userId,
          displayName: user != null ? user.displayName : s.userId,
          avatarUrl: user != null ? user.avatarUrl : null,
          value: s.totalWorkouts.toDouble(),
          rank: 0,
          formattedValue: '${s.totalWorkouts} workouts',
        ));
      }
    }

    entries.sort((a, b) => b.value.compareTo(a.value));
    for (int i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        userId: entries[i].userId,
        displayName: entries[i].displayName,
        avatarUrl: entries[i].avatarUrl,
        value: entries[i].value,
        rank: i + 1,
        formattedValue: entries[i].formattedValue,
      );
    }

    return entries;
  }

  /// Get streak leaderboard (consecutive days with workouts)
  Future<List<LeaderboardEntry>> _getStreakLeaderboard() async {
    // Use userStats.currentStreak if available
    final users = await _db.select(_db.users).get();
    final stats = await _db.select(_db.userStats).get();
    final entries = <LeaderboardEntry>[];

    for (final s in stats) {
      final streak = s.currentStreak;
      if (streak > 0) {
        User? user;
        try {
          user = users.firstWhere((u) => u.id == s.userId);
        } catch (_) {
          user = null;
        }
        entries.add(LeaderboardEntry(
          userId: s.userId,
          displayName: user != null ? user.displayName : s.userId,
          avatarUrl: user != null ? user.avatarUrl : null,
          value: streak.toDouble(),
          rank: 0,
          formattedValue: '$streak days',
        ));
      }
    }

    entries.sort((a, b) => b.value.compareTo(a.value));
    for (int i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        userId: entries[i].userId,
        displayName: entries[i].displayName,
        avatarUrl: entries[i].avatarUrl,
        value: entries[i].value,
        rank: i + 1,
        formattedValue: entries[i].formattedValue,
      );
    }

    return entries;
  }

  /// Get PR count leaderboard
  Future<List<LeaderboardEntry>> _getPRCountLeaderboard(
      (DateTime?, DateTime?) dateRange) async {
    // Personal records in the local database are currently stored without a
    // userId (they're per-device). For accurate PR leaderboards across users
    // we rely on a server (Supabase). Return an empty list locally and mark
    // this as a TODO to implement via server-side aggregation.
    return const [];
  }

  /// Calculate current streak for a user
  // Note: streak calculations are now driven from `userStats` in the DB.

  /// Get date range for period
  (DateTime?, DateTime?) _getDateRange(Period period) {
    final now = DateTime.now();

    switch (period) {
      case Period.daily:
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        return (startOfDay, endOfDay);

      case Period.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDay =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final endOfWeek = startOfWeekDay.add(const Duration(days: 7));
        return (startOfWeekDay, endOfWeek);

      case Period.monthly:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        return (startOfMonth, endOfMonth);

      case Period.allTime:
        return (null, null);
    }
  }
}
