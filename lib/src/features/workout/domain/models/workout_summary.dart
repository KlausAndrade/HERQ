/// Model for workout completion summary with achievements and PRs
class WorkoutSummary {
  const WorkoutSummary({
    required this.workoutName,
    required this.duration,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.totalTonnage,
    required this.exercises,
    required this.prs,
    required this.achievements,
    this.sessionId,
  });
  final String workoutName;
  final Duration duration;
  final int totalSets;
  final int totalReps;
  final double totalVolume;
  final double totalTonnage;
  final List<ExerciseSummary> exercises;
  final List<PersonalRecordAchievement> prs;
  final WorkoutAchievements achievements;
  final String? sessionId; // Workout session ID for linking to social posts
}

class ExerciseSummary {
  const ExerciseSummary({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.totalReps,
    this.maxWeight,
    this.totalVolume,
    this.isNewPR = false,
  });
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int totalReps;
  final double? maxWeight;
  final double? totalVolume;
  final bool isNewPR;
}

class PersonalRecordAchievement {
  const PersonalRecordAchievement({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.value,
    required this.unit,
    this.previousValue,
  });
  final String exerciseId;
  final String exerciseName;
  final PRType type;
  final double value;
  final double? previousValue;
  final String unit;

  double get improvement {
    if (previousValue == null || previousValue == 0) return 0;
    return ((value - previousValue!) / previousValue!) * 100;
  }
}

enum PRType { maxWeight, totalVolume, maxReps, oneRepMax }

class WorkoutAchievements {
  // Consecutive workout days

  const WorkoutAchievements({
    this.isPersonalBest = false,
    this.isLongestWorkout = false,
    this.isMostSets = false,
    this.perfectCompletion = false,
    this.streak = 0,
  });
  final bool isPersonalBest; // Best total volume workout
  final bool isLongestWorkout;
  final bool isMostSets;
  final bool perfectCompletion; // All sets completed
  final int streak;

  bool get hasAnyAchievement =>
      isPersonalBest || isLongestWorkout || isMostSets || perfectCompletion;
}
