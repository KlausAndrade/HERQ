import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/services/workout_summary_service.dart';

/// Provider for the workout summary service
final workoutSummaryServiceProvider = Provider<WorkoutSummaryService?>((ref) {
  final database = ref.watch(databaseProvider);
  if (database == null) return null;

  return WorkoutSummaryService(database);
});
