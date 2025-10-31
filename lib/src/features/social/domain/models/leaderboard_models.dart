enum LeaderboardType { totalVolume, workoutCount, streak, prCount }

enum Period { daily, weekly, monthly, allTime }

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.value,
    required this.rank,
    required this.formattedValue,
    this.avatarUrl,
  });
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final double value;
  final int rank;
  final String formattedValue;
}

class Leaderboard {
  const Leaderboard({
    required this.type,
    required this.period,
    required this.entries,
    this.currentUserEntry,
  });
  final LeaderboardType type;
  final Period period;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;

  String get title {
    switch (type) {
      case LeaderboardType.totalVolume:
        return 'Total Volume';
      case LeaderboardType.workoutCount:
        return 'Workouts Completed';
      case LeaderboardType.streak:
        return 'Workout Streak';
      case LeaderboardType.prCount:
        return 'Personal Records';
    }
  }

  String get unit {
    switch (type) {
      case LeaderboardType.totalVolume:
        return 'kg';
      case LeaderboardType.workoutCount:
        return 'workouts';
      case LeaderboardType.streak:
        return 'days';
      case LeaderboardType.prCount:
        return 'PRs';
    }
  }
}

class LeaderboardParams {
  const LeaderboardParams({required this.type, required this.period});
  final LeaderboardType type;
  final Period period;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          period == other.period;

  @override
  int get hashCode => type.hashCode ^ period.hashCode;
}
