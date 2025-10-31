import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/workout_checkpoint_service.dart';

/// Provider for workout checkpoint service
final workoutCheckpointServiceProvider = Provider<WorkoutCheckpointService?>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  if (database == null) return null;

  return WorkoutCheckpointService(database);
});
