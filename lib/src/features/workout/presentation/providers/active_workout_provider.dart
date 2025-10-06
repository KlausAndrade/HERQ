import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/models/active_workout.dart';
import 'exercise_timer_preferences_provider.dart';

// Provider for active workout state with real template data
final activeWorkoutProvider = StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkout?>((ref) {
  final database = ref.watch(databaseProvider);
  return ActiveWorkoutNotifier(database, ref);
});

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkout?> {
  final AppDatabase? database;
  final Ref _ref;
  
  ActiveWorkoutNotifier(this.database, this._ref) : super(null);

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
    }
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

  void updateSet(int exerciseIndex, int setIndex, ActiveSet updatedSet) {
    if (state != null) {
      final exercises = List<ActiveExercise>.from(state!.exercises);
      final exercise = exercises[exerciseIndex];
      final sets = List<ActiveSet>.from(exercise.sets);
      sets[setIndex] = updatedSet;
      
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
              ? ActiveSet(number: 1, weight: initialWeight, reps: 0, isCompleted: false)
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
    if (state != null && exerciseIndex >= 0 && exerciseIndex < state!.exercises.length) {
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
      return total + exercise.sets.fold(0.0, (exerciseTotal, set) {
        if (set.isCompleted && set.weight != null) {
          return exerciseTotal + (set.weight! * set.reps);
        }
        return exerciseTotal;
      });
    });
  }

  void finishWorkout() {
    state = null;
  }
}

// Rest timer provider
final restTimerProvider = StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) => RestTimerNotifier());

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  RestTimerNotifier() : super(const RestTimerState());
  Timer? _timer;

  void startTimer(int durationSeconds) {
    _timer?.cancel();
    state = RestTimerState(
      isActive: true,
      remainingSeconds: durationSeconds,
      totalSeconds: durationSeconds,
    );
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = RestTimerState(
          isActive: true,
          remainingSeconds: state.remainingSeconds - 1,
          totalSeconds: state.totalSeconds,
        );
      } else {
        timer.cancel();
        state = const RestTimerState();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    state = const RestTimerState();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class RestTimerState {
  final bool isActive;
  final int remainingSeconds;
  final int totalSeconds;

  const RestTimerState({
    this.isActive = false,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
  });
}