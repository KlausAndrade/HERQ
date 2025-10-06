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
    final (start, end) = dateRange;

    // Get all users
    final users = await _db.select(_db.users).get();
    final Map<String, double> userVolumes = {};

    for (final user in users) {
      final query = _db.select(_db.workoutSessions)
        ..where((t) {
          var condition = t.id.contains(user.id) & t.completedAt.isNotNull();
          if (start != null) {
            condition = condition & t.completedAt.isBiggerOrEqualValue(start);
          }
          if (end != null) {
            condition = condition & t.completedAt.isSmallerThanValue(end);
          }
          return condition;
        });

      final sessions = await query.get();
      final totalVolume = sessions.fold<double>(
        0,
        (sum, session) => sum + session.totalVolume,
      );

      if (totalVolume > 0) {
        userVolumes[user.id] = totalVolume;
      }
    }

    // Convert to entries
    final entries = userVolumes.entries.map((e) {
      final user = users.firstWhere((u) => u.id == e.key);
      return LeaderboardEntry(
        userId: user.id,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        value: e.value,
        rank: 0,
        formattedValue: '${e.value.toStringAsFixed(0)} kg',
      );
    }).toList();

    entries.sort((a, b) => b.value.compareTo(a.value));

    // Assign ranks
    return List.generate(entries.length, (i) {
      return LeaderboardEntry(
        userId: entries[i].userId,
        displayName: entries[i].displayName,
        avatarUrl: entries[i].avatarUrl,
        value: entries[i].value,
        rank: i + 1,
        formattedValue: entries[i].formattedValue,
      );
    });
  }

  /// Get workout count leaderboard
  Future<List<LeaderboardEntry>> _getWorkoutCountLeaderboard(
      (DateTime?, DateTime?) dateRange) async {
    final (start, end) = dateRange;

    // Get all users
    final users = await _db.select(_db.users).get();
    final Map<String, int> userCounts = {};

    for (final user in users) {
      final query = _db.select(_db.workoutSessions)
        ..where((t) {
          var condition = t.id.equals(user.id) &
              t.completedAt.isNotNull();
          if (start != null) {
            condition = condition & t.completedAt.isBiggerOrEqualValue(start);
          }
          if (end != null) {
            condition = condition & t.completedAt.isSmallerThanValue(end);
          }
          return condition;
        });

      final count = await query.get().then((sessions) => sessions.length);
      if (count > 0) {
        userCounts[user.id] = count;
      }
    }

    final entries = <LeaderboardEntry>[];
    for (final entry in userCounts.entries) {
      final user = users.firstWhere((u) => u.id == entry.key);
      entries.add(LeaderboardEntry(
        userId: user.id,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        value: entry.value.toDouble(),
        rank: 0,
        formattedValue: '${entry.value} workouts',
      ));
    }

    entries.sort((a, b) => b.value.compareTo(a.value));

    // Assign ranks
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
    final users = await _db.select(_db.users).get();
    final entries = <LeaderboardEntry>[];

    for (final user in users) {
      final streak = await _calculateStreak(user.id);
      if (streak > 0) {
        entries.add(LeaderboardEntry(
          userId: user.id,
          displayName: user.displayName,
          avatarUrl: user.avatarUrl,
          value: streak.toDouble(),
          rank: 0,
          formattedValue: '$streak days',
        ));
      }
    }

    entries.sort((a, b) => b.value.compareTo(a.value));

    // Assign ranks
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
    final (start, end) = dateRange;
    final users = await _db.select(_db.users).get();
    final Map<String, int> userPRCounts = {};

    for (final user in users) {
      final query = _db.select(_db.personalRecords)
        ..where((t) {
          var condition = t.id.equals(user.id); 
          if (start != null) {
            condition = condition & t.achievedAt.isBiggerOrEqualValue(start);
          }
          if (end != null) {
            condition = condition & t.achievedAt.isSmallerThanValue(end);
          }
          return condition;
        });

      final count = await query.get().then((prs) => prs.length);
      if (count > 0) {
        userPRCounts[user.id] = count;
      }
    }

    final entries = <LeaderboardEntry>[];
    for (final entry in userPRCounts.entries) {
      final user = users.firstWhere((u) => u.id == entry.key);
      entries.add(LeaderboardEntry(
        userId: user.id,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        value: entry.value.toDouble(),
        rank: 0,
        formattedValue: '${entry.value} PRs',
      ));
    }

    entries.sort((a, b) => b.value.compareTo(a.value));

    // Assign ranks
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

  /// Calculate current streak for a user
  Future<int> _calculateStreak(String userId) async {
    final sessions = await (_db.select(_db.workoutSessions)
          ..where((t) => t.id.equals(userId) & t.completedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();

    if (sessions.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final session in sessions) {
      if (session.completedAt == null) continue;

      final sessionDate = DateTime(
        session.completedAt!.year,
        session.completedAt!.month,
        session.completedAt!.day,
      );

      if (lastDate == null) {
        // First session
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        
        // Only count if workout was today or yesterday
        if (sessionDate.difference(todayDate).inDays <= 1) {
          streak = 1;
          lastDate = sessionDate;
        } else {
          break; // Streak broken
        }
      } else {
        // Check if consecutive day
        final diff = lastDate.difference(sessionDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = sessionDate;
        } else if (diff == 0) {
          // Same day, don't break streak
          continue;
        } else {
          break; // Streak broken
        }
      }
    }

    return streak;
  }

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
