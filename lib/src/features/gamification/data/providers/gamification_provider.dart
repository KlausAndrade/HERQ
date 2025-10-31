import 'package:drift/drift.dart' hide JsonKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/models/achievement.dart';

// Provider for user stats (wires to current authenticated user)
final userStatsProvider = StreamProvider.autoDispose<UserStat?>((ref) {
  final database = ref.watch(databaseProvider);
  final currentUser = ref.watch(currentUserProvider);
  if (database == null || currentUser == null) return Stream.value(null);

  return database.watchUserStats(currentUser.id);
});

// Provider for user achievements (wires to current authenticated user)
final userAchievementsProvider =
    StreamProvider.autoDispose<List<UserAchievement>>((ref) {
      final database = ref.watch(databaseProvider);
      final currentUser = ref.watch(currentUserProvider);
      if (database == null || currentUser == null) return Stream.value([]);

      return database.watchUserAchievements(currentUser.id);
    });

// Provider for gamification service
final gamificationServiceProvider = Provider<GamificationService?>((ref) {
  final database = ref.watch(databaseProvider);
  final currentUser = ref.watch(currentUserProvider);
  if (database == null || currentUser == null) return null;
  return GamificationService(database, currentUser.id);
});

class GamificationService {
  GamificationService(this.database, [this.defaultUserId]);
  final AppDatabase database;
  final String? defaultUserId;

  // Calculate XP required for a given level
  int xpRequiredForLevel(int level) {
    // Exponential curve: level 1 = 100 XP, level 2 = 250 XP, level 3 = 450 XP, etc.
    return (100 * level * (level + 1) / 2).round();
  }

  // Calculate level from total XP
  int calculateLevel(int totalXp) {
    int level = 1;
    while (xpRequiredForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  // Calculate XP progress towards next level
  double calculateLevelProgress(int totalXp, int currentLevel) {
    final currentLevelXp = xpRequiredForLevel(currentLevel);
    final nextLevelXp = xpRequiredForLevel(currentLevel + 1);
    final xpIntoCurrentLevel = totalXp - currentLevelXp;
    final xpNeededForNextLevel = nextLevelXp - currentLevelXp;

    return xpIntoCurrentLevel / xpNeededForNextLevel;
  }

  // Initialize user stats if they don't exist
  /// Recalculate user stats from all completed workouts
  Future<UserStat> recalculateUserStats({
    String? userId,
    String? userEmail,
    String? userDisplayName,
  }) async {
    print('📊 Recalculating user stats...');

    final uid = userId ?? defaultUserId;
    if (uid == null) {
      throw StateError('No userId available for gamification');
    }
    print('  User ID: $uid');
    print('  User Email: $userEmail');
    print('  User Display Name: $userDisplayName');

    // Ensure user record exists
    final existingUser = await (database.select(
      database.users,
    )..where((tbl) => tbl.id.equals(uid))).getSingleOrNull();

    if (existingUser == null) {
      print('  ⚠️ User record not found, creating one...');
      final displayName = userDisplayName ?? 'Unknown Athlete';
      await database
          .into(database.users)
          .insertOnConflictUpdate(
            UsersCompanion.insert(
              id: uid,
              email: Value(userEmail),
              displayName: displayName,
              createdAt: Value(DateTime.now()),
            ),
          );
      print('  ✅ User record created:');
      print('     ID: $uid');
      print('     Email: $userEmail');
      print('     Display Name: $displayName');

      // Verify it was created
      final verifyUser = await (database.select(
        database.users,
      )..where((tbl) => tbl.id.equals(uid))).getSingleOrNull();
      print(
        '  🔍 Verification: User ${verifyUser != null ? "FOUND" : "NOT FOUND"} in DB',
      );
    } else {
      print('  ✅ User record already exists:');
      print('     ID: ${existingUser.id}');
      print('     Email: ${existingUser.email}');
      print('     Display Name: ${existingUser.displayName}');

      if (existingUser.displayName.isEmpty && userDisplayName != null) {
        // Update existing user if they have no display name but we have one now
        print('  🔄 Updating user record with display name...');
        await database
            .into(database.users)
            .insertOnConflictUpdate(
              UsersCompanion.insert(
                id: uid,
                email: Value(userEmail ?? existingUser.email),
                displayName: userDisplayName,
                createdAt: Value(existingUser.createdAt),
              ),
            );
        print('  ✅ User record updated with name: $userDisplayName');
      }
    }

    // Get all completed workouts
    final workouts = await (database.select(
      database.workoutSessions,
    )..where((tbl) => tbl.completedAt.isNotNull())).get();

    print('  Found ${workouts.length} completed workouts');

    if (workouts.isEmpty) {
      print('  ⚠️ No completed workouts found!');
      // Still create/update the stats entry with zeros
      await database
          .into(database.userStats)
          .insertOnConflictUpdate(
            UserStatsCompanion.insert(
              userId: uid,
              totalWorkouts: const Value(0),
              currentStreak: const Value(0),
              longestStreak: const Value(0),
              totalVolumeLifted: const Value(0),
              totalSetsCompleted: const Value(0),
              experiencePoints: const Value(0),
              level: const Value(1),
              lastWorkoutDate: const Value(null),
            ),
          );
      final updated = await database.getUserStats(uid);
      if (updated == null) {
        throw StateError('Failed to create user stats');
      }
      return updated;
    }

    // Calculate totals
    final totalWorkouts = workouts.length;
    final totalVolume = workouts.fold<double>(
      0,
      (sum, w) => sum + w.totalVolume,
    );
    final totalSets = workouts.fold<int>(0, (sum, w) => sum + w.totalSets);

    print('  Total workouts: $totalWorkouts');
    print('  Total volume: ${totalVolume.toStringAsFixed(1)} kg');
    print('  Total sets: $totalSets');

    // Calculate streak
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workedOutToday = workouts.any((w) {
      final workoutDate = DateTime(
        w.startedAt.year,
        w.startedAt.month,
        w.startedAt.day,
      );
      return workoutDate.isAtSameMomentAs(today);
    });

    // Get existing stats
    final existing = await database.getUserStats(uid);
    final currentStreak = workedOutToday
        ? ((existing?.currentStreak ?? 0) > 0 ? (existing!.currentStreak) : 1)
        : 0;
    final longestStreak =
        existing != null && existing.longestStreak > currentStreak
        ? existing.longestStreak
        : currentStreak;

    print('  Current streak: $currentStreak days');
    print('  Longest streak: $longestStreak days');

    // Update or insert user stats
    await database
        .into(database.userStats)
        .insertOnConflictUpdate(
          UserStatsCompanion.insert(
            userId: uid,
            totalWorkouts: Value(totalWorkouts),
            currentStreak: Value(currentStreak),
            longestStreak: Value(longestStreak),
            totalVolumeLifted: Value(totalVolume),
            totalSetsCompleted: Value(totalSets),
            experiencePoints: Value(
              existing?.experiencePoints ?? totalWorkouts * 100,
            ),
            level: Value(existing?.level ?? 1),
            lastWorkoutDate: Value(
              workouts.isNotEmpty ? workouts.last.completedAt : null,
            ),
          ),
        );

    print('  ✅ User stats updated');

    final updated = await database.getUserStats(uid);
    if (updated == null) {
      throw StateError('Failed to update user stats');
    }

    print(
      '  📊 Final stats: ${updated.totalWorkouts} workouts, ${updated.totalVolumeLifted.toStringAsFixed(1)} kg volume',
    );
    return updated;
  }

  Future<UserStat> initializeUserStats({String? userId}) async {
    final uid = userId ?? defaultUserId;
    if (uid == null) throw StateError('No userId available for gamification');

    final existing = await database.getUserStats(uid);
    if (existing != null) {
      return existing;
    }

    final newStats = UserStatsCompanion.insert(
      userId: uid,
      level: const Value(1),
      experiencePoints: const Value(0),
      currentStreak: const Value(0),
      longestStreak: const Value(0),
      totalWorkouts: const Value(0),
      totalSetsCompleted: const Value(0),
      totalVolumeLifted: const Value(0),
      totalWorkoutMinutes: const Value(0),
    );

    await database.into(database.userStats).insert(newStats);
    return (await database.getUserStats(uid))!;
  }

  // Calculate current streak based on workout dates
  Future<int> calculateCurrentStreak({String? userId}) async {
    final uid = userId ?? defaultUserId;
    if (uid == null) throw StateError('No userId available for gamification');

    // Get all workout sessions ordered by date descending
    // Note: WorkoutSessions doesn't have userId, so we get all sessions
    final sessions = await (database.select(
      database.workoutSessions,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)])).get();

    if (sessions.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;
    final today = DateTime.now();

    for (final session in sessions) {
      final completedAt = session.completedAt;
      if (completedAt == null) continue;

      final sessionDate = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );

      if (lastDate == null) {
        // First session - check if it's today or yesterday
        final daysDiff = today.difference(sessionDate).inDays;
        if (daysDiff > 1) {
          // Streak is broken (last workout was more than 1 day ago)
          return 0;
        }
        streak = 1;
        lastDate = sessionDate;
      } else {
        // Check if this session is exactly 1 day before the last one
        final daysDiff = lastDate.difference(sessionDate).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = sessionDate;
        } else if (daysDiff == 0) {
          // Same day, don't increment streak
          continue;
        } else {
          // Gap in streak, we're done
          break;
        }
      }
    }

    return streak;
  }

  // Award XP to user
  Future<void> awardXp(int xpAmount, {String? userId}) async {
    final uid = userId ?? defaultUserId;
    if (uid == null) throw StateError('No userId available for gamification');
    await initializeUserStats(userId: uid);

    final stats = await database.getUserStats(uid);
    if (stats == null) return;

    final newXp = stats.experiencePoints + xpAmount;
    final newLevel = calculateLevel(newXp);

    await database
        .update(database.userStats)
        .replace(stats.copyWith(experiencePoints: newXp, level: newLevel));
  }

  // Update stats after workout completion
  Future<List<Achievement>> onWorkoutCompleted({
    required int workoutId,
    required int setsCompleted,
    required double volumeLifted,
    required int durationMinutes,
    String? userId,
  }) async {
    final uid = userId ?? defaultUserId;
    if (uid == null) throw StateError('No userId available for gamification');
    await initializeUserStats(userId: uid);

    final stats = await database.getUserStats(uid);
    if (stats == null) return [];

    // Calculate new streak
    final newStreak = await calculateCurrentStreak(userId: uid);
    final newLongestStreak = newStreak > stats.longestStreak
        ? newStreak
        : stats.longestStreak;

    // Update stats
    final updatedStats = stats.copyWith(
      totalWorkouts: stats.totalWorkouts + 1,
      totalSetsCompleted: stats.totalSetsCompleted + setsCompleted,
      totalVolumeLifted: stats.totalVolumeLifted + volumeLifted,
      totalWorkoutMinutes: stats.totalWorkoutMinutes + durationMinutes,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastWorkoutDate: Value(DateTime.now()),
    );

    await database.update(database.userStats).replace(updatedStats);

    // Award base XP for completing workout
    final baseXp = 50 + (setsCompleted * 5); // 50 base + 5 per set
    await awardXp(baseXp, userId: uid);

    // Check for achievements and award bonus XP
    final unlockedAchievements = await checkAchievements(userId: uid);

    return unlockedAchievements;
  }

  // Check and unlock achievements
  Future<List<Achievement>> checkAchievements({String? userId}) async {
    final uid = userId ?? defaultUserId;
    if (uid == null) throw StateError('No userId available for gamification');
    final stats = await database.getUserStats(uid);
    if (stats == null) return [];

    final existingAchievements = await database.getUserAchievements(uid);
    final completedIds = existingAchievements
        .where((a) => a.isCompleted)
        .map((a) => a.achievementId)
        .toSet();

    final newlyUnlocked = <Achievement>[];

    for (final achievement in Achievements.all) {
      if (completedIds.contains(achievement.id)) continue;

      int currentProgress = 0;

      // Calculate progress based on achievement category
      switch (achievement.category) {
        case AchievementCategory.workouts:
          currentProgress = stats.totalWorkouts;
          break;
        case AchievementCategory.streaks:
          currentProgress = stats.longestStreak; // Check against longest streak
          break;
        case AchievementCategory.volume:
          currentProgress = stats.totalVolumeLifted.round();
          break;
        case AchievementCategory.milestones:
          if (achievement.id.startsWith('sets_')) {
            currentProgress = stats.totalSetsCompleted;
          } else if (achievement.id.startsWith('workout_time_')) {
            currentProgress = stats.totalWorkoutMinutes;
          }
          break;
        case AchievementCategory.consistency:
          // Special logic for consistency achievements
          currentProgress = stats.totalWorkouts; // Simplified for now
          break;
      }

      // Update or create achievement progress
      final existingAchievement = existingAchievements
          .where((a) => a.achievementId == achievement.id)
          .firstOrNull;

      final progressPercentage =
          ((currentProgress / achievement.requiredProgress) * 100)
              .clamp(0, 100)
              .toInt();

      if (currentProgress >= achievement.requiredProgress) {
        // Achievement unlocked!
        if (existingAchievement != null) {
          await database
              .update(database.userAchievements)
              .replace(
                existingAchievement.copyWith(
                  progress: 100,
                  isCompleted: true,
                  unlockedAt: DateTime.now(),
                ),
              );
        } else {
          await database
              .into(database.userAchievements)
              .insert(
                UserAchievementsCompanion.insert(
                  userId: uid,
                  achievementId: achievement.id,
                  progress: const Value(100),
                  isCompleted: const Value(true),
                  unlockedAt: Value(DateTime.now()),
                ),
              );
        }

        // Award XP for achievement
        await awardXp(achievement.xpReward, userId: uid);
        newlyUnlocked.add(achievement);
      } else {
        // Update progress
        if (existingAchievement != null) {
          await database
              .update(database.userAchievements)
              .replace(
                existingAchievement.copyWith(progress: progressPercentage),
              );
        } else {
          await database
              .into(database.userAchievements)
              .insert(
                UserAchievementsCompanion.insert(
                  userId: uid,
                  achievementId: achievement.id,
                  progress: Value(progressPercentage),
                  isCompleted: const Value(false),
                ),
              );
        }
      }
    }

    return newlyUnlocked;
  }

  // Get achievement progress summary
  Future<Map<String, dynamic>> getAchievementProgress({String? userId}) async {
    final uid = userId ?? defaultUserId;
    if (uid == null) throw StateError('No userId available for gamification');
    final userAchievements = await database.getUserAchievements(uid);

    final completed = userAchievements.where((a) => a.isCompleted).length;
    final total = Achievements.all.length;
    final inProgress = userAchievements
        .where((a) => !a.isCompleted && a.progress > 0)
        .length;

    return {
      'completed': completed,
      'total': total,
      'inProgress': inProgress,
      'completionPercentage': (completed / total * 100).round(),
    };
  }
}

// Database extension methods
extension GamificationQueries on AppDatabase {
  // Watch user stats
  Stream<UserStat?> watchUserStats(String userId) => (select(
    userStats,
  )..where((tbl) => tbl.userId.equals(userId))).watchSingleOrNull();

  // Get user stats
  Future<UserStat?> getUserStats(String userId) => (select(
    userStats,
  )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();

  // Watch user achievements
  Stream<List<UserAchievement>> watchUserAchievements(String userId) => (select(
    userAchievements,
  )..where((tbl) => tbl.userId.equals(userId))).watch();

  // Get user achievements
  Future<List<UserAchievement>> getUserAchievements(String userId) => (select(
    userAchievements,
  )..where((tbl) => tbl.userId.equals(userId))).get();
}
