# Quick Workout Route Fix

## Issue
Quick Workout feature was navigating to a "Workout Not Found" error page instead of starting the workout.

## Root Cause
The navigation routes were incorrect. The code was navigating to `/workout/active` but the router was configured for `/active-workout`.

### Router Configuration (Correct)
```dart
GoRoute(
  path: '/active-workout',  // ← Correct path
  name: 'active-workout',
  builder: (context, state) {
    final templateId = state.uri.queryParameters['templateId'];
    return ActiveWorkoutScreen(templateId: templateId);
  },
),
```

### Incorrect Navigation (Before Fix)
```dart
context.go('/workout/active?templateId=$templateId');  // ❌ Wrong path
```

### Correct Navigation (After Fix)
```dart
context.go('/active-workout?templateId=$templateId');  // ✅ Correct path
```

## Files Fixed

### 1. exercise_detail_screen.dart
**Function**: `_startQuickWorkout()`
- **Line**: 757
- **Change**: `/workout/active` → `/active-workout`
- **Feature**: Quick Workout button on exercise detail page

### 2. workout_detail_screen.dart (2 locations)

#### Location 1: Repeat Workout
**Function**: `_startNewWorkoutWithTemplate()`
- **Line**: 254
- **Change**: `/workout/active` → `/active-workout`
- **Feature**: "Repeat Workout" option from workout menu

#### Location 2: Quick Start from Template
**Function**: Part of category templates quick start
- **Line**: 290
- **Change**: `/workout/active` → `/active-workout`
- **Feature**: Quick start workout from template

## Impact
✅ **Quick Workout** from exercise detail now works correctly  
✅ **Repeat Workout** from completed workouts now works  
✅ **Quick Start** from workout templates now works  

## Testing Steps
1. Go to Exercise Library
2. Select any exercise (e.g., Bench Press)
3. Tap "Quick Workout" button
4. ✅ Should navigate to Active Workout Screen with that exercise loaded
5. Go to Workout History
6. Select a completed workout
7. Tap menu (⋮) → "Repeat Workout"
8. ✅ Should navigate to Active Workout Screen with same exercises

## Related Code Flow

### Quick Workout Flow
1. User taps "Quick Workout" on exercise detail
2. Creates temporary template: `'quick_${timestamp}'`
3. Inserts template into database with exercise ID
4. Navigates to `/active-workout?templateId=quick_123456`
5. `ActiveWorkoutScreen` loads with template ID
6. `startWorkoutFromTemplate()` fetches template from DB
7. Initializes active workout with exercise and 3 empty sets
8. User can start logging sets

### Template Properties
```dart
WorkoutTemplatesCompanion.insert(
  id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
  name: 'Quick: ${exercise.name}',
  exerciseIds: [exercise.id],
  tags: const [],
  category: const Value('Quick Start'),
)
```

## Why This Bug Occurred
The route path `/active-workout` was established in the router, but when implementing the quick workout feature, the developers used `/workout/active` instead, likely thinking it followed the pattern of other workout routes like:
- `/workout/:id` - Workout detail
- `/workout/active` - Active workout (assumed, but wrong)

The correct pattern is that main feature screens use simple paths:
- `/active-workout` - Active workout screen
- `/workout-history` - Workout history screen
- `/exercises` - Exercise library screen

## Prevention
When adding new navigation, always:
1. Check the router configuration in `app_router.dart`
2. Use the exact path defined in the router
3. Consider using named routes: `context.goNamed('active-workout', ...)`
4. Test the navigation immediately after implementation

## Named Route Alternative (Future Improvement)
Instead of:
```dart
context.go('/active-workout?templateId=$templateId');
```

Could use:
```dart
context.goNamed(
  'active-workout',
  queryParameters: {'templateId': templateId},
);
```

This would prevent path typos since the route name is validated at compile time.
