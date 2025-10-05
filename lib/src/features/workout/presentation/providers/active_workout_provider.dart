import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/active_workout.dart';

// Mock provider for active workout state
final activeWorkoutProvider = StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkout?>((ref) => ActiveWorkoutNotifier());

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkout?> {
  ActiveWorkoutNotifier() : super(null);

  void startWorkoutFromTemplate(String templateId) {
    // Mock implementation - would fetch template and create active workout
    final mockExercises = [
      const ActiveExercise(
        id: 'bench_press',
        name: 'Bench Press',
        sets: [
          ActiveSet(number: 1, weight: 80, reps: 10),
          ActiveSet(number: 2, weight: 80, reps: 10),
          ActiveSet(number: 3, weight: 80, reps: 10),
        ],
      ),
      const ActiveExercise(
        id: 'overhead_press',
        name: 'Overhead Press',
        sets: [
          ActiveSet(number: 1, weight: 50, reps: 8),
          ActiveSet(number: 2, weight: 50, reps: 8),
        ],
      ),
    ];

    state = ActiveWorkout(
      id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
      name: _getTemplateName(templateId),
      exercises: mockExercises,
      elapsedTime: const Duration(minutes: 15),
      totalSets: 5,
      totalVolume: 650,
    );
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

  void addExercise(String exerciseName) {
    if (state != null) {
      final exercises = List<ActiveExercise>.from(state!.exercises);
      exercises.add(ActiveExercise(
        id: 'exercise_${DateTime.now().millisecondsSinceEpoch}',
        name: exerciseName,
        sets: [const ActiveSet(number: 1, reps: 0, isCompleted: false)],
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

  String _getTemplateName(String templateId) {
    switch (templateId) {
      case 'push_day':
        return 'Push Day';
      case 'pull_day':
        return 'Pull Day';
      case 'leg_day':
        return 'Leg Day';
      default:
        return 'Workout';
    }
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