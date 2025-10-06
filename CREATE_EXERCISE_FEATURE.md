# Create Custom Exercise Feature

## Issue
User reported: "I can't create an exercise?"

The app had no functionality to create custom exercises. Only pre-seeded exercises from the database were available.

## Solution
Added a complete **Create Custom Exercise** feature with:

1. ✅ New screen: `CreateExerciseScreen`
2. ✅ FloatingActionButton on Exercise Library
3. ✅ Route configuration
4. ✅ Full exercise configuration form

## Files Created

### 1. CreateExerciseScreen
**Path**: `lib/src/features/exercises/presentation/screens/create_exercise_screen.dart`

**Features**:
- ✅ Exercise name input (required)
- ✅ Primary muscle group dropdown
- ✅ Secondary muscle groups (multi-select chips)
- ✅ Equipment selection
- ✅ Category (strength, calisthenics, yoga, cardio, flexibility)
- ✅ Exercise type (reps, timer, body_weighted, assisted)
- ✅ Difficulty (beginner, intermediate, advanced, expert)
- ✅ Tags (multi-select: Compound, Isolation, Push, Pull, etc.)
- ✅ Bodyweight checkbox (auto-checked for bodyweight equipment)
- ✅ **Exercise Variants** (NEW! - set as variant of another exercise)
- ✅ Instructions (optional multi-line text)
- ✅ Form validation
- ✅ Loading state with spinner
- ✅ Success/error feedback

**ID Format**: Custom exercises get IDs with prefix `custom_` (e.g., `custom_uuid-here`) to differentiate from system exercises.

## Files Modified

### 1. Exercise Library Screen
**File**: `lib/src/features/exercises/presentation/screens/exercise_library_screen.dart`

**Changes**:
- Added `FloatingActionButton` to create new exercises
- Button navigates to `/exercises/create`
- Tooltip: "Create Exercise"

### 2. App Router
**File**: `lib/src/core/routing/app_router.dart`

**Changes**:
- Added import for `CreateExerciseScreen`
- Added route: `/exercises/create` → `CreateExerciseScreen`

## Usage Flow

1. **Go to Exercise Library**
   - Tap on "Exercises" tab or go to Exercise Library

2. **Tap the + Button (FAB)**
   - FloatingActionButton in bottom-right corner
   - Opens Create Exercise screen

3. **Fill Exercise Details**
   - **Required**: Name, Primary Muscle, Equipment, Category, Type, Difficulty
   - **Optional**: Secondary muscles, Tags, Instructions
   - Bodyweight auto-checks when equipment is "Bodyweight" or "None"

4. **Save Exercise**
   - Tap "Save" in AppBar
   - Shows loading spinner while saving
   - Success: Green snackbar + navigates back
   - Error: Red snackbar with error message

5. **View Custom Exercise**
   - Exercise appears in Exercise Library
   - Can be used in workouts like any other exercise
   - Can be favorited, added to templates, used in Quick Workout

## Exercise Configuration Options

### Muscle Groups
- Chest, Back, Shoulders, Arms, Legs, Core, Glutes, Calves, Forearms, Traps

### Equipment
- Barbell, Dumbbell, Machine, Bodyweight, Cable, Kettlebell, Resistance Band, Medicine Ball, None

### Categories
- Strength, Calisthenics, Yoga, Cardio, Flexibility

### Exercise Types
- **Reps**: Standard rep-based (e.g., Bench Press)
- **Timer**: Time-based (e.g., Plank)
- **Body Weighted**: Weighted bodyweight (e.g., Weighted Pull-ups)
- **Assisted**: Assisted variations (e.g., Assisted Dips)

### Difficulty Levels
- Beginner, Intermediate, Advanced, Expert

### Common Tags
- Compound, Isolation, Push, Pull, Unilateral, Bilateral, Core, Stability, Power, Hypertrophy

### Variant Types (NEW!)
- **Progression**: Harder version (🟢 Green badge)
- **Regression**: Easier version (🟡 Amber badge)
- **Assisted**: With assistance (🔵 Blue badge)
- **Weighted**: Add weight to bodyweight (🟣 Purple badge)
- **Equipment**: Different equipment (🟦 Teal badge)
- **Strict**: Stricter form (🔷 Indigo badge)
- **Angle**: Different angle (🟠 Orange badge)
- **Tempo**: Different speed (🌸 Pink badge)

**See EXERCISE_VARIANT_GUIDE.md for complete variant documentation**

## Data Storage

Custom exercises are stored in the same `exercises` table as system exercises:
- **System exercises**: IDs from seed data (e.g., `bench_press`, `squat`)
- **Custom exercises**: IDs with `custom_` prefix (e.g., `custom_a1b2c3d4-...`)

### Database Fields Used
```dart
ExercisesCompanion.insert(
  id: 'custom_${uuid}',
  name: 'Exercise Name',
  primaryMuscleGroup: 'Chest',
  secondaryMuscleGroups: ['Shoulders', 'Arms'],
  equipment: 'Barbell',
  instructions: 'Instructions...',
  tags: ['Compound', 'Push'],
  isBodyweight: false,
  exerciseType: 'reps',
  category: 'strength',
  difficulty: 'intermediate',
  parentExerciseId: 'bench_press',  // NEW! Link to parent if variant
  variantType: 'angle',              // NEW! Type of variation
)
```

## Benefits

### For Users
✅ **Flexibility**: Create exercises not in the default library  
✅ **Customization**: Add gym-specific machines or unique variations  
✅ **Complete Library**: Mix custom and system exercises seamlessly  
✅ **Easy to Use**: Simple form with sensible defaults  

### For App
✅ **No Migration Needed**: Uses existing database schema  
✅ **Unique IDs**: `custom_` prefix prevents conflicts  
✅ **Full Integration**: Works with all existing features (favorites, templates, workouts)  
✅ **Instant Sync**: Refreshes exercise list after creation  

## Testing Steps

1. **Open Exercise Library**
2. **Tap + Button (FloatingActionButton)**
3. **Create a custom exercise**:
   ```
   Name: "Cable Crossover"
   Primary Muscle: Chest
   Secondary: Shoulders
   Equipment: Cable
   Category: strength
   Type: reps
   Difficulty: intermediate
   Tags: Isolation, Push
   ```
4. **Tap Save**
5. **Verify**:
   - ✅ Green success snackbar appears
   - ✅ Returns to Exercise Library
   - ✅ New exercise appears in list
   - ✅ Can tap exercise to view details
   - ✅ Can use in Quick Workout
   - ✅ Can add to templates

## Future Enhancements

### Possible Improvements
- [ ] **Edit Exercise**: Allow editing custom exercises
- [ ] **Delete Exercise**: Remove custom exercises (check if used in workouts first)
- [ ] **User ID Field**: Add `userId` to track who created each exercise
- [ ] **Share Exercises**: Share custom exercises with other users
- [ ] **Import/Export**: Bulk import exercises from CSV/JSON
- [ ] **Exercise Images**: Add photos or diagrams for custom exercises
- [ ] **Video Links**: Add YouTube links for exercise tutorials
- [ ] **Exercise History**: Track when exercise was created/modified
- [ ] **Templates**: Save exercise creation templates for quick reuse

### Database Migration (If Needed)
If you want to add user ownership later:
```dart
// Add userId column (nullable for backward compatibility)
TextColumn get userId => text().nullable()();
```

Then filter exercises:
```dart
// Show system exercises + user's custom exercises
final exercises = await (
  select(exercises)
    ..where((tbl) => 
      tbl.userId.isNull() | // System exercises
      tbl.userId.equals(currentUserId) // User's exercises
    )
).get();
```

## Notes

- Custom exercises persist across app restarts (stored in SQLite)
- Custom exercises appear alongside system exercises in all views
- No limit on number of custom exercises
- Form has proper validation and error handling
- Auto-formats exercise type and category names for display
- Bodyweight flag auto-updates based on equipment selection
- Instructions are optional but recommended for proper form

## Documentation Updated
- Added this documentation file
- Ready for user testing
- Feature fully integrated with existing codebase
