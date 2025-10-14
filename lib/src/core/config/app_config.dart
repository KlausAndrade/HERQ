/// Application configuration constants that can be made configurable
class AppConfig {
  // Chart Configuration
  static const int defaultChartWeeks = 12;
  static const int defaultChartMonths = 12;
  static const int maxChartDataPoints = 50;

  // Workout Configuration
  static const int defaultRestTimerSeconds = 90;
  static const int maxWorkoutDurationHours = 6;
  static const int defaultSetRestSeconds = 60;

  // UI Configuration
  static const int maxRecentWorkouts = 10;
  static const int homeRecentWorkoutsLimit = 3;
  static const int leaderboardTopCount = 20;
  static const int maxSearchResults = 50;

  // Timer Configuration
  static const int minRestTimerSeconds = 10;
  static const int maxRestTimerSeconds = 600; // 10 minutes
  static const int restTimerIncrementSeconds = 5;

  // Data Retention
  static const int maxStoredWorkouts = 1000;
  static const int maxExerciseHistory = 500;

  // Performance Configuration
  static const int exerciseSearchDebounceMs = 300;
  static const int autoSaveIntervalSeconds = 30;

  // Social Features
  static const int maxFeedItemsPerLoad = 20;
  static const int maxCommentLength = 500;
  static const int maxBioLength = 150;

  // AI Coaching
  static const int aiRecommendationCount = 5;
  static const int mlProcessingSimulationMs = 800;

  // Units & Formatting
  static const List<String> supportedUnits = ['metric', 'imperial'];
  static const List<String> supportedThemes = ['light', 'dark', 'system'];
  static const List<int> supportedWeekStarts = [0, 1]; // Sunday = 0, Monday = 1

  // Validation Limits
  static const double minWeight = 0.1;
  static const double maxWeight = 1000;
  static const int minReps = 1;
  static const int maxReps = 100;
  static const int minSets = 1;
  static const int maxSets = 20;
}
