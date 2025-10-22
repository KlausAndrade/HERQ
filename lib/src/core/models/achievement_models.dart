import 'package:equatable/equatable.dart';

/// Achievement types for gamification
enum AchievementType {
  workoutStreak,
  totalWorkouts,
  totalVolume,
  personalRecord,
  consistency,
  social,
  premium,
}

/// Achievement difficulty levels
enum AchievementDifficulty {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

/// Achievement model
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.icon,
    required this.requirement,
    required this.reward,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
  });

  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final AchievementDifficulty difficulty;
  final String icon;
  final int requirement; // Target value to unlock
  final String reward; // Description of reward
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 to 1.0

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    AchievementDifficulty? difficulty,
    String? icon,
    int? requirement,
    String? reward,
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      icon: icon ?? this.icon,
      requirement: requirement ?? this.requirement,
      reward: reward ?? this.reward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        difficulty,
        icon,
        requirement,
        reward,
        isUnlocked,
        unlockedAt,
        progress,
      ];
}

/// User achievement progress
class UserAchievement extends Equatable {
  const UserAchievement({
    required this.achievementId,
    required this.userId,
    required this.isUnlocked,
    required this.unlockedAt,
    required this.progress,
  });

  final String achievementId;
  final String userId;
  final bool isUnlocked;
  final DateTime unlockedAt;
  final double progress;

  @override
  List<Object?> get props => [achievementId, userId, isUnlocked, unlockedAt, progress];
}

/// Achievement notification
class AchievementNotification extends Equatable {
  const AchievementNotification({
    required this.achievement,
    required this.timestamp,
    this.isRead = false,
  });

  final Achievement achievement;
  final DateTime timestamp;
  final bool isRead;

  @override
  List<Object?> get props => [achievement, timestamp, isRead];
}

/// Streak data for retention
class StreakData extends Equatable {
  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastWorkoutDate,
    required this.streakStartDate,
  });

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final DateTime? streakStartDate;

  bool get isActive => 
      lastWorkoutDate != null && 
      DateTime.now().difference(lastWorkoutDate!).inDays <= 1;

  @override
  List<Object?> get props => [currentStreak, longestStreak, lastWorkoutDate, streakStartDate];
}

/// User engagement metrics
class EngagementMetrics extends Equatable {
  const EngagementMetrics({
    required this.totalWorkouts,
    required this.totalVolume,
    required this.workoutStreak,
    required this.socialInteractions,
    required this.aiUsage,
    required this.lastActiveDate,
  });

  final int totalWorkouts;
  final double totalVolume;
  final int workoutStreak;
  final int socialInteractions;
  final int aiUsage;
  final DateTime lastActiveDate;

  @override
  List<Object?> get props => [
        totalWorkouts,
        totalVolume,
        workoutStreak,
        socialInteractions,
        aiUsage,
        lastActiveDate,
      ];
}
