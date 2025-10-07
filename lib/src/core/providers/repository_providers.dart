import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/base_repository.dart';
import '../data/repositories/web_repository.dart';
import 'auth_provider.dart';

/// Platform-aware Workout Repository Provider
/// 
/// On mobile/desktop: Returns null (use providers that access database directly)
/// On web: Returns WebWorkoutRepository that uses Supabase
final workoutRepositoryProvider = Provider<WorkoutRepository?>((ref) {
  if (!kIsWeb) {
    // Mobile/Desktop: Use existing database-based providers
    // Return null to indicate repository pattern not used
    return null;
  }

  // Web: Use Supabase repository
  final supabase = ref.watch(supabaseClientProvider);
  return WebWorkoutRepository(supabase);
});

/// Platform-aware Exercise Repository Provider
/// 
/// On mobile/desktop: Returns null (use providers that access database directly)
/// On web: Returns WebExerciseRepository that uses Supabase
final exerciseRepositoryProvider = Provider<ExerciseRepository?>((ref) {
  if (!kIsWeb) {
    // Mobile/Desktop: Use existing database-based providers
    return null;
  }

  // Web: Use Supabase repository
  final supabase = ref.watch(supabaseClientProvider);
  return WebExerciseRepository(supabase);
});
