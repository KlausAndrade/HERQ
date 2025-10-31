import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Service to keep the app alive during an active workout session
/// Uses WakeLock to prevent screen sleep and keep app in foreground
/// Android: Also shows persistent notification to indicate active workout
/// iOS: Uses WakeLock + relies on Live Activities for proper background handling
class WorkoutForegroundService {
  factory WorkoutForegroundService() => _instance;
  WorkoutForegroundService._internal();
  static final WorkoutForegroundService _instance =
      WorkoutForegroundService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isServiceRunning = false;

  static const String _channelId = 'workout_foreground_service';
  static const String _channelName = 'Active Workout';
  static const String _channelDescription = 'Keeps workout session active';
  static const int _notificationId = 999; // Different from timer notifications

  Future<void> initialize() async {
    if (Platform.isAndroid) {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidSettings);
      await _notifications.initialize(initSettings);
    }
  }

  /// Start foreground service (Android only)
  Future<void> startService({
    required String workoutName,
    required int exerciseCount,
  }) async {
    if (_isServiceRunning) return;

    // Enable WakeLock to keep screen on and prevent app from sleeping
    try {
      await WakelockPlus.enable();
      print('✅ WakeLock enabled - screen will stay on');
    } catch (e) {
      print('❌ Failed to enable WakeLock: $e');
    }

    if (Platform.isAndroid) {
      try {
        const androidDetails = AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.low, // Low importance = minimal intrusion
          priority: Priority.low,
          ongoing: true, // Cannot be dismissed by swipe
          autoCancel: false,
          showWhen: false,
          // Foreground service notification
          category: AndroidNotificationCategory.workout,
          playSound: false,
          enableVibration: false,
          icon: '@mipmap/ic_launcher',
        );

        const details = NotificationDetails(android: androidDetails);

        await _notifications.show(
          _notificationId,
          '🏋️ Workout in Progress',
          '$workoutName • $exerciseCount exercises',
          details,
          payload: 'workout_service',
        );

        _isServiceRunning = true;
        print('✅ Workout foreground service started');
      } catch (e) {
        print('❌ Failed to start foreground service: $e');
      }
    } else if (Platform.isIOS) {
      // iOS: WakeLock + Live Activities keeps workout alive
      _isServiceRunning = true;
      print('✅ iOS: WakeLock enabled for workout session');
    }
  }

  /// Update service notification with current progress
  Future<void> updateService({
    required String workoutName,
    required int completedExercises,
    required int totalExercises,
  }) async {
    if (!_isServiceRunning || !Platform.isAndroid) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
        category: AndroidNotificationCategory.workout,
        playSound: false,
        enableVibration: false,
        icon: '@mipmap/ic_launcher',
      );

      const details = NotificationDetails(android: androidDetails);

      await _notifications.show(
        _notificationId,
        '🏋️ Workout in Progress',
        '$workoutName • $completedExercises/$totalExercises exercises',
        details,
        payload: 'workout_service',
      );
    } catch (e) {
      print('❌ Failed to update foreground service: $e');
    }
  }

  /// Stop foreground service
  Future<void> stopService() async {
    if (!_isServiceRunning) return;

    // Disable WakeLock
    try {
      await WakelockPlus.disable();
      print('✅ WakeLock disabled - screen can sleep again');
    } catch (e) {
      print('❌ Failed to disable WakeLock: $e');
    }

    if (Platform.isAndroid) {
      try {
        await _notifications.cancel(_notificationId);
        _isServiceRunning = false;
        print('✅ Workout foreground service stopped');
      } catch (e) {
        print('❌ Failed to stop foreground service: $e');
      }
    } else {
      _isServiceRunning = false;
      print('✅ iOS: Workout session ended');
    }
  }

  bool get isRunning => _isServiceRunning;
}
