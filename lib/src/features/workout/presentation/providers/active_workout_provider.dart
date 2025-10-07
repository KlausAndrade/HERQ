import 'dart:async';
import 'package:drift/drift.dart' hide JsonKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/live_activity_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/workout_foreground_service.dart';
import '../../domain/models/active_workout.dart';
import '../../domain/models/workout_summary.dart';
import 'exercise_timer_preferences_provider.dart';
import 'workout_providers.dart';
import 'workout_summary_provider.dart';
import 'workout_checkpoint_provider.dart';
import 'pr_detection_provider.dart';
import '../../../gamification/data/providers/gamification_provider.dart';

// Provider for active workout state with real template data
final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkout?>((ref) {
  final database = ref.watch(databaseProvider);
  return ActiveWorkoutNotifier(database, ref);
});

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkout?> {
  final AppDatabase? database;
  final Ref _ref;
  final _foregroundService = WorkoutForegroundService();

  ActiveWorkoutNotifier(this.database, this._ref) : super(null) {
    // Listen to state changes to update checkpoint
    addListener(_onStateChanged);
  }

  void _onStateChanged(ActiveWorkout? workout) {
    if (workout != null) {
      // Save checkpoint when workout state changes
      final checkpointService = _ref.read(workoutCheckpointServiceProvider);
      checkpointService?.saveCheckpoint(workout);
    }
  }

  @override
  void dispose() {
    _foregroundService.stopService();
    super.dispose();
  }

  Future<void> startWorkoutFromTemplate(String templateId) async {
    final db = database;
    if (db == null) {
      throw Exception('Database not available');
    }

    try {
      // Fetch template from database
      final template = await (db.select(db.workoutTemplates)
            ..where((tbl) => tbl.id.equals(templateId)))
          .getSingleOrNull();

      if (template == null) {
        throw Exception('Template not found: $templateId');
      }

      // Fetch all exercises for this template
      final exercisesList = await (db.select(db.exercises)
            ..where((tbl) => tbl.id.isIn(template.exerciseIds)))
          .get();

      // Create exercise map for ordering
      final exerciseMap = {for (final ex in exercisesList) ex.id: ex};

      // Get timer preferences
      final timerPrefs = _ref.read(exerciseTimerPreferencesProvider);

      // Create active exercises in template order
      final activeExercises = template.exerciseIds
          .where((id) => exerciseMap.containsKey(id))
          .map((id) {
        final exercise = exerciseMap[id]!;
        // Load saved timer preference or use default (90s)
        final savedTimer = timerPrefs[exercise.id] ?? 90;

        // Start with 3 empty sets for each exercise
        return ActiveExercise(
          id: exercise.id,
          name: exercise.name,
          sets: const [
            ActiveSet(number: 1, reps: 0, isCompleted: false),
            ActiveSet(number: 2, reps: 0, isCompleted: false),
            ActiveSet(number: 3, reps: 0, isCompleted: false),
          ],
          restTimerSeconds: savedTimer,
        );
      }).toList();

      state = ActiveWorkout(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        name: template.name,
        exercises: activeExercises,
        elapsedTime: const Duration(),
        totalSets: activeExercises.length * 3,
        totalVolume: 0,
      );

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
      // Fallback to empty workout if template fetch fails
      state = ActiveWorkout(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Quick Start Workout',
        exercises: const [],
        elapsedTime: const Duration(),
        totalSets: 0,
        totalVolume: 0,
      );

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

  /// Resume a workout from a saved checkpoint
  Future<void> resumeWorkout(ActiveWorkout workout) async {
    state = workout;
    
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

  Future<void> updateSet(int exerciseIndex, int setIndex, ActiveSet updatedSet) async {
    if (state != null) {
      final exercises = List<ActiveExercise>.from(state!.exercises);
      final exercise = exercises[exerciseIndex];
      
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
            rpe: updatedSet.rpe,
            isCompleted: updatedSet.isCompleted,
            isPRWeight: prResult['isPRWeight'] ?? false,
            isPRReps: prResult['isPRReps'] ?? false,
          );
        }
      }
      
      final sets = List<ActiveSet>.from(exercise.sets);
      sets[setIndex] = finalSet;

      exercises[exerciseIndex] = ActiveExercise(
        id: exercise.id,
        name: exercise.name,
        sets: sets,
        restTimerSeconds: exercise.restTimerSeconds,
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
        final completedExercises = exercises.where((e) => 
          e.sets.every((s) => s.isCompleted || s.reps == 0)).length;
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

      // Add new set with previous set's values as template
      final lastSet = sets.isNotEmpty ? sets.last : null;
      sets.add(ActiveSet(
        number: sets.length + 1,
        weight: lastSet?.weight,
        reps: lastSet?.reps ?? 0,
        isCompleted: false,
      ));

      exercises[exerciseIndex] = ActiveExercise(
        id: exercise.id,
        name: exercise.name,
        sets: sets,
        restTimerSeconds: exercise.restTimerSeconds,
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
                  number: 1, weight: initialWeight, reps: 0, isCompleted: false)
              : const ActiveSet(number: 1, reps: 0, isCompleted: false);

          exercises.add(ActiveExercise(
            id: exercise.id,
            name: exercise.name,
            sets: [initialSet],
            restTimerSeconds: restTimerSeconds,
          ));
        } else {
          // Fallback: create custom exercise
          exercises.add(ActiveExercise(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            name: exerciseId,
            sets: const [ActiveSet(number: 1, reps: 0, isCompleted: false)],
            restTimerSeconds: restTimerSeconds,
          ));
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
      } catch (e) {
        // On error, add as custom exercise
        final exercises = List<ActiveExercise>.from(state!.exercises);
        exercises.add(ActiveExercise(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: exerciseId,
          sets: const [ActiveSet(number: 1, reps: 0, isCompleted: false)],
          restTimerSeconds: restTimerSeconds,
        ));

        state = ActiveWorkout(
          id: state!.id,
          name: state!.name,
          exercises: exercises,
          currentExerciseIndex: state!.currentExerciseIndex,
          elapsedTime: state!.elapsedTime,
          totalSets: _calculateTotalSets(exercises),
          totalVolume: _calculateTotalVolume(exercises),
        );
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

  int _calculateTotalSets(List<ActiveExercise> exercises) {
    return exercises.fold(0, (total, exercise) => total + exercise.sets.length);
  }

  double _calculateTotalVolume(List<ActiveExercise> exercises) {
    return exercises.fold(0.0, (total, exercise) {
      return total +
          exercise.sets.fold(0.0, (exerciseTotal, set) {
            if (set.isCompleted && set.weight != null) {
              return exerciseTotal + (set.weight! * set.reps);
            }
            return exerciseTotal;
          });
    });
  }

  Future<WorkoutSummary?> finishWorkout() async {
    if (state == null) return null;

    final db = database;
    if (db == null) {
      // Just clear state if no database
      state = null;
      return null;
    }

    final workout = state!;
    final now = DateTime.now();
    final sessionId = const Uuid().v4();

    try {
      // Calculate workout summary before saving
      final summaryService = _ref.read(workoutSummaryServiceProvider);
      final summary = summaryService != null
          ? await summaryService.calculateSummary(
              workout: workout,
              duration: workout.elapsedTime,
            )
          : null;
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

      // Save workout session to database
      await db.into(db.workoutSessions).insert(
            WorkoutSessionsCompanion.insert(
              id: sessionId,
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

      // Save all completed sets to database
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets.where((s) => s.isCompleted)) {
          await db.into(db.setEntries).insert(
                SetEntriesCompanion.insert(
                  id: const Uuid().v4(),
                  workoutSessionId: sessionId,
                  exerciseId: exercise.id,
                  setNumber: set.number,
                  weight: Value(set.weight),
                  reps: set.reps,
                  rpe: Value(set.rpe),
                  completedAt: now,
                ),
              );
        }
      }

      // Update gamification stats
      final gamificationService = _ref.read(gamificationServiceProvider);
      if (gamificationService != null) {
        try {
          await gamificationService.onWorkoutCompleted(
            workoutId: 0, // Using 0 as placeholder
            setsCompleted: totalSets,
            volumeLifted: totalVolume,
            durationMinutes: workout.elapsedTime.inMinutes,
          );
        } catch (e) {
          // Log error but don't block workout completion
          print('Error updating gamification stats: $e');
        }
      }

      // Invalidate providers to refresh UI with new data
      _ref.invalidate(workoutSessionsProvider);
      _ref.invalidate(recentWorkoutSessionsProvider);
      _ref.invalidate(weeklyStatsProvider);
      _ref.invalidate(workoutStatsProvider);
      _ref.invalidate(workoutSessionsByMonthProvider);

      // Stop foreground service
      await _foregroundService.stopService();

      // Stop auto-save and delete checkpoint (workout completed successfully)
      final checkpointService = _ref.read(workoutCheckpointServiceProvider);
      await checkpointService?.stopAutoSave(deleteCheckpoint: true);

      // Clear the active workout
      state = null;
      
      return summary;
    } catch (e) {
      print('Error finishing workout: $e');
      // Still clear state even if save failed
      state = null;
      rethrow;
    }
  }
}

// Rest timer provider
final restTimerProvider =
    StateNotifierProvider<RestTimerNotifier, RestTimerState>(
        (ref) => RestTimerNotifier());

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
    if (_liveActivityService != null && exerciseName != null && currentSet != null && totalSets != null && targetReps != null) {
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
      final newRemainingSeconds = (state.remainingSeconds - seconds).clamp(0, state.totalSeconds);
      
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
  final bool isActive;
  final int remainingSeconds;
  final int totalSeconds;
  final String? exerciseName;
  final int? currentSet;
  final int? totalSets;
  final int? targetReps;

  const RestTimerState({
    this.isActive = false,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.exerciseName,
    this.currentSet,
    this.totalSets,
    this.targetReps,
  });
}
