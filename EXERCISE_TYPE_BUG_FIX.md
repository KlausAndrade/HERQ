# Exercise Type Auto-Reset Bug - FIXED ✅

## The Problem
When trying to input values for exercises with non-standard types (like `distance_duration` for Burpees), the input fields would auto-reset to "kg & reps" as soon as the user started typing.

## Root Cause
The `ActiveExercise` was being reconstructed in **4 different places** in `active_workout_provider.dart` without preserving the `exerciseType` field. Every time the workout state updated (like when typing in a set value), the exercise type would revert to the default `'reps'`.

## Locations Fixed

### 1. `updateSet()` - Line 456-462
**Issue**: When updating a set (typing values, completing a set), the `exerciseType` was lost.
**Fix**: Added `exerciseType: exercise.exerciseType` to the `ActiveExercise` constructor.

### 2. `addSet()` - Line 514-520  
**Issue**: When adding a new set, the `exerciseType` was lost.
**Fix**: Added `exerciseType: exercise.exerciseType` and also preserved all new fields (`durationSeconds`, `distance`, `assistanceWeight`, `addedWeight`) when copying from the template set.

### 3. `removeSet()` - Line 570-576
**Issue**: When removing a set and renumbering remaining sets, the `exerciseType` was lost and new fields weren't preserved.
**Fix**: Added `exerciseType: exercise.exerciseType` and included all new fields in the `ActiveSet` renumbering.

### 4. `updateExerciseRestTimer()` - Line 678-684
**Issue**: When changing rest timer, the `exerciseType` was lost.
**Fix**: Added `exerciseType: exercise.exerciseType`.

## Additional Improvements

### PR Detection (Line 417-429)
- Added all new fields (`durationSeconds`, `distance`, `assistanceWeight`, `addedWeight`) to the PR detection ActiveSet creation.

### Auto-fill Logic (Line 433-459)
- Updated to copy **all** field types (duration, distance, weights) when auto-filling subsequent sets.
- Updated the "isEmpty" check to include new fields.

## Debugging Added

### `active_workout_provider.dart` (Line 157)
- Logs exercise type when loading from database: `📝 Loading exercise: {name}, Type: {type}`

### `set_entry_widget.dart` (Lines 114-116 & 73-77)
- Logs exercise type received by widget on first set
- Logs if exercise type changes during rebuild (should never happen now!)

## Testing
1. Start any workout with non-standard exercise types (duration, distance_duration, etc.)
2. Try typing values in the input fields
3. The fields should **stay correct** and not reset to kg & reps
4. Add/remove sets - exercise type should be preserved
5. Check console logs - no warnings about exercise type changing

## Files Modified
- `lib/src/features/workout/presentation/providers/active_workout_provider.dart`
- `lib/src/features/workout/presentation/widgets/set_entry_widget.dart`
- `lib/src/features/settings/presentation/screens/settings_screen.dart` (added debug tool)

## Note
The web provider (`active_workout_web_provider.dart`) was already correctly preserving `exerciseType` in all locations ✅
