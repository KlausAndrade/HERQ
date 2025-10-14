import '../../../core/database/database.dart';
import '../domain/models/leaderboard_models.dart';

class LeaderboardService {
  LeaderboardService(this._db);
  final AppDatabase _db;

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
    (DateTime?, DateTime?) dateRange,
  ) async {
    print('🏆 Getting volume leaderboard...');

    final users = await _db.select(_db.users).get();
    final stats = await _db.select(_db.userStats).get();

    print('  Found ${users.length} users, ${stats.length} stats entries');

    // Debug: Print all users
    for (final u in users) {
      print(
        '  👤 User: id=${u.id}, email=${u.email}, displayName=${u.displayName}',
      );
    }

    final entries = <LeaderboardEntry>[];
    for (final s in stats) {
      print(
        '  📊 Processing stat: userId=${s.userId}, volume=${s.totalVolumeLifted}',
      );

      // Get user info or create friendly display name
      User? user;
      try {
        user = users.firstWhere((u) => u.id == s.userId);
        print(
          '    ✅ Found user: email=${user.email}, displayName=${user.displayName}',
        );
      } catch (_) {
        print('    ⚠️ No user record found for ${s.userId}');
      }

      // Create display name - prefer real names, never show emails
      String displayName;
      if (s.userId.contains('default')) {
        displayName = 'You';
      } else if (user != null && user.displayName.isNotEmpty) {
        displayName = user.displayName;
      } else {
        // Fallback to "Unknown Athlete" (never show email)
        displayName = 'Unknown Athlete';
        print('    ⚠️ Using fallback display name: $displayName');
      }

      if (s.totalVolumeLifted > 0) {
        print(
          '  ✅ Adding entry: $displayName - ${s.totalVolumeLifted.toStringAsFixed(0)} kg',
        );
        entries.add(
          LeaderboardEntry(
            userId: s.userId,
            displayName: displayName,
            avatarUrl: user?.avatarUrl,
            value: s.totalVolumeLifted,
            rank: 0,
            formattedValue: '${s.totalVolumeLifted.toStringAsFixed(1)} kg',
          ),
        );
      }
    }

    print('  Total entries: ${entries.length}');

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
    (DateTime?, DateTime?) dateRange,
  ) async {
    print('🏆 Getting workout count leaderboard...');

    final users = await _db.select(_db.users).get();
    final stats = await _db.select(_db.userStats).get();

    print('  Found ${users.length} users, ${stats.length} stats entries');

    final entries = <LeaderboardEntry>[];
    for (final s in stats) {
      if (s.totalWorkouts > 0) {
        // Get user info or create friendly display name
        User? user;
        try {
          user = users.firstWhere((u) => u.id == s.userId);
        } catch (_) {}

        // Create display name - prefer real names, never show emails
        String displayName;
        if (s.userId.contains('default')) {
          displayName = 'You';
        } else if (user != null && user.displayName.isNotEmpty) {
          displayName = user.displayName;
        } else {
          // Fallback to "Unknown Athlete" (never show email)
          displayName = 'Unknown Athlete';
        }

        print('  ✅ Adding entry: $displayName - ${s.totalWorkouts} workouts');

        entries.add(
          LeaderboardEntry(
            userId: s.userId,
            displayName: displayName,
            avatarUrl: user?.avatarUrl,
            value: s.totalWorkouts.toDouble(),
            rank: 0,
            formattedValue:
                '${s.totalWorkouts} ${s.totalWorkouts == 1 ? "workout" : "workouts"}',
          ),
        );
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
    print('🏆 Getting streak leaderboard...');

    final users = await _db.select(_db.users).get();
    final stats = await _db.select(_db.userStats).get();

    print('  Found ${users.length} users, ${stats.length} stats entries');

    final entries = <LeaderboardEntry>[];

    for (final s in stats) {
      final streak = s.currentStreak;
      if (streak > 0) {
        // Get user info or create friendly display name
        User? user;
        try {
          user = users.firstWhere((u) => u.id == s.userId);
        } catch (_) {}

        // Create display name - prefer real names, never show emails
        String displayName;
        if (s.userId.contains('default')) {
          displayName = 'You';
        } else if (user != null && user.displayName.isNotEmpty) {
          displayName = user.displayName;
        } else {
          // Fallback to "Unknown Athlete" (never show email)
          displayName = 'Unknown Athlete';
        }

        print('  ✅ Adding streak entry: $displayName - $streak days');

        entries.add(
          LeaderboardEntry(
            userId: s.userId,
            displayName: displayName,
            avatarUrl: user?.avatarUrl,
            value: streak.toDouble(),
            rank: 0,
            formattedValue: '$streak ${streak == 1 ? "day" : "days"} 🔥',
          ),
        );
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
    (DateTime?, DateTime?) dateRange,
  ) async {
    print('🏆 Getting PR count leaderboard...');
    // Count PRs from personal_records table
    final users = await _db.select(_db.users).get();
    final entries = <LeaderboardEntry>[];

    // For local database, PRs don't have userId - they're device-local
    // So we count all PRs for the current user
    final prs = await _db.select(_db.personalRecords).get();

    print('  Found ${users.length} users, ${prs.length} PRs');

    if (prs.isEmpty) {
      print('  ⚠️ No PRs found, returning empty');
      return entries;
    }

    // All PRs belong to the device's user (local-only)
    final prCount = prs.length;
    const userId = 'local_user'; // Device-local user ID

    User? user;
    if (users.isNotEmpty) {
      user = users.first; // Use first user in local DB
    }

    print('  ✅ Adding PR entry: ${user?.displayName ?? "You"} - $prCount PRs');

    entries.add(
      LeaderboardEntry(
        userId: userId,
        displayName: user?.displayName ?? 'You',
        avatarUrl: user?.avatarUrl,
        value: prCount.toDouble(),
        rank: 1,
        formattedValue: '$prCount PRs',
      ),
    );

    print('  Total PR entries: ${entries.length}');
    return entries;
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
        final startOfMonth = DateTime(now.year, now.month);
        final endOfMonth = DateTime(now.year, now.month + 1);
        return (startOfMonth, endOfMonth);

      case Period.allTime:
        return (null, null);
    }
  }
}
