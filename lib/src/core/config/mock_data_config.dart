/// Configuration for mock data - should be replaced with real data sources in production
class MockDataConfig {
  // AI Coaching Mock Data
  static const List<Map<String, dynamic>> mockWorkoutTemplates = [
    {
      'id': 'upper_power',
      'name': 'Upper Body Power MOCKED',
      'description': 'Focus on compound movements for upper body strength',
      'difficulty': 'intermediate',
      'estimatedDurationMinutes': 60,
    },
    {
      'id': 'lower_hypertrophy',
      'name': 'Lower Body Hypertrophy MOCKED',
      'description': 'High volume leg training for muscle growth',
      'difficulty': 'advanced',
      'estimatedDurationMinutes': 75,
    },
  ];

  static const List<Map<String, dynamic>> mockExercises = [
    {
      'id': 'bench_press',
      'name': 'Bench Press',
      'muscleGroups': ['chest', 'triceps', 'shoulders'],
      'equipment': ['barbell', 'bench'],
      'difficulty': 'intermediate',
    },
    {
      'id': 'squat',
      'name': 'Back Squat',
      'muscleGroups': ['quadriceps', 'glutes', 'core'],
      'equipment': ['barbell', 'squat_rack'],
      'difficulty': 'intermediate',
    },
  ];

  // Social Mock Data Configuration
  static const int mockUserCount = 20;
  static const int mockPostsPerUser = 5;
  static const List<String> mockUserNames = [
    'Alex Chen',
    'Sarah Johnson',
    'Mike Rodriguez',
    'Emma Wilson',
    'David Kim',
    'Lisa Thompson',
    'Ryan Martinez',
    'Anna Davis',
  ];

  static const List<String> mockLocations = [
    'San Francisco, CA',
    'Austin, TX',
    'Miami, FL',
    'Seattle, WA',
    'Denver, CO',
    'Portland, OR',
    'Atlanta, GA',
    'Boston, MA',
  ];

  static const List<String> mockWorkoutTypes = [
    'Push Day',
    'Pull Day',
    'Leg Day',
    'Full Body',
    'Upper Body',
    'Lower Body',
    'Cardio',
    'Strength',
  ];

  // AI Coaching Parameters
  static const Map<String, dynamic> aiCoachingParams = {
    'mlProcessingDelayMs': 800,
    'maxRecommendations': 5,
    'confidenceThreshold': 0.7,
    'learningRateAdjustment': 0.1,
  };

  // Feature Flags for Mock Services
  static const bool enableMockAI = true;
  static const bool enableMockSocial = true;
  static const bool enableMockData = true;

  // Data Generation Settings
  static const int maxMockWorkoutHistory = 100;
  static const int maxMockExerciseVariations = 50;
  static const Duration mockDataTimeRange = Duration(days: 365);
}
