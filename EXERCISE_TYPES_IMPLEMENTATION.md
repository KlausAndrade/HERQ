# Exercise Types Implementation Summary

## Overview
Successfully implemented support for 8 distinct exercise types with dynamic input fields during workout sessions. The system automatically assigns exercise types based on exercise names and properties, with manual override capability.

## Implemented Exercise Types

1. **Weight & Reps** (`weight_reps`) - Default
   - Fields: Weight (kg), Reps
   - Examples: Bench Press, Squat, Deadlift

2. **Bodyweight Reps** (`bodyweight_reps`)
   - Fields: Reps only
   - Examples: Push-ups, Pull-ups, Dips

3. **Weighted Bodyweight** (`weighted_bodyweight`)
   - Fields: Added Weight (kg), Reps
   - Examples: Weighted Pull-ups, Weighted Dips

4. **Assisted Bodyweight** (`assisted_bodyweight`)
   - Fields: Assistance Weight (kg), Reps
   - Examples: Assisted Pull-ups, Band-assisted Dips

5. **Duration** (`duration`)
   - Fields: Duration (seconds)
   - Examples: Plank, Wall Sit, Dead Hang, L-sit

6. **Duration & Weight** (`duration_weight`)
   - Fields: Duration (seconds), Weight (kg)
   - Examples: Farmer's Walk, Sled Push (timed)

7. **Distance & Duration** (`distance_duration`)
   - Fields: Distance (meters), Duration (seconds)
   - Examples: Running, Rowing, Swimming, Cycling

8. **Weight & Distance** (`weight_distance`)
   - Fields: Weight (kg), Distance (meters)
   - Examples: Farmer's Carry, Yoke Walk

## Changes Made

### New Files Created

1. **`lib/src/core/constants/exercise_types.dart`**
   - Exercise type enum and constants
   - `ExerciseTypeConfig` class with field definitions
   - Helper formatters for distance and duration
   - Field labels and configuration

2. **`lib/src/core/utils/exercise_type_mapper.dart`**
   - Auto-assignment logic based on exercise name, equipment, category
   - Pattern matching for different exercise types
   - Assignment reason descriptions

3. **`supabase_exercise_types_migration.sql`**
   - Migration SQL for existing Supabase databases
   - Adds new columns to `set_entries` table
   - Updates old exercise type values to new naming convention

### Modified Files

#### Database Schema

1. **`lib/src/core/models/set_entry.dart`**
   - Added `distance` field (REAL, nullable)
   - Already had `assistanceWeight` and `addedWeight` fields

2. **`lib/src/core/database/database.dart`**
   - Updated schema version to 14
   - Added migration for distance field
   - Maintains backward compatibility

3. **`supabase_web_schema.sql`**
   - Added `distance`, `assistance_weight`, `added_weight` columns to `set_entries` table

#### Domain Models

4. **`lib/src/features/workout/domain/models/active_workout.dart`**
   - Added `distance`, `assistanceWeight`, `addedWeight` to `ActiveSet` model
   - Updated JSON serialization/deserialization
   - Updated props for equality checks

5. **`lib/src/core/data/dto/workout_dto.dart`**
   - Added `assistanceWeight`, `addedWeight` to `SetEntryDto`
   - Updated JSON mapping for Supabase sync
   - Added fields to props

#### UI Components

6. **`lib/src/features/workout/presentation/widgets/set_entry_widget.dart`**
   - Complete refactor for dynamic input fields
   - Added controllers for all field types
   - Dynamic header labels based on exercise type
   - Helper methods for each input type (`_buildWeightInput`, `_buildRepsInput`, etc.)
   - Smart previous set display based on exercise type
   - Automatic field selection based on `ExerciseTypeConfig`

7. **`lib/src/features/workout/presentation/screens/web_workout_screen.dart`**
   - Updated `_SetRow` widget with dynamic input fields
   - Exercise type-based field rendering
   - All controllers for new field types
   - Preserves all fields when updating sets
   - Full web platform support

8. **`lib/src/features/exercises/presentation/screens/create_exercise_screen.dart`**
   - Auto-assignment toggle for exercise types
   - Real-time type assignment as user types exercise name
   - Equipment and category-based type detection
   - Manual override capability
   - Shows assignment reason
   - Displays field requirements for each type

#### Data Providers

9. **`lib/src/features/workout/presentation/providers/active_workout_provider.dart`**
   - Updated `finishWorkout()` to save new fields to local database
   - Updated Supabase sync to include `distance`, `assistance_weight`, `added_weight`
   - Maintains compatibility with existing sets

10. **`lib/src/features/workout/presentation/providers/active_workout_web_provider.dart`**
   - Updated `startWorkoutFromTemplate()` to load exercise types
   - Updated `finishWorkout()` to save all new fields
   - Updated `addSet()` to preserve all field values
   - Updated `updateSet()` to maintain exercise type
   - Full web platform data persistence

## Auto-Assignment Logic

The system intelligently assigns exercise types based on:

### Duration Exercises
- Keywords: plank, hold, wall sit, dead hang, hollow hold, l-sit, isometric
- Example: "Plank" → Duration

### Distance & Duration (Cardio)
- Keywords: run, jog, sprint, row, swim, cycle, bike, elliptical
- Category: cardio, conditioning
- Example: "Running" → Distance & Duration

### Duration & Weight (Timed Carries)
- Keywords: farmer walk, sled push, sled pull, prowler push
- Example: "Farmer Walk" → Duration & Weight

### Weight & Distance (Distance Carries)
- Keywords: farmer carry, waiter carry, overhead carry, suitcase carry, yoke walk
- Example: "Farmer Carry" → Weight & Distance

### Weighted Bodyweight
- Keywords: weighted pull, weighted dip, weighted push, +weight
- Example: "Weighted Pull-up" → Weighted Bodyweight

### Assisted Bodyweight
- Keywords: assisted pull, assisted chin, assisted dip, band pull, machine pull
- Equipment: assisted, machine, band (with bodyweight exercises)
- Example: "Assisted Pull-up" → Assisted Bodyweight

### Bodyweight Reps
- Equipment: bodyweight, none
- Category: calisthenics
- Keywords: push-up, pull-up, chin-up, dip, burpee, etc.
- Example: "Push-up" → Bodyweight Reps

### Weight & Reps (Default)
- All other exercises
- Example: "Bench Press" → Weight & Reps

## Migration Guide

### For Local Database (Drift)
The migration is automatic. When users update the app:
1. Schema version increments to 14
2. `distance` column is added to `set_entries` table
3. Existing data remains intact

### For Supabase (Cloud Database)
Run the migration SQL file:
```bash
# In Supabase SQL Editor, run:
supabase_exercise_types_migration.sql
```

This will:
- Add `distance`, `assistance_weight`, `added_weight` columns
- Update old exercise type values to new naming convention
- Maintain data integrity

## Usage

### Creating Exercises
1. Enter exercise name (e.g., "Plank")
2. System auto-assigns type (Duration)
3. Shows reason: "Time-based exercise (hold or isometric)"
4. Toggle "Auto-assign" OFF to manually select
5. View field requirements in dropdown

### During Workout
1. Exercise type determines which input fields appear
2. Headers adjust to show relevant labels
3. Previous set data displays only relevant fields
4. Examples:
   - Bench Press: Shows KG and REPS fields
   - Plank: Shows TIME field
   - Weighted Pull-up: Shows +KG and REPS fields
   - Running: Shows M (meters) and TIME fields

### Data Storage
All fields are stored in the database:
- `weight`: Standard weight in kg
- `reps`: Number of repetitions
- `duration_seconds`: Time in seconds
- `distance`: Distance in meters
- `assistance_weight`: Assistance provided (kg)
- `added_weight`: Additional weight for bodyweight exercises (kg)

## Display Formatting

- **Distance**: Automatically converts to km if ≥ 1000m
  - `500m` → "500 m"
  - `1500m` → "1.50 km"

- **Duration**: Displays in MM:SS format
  - `75 seconds` → "01:15"
  - `125 seconds` → "02:05"

- **Added Weight**: Shows with plus sign
  - `10kg` → "+10 kg"

- **Assistance Weight**: Shows with minus sign (in previous set display)
  - `20kg` assistance → "-20 kg" or "20 kg" depending on context

## Backward Compatibility

✅ Existing sets without new fields continue to work
✅ Null values handled gracefully
✅ Old exercise types automatically migrated
✅ Web and mobile platforms synchronized

## Testing Recommendations

1. **Create New Exercises**
   - Test auto-assignment with various exercise names
   - Verify manual override works
   - Check field display matches type

2. **Run Workouts**
   - Test each exercise type during a workout
   - Verify correct input fields appear
   - Check data saves correctly

3. **Migration**
   - Backup database before running migration
   - Verify existing data intact after migration
   - Test old workouts display correctly

4. **Sync**
   - Create workout on mobile, check web
   - Verify all new fields sync properly
   - Test offline → online sync

## Next Steps (Optional Enhancements)

1. **Unit Preferences**: Add imperial/metric toggle
2. **Pace Calculation**: For distance/duration exercises (min/km)
3. **Rest Timer Adjustment**: Different defaults per exercise type
4. **Volume Calculations**: Account for bodyweight in weighted/assisted exercises
5. **Exercise Search**: Filter by exercise type
6. **Analytics**: Type-specific charts and insights

## Files Requiring Drift Code Generation

After these changes, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This regenerates the database code based on the updated schema.

