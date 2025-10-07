import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/workout/presentation/providers/active_workout_provider.dart';
import '../../features/workout/presentation/providers/workout_checkpoint_provider.dart';

/// Observer for app lifecycle events
/// Saves workout checkpoint when app goes to background
class AppLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;

  AppLifecycleObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // App is going to background - save checkpoint
        _saveCheckpointOnPause();
        break;
      case AppLifecycleState.resumed:
        // App is coming back to foreground
        print('📱 App resumed');
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., during a phone call)
        break;
      case AppLifecycleState.detached:
        // App is detached
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  void _saveCheckpointOnPause() {
    final workout = ref.read(activeWorkoutProvider);
    if (workout != null) {
      final checkpointService = ref.read(workoutCheckpointServiceProvider);
      checkpointService?.saveCheckpoint(workout);
      print('💾 Checkpoint saved on app pause');
    }
  }
}
