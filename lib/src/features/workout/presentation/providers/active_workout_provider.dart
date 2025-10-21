import 'dart:async';

import 'package:drift/drift.dart' hide JsonKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/services/user_context_service.dart';
import '../../../../core/services/live_activity_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/workout_foreground_service.dart';
import '../../../gamification/data/providers/gamification_provider.dart';
import '../../domain/models/active_workout.dart';
import '../../domain/models/workout_summary.dart';
import 'exercise_timer_preferences_provider.dart';
import 'exercise_variant_preferences_provider.dart';
import 'pr_detection_provider.dart';
import 'workout_checkpoint_provider.dart';
import 'workout_providers.dart';
import 'workout_summary_provider.dart';

// Provider for tracking workout modifications
final workoutModificationsProvider =
    StateNotifierProvider<WorkoutModificationsNotifier, bool>(
        (ref) => WorkoutModificationsNotifier());

class WorkoutModificationsNotifier extends StateNotifier<bool> {
  WorkoutModificationsNotifier() : super(false);

  void markAsModified() {
    state = true;
  }

  void reset() {
    state = false;
  }
}

// Provider for active workout state with real template data
final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkout?>((ref) {
  final database = ref.watch(databaseProvider);
  return ActiveWorkoutNotifier(database, ref);
});

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkout?> {
  ActiveWorkoutNotifier(this.database, this._ref) : super(null) {
    // Listen to state changes to update checkpoint
    addListener(_onStateChanged);
  }
  final AppDatabase? database;
  final Ref _ref;
  final _foregroundService = WorkoutForegroundService();
  Timer? _workoutTimer;
  DateTime? _workoutStartTime;

  void _onStateChanged(ActiveWorkout? workout) {
    if (workout != null) {
      // Save checkpoint when workout state changes
      final checkpointService = _ref.read(workoutCheckpointServiceProvider);
      checkpointService?.saveCheckpoint(workout);
    }
  }

  @override
  void dispose() {
    _stopWorkoutTimer();
    _foregroundService.stopService();
    // Clear any active rest timer when disposing. Wrap in try/catch because
    // reading other providers during dispose can throw if the container is
    // already being torn down in tests.
    try {
      _ref.read(restTimerProvider.notifier).stopTimer();
    } catch (_) {
      // ignore - safe to swallow during dispose
    }
    super.dispose();
  }

  /// Start the workout duration timer
  void _startWorkoutTimer() {
    _stopWorkoutTimer(); // Stop any existing timer
    _workoutStartTime = DateTime.now();

    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != null && _workoutStartTime != null) {
        final elapsed = DateTime.now().difference(_workoutStartTime!);
        state = ActiveWorkout(
          id: state!.id,
          name: state!.name,
          exercises: state!.exercises,
          currentExerciseIndex: state!.currentExerciseIndex,
          elapsedTime: elapsed,
          totalSets: state!.totalSets,
          totalVolume: state!.totalVolume,
        );
      }
    });
  }

  /// Stop the workout duration timer
  void _stopWorkoutTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = null;
  }

  /// Manually adjust the workout elapsed time
  /// This recalculates the start time to reflect the new elapsed duration
  void adjustElapsedTime(Duration newElapsed) {
    if (state != null && _workoutStartTime != null) {
      // Recalculate start time based on new elapsed duration
      _workoutStartTime = DateTime.now().subtract(newElapsed);

      // Update state immediately
      state = ActiveWorkout(
        id: state!.id,
        name: state!.name,
        exercises: state!.exercises,
        currentExerciseIndex: state!.currentExerciseIndex,
        elapsedTime: newElapsed,
        totalSets: state!.totalSets,
        totalVolume: state!.totalVolume,
      );

      print(
        '⏱️ Workout time adjusted to: ${newElapsed.inMinutes}m ${newElapsed.inSeconds % 60}s',
      );
    }
  }

  /// Clear any existing workout and cleanup resources
  Future<void> _clearActiveWorkout() async {
    if (state != null) {
      print('🧹 Clearing existing active workout: ${state!.name}');

      // Stop all services and timers
      _stopWorkoutTimer();
      await _foregroundService.stopService();
      _ref.read(restTimerProvider.notifier).stopTimer();

      // Stop auto-save and delete checkpoint
      final checkpointService = _ref.read(workoutCheckpointServiceProvider);
      await checkpointService?.stopAutoSave();

      // Clear the state
      state = null;
    }
  }

  /// Force clear any leftover checkpoints and reset state
  /// This can be used to recover from inconsistent states
  Future<void> forceCleanup() async {
    print('🧹 Force cleanup - clearing all workout data');

    // Stop all services and timers regardless of state
    await _foregroundService.stopService();
    _ref.read(restTimerProvider.notifier).stopTimer();

    // Force clear checkpoints
    final checkpointService = _ref.read(workoutCheckpointServiceProvider);
    await checkpointService?.stopAutoSave();

    // Clear state
    state = null;

    print('🧹 Force cleanup completed');
  }

  Future<void> startWorkoutFromTemplate(String templateId) async {
    print('🔍 startWorkoutFromTemplate - Starting with templateId: $templateId');
    
    // First, clear any existing workout
    await _clearActiveWorkout();

    final db = database;
    if (db == null) {
      print('🔍 startWorkoutFromTemplate - Database not available');
      throw Exception('Database not available');
    }
    
    print('🔍 startWorkoutFromTemplate - Database available, proceeding with template lookup');

    try {
      print('🔍 startWorkoutFromTemplate - Fetching template from database');
      // Fetch template from database
      final template = await (db.select(db.workoutTemplates)
            ..where((tbl) => tbl.id.equals(templateId)))
          .getSingleOrNull();

      if (template == null) {
        print('🔍 startWorkoutFromTemplate - Template not found: $templateId');
        print('🔍 startWorkoutFromTemplate - Available templates: ${await (db.select(db.workoutTemplates)).get().then((t) => t.map((e) => e.id).toList())}');
        throw Exception('Template not found: $templateId');
      }
      
      print('🔍 startWorkoutFromTemplate - Template found: ${template.name}');
      print('🔍 startWorkoutFromTemplate - Template exerciseIds: ${template.exerciseIds}');
      print('🔍 startWorkoutFromTemplate - Template exerciseIds count: ${template.exerciseIds.length}');

      // Fetch all exercises for this template
      final exercisesList = await (db.select(db.exercises)
            ..where((tbl) => tbl.id.isIn(template.exerciseIds)))
          .get();

      print('🔍 startWorkoutFromTemplate - Found ${exercisesList.length} exercises');
      print('🔍 startWorkoutFromTemplate - Exercise IDs: ${exercisesList.map((e) => e.id).toList()}');

      // Create exercise map for ordering
      final exerciseMap = {for (final ex in exercisesList) ex.id: ex};

      // Check for missing exercises and log warning
      final missingExercises = template.exerciseIds
          .where((id) => !exerciseMap.containsKey(id))
          .toList();
      if (missingExercises.isNotEmpty) {
        print(
          '⚠️ Template "${template.name}" references ${missingExercises.length} missing exercises: $missingExercises',
        );
        print(
          '💡 Tip: Go to Settings → Maintenance → "Reload Templates & Exercises" to load all exercises',
        );
      }

      // Get timer preferences
      final timerPrefs = _ref.read(exerciseTimerPreferencesProvider);
      
      // Get variant preferences
      final variantPrefs = _ref.read(exerciseVariantPreferencesProvider);

      // Create active exercises in template order (skip missing exercises)
      final activeExercises = <ActiveExercise>[];
      for (final id in template.exerciseIds.where(exerciseMap.containsKey)) {
        final exercise = exerciseMap[id]!;

        // Debug: Log exercise type
        print(
          '📝 Loading exercise: ${exercise.name}, Type: ${exercise.exerciseType}',
        );

        // Load saved timer preference or use default (90s)
        final savedTimer = timerPrefs[exercise.id] ?? 90;
        
        // Load saved variant preference or use exercise defaults
        final savedVariant = variantPrefs[exercise.id];
        final equipmentUsed = savedVariant?.equipmentUsed ?? exercise.equipment;
        final variantType = savedVariant?.variantType;

        // Try to fetch last completed set for this exercise from DB and prefill
        final lastSet = await (db.select(db.setEntries)
              ..where((tbl) => tbl.exerciseId.equals(exercise.id))
              ..orderBy([
                (t) => OrderingTerm(
                      expression: t.completedAt,
                      mode: OrderingMode.desc,
                    ),
              ])
              ..limit(1))
            .getSingleOrNull();

        final initialWeight = lastSet?.weight;
        final initialReps = lastSet?.reps ?? 0;

        // Convert lastSet to ActiveSet for previous data display
        ActiveSet? previousSet;
        if (lastSet != null) {
          previousSet = ActiveSet(
            number: lastSet.setNumber,
            weight: lastSet.weight,
            reps: lastSet.reps,
            durationSeconds: lastSet.durationSeconds,
            distance: lastSet.distance,
            assistanceWeight: lastSet.assistanceWeight,
            addedWeight: lastSet.addedWeight,
            rpe: lastSet.rpe,
            isCompleted: true, // Previous set was completed
          );
        }

        // Start with 3 prefilled sets using last completed values (if any)
        // Prefill based on exercise type
        final isDuration = exercise.exerciseType == 'duration';
        final initialDuration =
            isDuration ? (lastSet?.durationSeconds ?? 30) : null;

        activeExercises.add(
          ActiveExercise(
            id: exercise.id,
            name: exercise.name,
            exerciseType: exercise.exerciseType,
            previousSet: previousSet,
            sets: [
              ActiveSet(
                number: 1,
                weight: isDuration ? null : initialWeight,
                reps: isDuration ? 0 : initialReps,
                durationSeconds: initialDuration,
              ),
              ActiveSet(
                number: 2,
                weight: isDuration ? null : initialWeight,
                reps: isDuration ? 0 : initialReps,
                durationSeconds: initialDuration,
              ),
              ActiveSet(
                number: 3,
                weight: isDuration ? null : initialWeight,
                reps: isDuration ? 0 : initialReps,
                durationSeconds: initialDuration,
              ),
            ],
            restTimerSeconds: savedTimer,
            equipmentUsed: equipmentUsed, // Use saved preference or default
            variantType: variantType, // Use saved variant preference
          ),
        );
      }

      state = ActiveWorkout(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        name: template.name,
        exercises: activeExercises,
        totalSets: activeExercises.length * 3,
      );

      print('🔍 startWorkoutFromTemplate - Workout state set successfully');
      print('🔍 startWorkoutFromTemplate - Workout name: ${state?.name}');
      print('🔍 startWorkoutFromTemplate - Exercise count: ${state?.exercises.length}');
      print('🏁 New workout created: ${template.name}');

      // Start the workout duration timer
      _startWorkoutTimer();

      // Reset modifications flag - this is a fresh workout
      _ref.read(workoutModificationsProvider.notifier).reset();

      // Start foreground service to keep app alive
      await _foregroundService.startService(
        workoutName: template.name,
        exerciseCount: activeExercises.length,
      );

      // Start auto-save checkpoint service
      final checkpointService = _ref.read(workoutCheckpointServiceProvider);
      if (checkpointService != null && state != null) {
        checkpointService.startAutoSave(state!);
      }
    } catch (e) {
      print('🔍 startWorkoutFromTemplate - Error occurred: $e');
      print('🔍 startWorkoutFromTemplate - Error type: ${e.runtimeType}');
      
      // Fallback to empty workout if template fetch fails
      state = ActiveWorkout(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Quick Start Workout',
        exercises: const [],
      );

      print('🏁 Fallback workout created: Quick Start Workout');

      // Start the workout duration timer
      _startWorkoutTimer();

      // Reset modifications flag
      _ref.read(workoutModificationsProvider.notifier).reset();

      // Start foreground service even for fallback workout
      await _foregroundService.startService(
        workoutName: 'Quick Start Workout',
        exerciseCount: 0,
      );

      // Start auto-save for fallback workout too
      final checkpointService = _ref.read(workoutCheckpointServiceProvider);
      if (checkpointService != null && state != null) {
        checkpointService.startAutoSave(state!);
      }
    }
  }

  /// Start a workout directly from a list of exercise IDs (no template record)
  Future<void> startWorkoutFromExerciseIds(
    String name,
    List<String> exerciseIds,
  ) async {
    // First, clear any existing workout
    await _clearActiveWorkout();

    final db = database;
    if (db == null) {
      throw Exception('Database not available');
    }

    try {
      // Fetch exercises for the provided IDs
      final exercisesList = exerciseIds.isNotEmpty
          ? await (db.select(db.exercises)
                ..where((tbl) => tbl.id.isIn(exerciseIds)))
              .get()
          : <Exercise>[];

      final exerciseMap = {for (final ex in exercisesList) ex.id: ex};

      // Get timer preferences
      final timerPrefs = _ref.read(exerciseTimerPreferencesProvider);
      
      // Get variant preferences
      final variantPrefs = _ref.read(exerciseVariantPreferencesProvider);

      // Create active exercises in provided order
      final activeExercises = <ActiveExercise>[];
      for (final id in exerciseIds.where(exerciseMap.containsKey)) {
        final exercise = exerciseMap[id]!;
        final savedTimer = timerPrefs[exercise.id] ?? 90;
        
        // Load saved variant preference or use exercise defaults
        final savedVariant = variantPrefs[exercise.id];
        final equipmentUsed = savedVariant?.equipmentUsed ?? exercise.equipment;
        final variantType = savedVariant?.variantType;

        final lastSet = await (db.select(db.setEntries)
              ..where((tbl) => tbl.exerciseId.equals(exercise.id))
              ..orderBy([
                (t) => OrderingTerm(
                      expression: t.completedAt,
                      mode: OrderingMode.desc,
                    ),
              ])
              ..limit(1))
            .getSingleOrNull();

        final initialWeight = lastSet?.weight;
        final initialReps = lastSet?.reps ?? 0;

        // Convert lastSet to ActiveSet for previous data display
        ActiveSet? previousSet;
        if (lastSet != null) {
          previousSet = ActiveSet(
            number: lastSet.setNumber,
            weight: lastSet.weight,
            reps: lastSet.reps,
            durationSeconds: lastSet.durationSeconds,
            distance: lastSet.distance,
            assistanceWeight: lastSet.assistanceWeight,
            addedWeight: lastSet.addedWeight,
            rpe: lastSet.rpe,
            isCompleted: true, // Previous set was completed
          );
        }

        final isDuration = exercise.exerciseType == 'duration';
        final initialDuration =
            isDuration ? (lastSet?.durationSeconds ?? 30) : null;

        activeExercises.add(
          ActiveExercise(
            id: exercise.id,
            name: exercise.name,
            exerciseType: exercise.exerciseType,
            previousSet: previousSet,
            sets: [
              ActiveSet(
                number: 1,
                weight: isDuration ? null : initialWeight,
                reps: isDuration ? 0 : initialReps,
                durationSeconds: initialDuration,
              ),
              ActiveSet(
                number: 2,
                weight: isDuration ? null : initialWeight,
                reps: isDuration ? 0 : initialReps,
                durationSeconds: initialDuration,
              ),
              ActiveSet(
                number: 3,
                weight: isDuration ? null : initialWeight,
                reps: isDuration ? 0 : initialReps,
                durationSeconds: initialDuration,
              ),
            ],
            restTimerSeconds: savedTimer,
            equipmentUsed: equipmentUsed, // Use saved preference or default
            variantType: variantType, // Use saved variant preference
          ),
        );
      }

      state = ActiveWorkout(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        exercises: activeExercises,
        totalSets: activeExercises.length * 3,
      );

      // Start the workout duration timer
      _startWorkoutTimer();

      // Reset modifications flag
      _ref.read(workoutModificationsProvider.notifier).reset();

      // Start foreground service
      await _foregroundService.startService(
        workoutName: name,
        exerciseCount: activeExercises.length,
      );

      // Start auto-save checkpoint service
      final checkpointService = _ref.read(workoutCheckpointServiceProvider);
      if (checkpointService != null && state != null) {
        checkpointService.startAutoSave(state!);
      }
    } catch (e) {
      // Fallback to empty workout
      state = ActiveWorkout(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        exercises: const [],
      );

      // Start the workout duration timer
      _startWorkoutTimer();

      // Reset modifications flag
      _ref.read(workoutModificationsProvider.notifier).reset();

      // Start foreground service even for fallback workout
      await _foregroundService.startService(
        workoutName: name,
        exerciseCount: 0,
      );

      final checkpointService = _ref.read(workoutCheckpointServiceProvider);
      if (checkpointService != null && state != null) {
        checkpointService.startAutoSave(state!);
      }
    }
  }

  /// Resume a workout from a saved checkpoint
  Future<void> resumeWorkout(ActiveWorkout workout) async {
    // First, clear any existing workout
    await _clearActiveWorkout();

    state = workout;

    print('🏁 Workout resumed: ${workout.name}');

    // Restart the workout duration timer
    _startWorkoutTimer();

    // Restart foreground service
    await _foregroundService.startService(
      workoutName: workout.name,
      exerciseCount: workout.exercises.length,
    );

    // Restart auto-save
    final checkpointService = _ref.read(workoutCheckpointServiceProvider);
    checkpointService?.startAutoSave(workout);

    print('✅ Workout resumed: ${workout.name}');
  }

  void setCurrentExercise(int index) {
    if (state != null) {
      state = ActiveWorkout(
        id: state!.id,
        name: state!.name,
        exercises: state!.exercises,
        currentExerciseIndex: index,
        elapsedTime: state!.elapsedTime,
        totalSets: state!.totalSets,
        totalVolume: state!.totalVolume,
      );
    }
  }

  Future<void> updateSet(
    int exerciseIndex,
    int setIndex,
    ActiveSet updatedSet,
  ) async {
    if (state != null) {
      final exercises = List<ActiveExercise>.from(state!.exercises);
      final exercise = exercises[exerciseIndex];
      final sets = List<ActiveSet>.from(exercise.sets);

      // Check for PR if set is being marked as completed
      ActiveSet finalSet = updatedSet;
      if (updatedSet.isCompleted && !exercise.sets[setIndex].isCompleted) {
        // Set just got completed - check for PR
        final prService = _ref.read(prDetectionServiceProvider);
        if (prService != null) {
          // Get all OTHER completed sets from this exercise in current workout
          final currentWorkoutCompletedSets = <Map<String, dynamic>>[];
          for (int i = 0; i < exercise.sets.length; i++) {
            if (i != setIndex && exercise.sets[i].isCompleted) {
              currentWorkoutCompletedSets.add({
                'weight': exercise.sets[i].weight,
                'reps': exercise.sets[i].reps,
              });
            }
          }

          final prResult = await prService.checkSetForPR(
            exerciseId: exercise.id,
            weight: updatedSet.weight,
            reps: updatedSet.reps,
            currentWorkoutSets: currentWorkoutCompletedSets,
          );

          finalSet = ActiveSet(
            number: updatedSet.number,
            weight: updatedSet.weight,
            reps: updatedSet.reps,
            durationSeconds: updatedSet.durationSeconds,
            distance: updatedSet.distance,
            assistanceWeight: updatedSet.assistanceWeight,
            addedWeight: updatedSet.addedWeight,
            rpe: updatedSet.rpe,
            isCompleted: updatedSet.isCompleted,
            isPRWeight: prResult['isPRWeight'] ?? false,
            isPRReps: prResult['isPRReps'] ?? false,
          );
        }
      }

      // Auto-fill logic: when completing ANY set, if no other sets are completed,
      // copy the values to all empty incomplete sets
      if (updatedSet.isCompleted) {
        print('🔄 Set ${updatedSet.number} completed! Checking auto-fill...');
        print(
          '  Updated set values: weight=${updatedSet.weight}, reps=${updatedSet.reps}, duration=${updatedSet.durationSeconds}, distance=${updatedSet.distance}, assistance=${updatedSet.assistanceWeight}, added=${updatedSet.addedWeight}',
        );

        final hadOtherCompleted =
            sets.any((s) => s.isCompleted && s.number != updatedSet.number);
        if (!hadOtherCompleted) {
          print('  ✅ No other completed sets - AUTO-FILL TRIGGERED!');
          for (int i = 0; i < sets.length; i++) {
            if (i != setIndex) {
              final s = sets[i];
              print(
                '  📋 Checking set ${s.number}: weight=${s.weight}, reps=${s.reps}, duration=${s.durationSeconds}, distance=${s.distance}, completed=${s.isCompleted}',
              );

              // Check if set is empty based on what fields have been filled
              // A set is empty if none of the value fields have meaningful data
              final hasWeight = s.weight != null && s.weight! > 0;
              final hasReps = s.reps > 0;
              final hasDuration =
                  s.durationSeconds != null && s.durationSeconds! > 0;
              final hasDistance = s.distance != null && s.distance! > 0;
              final hasAssistance =
                  s.assistanceWeight != null && s.assistanceWeight! != 0;
              final hasAdded = s.addedWeight != null && s.addedWeight! > 0;

              final isEmpty = !hasWeight &&
                  !hasReps &&
                  !hasDuration &&
                  !hasDistance &&
                  !hasAssistance &&
                  !hasAdded;

              print(
                '    hasWeight=$hasWeight, hasReps=$hasReps, hasDuration=$hasDuration, hasDistance=$hasDistance, isEmpty=$isEmpty',
              );

              if (!s.isCompleted && isEmpty) {
                print(
                  '  ✅ Auto-filling set ${s.number} with values from set ${updatedSet.number}',
                );
                sets[i] = ActiveSet(
                  number: s.number,
                  weight: updatedSet.weight,
                  reps: updatedSet.reps,
                  durationSeconds: updatedSet.durationSeconds,
                  distance: updatedSet.distance,
                  assistanceWeight: updatedSet.assistanceWeight,
                  addedWeight: updatedSet.addedWeight,
                  rpe: s.rpe,
                  isCompleted: s.isCompleted,
                );
                print(
                  '    Set ${s.number} after auto-fill: weight=${sets[i].weight}, reps=${sets[i].reps}, duration=${sets[i].durationSeconds}, distance=${sets[i].distance}',
                );
              } else {
                print('  ⏭️ Skipping set ${s.number} (not empty or completed)');
              }
            }
          }
        } else {
          print('  ⏭️ Auto-fill skipped (other sets already completed)');
        }
      }

      // Update the specific set and apply the PR/completion changes
      sets[setIndex] = finalSet;

      exercises[exerciseIndex] = ActiveExercise(
        id: exercise.id,
        name: exercise.name,
        sets: sets,
        restTimerSeconds: exercise.restTimerSeconds,
        exerciseType: exercise.exerciseType, // 🔧 FIX: Preserve exercise type!
        equipmentUsed: exercise.equipmentUsed,
        variantType: exercise.variantType,
      );

      state = ActiveWorkout(
        id: state!.id,
        name: state!.name,
        exercises: exercises,
        currentExerciseIndex: state!.currentExerciseIndex,
        elapsedTime: state!.elapsedTime,
        totalSets: _calculateTotalSets(exercises),
        totalVolume: _calculateTotalVolume(exercises),
      );

      // Update foreground service notification with progress
      if (_foregroundService.isRunning) {
        final completedExercises = exercises
            .where((e) => e.sets.every((s) => s.isCompleted || s.reps == 0))
            .length;
        await _foregroundService.updateService(
          workoutName: state!.name,
          completedExercises: completedExercises,
          totalExercises: exercises.length,
        );
      }
    }
  }

  void addSet(int exerciseIndex) {
    if (state != null) {
      final exercises = List<ActiveExercise>.from(state!.exercises);
      final exercise = exercises[exerciseIndex];
      final sets = List<ActiveSet>.from(exercise.sets);

      // Add new set using last completed set as template if available
      ActiveSet? templateSet;
      for (int i = sets.length - 1; i >= 0; i--) {
        if (sets[i].isCompleted) {
          templateSet = sets[i];
          break;
        }
      }
      templateSet ??= (sets.isNotEmpty ? sets.last : null);

      sets.add(
        ActiveSet(
          number: sets.length + 1,
          weight: templateSet?.weight,
          reps: templateSet?.reps ?? 0,
          durationSeconds: templateSet?.durationSeconds,
          distance: templateSet?.distance,
          assistanceWeight: templateSet?.assistanceWeight,
          addedWeight: templateSet?.addedWeight,
        ),
      );

      exercises[exerciseIndex] = ActiveExercise(
        id: exercise.id,
        name: exercise.name,
        sets: sets,
        restTimerSeconds: exercise.restTimerSeconds,
        exerciseType: exercise.exerciseType, // 🔧 FIX: Preserve exercise type!
        equipmentUsed: exercise.equipmentUsed,
        variantType: exercise.variantType,
      );

      state = ActiveWorkout(
        id: state!.id,
        name: state!.name,
        exercises: exercises,
        currentExerciseIndex: state!.currentExerciseIndex,
        elapsedTime: state!.elapsedTime,
        totalSets: _calculateTotalSets(exercises),
        totalVolume: _calculateTotalVolume(exercises),
      );

      // Mark as modified
      _ref.read(workoutModificationsProvider.notifier).markAsModified();
    }
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (state != null) {
      final exercises = List<ActiveExercise>.from(state!.exercises);
      final exercise = exercises[exerciseIndex];
      final sets = List<ActiveSet>.from(exercise.sets);

      // Don't allow removing the last set
      if (sets.length <= 1) {
        return;
      }

      // Remove the set at the specified index
      sets.removeAt(setIndex);

      // Renumber remaining sets
      final renumberedSets = sets.asMap().entries.map((entry) {
        final idx = entry.key;
        final set = entry.value;
        return ActiveSet(
          number: idx + 1,
          weight: set.weight,
          reps: set.reps,
          durationSeconds: set.durationSeconds,
          distance: set.distance,
          assistanceWeight: set.assistanceWeight,
          addedWeight: set.addedWeight,
          rpe: set.rpe,
          isCompleted: set.isCompleted,
          isPRWeight: set.isPRWeight,
          isPRReps: set.isPRReps,
        );
      }).toList();

      exercises[exerciseIndex] = ActiveExercise(
        id: exercise.id,
        name: exercise.name,
        sets: renumberedSets,
        restTimerSeconds: exercise.restTimerSeconds,
        exerciseType: exercise.exerciseType, // 🔧 FIX: Preserve exercise type!
      );

      state = ActiveWorkout(
        id: state!.id,
        name: state!.name,
        exercises: exercises,
        currentExerciseIndex: state!.currentExerciseIndex,
        elapsedTime: state!.elapsedTime,
        totalSets: _calculateTotalSets(exercises),
        totalVolume: _calculateTotalVolume(exercises),
      );

      // Mark as modified
      _ref.read(workoutModificationsProvider.notifier).markAsModified();
    }
  }

  Future<void> addExercise(
    String exerciseId, {
    double? initialWeight,
    int restTimerSeconds = 90,
    bool isAssisted = false,
  }) async {
    final db = database;
    if (state != null && db != null) {
      try {
        // Find exercise by ID
        final exercise = await (db.select(db.exercises)
              ..where((tbl) => tbl.id.equals(exerciseId)))
            .getSingleOrNull();

        final exercises = List<ActiveExercise>.from(state!.exercises);

        if (exercise != null) {
          // Add exercise from database with initial weight if provided
          final initialSet = initialWeight != null
              ? ActiveSet(
                  number: 1,
                  weight: initialWeight,
                  reps: 0,
                )
              : const ActiveSet(number: 1, reps: 0);

          exercises.add(
            ActiveExercise(
              id: exercise.id,
              name: exercise.name,
              exerciseType: exercise.exerciseType,
              sets: [initialSet],
              restTimerSeconds: restTimerSeconds,
              equipmentUsed: exercise.equipment,
            ),
          );
        } else {
          // Fallback: create custom exercise
          exercises.add(
            ActiveExercise(
              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
              name: exerciseId,
              sets: const [ActiveSet(number: 1, reps: 0)],
              restTimerSeconds: restTimerSeconds,
            ),
          );
        }

        state = ActiveWorkout(
          id: state!.id,
          name: state!.name,
          exercises: exercises,
          currentExerciseIndex: state!.currentExerciseIndex,
          elapsedTime: state!.elapsedTime,
          totalSets: _calculateTotalSets(exercises),
          totalVolume: _calculateTotalVolume(exercises),
        );

        // Mark as modified
        _ref.read(workoutModificationsProvider.notifier).markAsModified();
      } catch (e) {
        // On error, add as custom exercise
        final exercises = List<ActiveExercise>.from(state!.exercises);
        exercises.add(
          ActiveExercise(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            name: exerciseId,
            sets: const [ActiveSet(number: 1, reps: 0)],
            restTimerSeconds: restTimerSeconds,
          ),
        );

        state = ActiveWorkout(
          id: state!.id,
          name: state!.name,
          exercises: exercises,
          currentExerciseIndex: state!.currentExerciseIndex,
          elapsedTime: state!.elapsedTime,
          totalSets: _calculateTotalSets(exercises),
          totalVolume: _calculateTotalVolume(exercises),
        );

        // Mark as modified
        _ref.read(workoutModificationsProvider.notifier).markAsModified();
      }
    }
  }

  void updateExerciseRestTimer(int exerciseIndex, int newRestTimerSeconds) {
    if (state != null &&
        exerciseIndex >= 0 &&
        exerciseIndex < state!.exercises.length) {
      final exercises = List<ActiveExercise>.from(state!.exercises);
      final exercise = exercises[exerciseIndex];

      exercises[exerciseIndex] = ActiveExercise(
        id: exercise.id,
        name: exercise.name,
        sets: exercise.sets,
        restTimerSeconds: newRestTimerSeconds,
        exerciseType: exercise.exerciseType, // 🔧 FIX: Preserve exercise type!
      );

      state = ActiveWorkout(
        id: state!.id,
        name: state!.name,
        exercises: exercises,
        currentExerciseIndex: state!.currentExerciseIndex,
        elapsedTime: state!.elapsedTime,
        totalSets: state!.totalSets,
        totalVolume: state!.totalVolume,
      );

      // Save timer preference for this exercise
      _ref.read(exerciseTimerPreferencesProvider.notifier).setTimerForExercise(
            exercise.id,
            newRestTimerSeconds,
          );
    }
  }

  /// Update equipment and variant type for an exercise
  void updateExerciseVariant(
    int exerciseIndex, {
    String? equipmentUsed,
    String? variantType,
  }) {
    if (state != null &&
        exerciseIndex >= 0 &&
        exerciseIndex < state!.exercises.length) {
      final exercises = List<ActiveExercise>.from(state!.exercises);
      final exercise = exercises[exerciseIndex];

      print('🔄 Updating exercise variant:');
      print('   Exercise: ${exercise.name}');
      print(
        '   Old equipment: ${exercise.equipmentUsed} → New: $equipmentUsed',
      );
      print('   Old variant: ${exercise.variantType} → New: $variantType');

      exercises[exerciseIndex] = ActiveExercise(
        id: exercise.id,
        name: exercise.name,
        sets: exercise.sets,
        restTimerSeconds: exercise.restTimerSeconds,
        exerciseType: exercise.exerciseType,
        equipmentUsed: equipmentUsed, // Use new value directly (can be null)
        variantType: variantType, // Use new value directly (can be null)
      );

      state = ActiveWorkout(
        id: state!.id,
        name: state!.name,
        exercises: exercises,
        currentExerciseIndex: state!.currentExerciseIndex,
        elapsedTime: state!.elapsedTime,
        totalSets: state!.totalSets,
        totalVolume: state!.totalVolume,
      );

      // Save variant preference for this exercise
      if (equipmentUsed != null) {
        _ref.read(exerciseVariantPreferencesProvider.notifier).setVariantForExercise(
          exercise.id,
          equipmentUsed,
          variantType,
        );
      }

      // Mark as modified
      _ref.read(workoutModificationsProvider.notifier).markAsModified();

      print('✅ Exercise variant updated successfully');
    }
  }

  /// Reorder exercises during an active workout
  void reorderExercises(int oldIndex, int newIndex) {
    if (state == null) return;

    final exercises = List<ActiveExercise>.from(state!.exercises);
    if (oldIndex < 0 ||
        oldIndex >= exercises.length ||
        newIndex < 0 ||
        newIndex >= exercises.length) {
      return;
    }

    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);

    // Update current exercise index if needed
    int currentIndex = state!.currentExerciseIndex;
    if (currentIndex == oldIndex) {
      currentIndex = newIndex;
    } else if (oldIndex < currentIndex && newIndex >= currentIndex) {
      currentIndex--;
    } else if (oldIndex > currentIndex && newIndex <= currentIndex) {
      currentIndex++;
    }

    state = ActiveWorkout(
      id: state!.id,
      name: state!.name,
      exercises: exercises,
      currentExerciseIndex: currentIndex,
      elapsedTime: state!.elapsedTime,
      totalSets: state!.totalSets,
      totalVolume: state!.totalVolume,
    );

    // Mark as modified
    _ref.read(workoutModificationsProvider.notifier).markAsModified();

    // Checkpoint is automatically saved via state listener
  }

  int _calculateTotalSets(List<ActiveExercise> exercises) =>
      exercises.fold(0, (total, exercise) => total + exercise.sets.length);

  double _calculateTotalVolume(List<ActiveExercise> exercises) =>
      exercises.fold(
        0,
        (total, exercise) =>
            total +
            exercise.sets.fold(0.0, (exerciseTotal, set) {
              if (set.isCompleted && set.weight != null) {
                return exerciseTotal + (set.weight! * set.reps);
              }
              return exerciseTotal;
            }),
      );

  Future<WorkoutSummary?> finishWorkout() async {
    print('🏁 Starting finishWorkout...');
    if (state == null) {
      print('❌ No active workout to finish');
      return null;
    }

    final db = database;
    if (db == null) {
      print('❌ Database is null, clearing state');
      // Just clear state if no database
      state = null;
      return null;
    }

    final workout = state!;
    final now = DateTime.now();
    final sessionId = const Uuid().v4();

    print('🏁 Finishing workout: ${workout.name}');

    try {
      // Calculate workout summary before saving (with timeout)
      final summaryService = _ref.read(workoutSummaryServiceProvider);
      print(
        '🏁 Summary service: ${summaryService != null ? 'available' : 'null'}',
      );

      WorkoutSummary? summary;
      try {
        summary = summaryService != null
            ? await summaryService
                .calculateSummary(
                workout: workout,
                duration: workout.elapsedTime,
              )
                .timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                  print('⚠️ Summary calculation timed out after 5s');
                  throw TimeoutException('Summary calculation timed out');
                },
              )
            : null;
      } catch (e) {
        print('⚠️ Error calculating summary: $e');
        summary = null;
      }

      print('🏁 Summary calculated: ${summary != null ? 'success' : 'null'}');

      // Calculate workout stats
      final totalSets = _calculateTotalSets(workout.exercises);
      final totalVolume = _calculateTotalVolume(workout.exercises);
      final totalReps = workout.exercises
          .expand((e) => e.sets)
          .where((s) => s.isCompleted)
          .fold(0, (sum, set) => sum + set.reps);
      final totalTonnage = workout.exercises
          .expand((e) => e.sets)
          .where((s) => s.isCompleted && s.weight != null)
          .fold(0.0, (sum, set) => sum + (set.weight! * set.reps));

      // Create fallback summary if service failed
      if (summary == null && totalSets > 0) {
        print('🏁 Creating fallback summary');
        summary = WorkoutSummary(
          workoutName: workout.name,
          duration: workout.elapsedTime,
          totalSets: totalSets,
          totalReps: totalReps,
          totalVolume: totalVolume,
          totalTonnage: totalTonnage,
          exercises: workout.exercises.map((e) {
            final completedSets = e.sets.where((s) => s.isCompleted).toList();
            final exerciseVolume = completedSets
                .where((s) => s.weight != null)
                .fold<double>(0, (sum, s) => sum + (s.weight! * s.reps));
            final maxWeight = completedSets
                .map((s) => s.weight)
                .whereType<double>()
                .fold<double?>(
                  null,
                  (max, w) => max == null || w > max ? w : max,
                );

            return ExerciseSummary(
              exerciseId: e.id,
              exerciseName: e.name,
              sets: completedSets.length,
              totalReps: completedSets.fold<int>(0, (sum, s) => sum + s.reps),
              maxWeight: maxWeight,
              totalVolume: exerciseVolume,
            );
          }).toList(),
          prs: const [],
          achievements: WorkoutAchievements(
            perfectCompletion: workout.isFullyCompleted(),
          ),
          sessionId: sessionId,
        );
      } else if (summary != null) {
        // Add sessionId to existing summary from service
        summary = WorkoutSummary(
          workoutName: summary.workoutName,
          duration: summary.duration,
          totalSets: summary.totalSets,
          totalReps: summary.totalReps,
          totalVolume: summary.totalVolume,
          totalTonnage: summary.totalTonnage,
          exercises: summary.exercises,
          prs: summary.prs,
          achievements: summary.achievements,
          sessionId: sessionId,
        );
      }

      // Save workout session to database
      print('💾 Saving workout session to local DB...');
      try {
        await db.into(db.workoutSessions).insert(
              WorkoutSessionsCompanion.insert(
                id: sessionId,
                userId: UserContextService.instance
                    .getCurrentUserId(), // ✅ USER ISOLATION
                name: workout.name,
                startedAt: now.subtract(workout.elapsedTime),
                completedAt: Value(now),
                totalDurationSeconds: Value(workout.elapsedTime.inSeconds),
                totalVolume: Value(totalVolume),
                totalTonnage: Value(totalTonnage),
                totalSets: Value(totalSets),
                totalReps: Value(totalReps),
              ),
            );
        print('✅ Workout session saved');
      } catch (e, stackTrace) {
        print('❌ Error saving workout session: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }

      // Save all completed sets to database
      print('💾 Saving ${workout.exercises.length} exercises with sets...');
      try {
        for (final exercise in workout.exercises) {
          for (final set in exercise.sets.where((s) => s.isCompleted)) {
            print('  💾 Saving ${exercise.name} set ${set.number}...');
            await db.into(db.setEntries).insert(
                  SetEntriesCompanion.insert(
                    id: const Uuid().v4(),
                    userId: UserContextService.instance
                        .getCurrentUserId(), // ✅ USER ISOLATION
                    workoutSessionId: sessionId,
                    exerciseId: exercise.id,
                    setNumber: set.number,
                    weight: Value(set.weight),
                    reps: set.reps,
                    durationSeconds: Value(set.durationSeconds),
                    distance: Value(set.distance),
                    assistanceWeight: Value(set.assistanceWeight),
                    addedWeight: Value(set.addedWeight),
                    rpe: Value(set.rpe),
                    equipmentUsed: Value(exercise.equipmentUsed),
                    variantType: Value(exercise.variantType),
                    completedAt: now,
                  ),
                );
          }
        }
        print('✅ All sets saved');
      } catch (e, stackTrace) {
        print('❌ Error saving set entries: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }

      // 🌩️ SYNC TO SUPABASE (background sync for cross-platform access)
      try {
        print('☁️ Attempting Supabase sync...');

        // Wrap entire Supabase sync in timeout
        await Future(() async {
          final supabase = _ref.read(supabaseClientProvider);
          final user = supabase.auth.currentUser;

          if (user != null) {
            print('☁️ User authenticated, syncing workout to Supabase...');

            // Sync workout session
            await supabase.from('workout_sessions').insert({
              'id': sessionId,
              'user_id': user.id,
              'name': workout.name,
              'started_at': now.subtract(workout.elapsedTime).toIso8601String(),
              'completed_at': now.toIso8601String(),
              'total_duration_seconds': workout.elapsedTime.inSeconds,
              'total_volume': totalVolume,
              'total_tonnage': totalTonnage,
              'total_sets': totalSets,
              'total_reps': totalReps,
            });

            // Sync exercises first (if they don't exist in Supabase)
            print('☁️ Syncing ${workout.exercises.length} exercises to Supabase...');
            for (final exercise in workout.exercises) {
              try {
                print('  🔍 Checking if exercise exists: ${exercise.id} (${exercise.name})');
                
                // Check if exercise exists in Supabase
                final existingExercise = await supabase
                    .from('exercises')
                    .select('id')
                    .eq('id', exercise.id)
                    .maybeSingle();

                if (existingExercise == null) {
                  // Exercise doesn't exist, create it
                  print('  📝 Creating new exercise: ${exercise.id}');
                  
                  await supabase.from('exercises').insert({
                    'id': exercise.id,
                    'name': exercise.name,
                    'exercise_type': exercise.exerciseType,
                    'equipment': exercise.equipmentUsed ?? 'bodyweight',
                    'primary_muscle_group': 'other',
                    'secondary_muscle_groups': '{}', // PostgreSQL array format
                    'instructions': '',
                    'category': 'Other',
                    'difficulty': 'intermediate',
                    'aliases': '{}', // PostgreSQL array format
                    'tags': '{}', // PostgreSQL array format
                    'user_id': null,
                  });
                  print('  ✅ Synced exercise: ${exercise.name} (${exercise.id})');
                } else {
                  print('  ✓ Exercise already exists: ${exercise.name} (${exercise.id})');
                }
              } catch (e, stackTrace) {
                print('  ❌ ERROR syncing exercise ${exercise.name} (${exercise.id}): $e');
                print('  Stack: $stackTrace');
                // Continue with other exercises even if one fails
              }
            }
            print('☁️ Finished syncing exercises');

            // Sync all completed sets
            print('☁️ Syncing set entries to Supabase...');
            final setEntries = <Map<String, dynamic>>[];
            for (final exercise in workout.exercises) {
              for (final set in exercise.sets.where((s) => s.isCompleted)) {
                setEntries.add({
                  'id': const Uuid().v4(),
                  'user_id': user.id,
                  'workout_session_id': sessionId,
                  'exercise_id': exercise.id,
                  'set_number': set.number,
                  'weight': set.weight,
                  'reps': set.reps,
                  'duration_seconds': set.durationSeconds,
                  'distance': set.distance,
                  'completed': true, // Fixed: was 'is_completed'
                  'rpe': set.rpe,
                  'notes': null,
                  'assistance_weight': set.assistanceWeight,
                  'added_weight': set.addedWeight,
                });
              }
            }

            if (setEntries.isNotEmpty) {
              await supabase.from('set_entries').insert(setEntries);
              print('  ✅ Synced ${setEntries.length} set entries');
            }

            print('✅ Workout synced to Supabase successfully');
          } else {
            print('⚠️ Not authenticated - workout saved locally only');
          }
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print(
              '⚠️ Supabase sync timed out after 10s - continuing with local save',
            );
          },
        );
      } catch (syncError) {
        // Don't fail the workout save if cloud sync fails
        print('⚠️ Cloud sync failed (offline?): $syncError');
        print('💾 Workout saved locally - will sync when online');
      }

      // Update gamification stats (with timeout)
      print('🎮 Updating gamification stats...');
      final gamificationService = _ref.read(gamificationServiceProvider);
      if (gamificationService != null) {
        try {
          final currentUser = _ref.read(currentUserProvider);
          final uid = currentUser?.id;
          await gamificationService
              .onWorkoutCompleted(
            workoutId: 0, // Using 0 as placeholder
            setsCompleted: totalSets,
            volumeLifted: totalVolume,
            durationMinutes: workout.elapsedTime.inMinutes,
            userId: uid,
          )
              .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⚠️ Gamification update timed out after 5s');
              throw TimeoutException('Gamification update timed out');
            },
          );
          print('✅ Gamification stats updated');

          // Sync stats to Supabase for multi-user leaderboards
          if (uid != null) {
            print('🌐 Syncing stats to Supabase for leaderboards...');
            try {
              final syncService = _ref.read(workoutSyncServiceProvider);
              if (syncService != null) {
                await syncService.syncUserStats(uid).timeout(
                  const Duration(seconds: 5),
                  onTimeout: () {
                    print('⚠️ Supabase sync timed out after 5s');
                    throw TimeoutException('Supabase sync timed out');
                  },
                );
                print('✅ Stats synced to Supabase');
              } else {
                print('⚠️ Sync service not available');
              }
            } catch (e) {
              print('⚠️ Non-critical Supabase sync error: $e');
              // Don't throw - sync errors shouldn't block workout save
            }
          }
        } catch (e) {
          // Log error but don't block workout completion
          print('⚠️ Error updating gamification stats: $e');
        }
      }

      // Stop the workout duration timer
      _stopWorkoutTimer();

      // Clear the active workout FIRST (before cleanup to prevent race conditions)
      state = null;

      print(
        '🏁 Workout finished successfully. Summary: ${summary != null ? 'available' : 'null'}',
      );

      // Do cleanup in background (don't await - let it happen asynchronously)
      Future.microtask(() async {
        print('🧹 Starting background cleanup...');

        try {
          // Stop foreground service
          await _foregroundService
              .stopService()
              .timeout(const Duration(seconds: 3));
          print('✅ Foreground service stopped');
        } catch (e) {
          print('⚠️ Error stopping foreground service: $e');
        }

        try {
          // Stop auto-save and delete checkpoint
          final checkpointService = _ref.read(workoutCheckpointServiceProvider);
          await checkpointService
              ?.stopAutoSave()
              .timeout(const Duration(seconds: 3));
          print('✅ Checkpoint cleared');
        } catch (e) {
          print('⚠️ Error clearing checkpoint: $e');
        }

        try {
          // Clear any active rest timer
          _ref.read(restTimerProvider.notifier).stopTimer();
          print('✅ Rest timer stopped');
        } catch (e) {
          print('⚠️ Error stopping rest timer: $e');
        }

        try {
          // Invalidate providers to refresh UI with new data
          _ref.invalidate(workoutSessionsProvider);
          _ref.invalidate(recentWorkoutSessionsProvider);
          _ref.invalidate(weeklyStatsProvider);
          _ref.invalidate(workoutStatsProvider);
          _ref.invalidate(workoutSessionsByMonthProvider);
          print('✅ Providers invalidated');
        } catch (e) {
          print('⚠️ Error invalidating providers: $e');
        }

        print('🧹 Background cleanup completed');
      });

      // Return immediately with summary (don't wait for cleanup)
      return summary;
    } catch (e) {
      print('❌ Error finishing workout: $e');

      // Ensure cleanup happens even if save failed
      try {
        await _foregroundService.stopService();
        final checkpointService = _ref.read(workoutCheckpointServiceProvider);
        await checkpointService?.stopAutoSave();
        _ref.read(restTimerProvider.notifier).stopTimer();
      } catch (cleanupError) {
        print('❌ Error during cleanup: $cleanupError');
      }

      // Still clear state even if save failed
      state = null;
      rethrow;
    }
  }

  /// Remove an exercise from the active workout
  void removeExercise(int exerciseIndex) {
    if (state != null && exerciseIndex >= 0 && exerciseIndex < state!.exercises.length) {
      final exercises = List<ActiveExercise>.from(state!.exercises);
      exercises.removeAt(exerciseIndex);

      // Update current exercise index if needed
      int currentIndex = state!.currentExerciseIndex;
      if (exerciseIndex == currentIndex) {
        // If we removed the current exercise, move to the next one or previous one
        if (exercises.isNotEmpty) {
          currentIndex = currentIndex >= exercises.length ? exercises.length - 1 : currentIndex;
        } else {
          currentIndex = 0;
        }
      } else if (exerciseIndex < currentIndex) {
        currentIndex--;
      }

      state = ActiveWorkout(
        id: state!.id,
        name: state!.name,
        exercises: exercises,
        currentExerciseIndex: currentIndex,
        elapsedTime: state!.elapsedTime,
        totalSets: _calculateTotalSets(exercises),
        totalVolume: _calculateTotalVolume(exercises),
      );

      // Mark as modified
      _ref.read(workoutModificationsProvider.notifier).markAsModified();
    }
  }

  /// Add an exercise at a specific position in the workout
  Future<void> addExerciseAtPosition(
    String exerciseId,
    int position, {
    double? initialWeight,
    int restTimerSeconds = 90,
    bool isAssisted = false,
  }) async {
    final db = database;
    if (state != null && db != null) {
      try {
        // Find exercise by ID
        final exercise = await (db.select(db.exercises)
              ..where((tbl) => tbl.id.equals(exerciseId)))
            .getSingleOrNull();

        if (exercise == null) {
          print('❌ Exercise not found: $exerciseId');
          return;
        }

        // Get the last completed set for this exercise to use as template
        final lastSet = await (db.select(db.setEntries)
              ..where((tbl) =>
                  tbl.exerciseId.equals(exerciseId) &
                  tbl.userId.equals(UserContextService.instance.getCurrentUserId()))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)])
              ..limit(1))
            .getSingleOrNull();

        // Create initial set based on last completed set or defaults
        final initialSet = ActiveSet(
          number: 1,
          weight: initialWeight ?? lastSet?.weight,
          reps: lastSet?.reps ?? 0,
          durationSeconds: lastSet?.durationSeconds,
          distance: lastSet?.distance,
          assistanceWeight: isAssisted ? (lastSet?.assistanceWeight ?? -10.0) : null,
          addedWeight: lastSet?.addedWeight,
        );

        final newActiveExercise = ActiveExercise(
          id: exercise.id,
          name: exercise.name,
          sets: [initialSet],
          restTimerSeconds: restTimerSeconds,
          exerciseType: exercise.exerciseType,
          equipmentUsed: exercise.equipment,
          variantType: isAssisted ? 'assisted' : null,
        );

        // Insert at the specified position
        final exercises = List<ActiveExercise>.from(state!.exercises);
        exercises.insert(position, newActiveExercise);

        state = ActiveWorkout(
          id: state!.id,
          name: state!.name,
          exercises: exercises,
          currentExerciseIndex: state!.currentExerciseIndex,
          elapsedTime: state!.elapsedTime,
          totalSets: _calculateTotalSets(exercises),
          totalVolume: _calculateTotalVolume(exercises),
        );

        // Mark as modified
        _ref.read(workoutModificationsProvider.notifier).markAsModified();
      } catch (e) {
        print('❌ Error adding exercise: $e');
      }
    }
  }
}

// Rest timer provider
final restTimerProvider =
    StateNotifierProvider<RestTimerNotifier, RestTimerState>(
  (ref) => RestTimerNotifier(),
);

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  RestTimerNotifier() : super(const RestTimerState()) {
    // Listen to notification actions
    _actionSubscription = timerActionStreamController.stream.listen((action) {
      switch (action) {
        case 'add_15':
          addTime(15);
          break;
        case 'subtract_15':
          subtractTime(15);
          break;
        case 'skip':
          stopTimer();
          _onTimerComplete();
          break;
      }
    });
  }

  Timer? _timer;
  StreamSubscription<String>? _actionSubscription;
  final NotificationService _notificationService = NotificationService();
  LiveActivityService? _liveActivityService;

  void startTimer(
    int durationSeconds, {
    String? exerciseName,
    int? currentSet,
    int? totalSets,
    int? targetReps,
    LiveActivityService? liveActivityService,
  }) {
    _timer?.cancel();
    _liveActivityService = liveActivityService;

    state = RestTimerState(
      isActive: true,
      remainingSeconds: durationSeconds,
      totalSeconds: durationSeconds,
      exerciseName: exerciseName,
      currentSet: currentSet,
      totalSets: totalSets,
      targetReps: targetReps,
    );

    // Start live activity if service provided, otherwise fallback to notification
    if (_liveActivityService != null &&
        exerciseName != null &&
        currentSet != null &&
        totalSets != null &&
        targetReps != null) {
      _liveActivityService!.startTimerActivity(
        exerciseName: exerciseName,
        currentSet: currentSet,
        totalSets: totalSets,
        targetReps: targetReps,
        remainingSeconds: durationSeconds,
      );

      // Listen for action button taps
      _actionSubscription?.cancel();
      _actionSubscription = _liveActivityService!.actionStream.listen((action) {
        switch (action) {
          case 'subtract_15':
            subtractTime(15);
            break;
          case 'add_15':
            addTime(15);
            break;
          case 'skip':
            skipTimer();
            break;
        }
      });
    } else {
      // Fallback to regular notification
      _notificationService.showTimerNotification(
        remainingSeconds: durationSeconds,
        totalSeconds: durationSeconds,
        exerciseName: exerciseName,
        currentSet: currentSet,
        totalSets: totalSets,
        targetReps: targetReps,
      );
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        final newRemainingSeconds = state.remainingSeconds - 1;
        state = RestTimerState(
          isActive: true,
          remainingSeconds: newRemainingSeconds,
          totalSeconds: state.totalSeconds,
          exerciseName: state.exerciseName,
          currentSet: state.currentSet,
          totalSets: state.totalSets,
          targetReps: state.targetReps,
        );

        // Update live activity or notification every 5 seconds or when <= 10 seconds remaining
        // This reduces updates while keeping it responsive at the end
        if (newRemainingSeconds % 5 == 0 || newRemainingSeconds <= 10) {
          if (_liveActivityService != null) {
            _liveActivityService!.updateTimer(
              remainingSeconds: newRemainingSeconds,
            );
          } else {
            _notificationService.showTimerNotification(
              remainingSeconds: newRemainingSeconds,
              totalSeconds: state.totalSeconds,
              exerciseName: state.exerciseName,
              currentSet: state.currentSet,
              totalSets: state.totalSets,
              targetReps: state.targetReps,
            );
          }
        }
      } else {
        timer.cancel();
        state = const RestTimerState();
        // Timer complete - send notification and vibrate
        _onTimerComplete();
      }
    });
  }

  Future<void> _onTimerComplete() async {
    // End live activity or cancel notification
    if (_liveActivityService != null) {
      await _liveActivityService!.endTimerActivity();
      _actionSubscription?.cancel();
    } else {
      await _notificationService.cancelTimerNotification();
    }

    // Show completion notification
    await _notificationService.showTimerCompleteNotification(
      title: '⏰ Rest Timer Complete!',
      body: 'Time to start your next set! 💪',
    );

    // Vibrate device
    await _notificationService.vibrateTimerComplete();
  }

  void stopTimer() {
    _timer?.cancel();
    state = const RestTimerState();
    // Cancel notification when timer is stopped
    _notificationService.cancelTimerNotification();
  }

  /// Add 15 seconds to the timer
  void addTime(int seconds) {
    if (state.isActive) {
      final newRemainingSeconds = state.remainingSeconds + seconds;
      state = RestTimerState(
        isActive: true,
        remainingSeconds: newRemainingSeconds,
        totalSeconds: state.totalSeconds,
        exerciseName: state.exerciseName,
        currentSet: state.currentSet,
        totalSets: state.totalSets,
        targetReps: state.targetReps,
      );

      // Update live activity or notification immediately to show new time
      if (_liveActivityService != null) {
        _liveActivityService!.updateTimer(
          remainingSeconds: newRemainingSeconds,
        );
      } else {
        _notificationService.showTimerNotification(
          remainingSeconds: newRemainingSeconds,
          totalSeconds: state.totalSeconds,
          exerciseName: state.exerciseName,
          currentSet: state.currentSet,
          totalSets: state.totalSets,
          targetReps: state.targetReps,
        );
      }
    }
  }

  /// Subtract 15 seconds from the timer (minimum 0)
  void subtractTime(int seconds) {
    if (state.isActive) {
      final newRemainingSeconds =
          (state.remainingSeconds - seconds).clamp(0, state.totalSeconds);

      if (newRemainingSeconds == 0) {
        // Timer completed by user action
        stopTimer();
        _onTimerComplete();
      } else {
        state = RestTimerState(
          isActive: true,
          remainingSeconds: newRemainingSeconds,
          totalSeconds: state.totalSeconds,
          exerciseName: state.exerciseName,
          currentSet: state.currentSet,
          totalSets: state.totalSets,
          targetReps: state.targetReps,
        );

        // Update live activity or notification immediately to show new time
        if (_liveActivityService != null) {
          _liveActivityService!.updateTimer(
            remainingSeconds: newRemainingSeconds,
          );
        } else {
          _notificationService.showTimerNotification(
            remainingSeconds: newRemainingSeconds,
            totalSeconds: state.totalSeconds,
            exerciseName: state.exerciseName,
            currentSet: state.currentSet,
            totalSets: state.totalSets,
            targetReps: state.targetReps,
          );
        }
      }
    }
  }

  /// Skip the timer and go to completion
  void skipTimer() {
    if (state.isActive) {
      stopTimer();
      _onTimerComplete();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _actionSubscription?.cancel();
    super.dispose();
  }
}

class RestTimerState {
  const RestTimerState({
    this.isActive = false,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.exerciseName,
    this.currentSet,
    this.totalSets,
    this.targetReps,
  });
  final bool isActive;
  final int remainingSeconds;
  final int totalSeconds;
  final String? exerciseName;
  final int? currentSet;
  final int? totalSets;
  final int? targetReps;
}
