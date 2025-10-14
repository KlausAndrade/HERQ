import 'dart:math';

import '../../../../core/config/mock_data_config.dart';
import '../../domain/models/social_models.dart';

/// Social features service with mock data for Phase 3 demonstration
class SocialService {
  const SocialService();

  // Generate mock users from configuration
  static List<UserProfile> get _mockUsers {
    final users = <UserProfile>[];
    final random = Random(42); // Fixed seed for consistent data

    for (int i = 0; i < MockDataConfig.mockUserNames.length; i++) {
      final name = MockDataConfig.mockUserNames[i];
      final location =
          MockDataConfig.mockLocations[i % MockDataConfig.mockLocations.length];

      users.add(
        UserProfile(
          id: '${i + 1}',
          displayName: name,
          email: '${name.toLowerCase().replaceAll(' ', '.')}@example.com',
          avatarUrl: 'https://avatar.iran.liara.run/public/${i + 1}',
          bio: _generateBio(random),
          location: location,
          joinedAt:
              DateTime.now().subtract(Duration(days: 30 + random.nextInt(300))),
          totalWorkouts: 20 + random.nextInt(200),
          totalVolume: (50000 + random.nextInt(150000)).toDouble(),
          currentStreak: random.nextInt(30),
          maxStreak: random.nextInt(50),
        ),
      );
    }

    return users;
  }

  static String _generateBio(Random random) {
    final bios = [
      'Powerlifter and fitness enthusiast. Always chasing new PRs!',
      'Crossfit athlete and nutrition coach',
      'Bodybuilder focusing on hypertrophy training',
      'Marathon runner and strength training advocate',
      'Personal trainer helping others reach their goals',
      'Calisthenics enthusiast and yoga practitioner',
      'Olympic weightlifter and mobility specialist',
      'Functional fitness coach and movement specialist',
    ];
    return bios[random.nextInt(bios.length)];
  }

  static List<FeedItem> get _mockFeedItems {
    final items = <FeedItem>[];
    final random = Random(42);

    for (int i = 0; i < MockDataConfig.mockPostsPerUser; i++) {
      final userId = '${(i % MockDataConfig.mockUserNames.length) + 1}';
      final workoutType = MockDataConfig.mockWorkoutTypes[
          random.nextInt(MockDataConfig.mockWorkoutTypes.length)];

      items.add(
        FeedItem(
          id: '${i + 1}',
          userId: userId,
          type: FeedItemType.values[random.nextInt(FeedItemType.values.length)],
          createdAt: DateTime.now()
              .subtract(Duration(hours: i * 2 + random.nextInt(12))),
          exerciseId: random.nextBool() ? 'bench_press' : 'squat',
          workoutId: random.nextBool() ? 'workout_${i + 1}' : null,
          achievement: random.nextBool()
              ? Achievement(
                  id: 'achievement_${i + 1}',
                  name: '$workoutType Achievement',
                  description: 'Completed an amazing $workoutType session!',
                  type: AchievementType
                      .values[random.nextInt(AchievementType.values.length)],
                  unlockedAt: DateTime.now().subtract(Duration(hours: i * 2)),
                  badgeColor: _getRandomBadgeColor(random),
                )
              : null,
        ),
      );
    }

    return items;
  }

  static String _getRandomBadgeColor(Random random) {
    final colors = [
      '#FFD700',
      '#FF6B6B',
      '#4CAF50',
      '#FF9800',
      '#9C27B0',
      '#2196F3',
    ];
    return colors[random.nextInt(colors.length)];
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay

    if (query.isEmpty) return [];

    return _mockUsers
        .where(
          (user) =>
              user.displayName.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<List<UserProfile>> getFriends(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Return first 2 users as friends for demo
    return _mockUsers.take(2).toList();
  }

  Future<List<FriendConnection>> getFriendRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      FriendConnection(
        id: 'req_1',
        userId: '4',
        friendId: userId,
        status: FriendStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  Future<bool> sendFriendRequest(String fromUserId, String toUserId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Always succeed for demo
  }

  Future<bool> acceptFriendRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> declineFriendRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<List<FeedItem>> getFeed(String userId, {int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockFeedItems;
  }

  Future<Leaderboard> getLeaderboard(
    LeaderboardType type,
    Period period,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final entries = _mockUsers.asMap().entries.map((entry) {
      final index = entry.key;
      final user = entry.value;

      double score;
      switch (type) {
        case LeaderboardType.totalVolume:
          score = user.totalVolume;
          break;
        case LeaderboardType.workoutCount:
          score = user.totalWorkouts.toDouble();
          break;
        case LeaderboardType.streak:
          score = user.currentStreak.toDouble();
          break;
        case LeaderboardType.prCount:
          score =
              (user.totalWorkouts * 0.1).round().toDouble(); // Mock PR count
          break;
      }

      return LeaderboardEntry(
        userId: user.id,
        displayName: user.displayName,
        rank: index + 1,
        score: score,
        avatarUrl: user.avatarUrl,
        change: Random().nextInt(5) - 2, // Random change for demo
      );
    }).toList();

    // Sort by score (descending)
    entries.sort((a, b) => b.score.compareTo(a.score));

    // Update ranks
    for (int i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        userId: entries[i].userId,
        displayName: entries[i].displayName,
        rank: i + 1,
        score: entries[i].score,
        avatarUrl: entries[i].avatarUrl,
        change: entries[i].change,
      );
    }

    return Leaderboard(
      id: '${type.name}_${period.name}',
      name: '${_formatLeaderboardType(type)} - ${_formatPeriod(period)}',
      type: type,
      period: period,
      entries: entries,
      updatedAt: DateTime.now(),
    );
  }

  Future<List<Achievement>> getUserAchievements(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      Achievement(
        id: 'first_workout',
        name: 'First Steps',
        description: 'Completed your first workout',
        type: AchievementType.workoutCount,
        unlockedAt: DateTime.now().subtract(const Duration(days: 100)),
        badgeColor: '#4CAF50',
      ),
      Achievement(
        id: 'week_streak',
        name: 'Week Warrior',
        description: 'Maintained a 7-day workout streak',
        type: AchievementType.streak,
        unlockedAt: DateTime.now().subtract(const Duration(days: 50)),
        badgeColor: '#FF9800',
      ),
      Achievement(
        id: 'volume_milestone',
        name: 'Volume Victor',
        description: 'Lifted over 100,000 kg total volume',
        type: AchievementType.volume,
        unlockedAt: DateTime.now().subtract(const Duration(days: 20)),
        badgeColor: '#9C27B0',
      ),
    ];
  }

  String _formatLeaderboardType(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.totalVolume:
        return 'Total Volume';
      case LeaderboardType.workoutCount:
        return 'Workout Count';
      case LeaderboardType.streak:
        return 'Current Streak';
      case LeaderboardType.prCount:
        return 'Personal Records';
    }
  }

  String _formatPeriod(Period period) {
    switch (period) {
      case Period.weekly:
        return 'This Week';
      case Period.monthly:
        return 'This Month';
      case Period.yearly:
        return 'This Year';
      case Period.allTime:
        return 'All Time';
    }
  }
}
