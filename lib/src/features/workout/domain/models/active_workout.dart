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

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'currentExerciseIndex': currentExerciseIndex,
        'elapsedTimeSeconds': elapsedTime.inSeconds,
        'totalSets': totalSets,
        'totalVolume': totalVolume,
      };

  factory ActiveWorkout.fromJson(Map<String, dynamic> json) => ActiveWorkout(
        id: json['id'] as String,
        name: json['name'] as String,
        exercises: (json['exercises'] as List)
            .map((e) => ActiveExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        currentExerciseIndex: json['currentExerciseIndex'] as int? ?? 0,
        elapsedTime: Duration(seconds: json['elapsedTimeSeconds'] as int? ?? 0),
        totalSets: json['totalSets'] as int? ?? 0,
        totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0.0,
      );

  /// Check if all sets in the workout are completed
  bool isFullyCompleted() {
    if (exercises.isEmpty) return false;
    
    for (final exercise in exercises) {
      if (exercise.sets.isEmpty) return false;
      
      // Check if all sets in this exercise are completed
      final allSetsComplete = exercise.sets.every((set) => set.isCompleted);
      if (!allSetsComplete) return false;
    }
    
    return true; // All exercises have all sets completed
  }

  /// Get count of completed sets
  int getCompletedSetsCount() {
    return exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets.where((s) => s.isCompleted).length,
    );
  }

  /// Get total count of all sets
  int getTotalSetsCount() {
    return exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );
  }
}

class ActiveExercise {
  final String id;
  final String name;
  final List<ActiveSet> sets;
  final int restTimerSeconds;
  final String exerciseType; // 'reps' | 'timer' | 'body_weighted' | etc.

  const ActiveExercise({
    required this.id,
    required this.name,
    required this.sets,
    this.restTimerSeconds = 90, // Default 90 seconds rest
    this.exerciseType = 'reps',
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sets': sets.map((s) => s.toJson()).toList(),
    'restTimerSeconds': restTimerSeconds,
    'exerciseType': exerciseType,
      };

  factory ActiveExercise.fromJson(Map<String, dynamic> json) => ActiveExercise(
        id: json['id'] as String,
        name: json['name'] as String,
        sets: (json['sets'] as List)
            .map((s) => ActiveSet.fromJson(s as Map<String, dynamic>))
            .toList(),
    restTimerSeconds: json['restTimerSeconds'] as int? ?? 90,
    exerciseType: json['exerciseType'] as String? ?? 'reps',
      );
}

class ActiveSet {
  final int number;
  final double? weight;
  final int reps;
  final int? durationSeconds; // Used for timer-based sets (e.g. handstand hold)
  final int? rpe;
  final bool isCompleted;
  final bool isPRWeight;  // True if this set beat previous max weight
  final bool isPRReps;    // True if this set beat previous max reps (at same or higher weight)

  const ActiveSet({
    required this.number,
    this.weight,
    required this.reps,
    this.durationSeconds,
    this.rpe,
    this.isCompleted = false,
    this.isPRWeight = false,
    this.isPRReps = false,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'number': number,
        'weight': weight,
        'reps': reps,
    'durationSeconds': durationSeconds,
        'rpe': rpe,
        'isCompleted': isCompleted,
        'isPRWeight': isPRWeight,
        'isPRReps': isPRReps,
      };

  factory ActiveSet.fromJson(Map<String, dynamic> json) => ActiveSet(
        number: json['number'] as int,
        weight: (json['weight'] as num?)?.toDouble(),
        reps: json['reps'] as int,
    durationSeconds: json['durationSeconds'] as int?,
        rpe: json['rpe'] as int?,
        isCompleted: json['isCompleted'] as bool? ?? false,
        isPRWeight: json['isPRWeight'] as bool? ?? false,
        isPRReps: json['isPRReps'] as bool? ?? false,
      );
}
