/// Models for advanced analytics and gamification
library;

/// Overall analytics data for a user
class AnalyticsData {
  const AnalyticsData({
    required this.powerScore,
    required this.prStreaks,
    required this.nearMisses,
    required this.predictions,
    required this.volumeTrends,
    required this.exerciseProgress,
    required this.plateauAnalysis,
    required this.strengthBalance,
  });
  final PowerScore powerScore;
  final List<PRStreak> prStreaks;
  final List<NearMissPR> nearMisses;
  final List<PRPrediction> predictions;
  final List<VolumeAnalysis> volumeTrends;
  final List<ExerciseProgress> exerciseProgress;
  final PlateauAnalysis plateauAnalysis;
  final StrengthBalance strengthBalance;
}

/// User's overall strength score
class PowerScore {
  const PowerScore({
    required this.current,
    required this.change30Days,
    required this.changeAllTime,
    required this.rank,
    required this.tier,
    required this.pointsToNextTier,
  });
  final double current;
  final double change30Days;
  final double changeAllTime;
  final int rank; // Rank among all users
  final String tier; // Bronze, Silver, Gold, Platinum, Diamond
  final int pointsToNextTier;

  String get tierEmoji {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return '🥉';
      case 'silver':
        return '🥈';
      case 'gold':
        return '🥇';
      case 'platinum':
        return '💎';
      case 'diamond':
        return '💠';
      default:
        return '⭐';
    }
  }
}

/// Tracking consecutive PRs
class PRStreak {
  const PRStreak({
    required this.exerciseId,
    required this.exerciseName,
    required this.currentStreak,
    required this.longestStreak,
    this.lastPRDate,
    this.nextPossiblePR,
  });
  final String exerciseId;
  final String exerciseName;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPRDate;
  final DateTime? nextPossiblePR;

  bool get isActive => currentStreak > 0;
  bool get isOnFire => currentStreak >= 3;
}

/// Near-miss PRs to motivate users
class NearMissPR {
  const NearMissPR({
    required this.exerciseId,
    required this.exerciseName,
    required this.currentBest,
    required this.attemptedWeight,
    required this.attemptedReps,
    required this.percentageClose,
    required this.attemptDate,
    required this.motivationalMessage,
  });
  final String exerciseId;
  final String exerciseName;
  final double currentBest;
  final double attemptedWeight;
  final int attemptedReps;
  final double percentageClose;
  final DateTime attemptDate;
  final String motivationalMessage;

  /// How close the attempt was (0-100%)
  bool get isVeryClose => percentageClose >= 90;
  bool get isSoClose => percentageClose >= 95;
}

/// AI-powered PR predictions
class PRPrediction {
  const PRPrediction({
    required this.exerciseId,
    required this.exerciseName,
    required this.currentPR,
    required this.predictedPR,
    required this.predictedDate,
    required this.confidence,
    required this.reasoning,
    required this.recommendations,
  });
  final String exerciseId;
  final String exerciseName;
  final double currentPR;
  final double predictedPR;
  final DateTime predictedDate;
  final double confidence; // 0-100%
  final String reasoning;
  final List<String> recommendations;

  double get improvement => predictedPR - currentPR;
  double get improvementPercentage => (improvement / currentPR) * 100;
  int get daysUntilPredicted => predictedDate.difference(DateTime.now()).inDays;
}

/// Volume analysis over time
class VolumeAnalysis {
  const VolumeAnalysis({
    required this.date,
    required this.period,
    required this.totalVolume,
    required this.volumeByMuscleGroup,
    required this.change,
    required this.isIncreasing,
  });
  final DateTime date;
  final String period; // 'day', 'week', 'month'
  final double totalVolume;
  final Map<String, double> volumeByMuscleGroup;
  final double change; // Compared to previous period
  final bool isIncreasing;
}

/// Progress tracking for specific exercises
class ExerciseProgress {
  const ExerciseProgress({
    required this.exerciseId,
    required this.exerciseName,
    required this.startWeight,
    required this.currentWeight,
    required this.totalGain,
    required this.percentageGain,
    required this.workoutCount,
    required this.firstWorkout,
    required this.lastWorkout,
    required this.trend,
    required this.history,
  });
  final String exerciseId;
  final String exerciseName;
  final double startWeight;
  final double currentWeight;
  final double totalGain;
  final double percentageGain;
  final int workoutCount;
  final DateTime firstWorkout;
  final DateTime lastWorkout;
  final TrendDirection trend;
  final List<ProgressDataPoint> history;
}

class ProgressDataPoint {
  const ProgressDataPoint({
    required this.date,
    required this.weight,
    required this.reps,
    required this.isPR,
  });
  final DateTime date;
  final double weight;
  final int reps;
  final bool isPR;
}

enum TrendDirection { increasing, stable, decreasing, plateau }

/// Plateau detection and recommendations
class PlateauAnalysis {
  const PlateauAnalysis({
    required this.plateaus,
    required this.totalPlateaus,
    this.lastPlateauBroken,
  });
  final List<PlateauDetection> plateaus;
  final int totalPlateaus;
  final DateTime? lastPlateauBroken;
}

class PlateauDetection {
  const PlateauDetection({
    required this.exerciseId,
    required this.exerciseName,
    required this.weeksStagnant,
    required this.currentWeight,
    required this.startDate,
    required this.severity,
    required this.recommendations,
  });
  final String exerciseId;
  final String exerciseName;
  final int weeksStagnant;
  final double currentWeight;
  final DateTime startDate;
  final PlateauSeverity severity;
  final List<String> recommendations;
}

enum PlateauSeverity { mild, moderate, severe }

/// Strength balance across muscle groups
class StrengthBalance {
  const StrengthBalance({
    required this.volumeDistribution,
    required this.imbalances,
    required this.balanceScore,
    required this.recommendations,
  });
  final Map<String, double> volumeDistribution; // Percentage per muscle group
  final List<MuscleGroupBalance> imbalances;
  final double balanceScore; // 0-100, higher is more balanced
  final List<String> recommendations;
}

class MuscleGroupBalance {
  const MuscleGroupBalance({
    required this.muscleGroup,
    required this.currentPercentage,
    required this.idealPercentage,
    required this.difference,
    required this.status,
  });
  final String muscleGroup;
  final double currentPercentage;
  final double idealPercentage;
  final double difference;
  final BalanceStatus status;
}

enum BalanceStatus { undertrained, balanced, overtrained }

/// Weekly/Monthly challenges
class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.targetValue,
    required this.currentProgress,
    required this.exerciseId,
    required this.rewardPoints,
    required this.isCompleted,
    this.exerciseName,
  });
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final DateTime startDate;
  final DateTime endDate;
  final double targetValue;
  final double currentProgress;
  final String exerciseId;
  final String? exerciseName;
  final int rewardPoints;
  final bool isCompleted;

  double get progressPercentage =>
      (currentProgress / targetValue * 100).clamp(0, 100);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  bool get isActive => DateTime.now().isBefore(endDate) && !isCompleted;
}

enum ChallengeType {
  beatPR, // Beat a specific PR
  volumeTarget, // Hit volume target
  workoutStreak, // Workout X days in a row
  muscleGroup, // Train specific muscle group X times
  consistency, // Workout X times this week/month
}

/// Achievement/Badge system
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.points,
    required this.progress,
    required this.requirement,
    this.unlockedAt,
  });
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementRarity rarity;
  final int points;
  final DateTime? unlockedAt;
  final double progress; // 0-100%
  final String requirement;

  bool get isUnlocked => unlockedAt != null;
}

enum AchievementRarity { common, rare, epic, legendary }
