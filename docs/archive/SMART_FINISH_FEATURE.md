# Smart Finish Feature - Workout Resume Enhancement

## Overview

The Smart Finish feature enhances the workout recovery system with three intelligent behaviors:

1. **Auto-Finalize Complete Workouts**: Automatically saves completed workouts without showing a dialog
2. **Workout Reminder Notifications**: Sends a notification after 10 minutes if workout is incomplete
3. **Adaptive Resume Dialog**: Shows context-specific options for incomplete workouts

## Key Features

### 1. Auto-Finalize (100% Complete + >10 Minutes)
When user reopens the app after completing all exercises:
- ✅ **Detects 100% completion** - All sets marked as done
- ✅ **Checks time** - More than 10 minutes since last save
- ✅ **Skips dialog** - No interruption, frictionless UX
- ✅ **Auto-saves workout** - Immediately finalizes to database
- ✅ **Shows celebration** - Navigates directly to summary screen with confetti
- ✅ **Deletes checkpoint** - Cleans up after successful save

### 2. Workout Reminder Notification (>10 Minutes Paused)
When user closes app with incomplete workout:
- ⏰ **Schedules notification** - Timer starts when app goes to background
- 🔔 **Sends after 10 minutes** - "Don't forget your workout!"
- 📱 **Tap to resume** - Opens app to active workout screen
- ❌ **Auto-cancels** - If app resumes before 10 minutes
- 🧹 **Cleanup** - Removes notification when workout finalized

### 3. Adaptive Resume Dialog (For Incomplete Workouts)
Shows different UI based on completion state and time elapsed

## User Stories

### Story 1: Forgotten Finalization (Primary Use Case)
**Problem**: User completes all exercises in a workout, forgets to click "Finish Workout", closes app and goes home. They don't realize their workout isn't saved.

**Solution**: When they reopen the app (after 10+ minutes), the system detects that all sets are complete and shows a celebration dialog emphasizing "Finalize" to save their completed workout.

### Story 2: Interrupted Workout
**Problem**: User starts a workout, completes some exercises, then app is closed or crashes. After 10+ minutes, they may not want to continue but don't want to lose the work they already completed.

**Solution**: Show a "Finish" button that saves the completed sets and shows the workout summary, without requiring them to continue.

## Feature Behavior

### Detection Logic

The system checks two conditions:
1. **Time since last save** (`minutesSinceLastSave >= 10`)
2. **Workout completion status** (`workout.isFullyCompleted()`)

### Dialog Variations

#### Scenario A: Completed Workout (100% done + >10 min)
- **Title**: "Workout Complete!" 🎉
- **Icon**: Celebration icon (secondary color)
- **Message**: "You completed all exercises but forgot to finalize"
- **Banner**: Green/secondary colored "Finished X hours/minutes ago - don't forget to save!"
- **Buttons**:
  - **Finalize** (Primary - emphasized) - Saves and shows summary
  - **Add More** (Outlined - de-emphasized) - Resume to add extra sets
  - **Discard** (Text button) - Delete checkpoint

#### Scenario B: Incomplete Workout (>10 min paused)
- **Title**: "Resume Workout?"
- **Icon**: History icon (primary color)
- **Message**: "You have an unfinished workout"
- **Banner**: Yellow/error colored "Paused X hours/minutes ago"
- **Buttons**:
  - **Resume** (Primary) - Continue workout
  - **Finish** (Secondary) - Save partial progress
  - **Discard** (Text button) - Delete checkpoint

#### Scenario C: Recent Pause (<10 min)
- **Title**: "Resume Workout?"
- **Message**: "You have an unfinished workout"
- **No banner**
- **Buttons**:
  - **Resume** (Primary) - Continue workout
  - **Discard** (Text button) - Delete checkpoint

#### Scenario D: Completed Workout (<10 min)
- **Title**: "Workout Complete!" 🎉
- **Message**: "You completed all exercises but forgot to finalize"
- **No banner** (recently completed)
- **Buttons**:
  - **Finalize** (Primary) - Saves and shows summary
  - **Add More** (Outlined) - Resume to add extra sets
  - **Discard** (Text button) - Delete checkpoint

## Technical Implementation

### Modified Files

#### 1. `active_workout.dart`
- **New method**: `isFullyCompleted()` - Checks if all sets in all exercises are completed
  ```dart
  bool isFullyCompleted() {
    if (exercises.isEmpty) return false;
    
    for (final exercise in exercises) {
      if (exercise.sets.isEmpty) return false;
      
      final allSetsComplete = exercise.sets.every((set) => set.isCompleted);
      if (!allSetsComplete) return false;
    }
    
    return true;
  }
  ```
- **New method**: `getCompletedSetsCount()` - Returns count of completed sets
- **New method**: `getTotalSetsCount()` - Returns total count of all sets
- **Purpose**: Enable detection of workout completion state

#### 2. `workout_checkpoint_service.dart`
- **New class**: `CheckpointData`
  ```dart
  class CheckpointData {
    final String id;
    final ActiveWorkout workout;
    final DateTime lastSavedAt;
  }
  ```
- **Updated method**: `getLatestCheckpoint()` now returns `CheckpointData?` instead of `ActiveWorkout?`
- **Purpose**: Provides metadata (lastSavedAt) needed for time-based logic

#### 3. `resume_workout_dialog.dart`
- **New parameters**:
  - `lastSavedAt: DateTime` - When workout was last saved
  - `onFinish: VoidCallback` - Callback for finish action
  
- **Enhanced detection logic**:
  ```dart
  final isFullyCompleted = workout.isFullyCompleted();
  final showFinishOption = minutesSinceLastSave >= 10 || isFullyCompleted;
  final isCompleteForgotten = isFullyCompleted && minutesSinceLastSave >= 10;
  ```

- **Adaptive UI**:
  - **Title**: Changes from "Resume Workout?" to "Workout Complete!" when fully done
  - **Icon**: Celebration icon for complete workouts, history icon for incomplete
  - **Message**: Context-specific text based on completion state
  - **Banner color**: Green/secondary for complete, yellow/error for incomplete
  - **Banner text**: "Finished X ago - don't forget to save!" vs "Paused X ago"
  - **Button order**: Finalize prioritized when complete, Resume prioritized when incomplete
  - **Button labels**: "Finalize" vs "Finish", "Add More" vs "Resume"

- **Helper method**: `_formatDuration(Duration)` for human-readable time display
  - Shows days if > 24 hours
  - Shows hours if > 60 minutes
  - Shows minutes otherwise
  - Proper pluralization

#### 3. `home_screen.dart`
- **Updated checkpoint handling**:
  - Uses `CheckpointData` instead of `ActiveWorkout`
  - Passes `lastSavedAt` to dialog
  - Provides `onFinish` callback:
    ```dart
    onFinish: () async {
      Navigator.of(context).pop();
      ref.read(activeWorkoutProvider.notifier).resumeWorkout(checkpointData.workout);
      await ref.read(activeWorkoutProvider.notifier).finishWorkout();
      if (!mounted) return;
      context.go('/workout-summary');
    }
    ```

## User Experience Flow

### Scenario 1: Forgot to Finalize - Auto-Save (NEW! 🎉)
1. User completes all sets in workout
2. User closes app without clicking "Finish Workout"
3. 15 minutes pass
4. User opens app
5. **NO DIALOG** - App automatically finalizes workout
6. **Direct to celebration** - Summary screen with confetti
7. Workout saved to history with all completed sets
8. Checkpoint automatically deleted

**Why this is great**: Zero friction, instant gratification, feels magical!

### Scenario 2: Workout Reminder Notification (NEW! 🔔)
1. User starts workout, completes 3 out of 6 exercises
2. Phone call comes in, user closes app
3. Call takes 15 minutes
4. After 10 minutes: **Notification appears**
   - Title: "💪 Don't forget your workout!"
   - Body: "You still have 'Push Day' in progress. Tap to continue."
5. User taps notification
6. App opens to active workout screen
7. User continues where they left off

**Why this is great**: Gentle reminder, prevents lost workouts, reduces abandonment rate

### Scenario 3: Want to Add More Sets
1. User completes all sets in workout
2. User closes app without finalizing
3. 5 minutes later, user opens app
4. Dialog appears: "Workout Complete!" (still shows because <10 min)
5. User realizes they want to do bonus sets
6. User clicks "Add More" (outlined button)
7. Returns to active workout screen
8. Can add extra sets to any exercise
9. Eventually clicks "Finish Workout" normally

### Scenario 4: Interrupted Mid-Workout (>10 min)
1. User completes 5 out of 10 exercises
2. App crashes or phone dies
3. 30 minutes later, notification was sent at 10-minute mark
4. User opens app
5. Dialog shows: "Resume Workout?"
6. Yellow banner: "Paused 30 minutes ago"
7. Options: Resume (continue) | Finish (save partial) | Discard
8. User clicks "Finish" to save what's done
9. Summary shows completed exercises only

### Scenario 5: Quick Resume (<10 min, Incomplete)
1. User in middle of workout
2. Gets phone call, app goes to background
3. 3 minutes later, call ends
4. User opens app
5. Dialog shows: "Resume Workout?"
6. No warning banner (recent)
7. Only 2 buttons: Resume | Discard
8. User clicks Resume → back to workout immediately
9. No notification sent (cancelled when app resumed)

## Edge Cases Handled

1. **No sets completed**: Finish button still works, creates empty workout session
2. **Very old checkpoint**: Shows "X days ago" correctly
3. **App state checks**: Only shows dialog if no active workout already running
4. **Navigation safety**: Checks `mounted` before navigation
5. **Threshold boundary**: 9 minutes 59 seconds = no finish button, 10 minutes 0 seconds = shows finish button

## Time Formatting Examples

```dart
Duration(minutes: 5)   → "5 minutes"
Duration(minutes: 1)   → "1 minute"   // singular
Duration(hours: 2)     → "2 hours"
Duration(hours: 1, minutes: 30) → "1 hour"  // ignores minutes
Duration(days: 3)      → "3 days"
Duration(days: 1)      → "1 day"      // singular
```

## Testing Scenarios

### Manual Testing
1. **Start workout, wait >10 minutes**:
   - Complete 2-3 sets
   - Force close app or put in background
   - Wait 10+ minutes
   - Reopen app
   - Verify: Yellow warning banner appears
   - Verify: 3 buttons shown
   - Click "Finish"
   - Verify: Summary screen shows completed sets
   - Verify: Workout saved to history

2. **Start workout, wait <10 minutes**:
   - Complete 1 set
   - Close app
   - Wait 5 minutes
   - Reopen app
   - Verify: No yellow banner
   - Verify: Only 2 buttons (Resume, Discard)

3. **Test time formatting**:
   - Modify threshold to 1 minute for quick testing
   - Check all time ranges (minutes, hours, days)
   - Verify singular/plural forms

### Automated Testing
```dart
testWidgets('Shows finish button when paused >10 minutes', (tester) async {
  final now = DateTime.now();
  final elevenMinutesAgo = now.subtract(Duration(minutes: 11));
  
  await tester.pumpWidget(
    MaterialApp(
      home: ResumeWorkoutDialog(
        workout: mockWorkout,
        lastSavedAt: elevenMinutesAgo,
        onResume: () {},
        onFinish: () {},
        onDiscard: () {},
      ),
    ),
  );
  
  expect(find.text('Finish'), findsOneWidget);
  expect(find.text('Paused 11 minutes ago'), findsOneWidget);
});

testWidgets('Hides finish button when paused <10 minutes', (tester) async {
  final now = DateTime.now();
  final fiveMinutesAgo = now.subtract(Duration(minutes: 5));
  
  await tester.pumpWidget(
    MaterialApp(
      home: ResumeWorkoutDialog(
        workout: mockWorkout,
        lastSavedAt: fiveMinutesAgo,
        onResume: () {},
        onFinish: () {},
        onDiscard: () {},
      ),
    ),
  );
  
  expect(find.text('Finish'), findsNothing);
  expect(find.textContaining('Paused'), findsNothing);
});
```

## Configuration

### Adjusting Time Threshold
To change the 10-minute threshold, modify line in `resume_workout_dialog.dart`:

```dart
final showFinishOption = minutesSinceLastSave >= 10; // Change 10 to desired minutes
```

### Customizing Warning Colors
The warning banner uses `colorScheme.error` and `errorContainer`. To change:

```dart
Container(
  decoration: BoxDecoration(
    color: colorScheme.errorContainer.withOpacity(0.3), // Background
    border: Border.all(
      color: colorScheme.error.withOpacity(0.3), // Border
    ),
  ),
  child: Icon(Icons.access_time, color: colorScheme.error), // Icon
)
```

### Button Styling
- **Resume**: Primary color (default FilledButton)
- **Finish**: Secondary color via `FilledButton.styleFrom(backgroundColor: colorScheme.secondary)`
- **Discard**: Error color via `TextButton` with custom color

## Benefits

1. **User Flexibility**: Three options instead of binary choice
2. **Data Safety**: Saves partial work without forcing continuation
3. **Time-Aware UX**: Different UI for recent vs old workouts
4. **Clear Communication**: Visual warning shows how long workout was paused
5. **Smart Defaults**: Recent workouts emphasize Resume, old workouts offer Finish

## Future Enhancements

1. **Configurable threshold**: Let users set their own time preference
2. **Smart suggestions**: "You usually resume within 5 minutes" → suggest different action
3. **Progress preview**: Show which exercises were completed in dialog
4. **Quick stats**: "You completed 15 sets, 3 exercises" in warning banner
5. **Multiple checkpoints**: Keep last 3 workouts instead of just latest
6. **Checkpoint notes**: Auto-add "Resumed from checkpoint" to workout notes

## Related Files

- `/lib/src/core/services/workout_checkpoint_service.dart` - Checkpoint storage
- `/lib/src/features/workout/presentation/widgets/resume_workout_dialog.dart` - UI dialog
- `/lib/src/features/home/presentation/screens/home_screen.dart` - Dialog trigger
- `/lib/src/features/workout/presentation/providers/active_workout_provider.dart` - Workout state
- `WORKOUT_AUTO_SAVE_FEATURE.md` - Auto-save documentation

## Summary

This feature completes the workout recovery workflow by giving users control over how to handle forgotten or interrupted workouts. The time-based logic ensures the UI adapts to the context: quick resumes for recent interruptions, finish option for extended breaks.
