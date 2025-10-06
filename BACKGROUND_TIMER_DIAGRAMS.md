# Background Timer - Visual Flow Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        GymAI App                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Active Workout Screen                                │   │
│  │                                                        │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │ Set Entry Widget                                │  │   │
│  │  │                                                  │  │   │
│  │  │  [Weight: 225 lbs] [Reps: 10]                  │  │   │
│  │  │                                                  │  │   │
│  │  │  [Log Set Button] ◄─────┐                      │  │   │
│  │  └─────────────│────────────┘                      │  │   │
│  │                │                                     │  │   │
│  │                │ User taps                          │  │   │
│  │                ▼                                     │  │   │
│  │  ┌─────────────────────────────────────────────┐   │  │   │
│  │  │ Rest Timer Widget                            │   │  │   │
│  │  │                                               │   │  │   │
│  │  │  ⏱️  01:30                                   │   │  │   │
│  │  │  [████████░░] 50%                            │   │  │   │
│  │  │  [Stop]                                       │   │  │   │
│  │  └──────────────│──────────────────────────────┘   │  │   │
│  └─────────────────│──────────────────────────────────┘  │   │
│                    │                                       │   │
└────────────────────│───────────────────────────────────────┘
                     │
                     │ Triggers
                     ▼
        ┌────────────────────────┐
        │  RestTimerNotifier     │
        │  (State Management)    │
        └────────────┬───────────┘
                     │
                     │ Calls every second
                     ▼
        ┌────────────────────────┐
        │  NotificationService   │
        │  (Singleton)           │
        └────────────┬───────────┘
                     │
                     │ Sends to
                     ▼
        ┌────────────────────────┐
        │  OS Notification       │
        │  System                │
        └────────────┬───────────┘
                     │
                     │ Displays
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    Notification Bar                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ⏱️ Rest Timer                                🕐 2:30 PM     │
│  Time remaining: 01:30                                       │
│  [▓▓▓▓▓░░░░░░░░░] 40%                                       │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

## State Flow Diagram

```
┌─────────────────┐
│  User logs set  │
└────────┬────────┘
         │
         ▼
┌────────────────────────┐
│ RestTimerNotifier      │
│ .startTimer(90)        │
└────────┬───────────────┘
         │
         ├──────────────────────────────────────┐
         │                                      │
         ▼                                      ▼
┌──────────────────────┐            ┌──────────────────────┐
│ Update Internal      │            │ Show Notification    │
│ State:               │            │                      │
│ - isActive: true     │            │ remainingSeconds: 90 │
│ - remaining: 90      │            │ totalSeconds: 90     │
│ - total: 90          │            │ progress: 0%         │
└──────────┬───────────┘            └──────────────────────┘
           │
           │ Timer.periodic(1 second)
           │
           ▼
     ┌─────────────────┐
     │  Every Second   │
     └────────┬────────┘
              │
              ├──────────────────────────────────────┐
              │                                      │
              ▼                                      ▼
     ┌──────────────────┐              ┌──────────────────────┐
     │ Update State     │              │ Update Notification  │
     │ remaining - 1    │              │                      │
     │                  │              │ Time: 01:29          │
     │ 90→89→88→...→1→0 │              │ Progress: 1%→...→99% │
     └────────┬─────────┘              └──────────────────────┘
              │
              │ When remaining = 0
              ▼
     ┌───────────────────┐
     │  Timer Complete   │
     └────────┬──────────┘
              │
              ├───────────────────────────────────────────┐
              │                                           │
              ▼                                           ▼
     ┌──────────────────┐                    ┌──────────────────────┐
     │ Cancel Ongoing   │                    │ Show Completion      │
     │ Notification     │                    │ Notification         │
     └──────────────────┘                    │                      │
                                              │ + Vibration          │
                                              │ + Sound              │
                                              └──────────────────────┘
```

## Notification Lifecycle

```
APP STATE          NOTIFICATION STATE           WHAT USER SEES
═════════          ══════════════════           ══════════════

No timer      ──►  No notification        ──►   Clear notification tray
running

    │
    │ User logs set
    ▼

Timer starts  ──►  Ongoing notification    ──►   ⏱️ Rest Timer
(90 seconds)       appears                      Time: 01:30
                                                 [▓░░░░░░░░░] 1%

    │
    │ 1 second passes
    ▼

Timer at 89s  ──►  Notification updates    ──►   ⏱️ Rest Timer
                   (silent)                      Time: 01:29
                                                 [▓░░░░░░░░░] 2%

    │
    │ ... continues every second ...
    ▼

Timer at 5s   ──►  Notification updates    ──►   ⏱️ Rest Timer
                                                 Time: 00:05
                                                 [▓▓▓▓▓▓▓▓▓░] 94%

    │
    │ 5 more seconds...
    ▼

Timer at 0s   ──►  Ongoing disappears      ──►   (notification gone)
                   Completion appears            ⏰ Rest Timer Complete!
                   + Sound + Vibration           Time to start next set! 💪

    │
    │ User dismisses or auto-dismisses
    ▼

Timer done    ──►  No notification         ──►   Clear notification tray
```

## Multi-State Scenario

```
SCENARIO: User completes 3 sets with rest periods

Time: 0:00
├─ User completes Set 1
└─ Logs set (225 lbs × 10 reps)
   
Time: 0:01
├─ Timer starts: 90 seconds
└─ Notification: "⏱️ Rest Timer - 01:30"

Time: 0:15
├─ User minimizes app
├─ Opens Instagram
└─ Notification visible: "01:16"

Time: 0:45
├─ Still browsing Instagram
└─ Notification updates: "00:46"

Time: 1:31
├─ Timer completes
├─ Notification changes: "⏰ Rest Timer Complete!"
├─ Phone vibrates
└─ Sound plays

Time: 1:35
├─ User returns to GymAI
└─ Starts Set 2

Time: 1:40
├─ User completes Set 2
├─ Logs set (225 lbs × 8 reps)
└─ New timer starts: 90 seconds
   Notification: "⏱️ Rest Timer - 01:30"

Time: 2:00
├─ User takes form check video
├─ Camera app open
└─ Notification updates: "01:10"

Time: 3:10
├─ Timer completes
└─ Notification: "⏰ Rest Timer Complete!"

... continues for Set 3 ...
```

## Component Interaction Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                         App Layer                                 │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  SetEntryWidget                                                   │
│       │                                                            │
│       │ onLogSet()                                                │
│       ▼                                                            │
│  ref.read(restTimerProvider.notifier).startTimer(90)             │
│       │                                                            │
│       └────────────────────┐                                      │
│                            │                                      │
└────────────────────────────│──────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                      State Management Layer                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  RestTimerNotifier                                                │
│       │                                                            │
│       ├─► state = RestTimerState(isActive: true, ...)            │
│       │                                                            │
│       ├─► _timer = Timer.periodic(1 second, ...)                 │
│       │        │                                                   │
│       │        └─► Every second:                                  │
│       │            - Update state                                 │
│       │            - Call NotificationService                     │
│       │                                                            │
│       └─► _notificationService.showTimerNotification(...)        │
│                            │                                      │
└────────────────────────────│──────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                       Service Layer                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  NotificationService (Singleton)                                  │
│       │                                                            │
│       ├─► Calculate display values:                               │
│       │   - minutes = remainingSeconds ~/ 60                      │
│       │   - seconds = remainingSeconds % 60                       │
│       │   - timeString = "MM:SS"                                  │
│       │   - progress = (total - remaining) / total * 100          │
│       │                                                            │
│       ├─► Create AndroidNotificationDetails:                      │
│       │   - Channel: "timer_ongoing_channel"                      │
│       │   - Priority: Low                                         │
│       │   - Ongoing: True                                         │
│       │   - ShowProgress: True                                    │
│       │   - Progress: calculated percentage                       │
│       │                                                            │
│       └─► _notifications.show(...)                                │
│                            │                                      │
└────────────────────────────│──────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                      Platform Layer                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  FlutterLocalNotificationsPlugin                                  │
│       │                                                            │
│       ├─► iOS: DarwinNotificationDetails                          │
│       │   - Minimal configuration                                 │
│       │   - May be throttled in background                        │
│       │                                                            │
│       └─► Android: AndroidNotificationDetails                     │
│           - Full ongoing notification support                     │
│           - Progress bar rendering                                │
│           - No throttling                                         │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                      Operating System                             │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  Notification Manager                                             │
│       │                                                            │
│       ├─► Render notification in system tray                      │
│       ├─► Update notification content (every second)              │
│       ├─► Manage notification channel                             │
│       └─► Apply system notification settings                      │
│                                                                    │
└──────────────────────────────────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  User's Screen │
                    │                │
                    │  Notification  │
                    │  Tray/Shade    │
                    └────────────────┘
```

## Data Flow: Timer Update Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    One Second Cycle                              │
└─────────────────────────────────────────────────────────────────┘

    Time: T
    State: { remaining: 90, total: 90, isActive: true }
         │
         │ Timer tick (1 second elapsed)
         ▼
    ┌──────────────────────────────────────┐
    │ Timer.periodic callback fires        │
    └──────────────┬───────────────────────┘
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │ Check: remainingSeconds > 0?         │
    └──────────────┬───────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
       Yes                   No
        │                     │
        ▼                     ▼
    ┌───────────────┐    ┌──────────────────┐
    │ Update state: │    │ Timer complete:  │
    │ remaining: 89 │    │ - Cancel timer   │
    │ isActive: true│    │ - Clear state    │
    └───────┬───────┘    │ - Show alert     │
            │            │ - Vibrate        │
            │            └──────────────────┘
            │
            ▼
    ┌──────────────────────────────────────┐
    │ Call NotificationService             │
    │ .showTimerNotification(              │
    │   remainingSeconds: 89,              │
    │   totalSeconds: 90                   │
    │ )                                    │
    └──────────────┬───────────────────────┘
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │ Calculate display values:            │
    │ - minutes = 89 ~/ 60 = 1            │
    │ - seconds = 89 % 60 = 29            │
    │ - timeString = "01:29"              │
    │ - progress = (90-89)/90*100 = 1%    │
    └──────────────┬───────────────────────┘
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │ Update notification:                 │
    │ Title: "⏱️ Rest Timer"              │
    │ Body: "Time remaining: 01:29"       │
    │ Progress: 1%                        │
    └──────────────┬───────────────────────┘
                   │
                   ▼
    ┌──────────────────────────────────────┐
    │ OS displays updated notification     │
    └──────────────────────────────────────┘

    Time: T + 1 second
    State: { remaining: 89, total: 90, isActive: true }
         │
         │ ... cycle repeats 89 more times ...
         ▼
```

## Error Handling Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                    Error Scenarios                               │
└──────────────────────────────────────────────────────────────────┘

Scenario 1: Notification Permission Denied
─────────────────────────────────────────
User Action: Denies notification permission
         │
         ▼
NotificationService.initialize()
         │
         ├─► iOS: requestPermissions() → denied
         │   └─► Log warning, continue
         │
         ├─► Android: Permission check → denied
         │   └─► Log warning, continue
         │
         └─► Return (no error thrown)
                  │
                  ▼
App continues to work
Timer runs normally
No notifications shown
         │
         ▼
User can enable later in system settings


Scenario 2: App Backgrounded (iOS)
──────────────────────────────────
Timer running: 01:30 remaining
         │
         │ User backgrounds app
         ▼
OS may throttle background tasks
         │
         ├─► First few minutes: Notifications update normally
         │
         ├─► After ~5 minutes: Updates may slow down
         │
         └─► When timer completes: Completion alert always fires
                  │
                  ▼
User gets alerted even if updates were throttled


Scenario 3: Timer Stopped While Background
──────────────────────────────────────────
Timer running in background
Notification showing: 00:45
         │
         │ User returns to app
         │ Taps "Stop" button
         ▼
RestTimerNotifier.stopTimer()
         │
         ├─► Cancel Timer
         ├─► Clear State
         └─► Call cancelTimerNotification()
                  │
                  ▼
Notification immediately disappears
Even if app is backgrounded again


Scenario 4: Multiple Rapid Starts
─────────────────────────────────
Timer 1 starts (90 seconds)
         │
         │ 5 seconds later...
         │ User stops and starts Timer 2
         ▼
RestTimerNotifier.startTimer(90)
         │
         ├─► Cancel existing timer
         ├─► Clear old state
         ├─► Start new timer
         └─► Show new notification (replaces old)
                  │
                  ▼
Only one notification visible
Shows new timer countdown
```

---

**Visual Guide Version**: 1.0  
**Created**: October 6, 2025  
**For Feature**: Background Timer with Notifications
