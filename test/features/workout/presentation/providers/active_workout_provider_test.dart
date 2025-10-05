import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_ai/src/features/workout/presentation/providers/active_workout_provider.dart';

void main() {
  group('ActiveWorkoutProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with no active workout', () {
      final activeWorkout = container.read(activeWorkoutProvider);
      expect(activeWorkout, isNull);
    });

    test('should create workout from template', () {
      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkoutFromTemplate('push_day');
      
      final activeWorkout = container.read(activeWorkoutProvider);
      expect(activeWorkout, isNotNull);
      expect(activeWorkout!.name, equals('Push Day'));
      expect(activeWorkout.exercises.length, greaterThan(0));
    });

    test('should set current exercise index', () {
      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkoutFromTemplate('push_day');
      notifier.setCurrentExercise(1);
      
      final activeWorkout = container.read(activeWorkoutProvider);
      expect(activeWorkout!.currentExerciseIndex, equals(1));
    });

    test('should finish workout', () {
      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkoutFromTemplate('push_day');
      notifier.finishWorkout();
      
      final activeWorkout = container.read(activeWorkoutProvider);
      expect(activeWorkout, isNull);
    });
  });

  group('RestTimerProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with inactive timer', () {
      final restTimer = container.read(restTimerProvider);
      expect(restTimer.isActive, isFalse);
      expect(restTimer.remainingSeconds, equals(0));
    });

    test('should start timer correctly', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.startTimer(120);
      
      final restTimer = container.read(restTimerProvider);
      expect(restTimer.isActive, isTrue);
      expect(restTimer.totalSeconds, equals(120));
      expect(restTimer.remainingSeconds, equals(120));
    });

    test('should stop timer', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.startTimer(120);
      notifier.stopTimer();
      
      final restTimer = container.read(restTimerProvider);
      expect(restTimer.isActive, isFalse);
    });
  });
}