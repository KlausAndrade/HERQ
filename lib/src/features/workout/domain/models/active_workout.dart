class ActiveWorkout {
  final String id;
  final String name;
  final List<ActiveExercise> exercises;
  final int currentExerciseIndex;
  final Duration elapsedTime;
  final int totalSets;
  final double totalVolume;

  const ActiveWorkout({
    required this.id,
    required this.name,
    required this.exercises,
    this.currentExerciseIndex = 0,
    this.elapsedTime = Duration.zero,
    this.totalSets = 0,
    this.totalVolume = 0.0,
  });
}

class ActiveExercise {
  final String id;
  final String name;
  final List<ActiveSet> sets;
  final int restTimerSeconds;

  const ActiveExercise({
    required this.id,
    required this.name,
    required this.sets,
    this.restTimerSeconds = 90, // Default 90 seconds rest
  });
}

class ActiveSet {
  final int number;
  final double? weight;
  final int reps;
  final int? rpe;
  final bool isCompleted;

  const ActiveSet({
    required this.number,
    this.weight,
    required this.reps,
    this.rpe,
    this.isCompleted = false,
  });
}