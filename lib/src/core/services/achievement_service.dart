import 'package:drift/drift.dart';

import '../database/database.dart';
import '../models/achievement_models.dart';

/// Service for managing achievements and gamification
class AchievementService {
  AchievementService(this._database);
  final AppDatabase _database;

  /// Get all available achievements
  List<Achievement> getAllAchievements() {
    return [
      // Workout Streak Achievements
      Achievement(
        id: 'streak_3',
        title: 'Getting Started',
        description: 'Complete 3 workouts in a row',
        type: AchievementType.workoutStreak,
        difficulty: AchievementDifficulty.bronze,
        icon: '🔥',
        requirement: 3,
        reward: 'Unlock workout streak tracking',
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Complete 7 workouts in a row',
        type: AchievementType.workoutStreak,
        difficulty: AchievementDifficulty.silver,
        icon: '💪',
        requirement: 7,
        reward: 'Unlock advanced analytics',
      ),
      Achievement(
        id: 'streak_30',
        title: 'Month Master',
        description: 'Complete 30 workouts in a row',
        type: AchievementType.workoutStreak,
        difficulty: AchievementDifficulty.gold,
        icon: '👑',
        requirement: 30,
        reward: 'Unlock premium features for 1 week',
      ),

      // Total Workout Achievements
      Achievement(
        id: 'workouts_10',
        title: 'First Milestone',
        description: 'Complete 10 total workouts',
        type: AchievementType.totalWorkouts,
        difficulty: AchievementDifficulty.bronze,
        icon: '🎯',
        requirement: 10,
        reward: 'Unlock workout templates',
      ),
      Achievement(
        id: 'workouts_50',
        title: 'Dedicated',
        description: 'Complete 50 total workouts',
        type: AchievementType.totalWorkouts,
        difficulty: AchievementDifficulty.silver,
        icon: '🏆',
        requirement: 50,
        reward: 'Unlock custom exercises',
      ),
      Achievement(
        id: 'workouts_100',
        title: 'Century Club',
        description: 'Complete 100 total workouts',
        type: AchievementType.totalWorkouts,
        difficulty: AchievementDifficulty.gold,
        icon: '💯',
        requirement: 100,
        reward: 'Unlock advanced AI coaching',
      ),

      // Volume Achievements
      Achievement(
        id: 'volume_1000',
        title: 'Ton Lifter',
        description: 'Lift 1,000 kg total volume',
        type: AchievementType.totalVolume,
        difficulty: AchievementDifficulty.bronze,
        icon: '⚖️',
        requirement: 1000,
        reward: 'Unlock volume tracking',
      ),
      Achievement(
        id: 'volume_10000',
        title: 'Heavy Lifter',
        description: 'Lift 10,000 kg total volume',
        type: AchievementType.totalVolume,
        difficulty: AchievementDifficulty.silver,
        icon: '🏋️',
        requirement: 10000,
        reward: 'Unlock strength analytics',
      ),

      // Personal Record Achievements
      Achievement(
        id: 'pr_5',
        title: 'Record Breaker',
        description: 'Set 5 personal records',
        type: AchievementType.personalRecord,
        difficulty: AchievementDifficulty.bronze,
        icon: '📈',
        requirement: 5,
        reward: 'Unlock PR tracking',
      ),
      Achievement(
        id: 'pr_20',
        title: 'Progress Master',
        description: 'Set 20 personal records',
        type: AchievementType.personalRecord,
        difficulty: AchievementDifficulty.gold,
        icon: '🚀',
        requirement: 20,
        reward: 'Unlock progress insights',
      ),

      // Social Achievements
      Achievement(
        id: 'social_5',
        title: 'Social Butterfly',
        description: 'Make 5 social connections',
        type: AchievementType.social,
        difficulty: AchievementDifficulty.bronze,
        icon: '👥',
        requirement: 5,
        reward: 'Unlock social features',
      ),
      Achievement(
        id: 'social_20',
        title: 'Community Leader',
        description: 'Make 20 social connections',
        type: AchievementType.social,
        difficulty: AchievementDifficulty.silver,
        icon: '🌟',
        requirement: 20,
        reward: 'Unlock leaderboards',
      ),

      // AI Usage Achievements
      Achievement(
        id: 'ai_10',
        title: 'AI Explorer',
        description: 'Use AI coaching 10 times',
        type: AchievementType.premium,
        difficulty: AchievementDifficulty.bronze,
        icon: '🤖',
        requirement: 10,
        reward: 'Unlock advanced AI features',
      ),
      Achievement(
        id: 'ai_50',
        title: 'AI Master',
        description: 'Use AI coaching 50 times',
        type: AchievementType.premium,
        difficulty: AchievementDifficulty.gold,
        icon: '🧠',
        requirement: 50,
        reward: 'Unlock unlimited AI coaching',
      ),
    ];
  }

  /// Check and unlock achievements for a user
  Future<List<Achievement>> checkAchievements(String userId) async {
    final achievements = getAllAchievements();
    final unlockedAchievements = <Achievement>[];

    for (final achievement in achievements) {
      final progress = await _calculateProgress(achievement, userId);
      final isUnlocked = progress >= 1.0;

      if (isUnlocked) {
        // Check if already unlocked
        final existing = await _getUserAchievement(userId, achievement.id);
        if (existing == null) {
          // Unlock achievement
          await _unlockAchievement(userId, achievement);
          unlockedAchievements.add(achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            progress: 1.0,
          ));
        }
      }
    }

    return unlockedAchievements;
  }

  /// Calculate progress for an achievement
  Future<double> _calculateProgress(Achievement achievement, String userId) async {
    switch (achievement.type) {
      case AchievementType.workoutStreak:
        return await _calculateStreakProgress(achievement, userId);
      case AchievementType.totalWorkouts:
        return await _calculateWorkoutProgress(achievement, userId);
      case AchievementType.totalVolume:
        return await _calculateVolumeProgress(achievement, userId);
      case AchievementType.personalRecord:
        return await _calculatePRProgress(achievement, userId);
      case AchievementType.social:
        return await _calculateSocialProgress(achievement, userId);
      case AchievementType.premium:
        return await _calculateAIPProgress(achievement, userId);
      case AchievementType.consistency:
        return await _calculateConsistencyProgress(achievement, userId);
    }
  }

  /// Calculate streak progress
  Future<double> _calculateStreakProgress(Achievement achievement, String userId) async {
    final sessions = await (_database.select(_database.workoutSessions)
          ..where((w) => w.completedAt.isNotNull())
          ..orderBy([(w) => OrderingTerm.desc(w.completedAt)]))
        .get();

    if (sessions.isEmpty) return 0.0;

    int currentStreak = 0;
    DateTime? lastWorkoutDate;

    for (final session in sessions) {
      if (session.completedAt == null) continue;
      
      final workoutDate = session.completedAt!;
      if (lastWorkoutDate == null) {
        lastWorkoutDate = workoutDate;
        currentStreak = 1;
      } else {
        final daysDiff = lastWorkoutDate.difference(workoutDate).inDays;
        if (daysDiff == 1) {
          currentStreak++;
          lastWorkoutDate = workoutDate;
        } else if (daysDiff > 1) {
          break; // Streak broken
        }
      }
    }

    return (currentStreak / achievement.requirement).clamp(0.0, 1.0);
  }

  /// Calculate total workout progress
  Future<double> _calculateWorkoutProgress(Achievement achievement, String userId) async {
    final count = await (_database.select(_database.workoutSessions)
          ..where((w) => w.completedAt.isNotNull()))
        .get()
        .then((sessions) => sessions.length);

    return (count / achievement.requirement).clamp(0.0, 1.0);
  }

  /// Calculate total volume progress
  Future<double> _calculateVolumeProgress(Achievement achievement, String userId) async {
    final sessions = await (_database.select(_database.workoutSessions)
          ..where((w) => w.completedAt.isNotNull()))
        .get();

    final totalVolume = sessions.fold<double>(0.0, (sum, session) => sum + session.totalVolume);
    return (totalVolume / achievement.requirement).clamp(0.0, 1.0);
  }

  /// Calculate personal record progress
  Future<double> _calculatePRProgress(Achievement achievement, String userId) async {
    final prs = await (_database.select(_database.personalRecords)
          ..where((pr) => pr.userId.equals(userId)))
        .get();

    return (prs.length / achievement.requirement).clamp(0.0, 1.0);
  }

  /// Calculate social progress
  Future<double> _calculateSocialProgress(Achievement achievement, String userId) async {
    // This would need to be implemented based on your social features
    // For now, return 0
    return 0.0;
  }

  /// Calculate AI usage progress
  Future<double> _calculateAIPProgress(Achievement achievement, String userId) async {
    // This would need to be implemented based on AI usage tracking
    // For now, return 0
    return 0.0;
  }

  /// Calculate consistency progress
  Future<double> _calculateConsistencyProgress(Achievement achievement, String userId) async {
    // This would need to be implemented based on workout consistency
    // For now, return 0
    return 0.0;
  }

  /// Get user achievement
  Future<dynamic> _getUserAchievement(String userId, String achievementId) async {
    final achievements = await (_database.select(_database.userAchievements)
          ..where((a) => a.userId.equals(userId) & a.achievementId.equals(achievementId)))
        .get();

    return achievements.isNotEmpty ? achievements.first : null;
  }

  /// Unlock achievement for user
  Future<void> _unlockAchievement(String userId, Achievement achievement) async {
    await _database.into(_database.userAchievements).insert(
      UserAchievementsCompanion.insert(
        userId: userId,
        achievementId: achievement.id,
        unlockedAt: Value(DateTime.now()),
        progress: Value(1),
      ),
    );
  }

  /// Get user's unlocked achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    final userAchievements = await (_database.select(_database.userAchievements)
          ..where((a) => a.userId.equals(userId)))
        .get();

    final allAchievements = getAllAchievements();
    final unlockedAchievements = <Achievement>[];

    for (final userAchievement in userAchievements) {
      final achievement = allAchievements.firstWhere(
        (a) => a.id == userAchievement.achievementId,
        orElse: () => throw Exception('Achievement not found'),
      );

      unlockedAchievements.add(achievement.copyWith(
        isUnlocked: true,
        unlockedAt: userAchievement.unlockedAt,
        progress: 1.0,
      ));
    }

    return unlockedAchievements;
  }

  /// Get achievement progress for user
  Future<List<Achievement>> getAchievementProgress(String userId) async {
    final achievements = getAllAchievements();
    final progressAchievements = <Achievement>[];

    for (final achievement in achievements) {
      final progress = await _calculateProgress(achievement, userId);
      final isUnlocked = progress >= 1.0;

      progressAchievements.add(achievement.copyWith(
        isUnlocked: isUnlocked,
        progress: progress,
      ));
    }

    return progressAchievements;
  }
}