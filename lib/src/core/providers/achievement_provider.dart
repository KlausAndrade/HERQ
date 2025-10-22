import 'dart:math' as math;
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement_models.dart';
import '../services/achievement_service.dart';
import 'database_provider.dart';

/// Achievement service provider
final achievementServiceProvider = Provider<AchievementService>((ref) {
  final database = ref.watch(databaseProvider);
  if (database == null) throw StateError('Database not available');
  return AchievementService(database);
});

/// User achievements provider
final userAchievementsProvider = FutureProvider.family<List<Achievement>, String>((ref, userId) async {
  final service = ref.read(achievementServiceProvider);
  return await service.getUserAchievements(userId);
});

/// Achievement progress provider
final achievementProgressProvider = FutureProvider.family<List<Achievement>, String>((ref, userId) async {
  final service = ref.read(achievementServiceProvider);
  return await service.getAchievementProgress(userId);
});

/// Achievement notifications provider
final achievementNotificationsProvider = StateNotifierProvider<AchievementNotificationsNotifier, List<AchievementNotification>>((ref) {
  return AchievementNotificationsNotifier();
});

/// Achievement notifications notifier
class AchievementNotificationsNotifier extends StateNotifier<List<AchievementNotification>> {
  AchievementNotificationsNotifier() : super([]);

  /// Add a new achievement notification
  void addNotification(Achievement achievement) {
    final notification = AchievementNotification(
      achievement: achievement,
      timestamp: DateTime.now(),
    );
    
    state = [notification, ...state];
  }

  /// Mark notification as read
  void markAsRead(int index) {
    if (index >= 0 && index < state.length) {
      final notification = state[index];
      state = [
        ...state.sublist(0, index),
        AchievementNotification(
          achievement: notification.achievement,
          timestamp: notification.timestamp,
          isRead: true,
        ),
        ...state.sublist(index + 1),
      ];
    }
  }

  /// Clear all notifications
  void clearAll() {
    state = [];
  }

  /// Get unread count
  int get unreadCount => state.where((n) => !n.isRead).length;
}

/// Streak data provider
final streakDataProvider = FutureProvider.family<StreakData, String>((ref, userId) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return const StreakData(
      currentStreak: 0,
      longestStreak: 0,
      lastWorkoutDate: null,
      streakStartDate: null,
    );
  }

  final sessions = await (database.select(database.workoutSessions)
        ..where((w) => w.completedAt.isNotNull())
        ..orderBy([(w) => OrderingTerm.desc(w.completedAt)]))
      .get();

  if (sessions.isEmpty) {
    return const StreakData(
      currentStreak: 0,
      longestStreak: 0,
      lastWorkoutDate: null,
      streakStartDate: null,
    );
  }

  int currentStreak = 0;
  int longestStreak = 0;
  DateTime? lastWorkoutDate;
  DateTime? streakStartDate;

  for (final session in sessions) {
    if (session.completedAt == null) continue;
    
    final workoutDate = session.completedAt!;
    if (lastWorkoutDate == null) {
      lastWorkoutDate = workoutDate;
      currentStreak = 1;
      streakStartDate = workoutDate;
    } else {
      final daysDiff = lastWorkoutDate.difference(workoutDate).inDays;
      if (daysDiff == 1) {
        currentStreak++;
        lastWorkoutDate = workoutDate;
      } else if (daysDiff > 1) {
        longestStreak = math.max(longestStreak, currentStreak);
        currentStreak = 1;
        lastWorkoutDate = workoutDate;
        streakStartDate = workoutDate;
      }
    }
  }

  longestStreak = math.max(longestStreak, currentStreak);

  return StreakData(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lastWorkoutDate: lastWorkoutDate,
    streakStartDate: streakStartDate,
  );
});

/// Engagement metrics provider
final engagementMetricsProvider = FutureProvider.family<EngagementMetrics, String>((ref, userId) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return EngagementMetrics(
      totalWorkouts: 0,
      totalVolume: 0.0,
      workoutStreak: 0,
      socialInteractions: 0,
      aiUsage: 0,
      lastActiveDate: DateTime.now(),
    );
  }

  final sessions = await (database.select(database.workoutSessions)
        ..where((w) => w.completedAt.isNotNull()))
      .get();

  final totalWorkouts = sessions.length;
  final totalVolume = sessions.fold<double>(0.0, (sum, session) => sum + session.totalVolume);
  
  final streakData = await ref.read(streakDataProvider(userId).future);
  final workoutStreak = streakData.currentStreak;

  // Social interactions and AI usage would need to be implemented
  // based on your specific features
  const socialInteractions = 0;
  const aiUsage = 0;

  final lastActiveDate = sessions.isNotEmpty 
      ? sessions.first.completedAt ?? DateTime.now()
      : DateTime.now();

  return EngagementMetrics(
    totalWorkouts: totalWorkouts,
    totalVolume: totalVolume,
    workoutStreak: workoutStreak,
    socialInteractions: socialInteractions,
    aiUsage: aiUsage,
    lastActiveDate: lastActiveDate,
  );
});

/// Achievement checker provider - checks for new achievements
final achievementCheckerProvider = FutureProvider.family<List<Achievement>, String>((ref, userId) async {
  final service = ref.read(achievementServiceProvider);
  final newAchievements = await service.checkAchievements(userId);
  
  // Add notifications for new achievements
  if (newAchievements.isNotEmpty) {
    final notifications = ref.read(achievementNotificationsProvider.notifier);
    for (final achievement in newAchievements) {
      notifications.addNotification(achievement);
    }
  }
  
  return newAchievements;
});
