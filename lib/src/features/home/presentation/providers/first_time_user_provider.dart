import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/database_provider.dart';

/// Provider to check if the current user is a first-time user
/// A first-time user is someone who has no completed workouts
final firstTimeUserProvider = FutureProvider<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return false;
  }

  try {
    // Check if user has any completed workouts
    final database = ref.read(databaseProvider);
    if (database == null) {
      return false;
    }

    final completedWorkouts = await (database.select(database.workoutSessions)
          ..where((tbl) => tbl.completedAt.isNotNull()))
        .get();

    // If no completed workouts, this is a first-time user
    return completedWorkouts.isEmpty;
  } on Exception {
    // If there's an error checking, assume not first-time to be safe
    return false;
  }
});
