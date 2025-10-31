import 'dart:async';

import 'package:live_activities/live_activities.dart';

/// Service for managing iOS Live Activities and Android RemoteViews
/// for the rest timer during workouts
class LiveActivityService {
  LiveActivityService();

  final _liveActivitiesPlugin = LiveActivities();
  String? _currentActivityId;

  // Stream controller for action events (button taps)
  final _actionController = StreamController<String>.broadcast();
  Stream<String> get actionStream => _actionController.stream;

  /// Initialize the live activity service
  Future<void> initialize() async {
    // Initialize the plugin
    await _liveActivitiesPlugin.init(appGroupId: 'group.com.klausandrade.herq');

    // Listen for URL scheme actions (button taps from the widget)
    _liveActivitiesPlugin.urlSchemeStream().listen((schemeData) {
      // Extract the action from the URL scheme (e.g., herq://timer/add_15)
      final action = schemeData.path;
      if (action != null && action.isNotEmpty) {
        // Remove leading slash if present
        final actionId = action.startsWith('/') ? action.substring(1) : action;
        _actionController.add(actionId);
      }
    });
  }

  /// Start a live activity for the rest timer
  Future<void> startTimerActivity({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    required int targetReps,
    required int remainingSeconds,
  }) async {
    try {
      // Create the activity data
      final activityData = {
        'exerciseName': exerciseName,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'targetReps': targetReps,
        'remainingSeconds': remainingSeconds,
      };

      // Use a consistent activity ID for the timer
      const activityId = 'rest_timer';

      // Start the live activity
      final result = await _liveActivitiesPlugin.createActivity(
        activityId,
        activityData,
      );

      if (result != null) {
        _currentActivityId = result;
      }
    } catch (e) {
      print('Error starting live activity: $e');
    }
  }

  /// Update the timer countdown
  Future<void> updateTimer({
    required int remainingSeconds,
    String? exerciseName,
    int? currentSet,
    int? totalSets,
    int? targetReps,
  }) async {
    if (_currentActivityId == null) return;

    try {
      final updateData = <String, dynamic>{
        'remainingSeconds': remainingSeconds,
      };

      // Include optional fields if provided
      if (exerciseName != null) updateData['exerciseName'] = exerciseName;
      if (currentSet != null) updateData['currentSet'] = currentSet;
      if (totalSets != null) updateData['totalSets'] = totalSets;
      if (targetReps != null) updateData['targetReps'] = targetReps;

      await _liveActivitiesPlugin.updateActivity(
        _currentActivityId!,
        updateData,
      );
    } catch (e) {
      print('Error updating live activity: $e');
    }
  }

  /// End the current live activity
  Future<void> endTimerActivity() async {
    if (_currentActivityId == null) return;

    try {
      await _liveActivitiesPlugin.endActivity(_currentActivityId!);
      _currentActivityId = null;
    } catch (e) {
      print('Error ending live activity: $e');
    }
  }

  /// Check if live activities are supported on this device
  Future<bool> areActivitiesEnabled() async {
    try {
      return await _liveActivitiesPlugin.areActivitiesEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Dispose of resources
  void dispose() {
    _actionController.close();
  }
}
