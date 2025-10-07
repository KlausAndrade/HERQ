import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../domain/models/active_workout.dart';
import '../../domain/models/workout_summary.dart';
import 'workout_web_sessions_provider.dart';

// Web-only active workout provider (uses Supabase only)
final activeWorkoutWebProvider =
    StateNotifierProvider<ActiveWorkoutWebNotifier, ActiveWorkout?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ActiveWorkoutWebNotifier(supabase, ref);
});

class ActiveWorkoutWebNotifier extends StateNotifier<ActiveWorkout?> {
  final SupabaseClient supabase;
  final Ref _ref;

  ActiveWorkoutWebNotifier(this.supabase, this._ref) : super(null);

  @override
  void dispose() {
    _ref.read(restTimerWebProvider.notifier).stopTimer();
    super.dispose();
  }

  Future<void> _clearActiveWorkout() async {
    if (state != null) {
      print('🧹 Clearing existing active workout: ${state!.name}');
      _ref.read(restTimerWebProvider.notifier).stopTimer();
      state = null;
    }
  }

  Future<void> forceCleanup() async {
    print('🧹 Force cleanup - clearing all workout data');
    _ref.read(restTimerWebProvider.notifier).stopTimer();
    state = null;
    print('🧹 Force cleanup completed');
  }

  Future<void> startWorkoutFromTemplate(String templateId) async {
    await _clearActiveWorkout();

    try {
      // Web: Fetch from Supabase
      final templateData = await supabase
          .from('workout_templates')
          .select()
          .eq('id', templateId)
          .maybeSingle();

      if (templateData == null) {
        throw Exception('Template not found: $templateId');
      }
      
      // Fetch exercises
      final exerciseIds = List<String>.from(templateData['exercise_ids'] ?? []);
      List<Map<String, dynamic>> exercisesList = [];
      
      if (exerciseIds.isNotEmpty) {
        final exercisesData = await supabase
            .from('exercises')
            .select()
            .inFilter('id', exerciseIds);
        
        exercisesList = List<Map<String, dynamic>>.from(exercisesData);
      }

      // Create exercise map for ordering
      final exerciseMap = {
        for (final ex in exercisesList) ex['id'] as String: ex
      };

      // Create active exercises in template order
      final activeExercises = exerciseIds
          .where((id) => exerciseMap.containsKey(id))
          .map((id) {
        final exercise = exerciseMap[id]!;

        return ActiveExercise(
          id: id,
          name: exercise['name'] as String,
          sets: const [
            ActiveSet(number: 1, reps: 0, isCompleted: false),
            ActiveSet(number: 2, reps: 0, isCompleted: false),
            ActiveSet(number: 3, reps: 0, isCompleted: false),
          ],
          restTimerSeconds: 90, // Default rest timer for web
        );
      }).toList();

      state = ActiveWorkout(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        name: templateData['name'] as String,
        exercises: activeExercises,
        elapsedTime: const Duration(),
        totalSets: activeExercises.length * 3,
        totalVolume: 0,
      );

      print('🏁 New workout created: ${templateData['name']}');
    } catch (e) {
      // Fallback to empty workout
      state = ActiveWorkout(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Quick Start Workout',
        exercises: const [],
        elapsedTime: const Duration(),
        totalSets: 0,
        totalVolume: 0,
      );
      print('🏁 Fallback workout created: Quick Start Workout');
    }
  }

  Future<void> updateSet(int exerciseIndex, int setIndex, ActiveSet updatedSet) async {
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
    print('🏁 Starting finishWorkout...');
    if (state == null) {
      print('❌ No active workout to finish');
      return null;
    }

    final workout = state!;
    final now = DateTime.now();
    final sessionId = const Uuid().v4();
    
    print('🏁 Finishing workout: ${workout.name}');

    try {
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

      // Web: Save to Supabase
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

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

      // Save all completed sets
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
            'rpe': set.rpe,
            'completed': true,
          });
        }
      }

      if (setEntries.isNotEmpty) {
        await supabase.from('set_entries').insert(setEntries);
      }

      // Invalidate web providers to refresh UI
      _ref.invalidate(recentSessionsWebProvider);
      _ref.invalidate(allSessionsWebProvider);

      // Clear timer and state
      _ref.read(restTimerWebProvider.notifier).stopTimer();
      state = null;
      
      print('🏁 Workout finished successfully');
      
      // Web doesn't support workout summary calculation yet
      return null;
    } catch (e) {
      print('❌ Error finishing workout: $e');
      state = null;
      rethrow;
    }
  }
}

// Simple rest timer provider for web
final restTimerWebProvider =
    StateNotifierProvider<RestTimerWebNotifier, RestTimerWebState>(
        (ref) => RestTimerWebNotifier());

class RestTimerWebNotifier extends StateNotifier<RestTimerWebState> {
  RestTimerWebNotifier() : super(const RestTimerWebState());

  Timer? _timer;

  void startTimer(int durationSeconds, {String? exerciseName}) {
    _timer?.cancel();
    
    state = RestTimerWebState(
      isActive: true,
      remainingSeconds: durationSeconds,
      totalSeconds: durationSeconds,
      exerciseName: exerciseName,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = RestTimerWebState(
          isActive: true,
          remainingSeconds: state.remainingSeconds - 1,
          totalSeconds: state.totalSeconds,
          exerciseName: state.exerciseName,
        );
      } else {
        timer.cancel();
        state = const RestTimerWebState();
        print('⏰ Rest timer complete!');
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    state = const RestTimerWebState();
  }

  void addTime(int seconds) {
    if (state.isActive) {
      state = RestTimerWebState(
        isActive: true,
        remainingSeconds: state.remainingSeconds + seconds,
        totalSeconds: state.totalSeconds,
        exerciseName: state.exerciseName,
      );
    }
  }

  void subtractTime(int seconds) {
    if (state.isActive) {
      final newRemaining = (state.remainingSeconds - seconds).clamp(0, state.totalSeconds);
      if (newRemaining == 0) {
        stopTimer();
      } else {
        state = RestTimerWebState(
          isActive: true,
          remainingSeconds: newRemaining,
          totalSeconds: state.totalSeconds,
          exerciseName: state.exerciseName,
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class RestTimerWebState {
  final bool isActive;
  final int remainingSeconds;
  final int totalSeconds;
  final String? exerciseName;

  const RestTimerWebState({
    this.isActive = false,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.exerciseName,
  });
}
