import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';

class PRDetectionService {
  PRDetectionService(this.database);
  final AppDatabase database;

  /// Check if a set is a PR for weight or reps
  /// Returns a map with 'isPRWeight' and 'isPRReps' flags
  ///
  /// currentWorkoutSets: Other completed sets in the current active workout (to exclude from PR check)
  Future<Map<String, bool>> checkSetForPR({
    required String exerciseId,
    required double? weight,
    required int reps,
    List<Map<String, dynamic>>?
        currentWorkoutSets, // Sets from current workout to exclude
  }) async {
    // If no weight or reps, can't be a PR
    if (weight == null || weight <= 0 || reps <= 0) {
      return {'isPRWeight': false, 'isPRReps': false};
    }

    try {
      // Get all previous sets for this exercise across all COMPLETED workouts only
      final query = database.select(database.setEntries).join([
        innerJoin(
          database.workoutSessions,
          database.workoutSessions.id
              .equalsExp(database.setEntries.workoutSessionId),
        ),
      ])
        ..where(database.setEntries.exerciseId.equals(exerciseId))
        ..where(database.workoutSessions.completedAt.isNotNull())
        ..orderBy([
          OrderingTerm(
            expression: database.workoutSessions.startedAt,
            mode: OrderingMode.desc,
          ),
        ]);

      final results = await query.get();
      final previousSets =
          results.map((row) => row.readTable(database.setEntries)).toList();

      // Also consider completed sets from current workout
      double maxWeight = 0;
      int maxRepsAtCurrentWeight = 0;
      bool hasDataAtCurrentOrHigherWeight = false;

      // First, check against current workout's completed sets
      if (currentWorkoutSets != null && currentWorkoutSets.isNotEmpty) {
        for (final set in currentWorkoutSets) {
          final setWeight = set['weight'] as double? ?? 0;
          final setReps = set['reps'] as int? ?? 0;

          // Find max weight in current workout
          if (setWeight > maxWeight) {
            maxWeight = setWeight;
          }

          // Find max reps at current weight or heavier in current workout
          if (setWeight >= weight) {
            hasDataAtCurrentOrHigherWeight = true;
            if (setReps > maxRepsAtCurrentWeight) {
              maxRepsAtCurrentWeight = setReps;
            }
          }
        }
      }

      // Then check against historical completed workouts
      if (previousSets.isEmpty &&
          (currentWorkoutSets == null || currentWorkoutSets.isEmpty)) {
        // First time doing this exercise ever - it's a PR!
        return {'isPRWeight': true, 'isPRReps': true};
      }

      // Check historical sets
      for (final set in previousSets) {
        final setWeight = set.weight ?? 0;
        final setReps = set.reps;

        // Find max weight ever lifted (including history)
        if (setWeight > maxWeight) {
          maxWeight = setWeight;
        }

        // Find max reps at current weight or heavier (including history)
        if (setWeight >= weight) {
          hasDataAtCurrentOrHigherWeight = true;
          if (setReps > maxRepsAtCurrentWeight) {
            maxRepsAtCurrentWeight = setReps;
          }
        }
      }

      final isPRWeight = weight > maxWeight;
      // Only count as reps PR if we have data at this weight or heavier AND we beat it
      final isPRReps =
          hasDataAtCurrentOrHigherWeight && reps > maxRepsAtCurrentWeight;

      return {
        'isPRWeight': isPRWeight,
        'isPRReps': isPRReps,
      };
    } catch (e) {
      // On error, assume no PR
      return {'isPRWeight': false, 'isPRReps': false};
    }
  }
}
