import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/semantics.dart';
import '../ui/notification_redesign/in_app_notification.dart';

// Global stream controller for timer actions from notifications
final timerActionStreamController = StreamController<String>.broadcast();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification IDs
  static const int _timerNotificationId = 1;
  static const int _timerCompleteNotificationId = 2;
  static const int _workoutReminderNotificationId = 3;

  Future<void> initialize() async {
    if (_initialized) return;

    // Skip notification initialization on macOS/desktop to avoid compatibility issues
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      _initialized = true;
      return;
    }

    // During flutter test runs, avoid initializing the actual plugin which
    // may not be available in the headless test environment. Flutter sets
    // the FLUTTER_TEST environment variable during tests.
    const isFlutterTest =
        bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
    if (isFlutterTest) {
      _initialized = true;
      return;
    }

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettingsMacOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    try {
      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );
    } catch (e) {
      // If plugin initialization fails in a test or unsupported environment,
      // mark as initialized to avoid crashes and continue without notifications.
      _initialized = true;
      return;
    }

    // Handle background notification actions
    await _setupBackgroundActionHandler();

    // Request permissions for iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _initialized = true;
  }

  // In-app notification queue & stream
  final StreamController<InAppNotification> _inAppController =
      StreamController<InAppNotification>.broadcast();

  Stream<InAppNotification> get inAppStream => _inAppController.stream;

  /// Post an in-app notification — this will be emitted on `inAppStream`
  Future<void> showInAppNotification({
    required String id,
    required String title,
    required String body,
    Widget? leading,
    Color? backgroundColor,
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
  }) async {
    final notif = InAppNotification(
      id: id,
      title: title,
      body: body,
      leading: leading,
      backgroundColor: backgroundColor,
      primaryActionLabel: primaryActionLabel,
      onPrimaryAction: onPrimaryAction,
      secondaryActionLabel: secondaryActionLabel,
      onSecondaryAction: onSecondaryAction,
    );

    // Emit to listeners (UI overlays)
    _inAppController.add(notif);

    // Also announce via semantics for accessibility
    try {
      SemanticsService.announce('$title. $body', TextDirection.ltr);
    } catch (_) {
      // SemanticsService may not be available in some test/headless envs.
    }
  }

  Future<void> _setupBackgroundActionHandler() async {
    // This allows handling notification actions even when app is in background
    // The actual handler is set up via method channel callbacks
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;

    if (actionId != null && payload != null) {
      // Handle action button clicks
      _handleTimerAction(actionId, payload);
    } else if (payload != null) {
      // Handle notification tap (open app to workout)
      _handleNotificationTap(payload);
    }
  }

  void _handleTimerAction(String actionId, String payload) {
    // Emit action to stream so RestTimerNotifier can handle it
    timerActionStreamController.add(actionId);
  }

  void _handleNotificationTap(String payload) {
    // Navigate to active workout screen
    print('Notification tapped: $payload');
  }

  Future<void> showTimerCompleteNotification({
    required String title,
    required String body,
  }) async {
    // Skip notifications on desktop platforms
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return;
    }

    await initialize();

    final androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      channelDescription: 'Notifications for exercise timer completion',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
    );

    await _notifications.show(
      _timerCompleteNotificationId, // notification id
      title,
      body,
      notificationDetails,
    );
  }

  /// Shows an interactive notification for the active rest timer with action buttons
  Future<void> showTimerNotification({
    required int remainingSeconds,
    required int totalSeconds,
    String? exerciseName,
    int? currentSet,
    int? totalSets,
    int? targetReps,
  }) async {
    // Skip notifications on desktop platforms
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return;
    }

    await initialize();

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final progress =
        ((totalSeconds - remainingSeconds) / totalSeconds * 100).toInt();

    // Build title and body with exercise context
    final title = exerciseName ?? '⏱️ Rest Timer';
    final setInfo = currentSet != null && totalSets != null
        ? 'Set $currentSet of $totalSets'
        : '';
    final repsInfo = targetReps != null ? ' • $targetReps reps' : '';
    final body = setInfo.isNotEmpty
        ? '$setInfo$repsInfo • $timeString'
        : 'Time remaining: $timeString';

    // Create action buttons for Android
    final androidActions = <AndroidNotificationAction>[
      const AndroidNotificationAction(
        'subtract_15',
        '-15s',
        showsUserInterface: false,
      ),
      const AndroidNotificationAction(
        'add_15',
        '+15s',
        showsUserInterface: false,
      ),
      const AndroidNotificationAction(
        'skip',
        'Skip',
        showsUserInterface: false,
      ),
    ];

    final androidDetails = AndroidNotificationDetails(
      'timer_ongoing_channel',
      'Active Timer',
      channelDescription:
          'Shows the current rest timer countdown with controls',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      actions: androidActions,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
    );

    await _notifications.show(
      _timerNotificationId,
      title,
      body,
      notificationDetails,
      payload: 'timer_active',
    );
  }

  /// Cancels the ongoing timer notification
  Future<void> cancelTimerNotification() async {
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return;
    }
    await _notifications.cancel(_timerNotificationId);
  }

  Future<void> vibrateTimerComplete() async {
    // Check if device has vibration capability
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      // Custom vibration pattern: [wait, vibrate, wait, vibrate]
      // Times are in milliseconds
      await Vibration.vibrate(
        pattern: [0, 500, 200, 500, 200, 500],
        intensities: [0, 255, 0, 255, 0, 255],
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return;
    }
    await _notifications.cancelAll();
  }

  /// Show a reminder notification when workout is left incomplete for 10 minutes
  static Future<void> showWorkoutReminder({
    required String workoutName,
  }) async {
    final instance = NotificationService();
    if (!instance._initialized) {
      await instance.initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'workout_reminder_channel',
      'Workout Reminders',
      channelDescription: 'Reminds you to finish your incomplete workout',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
    );

    await instance._notifications.show(
      _workoutReminderNotificationId,
      '💪 Don\'t forget your workout!',
      'You still have "$workoutName" in progress. Tap to continue.',
      notificationDetails,
      payload: 'workout_reminder',
    );
  }

  /// Cancel the workout reminder notification
  static Future<void> cancelWorkoutReminder() async {
    final instance = NotificationService();
    await instance._notifications.cancel(_workoutReminderNotificationId);
  }
}
