import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../features/workout/presentation/providers/active_workout_provider.dart';
import '../../features/workout/presentation/providers/workout_checkpoint_provider.dart';
import 'notification_service.dart';

/// Observer for app lifecycle events
/// Saves workout checkpoint when app goes to background
/// Schedules reminder notification if workout is in progress
class AppLifecycleObserver extends WidgetsBindingObserver {
  final WidgetRef ref;
  Timer? _notificationTimer;

  AppLifecycleObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // App is going to background - save checkpoint and schedule notification
        _saveCheckpointOnPause();
        _scheduleWorkoutReminderNotification();
        break;
      case AppLifecycleState.resumed:
        // App is coming back to foreground - cancel reminder
        _cancelWorkoutReminderNotification();
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

  void _scheduleWorkoutReminderNotification() {
    final workout = ref.read(activeWorkoutProvider);
    if (workout == null) return;

    // Schedule notification for 10 minutes from now
    _notificationTimer?.cancel();
    _notificationTimer = Timer(const Duration(minutes: 10), () {
      _showWorkoutReminderNotification(workout.name);
    });

    print('⏰ Scheduled workout reminder notification for 10 minutes');
  }

  void _cancelWorkoutReminderNotification() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
    // Also cancel any already-shown notification
    NotificationService.cancelWorkoutReminder();
    print('❌ Cancelled workout reminder notification');
  }

  Future<void> _showWorkoutReminderNotification(String workoutName) async {
    try {
      await NotificationService.showWorkoutReminder(
        workoutName: workoutName,
      );
      print('🔔 Workout reminder notification sent');
    } catch (e) {
      print('❌ Failed to show workout reminder: $e');
    }
  }

  void dispose() {
    _notificationTimer?.cancel();
  }
}
