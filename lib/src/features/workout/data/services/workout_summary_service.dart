import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/services/user_context_service.dart';
import '../../domain/models/active_workout.dart';
import '../../domain/models/workout_summary.dart';

/// Service for calculating workout summaries and detecting personal records
class WorkoutSummaryService {
  WorkoutSummaryService(this.database);
  final AppDatabase database;

  /// Calculate comprehensive workout summary with PR detection
  Future<WorkoutSummary> calculateSummary({
    required ActiveWorkout workout,
    required Duration duration,
  }) async {
    // Calculate basic stats
    final exercises = await _calculateExerciseSummaries(workout);
    final prs = await _detectPersonalRecords(workout, exercises);
    final achievements = await _calculateAchievements(workout, duration);

    final totalSets = workout.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .length;

    final totalReps = workout.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .fold(0, (sum, set) => sum + set.reps);

    final totalVolume = workout.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted && s.weight != null)
        .fold(
          0.0,
          (sum, set) => sum + (set.weight! * set.reps),
        );

    final totalTonnage = totalVolume; // Same calculation for now

    return WorkoutSummary(
      workoutName: workout.name,
      duration: duration,
      totalSets: totalSets,
      totalReps: totalReps,
      totalVolume: totalVolume,
      totalTonnage: totalTonnage,
      exercises: exercises,
      prs: prs,
      achievements: achievements,
    );
  }

  Future<List<ExerciseSummary>> _calculateExerciseSummaries(
    ActiveWorkout workout,
  ) async {
    final summaries = <ExerciseSummary>[];

    for (final exercise in workout.exercises) {
      final completedSets = exercise.sets.where((s) => s.isCompleted).toList();

      if (completedSets.isEmpty) continue;

      final sets = completedSets.length;
      final totalReps = completedSets.fold(0, (sum, set) => sum + set.reps);
      final maxWeight = completedSets
          .where((s) => s.weight != null)
          .fold<double?>(null, (max, set) {
        if (max == null || set.weight! > max) return set.weight;
        return max;
      });
      final totalVolume = completedSets
          .where((s) => s.weight != null)
          .fold(0.0, (sum, set) => sum + (set.weight! * set.reps));

      summaries.add(
        ExerciseSummary(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          sets: sets,
          totalReps: totalReps,
          maxWeight: maxWeight,
          totalVolume: totalVolume,
        ),
      );
    }

    return summaries;
  }

  Future<List<PersonalRecordAchievement>> _detectPersonalRecords(
    ActiveWorkout workout,
    List<ExerciseSummary> exerciseSummaries,
  ) async {
    final prs = <PersonalRecordAchievement>[];

    for (final exerciseSummary in exerciseSummaries) {
      // Check max weight PR
      if (exerciseSummary.maxWeight != null) {
        final previousMaxWeight = await _getPreviousMaxWeight(
          exerciseSummary.exerciseId,
        );

        if (previousMaxWeight == null ||
            exerciseSummary.maxWeight! > previousMaxWeight) {
          prs.add(
            PersonalRecordAchievement(
              exerciseId: exerciseSummary.exerciseId,
              exerciseName: exerciseSummary.exerciseName,
              type: PRType.maxWeight,
              value: exerciseSummary.maxWeight!,
              previousValue: previousMaxWeight,
              unit: 'kg',
            ),
          );

          // Save PR to database
          await _savePersonalRecord(
            exerciseId: exerciseSummary.exerciseId,
            recordType: 'max_weight',
            value: exerciseSummary.maxWeight!,
            weight: exerciseSummary.maxWeight,
            unit: 'kg',
          );
        }
      }

      // Check total volume PR for this exercise
      if (exerciseSummary.totalVolume != null) {
        final previousMaxVolume = await _getPreviousMaxVolume(
          exerciseSummary.exerciseId,
        );

        if (previousMaxVolume == null ||
            exerciseSummary.totalVolume! > previousMaxVolume) {
          prs.add(
            PersonalRecordAchievement(
              exerciseId: exerciseSummary.exerciseId,
              exerciseName: exerciseSummary.exerciseName,
              type: PRType.totalVolume,
              value: exerciseSummary.totalVolume!,
              previousValue: previousMaxVolume,
              unit: 'kg',
            ),
          );

          // Save PR to database
          await _savePersonalRecord(
            exerciseId: exerciseSummary.exerciseId,
            recordType: 'total_volume',
            value: exerciseSummary.totalVolume!,
            unit: 'kg',
          );
        }
      }

      // Check max reps PR (for bodyweight exercises or same weight)
      final exercise = workout.exercises
          .firstWhere((e) => e.id == exerciseSummary.exerciseId);
      final maxRepsSet = exercise.sets
          .where((s) => s.isCompleted)
          .fold<ActiveSet?>(null, (max, set) {
        if (max == null || set.reps > max.reps) return set;
        return max;
      });

      if (maxRepsSet != null) {
        final previousMaxReps = await _getPreviousMaxReps(
          exerciseSummary.exerciseId,
          maxRepsSet.weight,
        );

        if (previousMaxReps == null || maxRepsSet.reps > previousMaxReps) {
          prs.add(
            PersonalRecordAchievement(
              exerciseId: exerciseSummary.exerciseId,
              exerciseName: exerciseSummary.exerciseName,
              type: PRType.maxReps,
              value: maxRepsSet.reps.toDouble(),
              previousValue: previousMaxReps?.toDouble(),
              unit: 'reps',
            ),
          );

          // Save PR to database
          await _savePersonalRecord(
            exerciseId: exerciseSummary.exerciseId,
            recordType: 'max_reps',
            value: maxRepsSet.reps.toDouble(),
            weight: maxRepsSet.weight,
            reps: maxRepsSet.reps,
            unit: 'reps',
          );
        }
      }
    }

    return prs;
  }

  Future<WorkoutAchievements> _calculateAchievements(
    ActiveWorkout workout,
    Duration duration,
  ) async {
    // Check if all sets were completed
    final totalSets = workout.exercises.expand((e) => e.sets).length;
    final completedSets = workout.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .length;
    final perfectCompletion = totalSets == completedSets && totalSets > 0;

    // Calculate total volume for this workout
    final totalVolume = workout.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted && s.weight != null)
        .fold(0.0, (sum, set) => sum + (set.weight! * set.reps));

    // Check if this is a personal best workout
    final previousBestVolume = await _getPreviousBestTotalVolume();
    final isPersonalBest = totalVolume > 0 &&
        (previousBestVolume == null || totalVolume > previousBestVolume);

    // Check if longest workout
    final previousLongestDuration = await _getPreviousLongestDuration();
    final isLongestWorkout = duration.inSeconds > 0 &&
        (previousLongestDuration == null ||
            duration.inSeconds > previousLongestDuration);

    // Check if most sets
    final previousMostSets = await _getPreviousMostSets();
    final isMostSets = completedSets > 0 &&
        (previousMostSets == null || completedSets > previousMostSets);

    // Calculate workout streak (placeholder - would need date-based logic)
    final streak = await _calculateWorkoutStreak();

    return WorkoutAchievements(
      isPersonalBest: isPersonalBest,
      isLongestWorkout: isLongestWorkout,
      isMostSets: isMostSets,
      perfectCompletion: perfectCompletion,
      streak: streak,
    );
  }

  // Helper methods to query previous records

  Future<double?> _getPreviousMaxWeight(String exerciseId) async {
    final records = await (database.select(database.personalRecords)
          ..where(
            (tbl) =>
                tbl.exerciseId.equals(exerciseId) &
                tbl.recordType.equals('max_weight'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.achievedAt)])
          ..limit(1))
        .get();

    return records.isNotEmpty ? records.first.value : null;
  }

  Future<double?> _getPreviousMaxVolume(String exerciseId) async {
    final records = await (database.select(database.personalRecords)
          ..where(
            (tbl) =>
                tbl.exerciseId.equals(exerciseId) &
                tbl.recordType.equals('total_volume'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.achievedAt)])
          ..limit(1))
        .get();

    return records.isNotEmpty ? records.first.value : null;
  }

  Future<int?> _getPreviousMaxReps(String exerciseId, double? weight) async {
    final records = await (database.select(database.personalRecords)
          ..where(
            (tbl) =>
                tbl.exerciseId.equals(exerciseId) &
                tbl.recordType.equals('max_reps'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.achievedAt)])
          ..limit(1))
        .get();

    return records.isNotEmpty ? records.first.reps : null;
  }

  Future<double?> _getPreviousBestTotalVolume() async {
    final sessions = await (database.select(database.workoutSessions)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.totalVolume)])
          ..limit(1))
        .get();

    return sessions.isNotEmpty ? sessions.first.totalVolume : null;
  }

  Future<int?> _getPreviousLongestDuration() async {
    final sessions = await (database.select(database.workoutSessions)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.totalDurationSeconds)])
          ..limit(1))
        .get();

    return sessions.isNotEmpty ? sessions.first.totalDurationSeconds : null;
  }

  Future<int?> _getPreviousMostSets() async {
    final sessions = await (database.select(database.workoutSessions)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.totalSets)])
          ..limit(1))
        .get();

    return sessions.isNotEmpty ? sessions.first.totalSets : null;
  }

  Future<int> _calculateWorkoutStreak() async {
    final now = DateTime.now();
    final sessions = await (database.select(database.workoutSessions)
          ..where((tbl) => tbl.completedAt.isNotNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)]))
        .get();

    if (sessions.isEmpty) return 1;

    var streak = 1;
    var currentDate = DateTime(now.year, now.month, now.day);

    for (var i = 1; i < sessions.length; i++) {
      final sessionDate = sessions[i].completedAt;
      if (sessionDate == null) break;

      final checkDate = DateTime(
        sessionDate.year,
        sessionDate.month,
        sessionDate.day,
      );

      final difference = currentDate.difference(checkDate).inDays;

      if (difference == 1) {
        streak++;
        currentDate = checkDate;
      } else if (difference > 1) {
        break;
      }
    }

    return streak;
  }

  Future<void> _savePersonalRecord({
    required String exerciseId,
    required String recordType,
    required double value,
    required String unit,
    double? weight,
    int? reps,
  }) async {
    await database.into(database.personalRecords).insert(
          PersonalRecordsCompanion.insert(
            id: const Uuid().v4(),
            userId: UserContextService.instance.getCurrentUserId(), // ✅ USER ISOLATION
            exerciseId: exerciseId,
            recordType: recordType,
            value: value,
            unit: unit,
            weight: Value(weight),
            reps: Value(reps),
            achievedAt: DateTime.now(),
          ),
        );
  }
}
