# Smart Finish Feature - Workout Resume Enhancement

## Overview

The Smart Finish feature enhances the workout recovery system by providing a third option when resuming workouts that have been paused for more than 10 minutes. This allows users to save their completed work without continuing the workout.

## User Story

**Problem**: User starts a workout, completes some exercises, then app is closed or crashes. After 10+ minutes, they may not want to continue but don't want to lose the work they already completed.

**Solution**: Show a "Finish Workout" button that saves the completed sets and shows the workout summary, without requiring them to continue and manually finish.

## Feature Behavior

### Time Threshold
- **< 10 minutes paused**: Show 2 buttons (Resume, Discard)
- **≥ 10 minutes paused**: Show 3 buttons (Resume, Finish, Discard)

### Visual Indicators
When paused ≥10 minutes:
- Yellow warning banner shows: "Paused X hours/minutes/days ago"
- Icon: Clock symbol with error color
- Finish button uses secondary color to distinguish from Resume

### Button Actions

1. **Resume** (Primary - FilledButton)
   - Restores workout state exactly as it was
   - Navigates to active workout screen
   - Restarts timer and services

2. **Finish** (Secondary - FilledButton, shown only if >10 min)
   - Loads the saved workout state
   - Immediately calls finishWorkout()
   - Shows workout summary with completed sets
   - Saves to database with actual completion time

3. **Discard** (Destructive - TextButton)
   - Deletes the checkpoint from database
   - No data is saved
   - Returns to home screen

## Technical Implementation

### Modified Files

#### 1. `workout_checkpoint_service.dart`
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

#### 2. `resume_workout_dialog.dart`
- **New parameters**:
  - `lastSavedAt: DateTime` - When workout was last saved
  - `onFinish: VoidCallback` - Callback for finish action
  
- **Time calculation logic**:
  ```dart
  final now = DateTime.now();
  final timeSinceLastSave = now.difference(lastSavedAt);
  final minutesSinceLastSave = timeSinceLastSave.inMinutes;
  final showFinishOption = minutesSinceLastSave >= 10;
  ```

- **Helper method**: `_formatDuration(Duration)` for human-readable time display
  - Shows days if > 24 hours
  - Shows hours if > 60 minutes
  - Shows minutes otherwise
  - Proper pluralization

- **UI enhancements**:
  - Warning banner with pause duration
  - Conditional third button
  - Secondary color styling for Finish button

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

### Scenario 1: Quick Resume (<10 minutes)
1. User opens app
2. Dialog shows: "Resume" or "Discard"
3. No warning banner
4. User clicks Resume → back to workout

### Scenario 2: Long Pause (≥10 minutes)
1. User opens app after extended break
2. Dialog shows: "Resume", "Finish", or "Discard"
3. Yellow warning: "Paused 43 minutes ago"
4. User options:
   - **Resume**: Continue where left off
   - **Finish**: Save completed work, show summary
   - **Discard**: Delete everything

### Scenario 3: Forgotten Workout (hours/days later)
1. User opens app next day
2. Dialog shows: "Paused 1 day ago"
3. User clicks "Finish" to save yesterday's partial workout
4. Summary screen shows completed sets with correct timestamps
5. Workout saved to history

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
