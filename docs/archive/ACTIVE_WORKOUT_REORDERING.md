# Active Workout Reordering & Change Tracking Implementation

## Overview
Added the ability to reorder exercises during an active workout and track modifications for confirmation before finishing.

## Features Implemented

### 1. Exercise Reordering During Workout
- **Location**: Active Workout Screen
- **UI**: Drag handle icon appears next to each exercise
- **Behavior**: 
  - Exercises can be reordered by dragging
  - Current exercise index is updated correctly when reordering
  - Changes are automatically saved to workout checkpoint
  - Smooth reordering animation with ReorderableListView

### 2. Change Tracking System
- **Provider**: `workoutModificationsProvider` (StateNotifier<bool>)
- **Tracks changes when**:
  - Exercises are reordered
  - New exercises are added
  - Exercises are removed
  - Sets are added
  - Sets are removed

### 3. Finish Workout Confirmation
- **Shows enhanced dialog when modifications detected**:
  - Lists types of changes made (reordering, adding/removing exercises, adding/removing sets)
  - Informs user that changes will be saved in workout history
  - Same Finish/Discard/Cancel options as before

## Technical Implementation

### Modified Files

#### 1. `active_workout_provider.dart`
**Added:**
- `workoutModificationsProvider` - Tracks if workout has been modified
- `WorkoutModificationsNotifier` - Simple StateNotifier for bool flag
- `reorderExercises(int oldIndex, int newIndex)` - Handles exercise reordering logic
- Calls to `markAsModified()` in:
  - `addSet()`
  - `removeSet()`
  - `addExercise()`
  - `reorderExercises()`
- Calls to `reset()` in:
  - `startWorkoutFromTemplate()` - Fresh workout starts unmodified

**Logic:**
- Reordering updates current exercise index correctly based on drag position
- Checkpoint auto-saves via state listener
- Removed unused `supabase_flutter` import

#### 2. `active_workout_screen.dart`
**Changed:**
- `ListView.builder` → `ReorderableListView.builder` (line 227)
- Added `buildDefaultDragHandles: false` - Custom drag handles
- Added `onReorder` callback that calls provider's `reorderExercises`
- Wrapped each exercise card in `ReorderableDragStartListener`
- Added `showDragHandle` parameter to `_ExerciseCard` widget

**_ExerciseCard Updates:**
- New optional parameter: `bool showDragHandle = false`
- Drag handle icon rendered if `showDragHandle == true`
- Icon appears between exercise name and expand/collapse arrow
- Uses `Icons.drag_handle` with opacity for subtle appearance

**Finish Dialog Enhancement:**
- Reads `workoutModificationsProvider` to check if changes were made
- Shows different content based on modification state:
  - **No changes**: Standard "Are you sure?" message
  - **Has changes**: Detailed list of what types of changes were made

## User Flow

### Starting Workout
1. User starts workout from template
2. Modifications flag is reset to `false`
3. Workout displays with 3 default sets per exercise

### Making Changes During Workout
1. **Reordering**: Drag exercises by drag handle icon
2. **Adding Sets**: Press "+" button
3. **Removing Sets**: Swipe to delete
4. **Adding Exercises**: Press "Add Exercise" button
5. All actions mark workout as modified

### Finishing Workout
1. User presses "Finish Workout"
2. If incomplete exercises → warning dialog
3. If modifications made → confirmation with change summary
4. User chooses:
   - **Finish** - Saves workout with all changes
   - **Discard** - Deletes workout
   - **Cancel** - Returns to workout

## Code Patterns Used

### Reordering Pattern
```dart
ReorderableListView.builder(
  buildDefaultDragHandles: false,
  onReorder: (oldIndex, newIndex) {
    ref.read(provider.notifier).reorderExercises(oldIndex, newIndex);
  },
  itemBuilder: (context, index) {
    return ReorderableDragStartListener(
      key: ValueKey('exercise-${exercise.id}-$index'),
      index: index,
      child: WidgetCard(...),
    );
  },
)
```

### Change Tracking Pattern
```dart
// Mark as modified after any change
void addSet(int exerciseIndex) {
  // ... update state ...
  _ref.read(workoutModificationsProvider.notifier).markAsModified();
}

// Reset on fresh workout
void startWorkout() {
  // ... create workout ...
  _ref.read(workoutModificationsProvider.notifier).reset();
}

// Check before finish
final hasModifications = ref.read(workoutModificationsProvider);
if (hasModifications) {
  // Show confirmation dialog
}
```

## Benefits

### User Experience
- ✅ Flexibility to adapt workout on the fly
- ✅ Clear indication when drag is possible (drag handle icon)
- ✅ Awareness of changes before finishing (confirmation dialog)
- ✅ No accidental loss of customizations

### Data Integrity
- ✅ All changes tracked in checkpoint system
- ✅ Workout modifications preserved if app crashes
- ✅ User explicitly confirms changes before saving

### Code Quality
- ✅ Consistent with existing reordering patterns (templates, folders)
- ✅ Clean separation of concerns (UI, state, business logic)
- ✅ Riverpod best practices (StateNotifier for flag)
- ✅ No breaking changes to existing functionality

## Testing Recommendations

1. **Reordering**:
   - Drag exercises to different positions
   - Verify current exercise indicator updates correctly
   - Check checkpoint saves reordered state
   - Test with 2, 5, 10+ exercises

2. **Change Tracking**:
   - Start workout, immediately finish → no confirmation
   - Add set → finish → confirmation shown
   - Remove set → finish → confirmation shown
   - Add exercise → finish → confirmation shown
   - Reorder exercises → finish → confirmation shown

3. **Edge Cases**:
   - Reorder while rest timer active
   - Reorder the currently active exercise
   - Reorder first/last exercises
   - App background/foreground during workout
   - Low battery mode

## Future Enhancements

- [ ] Undo/redo for reordering
- [ ] Visual indicator on cards showing they've been modified
- [ ] Comparison view showing original template vs current workout
- [ ] Option to save modified workout as new template
- [ ] Bulk reorder mode (select multiple, move together)

## Related Files
- `lib/src/features/workout/presentation/providers/active_workout_provider.dart`
- `lib/src/features/workout/presentation/screens/active_workout_screen.dart`
- `lib/src/features/workout/domain/models/active_workout.dart`
- `lib/src/features/workout/presentation/providers/workout_checkpoint_provider.dart`

## Dependencies
- `flutter_riverpod` - State management
- `hooks_riverpod` - Consumer widgets
- ReorderableListView (built-in Flutter widget)
- ReorderableDragStartListener (built-in Flutter widget)
