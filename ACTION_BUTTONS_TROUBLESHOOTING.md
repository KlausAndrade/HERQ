# Action Buttons Not Showing - Troubleshooting Guide

## Issue
The -15s, +15s, and Skip buttons are not visible in the notification widget.

## Changes Made

### Fixed Notification Configuration
1. ✅ **Removed timer display button** - The middle `⏱️` button with `contextual: true` can cause all buttons to be hidden
2. ✅ **Reduced to 3 buttons** - Android works better with 3 or fewer actions
3. ✅ **Changed priority to default** - `Importance.low` can hide actions on some devices
4. ✅ **Removed largeIcon** - Can conflict with action buttons on some Android versions
5. ✅ **Removed BigTextStyleInformation** - Can prevent actions from showing

### Current Button Configuration
```dart
[-15s]  [+15s]  [Skip]
```

## Why Action Buttons Might Not Show

### Android Version Issues
**Android 4.4 - 6.0:**
- Action buttons may not show on older versions
- Requires Android 7.0+ for best results

**Android 7.0 - 9.0:**
- Actions show when notification is expanded
- Swipe down on notification to see buttons

**Android 10+:**
- Actions usually visible by default
- May need to expand notification

### Device-Specific Issues

**Samsung Devices:**
- OneUI may hide actions for low-priority notifications
- Solution: Changed priority to `defaultPriority`

**MIUI (Xiaomi):**
- Aggressive notification management
- May hide actions to save space
- Check Settings → Notifications → GymAI → Show actions

**Huawei/EMUI:**
- May require "Allow notification actions" permission
- Check App info → Notifications → Advanced

**Stock Android:**
- Should work out of the box
- If not visible, try expanding notification

## How to See Action Buttons

### Method 1: Expand Notification (Most Common)
1. When timer notification appears
2. **Swipe down slowly** on the notification
3. Notification expands
4. Buttons should appear at bottom

### Method 2: Pull Down Notification Shade
1. Pull down notification shade from top
2. Find "Rest Timer" or exercise name notification
3. **Two-finger swipe down** on the notification OR
4. **Single swipe down** to expand it
5. Buttons appear at bottom

### Method 3: Long Press (Android 8+)
1. Long press on the notification
2. Should show expanded view with buttons

## Testing Steps

### Quick Test
```bash
# After making changes, do a hot restart (not hot reload)
flutter run

# OR kill and restart app
# Then start a workout and complete a set
```

### Detailed Test
1. **Stop the app completely** (don't just hot reload)
2. **Clear all notifications** from the device
3. **Restart the app**
4. **Start a workout**
5. **Complete a set** to trigger rest timer
6. **Pull down notification shade**
7. **Swipe down on the timer notification** to expand it
8. **Look for buttons** at the bottom

### What You Should See

**Collapsed Notification:**
```
┌─────────────────────────────────────┐
│ 💪 Bench Press                      │
│ Set 1 of 3 • 10 reps • 01:30       │
│ [████░░░░░░░░░░░░░░] 20%          │
│                                     │
│ ▼ (swipe to expand)                │
└─────────────────────────────────────┘
```

**Expanded Notification (with buttons):**
```
┌─────────────────────────────────────┐
│ 💪 Bench Press                      │
│ Set 1 of 3 • 10 reps • 01:30       │
│ [████░░░░░░░░░░░░░░] 20%          │
│                                     │
│ [-15s]    [+15s]    [Skip]         │
│ ▲ (swipe to collapse)              │
└─────────────────────────────────────┘
```

## Platform-Specific Notes

### Android Limitations
- **Ongoing notifications** may hide actions by default
- **Low priority** notifications often hide actions
- **Some launchers** hide notification actions
- **Battery saver mode** can limit notification features

### iOS
- **Action buttons NOT supported** for ongoing notifications
- This is an iOS platform limitation
- User must open app to adjust timer

## Alternative Solutions

### If Buttons Still Don't Show

#### Option 1: Change to Heads-Up Notification
Edit `notification_service.dart`:
```dart
importance: Importance.high,  // Was: defaultImportance
priority: Priority.high,       // Was: defaultPriority
```
**Trade-off:** More intrusive, pops up over other apps

#### Option 2: Remove Progress Bar
Some devices hide actions when progress bar is shown:
```dart
showProgress: false,  // Was: true
// Remove these lines:
// maxProgress: 100,
// progress: progress,
```
**Trade-off:** No visual progress indicator

#### Option 3: Remove Ongoing Flag
Allow notification to be dismissible:
```dart
ongoing: false,  // Was: true
```
**Trade-off:** User can accidentally swipe away timer

## Debugging

### Check Notification Channel
```dart
// Add debug logging in notification_service.dart
print('Showing notification with ${androidActions.length} actions');
print('Priority: ${androidDetails.importance}');
print('Actions: ${androidActions.map((a) => a.title).join(", ")}');
```

### Verify Permissions
```bash
# Check if notification permissions granted
adb shell dumpsys notification | grep GymAI

# Check notification channels
adb shell cmd notification list-channels com.example.gym_ai
```

### Test on Different Devices
- ✅ **Stock Android** (Pixel, Android emulator)
- ⚠️ **Samsung** (OneUI quirks)
- ⚠️ **Xiaomi** (MIUI aggressive management)
- ⚠️ **Huawei** (EMUI restrictions)

## Expected Behavior After Fix

1. **Notification appears** when timer starts
2. **Swipe down on notification** to expand
3. **3 buttons visible**: -15s, +15s, Skip
4. **Tapping -15s** reduces timer by 15 seconds
5. **Tapping +15s** adds 15 seconds to timer
6. **Tapping Skip** completes timer immediately
7. **Notification updates** to reflect new time

## Still Not Working?

### Check Android Version
```bash
adb shell getprop ro.build.version.release
```
- Needs Android 7.0+ for reliable action support

### Check Device Manufacturer Settings
- Samsung: Settings → Notifications → Advanced → Action buttons
- Xiaomi: Settings → Notifications → More settings → Show buttons
- Huawei: Settings → Apps → GymAI → Notifications → Show actions

### Try Clean Reinstall
```bash
flutter clean
flutter pub get
flutter run
```

### Last Resort: Use Notification Panel Instead
If actions never show, the timer controls are also available:
- In the app's rest timer widget
- Can still control from within the app
- Notification shows time but no buttons

## Summary of Changes

### Before
```dart
4 buttons (including timer display)
Importance: LOW
Priority: LOW
Had: largeIcon, BigTextStyleInformation
Result: Buttons hidden on many devices
```

### After
```dart
3 buttons (removed timer display)
Importance: DEFAULT
Priority: DEFAULT
Removed: largeIcon, BigTextStyleInformation
Result: Better compatibility
```

### Expected Improvement
- More devices will show buttons
- Better visibility when expanded
- Cleaner notification layout
- Standard Android behavior

---

**Remember:** You need to **EXPAND** the notification (swipe down on it) to see the action buttons. They won't show in the collapsed view!

**Next Step:** Stop the app, restart it, trigger a timer, and try **swiping down** on the notification to expand it.
