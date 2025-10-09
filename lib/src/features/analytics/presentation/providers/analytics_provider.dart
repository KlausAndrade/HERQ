import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/services/analytics_service.dart';
import '../../domain/models/analytics_models.dart';
import '../../../../core/providers/auth_provider.dart';

/// Provider for analytics service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final database = ref.watch(databaseProvider)!;
  return AnalyticsService(database);
});

/// Provider for comprehensive analytics data
final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getAnalytics();
});

/// Provider for power score only
final powerScoreProvider = FutureProvider<PowerScore>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  return service.calculatePowerScore(userId: currentUser?.id);
});

/// Provider for PR streaks
final prStreaksProvider = FutureProvider<List<PRStreak>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.calculatePRStreaks();
});

/// Provider for near-miss PRs
final nearMissPRsProvider = FutureProvider<List<NearMissPR>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.findNearMissPRs();
});

/// Provider for PR predictions
final prPredictionsProvider = FutureProvider<List<PRPrediction>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.predictFuturePRs();
});

/// Provider for volume trends
final volumeTrendsProvider = FutureProvider<List<VolumeAnalysis>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.analyzeVolumeTrends();
});

/// Provider for exercise progress
final exerciseProgressProvider =
    FutureProvider<List<ExerciseProgress>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getExerciseProgress();
});

/// Provider for plateau detection
final plateauAnalysisProvider = FutureProvider<PlateauAnalysis>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.detectPlateaus();
});

/// Provider for strength balance
final strengthBalanceProvider = FutureProvider<StrengthBalance>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.analyzeStrengthBalance();
});
