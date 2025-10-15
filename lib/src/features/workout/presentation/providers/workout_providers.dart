import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/user_context_service.dart';

// Provider for all workout sessions (with cloud sync)
final workoutSessionsProvider =
    FutureProvider<List<WorkoutSession>>((ref) async {
  final database = ref.read(databaseProvider);
  final supabase = ref.read(supabaseClientProvider);

  if (database == null) {
    return [];
  }

  // 🌩️ SYNC: Fetch latest from Supabase first
  try {
    final user = supabase.auth.currentUser;
    if (user != null) {
      print('☁️ Fetching workouts from Supabase...');

      final cloudData = await supabase
          .from('workout_sessions')
          .select()
          .eq('user_id', user.id)
          .order('started_at', ascending: false);

      // Merge cloud data into local database
      for (final session in cloudData) {
        try {
          await database.into(database.workoutSessions).insertOnConflictUpdate(
                WorkoutSession(
                  id: session['id'],
                  userId: UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
                  templateId: session['template_id'],
                  name: session['name'],
                  notes: session['notes'],
                  startedAt: DateTime.parse(session['started_at']),
                  completedAt: session['completed_at'] != null
                      ? DateTime.parse(session['completed_at'])
                      : null,
                  totalDurationSeconds: session['total_duration_seconds'],
                  totalVolume: session['total_volume']?.toDouble() ?? 0.0,
                  totalTonnage: session['total_tonnage']?.toDouble() ?? 0.0,
                  totalSets: session['total_sets'] ?? 0,
                  totalReps: session['total_reps'] ?? 0,
                  createdAt: session['created_at'] != null
                      ? DateTime.parse(session['created_at'])
                      : DateTime.now(),
                  updatedAt: session['updated_at'] != null
                      ? DateTime.parse(session['updated_at'])
                      : DateTime.now(),
                ),
              );
        } catch (e) {
          print('⚠️ Error syncing session ${session['id']}: $e');
        }
      }

      print('✅ Synced ${cloudData.length} workouts from cloud');
    }
  } catch (e) {
    print('⚠️ Cloud sync failed, using local data: $e');
  }

  // Return merged local + cloud data - FILTER BY CURRENT USER
  final currentUserId = UserContextService.instance.getCurrentUserId();
  final sessions = await (database.select(database.workoutSessions)
        ..where((tbl) => tbl.userId.equals(currentUserId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
      .get();

  return sessions;
});

// Provider for a single workout session by ID
final workoutSessionByIdProvider =
    FutureProvider.family<WorkoutSession?, String>((ref, sessionId) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return null;
  }

  final currentUserId = UserContextService.instance.getCurrentUserId();
  final results = await (database.select(database.workoutSessions)
        ..where((tbl) => tbl.id.equals(sessionId) & tbl.userId.equals(currentUserId)))
      .get();

  return results.isNotEmpty ? results.first : null;
});

// Provider for workout template by ID
final workoutTemplateByIdProvider =
    FutureProvider.family<WorkoutTemplate?, String>((ref, templateId) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return null;
  }

  final results = await (database.select(database.workoutTemplates)
        ..where((tbl) => tbl.id.equals(templateId)))
      .get();

  return results.isNotEmpty ? results.first : null;
});

// Provider for set entries in a workout session
final setEntriesBySessionProvider =
    FutureProvider.family<List<SetEntry>, String>((ref, sessionId) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }

  final sets = await (database.select(database.setEntries)
        ..where((tbl) => tbl.workoutSessionId.equals(sessionId))
        ..orderBy([
          (tbl) => OrderingTerm.asc(tbl.exerciseId),
          (tbl) => OrderingTerm.asc(tbl.setNumber),
        ]))
      .get();

  return sets;
});

// Provider for exercise count in a workout session
final exerciseCountBySessionProvider =
    FutureProvider.family<int, String>((ref, sessionId) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return 0;
  }

  final sets = await (database.select(database.setEntries)
        ..where((tbl) => tbl.workoutSessionId.equals(sessionId)))
      .get();

  // Get unique exercise IDs
  final uniqueExerciseIds = sets.map((set) => set.exerciseId).toSet();
  return uniqueExerciseIds.length;
});

// Provider for workout statistics
final workoutStatsProvider = FutureProvider<WorkoutStats>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return WorkoutStats.empty();
  }

  final sessions = await database.select(database.workoutSessions).get();
  final completedSessions =
      sessions.where((s) => s.completedAt != null).toList();

  if (completedSessions.isEmpty) {
    return WorkoutStats.empty();
  }

  final totalWorkouts = completedSessions.length;
  final totalDuration = completedSessions
      .where((s) => s.totalDurationSeconds != null)
      .fold(0, (sum, s) => sum + (s.totalDurationSeconds ?? 0));

  final totalVolume =
      completedSessions.fold(0.0, (sum, s) => sum + s.totalVolume);

  final totalTonnage =
      completedSessions.fold(0.0, (sum, s) => sum + s.totalTonnage);

  final avgDuration = totalDuration > 0 ? totalDuration / totalWorkouts : 0;

  // Calculate streak (consecutive days with workouts)
  final sortedSessions = completedSessions
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  int currentStreak = 0;
  DateTime? lastWorkoutDate;

  for (final session in sortedSessions) {
    final sessionDate = DateTime(
      session.startedAt.year,
      session.startedAt.month,
      session.startedAt.day,
    );

    if (lastWorkoutDate == null) {
      // First workout
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (sessionDate == todayDate ||
          sessionDate == todayDate.subtract(const Duration(days: 1))) {
        currentStreak = 1;
        lastWorkoutDate = sessionDate;
      } else {
        break;
      }
    } else {
      final expectedDate = lastWorkoutDate.subtract(const Duration(days: 1));

      if (sessionDate == expectedDate || sessionDate == lastWorkoutDate) {
        if (sessionDate == expectedDate) {
          currentStreak++;
        }
        lastWorkoutDate = sessionDate;
      } else {
        break;
      }
    }
  }

  return WorkoutStats(
    totalWorkouts: totalWorkouts,
    averageDurationMinutes: (avgDuration / 60).round(),
    totalVolumeKg: totalVolume,
    totalTonnage: totalTonnage,
    currentStreak: currentStreak,
  );
});

// Provider for recent workout sessions (last 10)
final recentWorkoutSessionsProvider =
    FutureProvider<List<WorkoutSession>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }

  final sessions = await (database.select(database.workoutSessions)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)])
        ..limit(10))
      .get();

  return sessions;
});

// Provider for workout sessions grouped by month
final workoutSessionsByMonthProvider =
    FutureProvider<Map<String, List<WorkoutSession>>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return {};
  }

  final sessions = await (database.select(database.workoutSessions)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
      .get();

  final groupedSessions = <String, List<WorkoutSession>>{};

  for (final session in sessions) {
    final monthKey =
        '${session.startedAt.year}-${session.startedAt.month.toString().padLeft(2, '0')}';
    groupedSessions.putIfAbsent(monthKey, () => []).add(session);
  }

  return groupedSessions;
});

// Provider for this week's workout statistics
final weeklyStatsProvider = FutureProvider<WeeklyStats>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return WeeklyStats.empty();
  }

  // Get start of current week (Monday)
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final startOfWeekDate =
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final endOfWeekDate = startOfWeekDate.add(const Duration(days: 7));

  // Get workout sessions for this week
  final sessions = await (database.select(database.workoutSessions)
        ..where(
          (tbl) =>
              tbl.startedAt.isBiggerOrEqualValue(startOfWeekDate) &
              tbl.startedAt.isSmallerThanValue(endOfWeekDate),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
      .get();

  final completedSessions =
      sessions.where((s) => s.completedAt != null).toList();

  if (completedSessions.isEmpty) {
    return WeeklyStats.empty();
  }

  // Calculate total volume from all sets in these sessions
  double totalVolume = 0;
  int totalPRs = 0;

  for (final session in completedSessions) {
    final sets = await (database.select(database.setEntries)
          ..where((tbl) => tbl.workoutSessionId.equals(session.id)))
        .get();

    for (final set in sets) {
      if (set.weight != null) {
        totalVolume += set.weight! * set.reps;
      }
    }

    // For now, assume each completed workout contributes to PRs
    // This would need to be calculated properly by comparing with previous bests
    totalPRs += (completedSessions.length * 0.3).round(); // Rough estimate
  }

  return WeeklyStats(
    workoutsCount: completedSessions.length,
    totalVolumeKg: totalVolume,
    prsSet:
        totalPRs.clamp(0, completedSessions.length * 2), // Cap PRs reasonably
  );
});

// Data class for weekly workout statistics
class WeeklyStats {
  const WeeklyStats({
    required this.workoutsCount,
    required this.totalVolumeKg,
    required this.prsSet,
  });

  factory WeeklyStats.empty() => const WeeklyStats(
        workoutsCount: 0,
        totalVolumeKg: 0,
        prsSet: 0,
      );

  final int workoutsCount;
  final double totalVolumeKg;
  final int prsSet;

  String get formattedVolume {
    if (totalVolumeKg >= 1000) {
      return '${(totalVolumeKg / 1000).toStringAsFixed(1)}k kg';
    }
    return '${totalVolumeKg.toStringAsFixed(0)} kg';
  }
}

// Data class for workout statistics
class WorkoutStats {
  const WorkoutStats({
    required this.totalWorkouts,
    required this.averageDurationMinutes,
    required this.totalVolumeKg,
    required this.totalTonnage,
    required this.currentStreak,
  });

  factory WorkoutStats.empty() => const WorkoutStats(
        totalWorkouts: 0,
        averageDurationMinutes: 0,
        totalVolumeKg: 0,
        totalTonnage: 0,
        currentStreak: 0,
      );

  final int totalWorkouts;
  final int averageDurationMinutes;
  final double totalVolumeKg;
  final double totalTonnage;
  final int currentStreak;
}
