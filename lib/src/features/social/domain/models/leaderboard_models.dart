enum LeaderboardType {
  totalVolume,
  workoutCount,
  streak,
  prCount,
}

enum Period {
  daily,
  weekly,
  monthly,
  allTime,
}

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final double value;
  final int rank;
  final String formattedValue;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.value,
    required this.rank,
    required this.formattedValue,
  });
}

class Leaderboard {
  final LeaderboardType type;
  final Period period;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;

  const Leaderboard({
    required this.type,
    required this.period,
    required this.entries,
    this.currentUserEntry,
  });

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
  final LeaderboardType type;
  final Period period;

  const LeaderboardParams({
    required this.type,
    required this.period,
  });

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
