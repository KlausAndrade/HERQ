# Setup Guide: Social Workout Sharing

This guide explains how to set up the multi-user workout sharing feature in Supabase.

## Overview

When users complete a workout and share it to social:
1. **Workout session** is saved to Supabase
2. **Set entries** (individual sets) are saved to Supabase  
3. **Post** is created with `workout_session_id` linking to the workout
4. Other users can view workout details, save as template, or start the workout

## Prerequisites

- Supabase project set up
- `posts` table already exists with `workout_session_id` column added

## Step 1: Run the Table Setup Migration

Run the SQL script in `docs/sql/supabase_workout_tables_setup.sql` in your Supabase SQL Editor.

This will create:
- `workout_sessions` table
- `exercises` table  
- `set_entries` table
- Proper foreign key relationships
- Row Level Security (RLS) policies
- Performance indexes

### What the Migration Does:

✅ **Creates Tables** with proper schemas
✅ **Sets up Foreign Keys** so `set_entries` can join with `exercises`
✅ **Enables RLS** for data security
✅ **Allows Read Access** so users can view each other's shared workouts
✅ **Restricts Write Access** so users can only modify their own data

## Step 2: Sync Exercise Data (One-Time Setup)

The app already syncs workout sessions and set entries to Supabase automatically. However, you need to ensure the `exercises` table is populated.

### Option A: Manual Sync (Recommended for Initial Setup)

Run this in your Supabase SQL Editor to copy exercises from the app's database:

```sql
-- This is a placeholder - you'll need to export exercises from your local database
-- and import them to Supabase using the Supabase dashboard or API

-- Example insert for a single exercise:
INSERT INTO exercises (id, name, exercise_type, equipment, primary_muscle_group, user_id)
VALUES 
  ('exercise_barbell_squat', 'Barbell Squat', 'reps', 'barbell', 'legs', NULL),
  ('exercise_bench_press', 'Bench Press', 'reps', 'barbell', 'chest', NULL);
-- Add more exercises as needed
```

### Option B: Automatic Sync (Future Enhancement)

TODO: Add a sync service that automatically uploads exercises to Supabase when they're created in the app.

## Step 3: Verify Setup

After running the migrations, verify the setup:

```sql
-- 1. Check that tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('workout_sessions', 'exercises', 'set_entries')
ORDER BY table_name;

-- 2. Check foreign key relationships
SELECT
    tc.table_name, 
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name IN ('workout_sessions', 'set_entries', 'posts');

-- 3. Check RLS policies
SELECT tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename IN ('workout_sessions', 'exercises', 'set_entries')
ORDER BY tablename, policyname;
```

## Step 4: Test the Feature

1. **Complete a workout** in the app
2. **Toggle "Share to social"** when finishing
3. **Check Supabase** to verify data was synced:

```sql
-- Check workout session was created
SELECT * FROM workout_sessions ORDER BY created_at DESC LIMIT 1;

-- Check set entries were created
SELECT * FROM set_entries ORDER BY created_at DESC LIMIT 10;

-- Check post was created with workout link
SELECT id, user_id, caption, workout_session_id, created_at 
FROM posts 
WHERE workout_session_id IS NOT NULL 
ORDER BY created_at DESC 
LIMIT 1;
```

4. **View the post** in the social feed
5. **Click "View Workout"** - should show real exercise details
6. **Click "Save Template"** - should save with correct exercises
7. **Click "Start Workout"** - should start with correct exercises

## Troubleshooting

### Issue: "No exercise details available"

**Cause**: Post doesn't have a `workout_session_id`

**Solutions**:
- Make sure you ran the migration to add `workout_session_id` column to `posts` table
- Complete a NEW workout after the migration
- Old posts created before the migration won't have workout links

### Issue: "Could not find a relationship between 'set_entries' and 'exercises'"

**Cause**: Foreign key relationship not set up in Supabase

**Solution**:
- Run the `supabase_workout_tables_setup.sql` migration
- This creates the proper foreign keys and relationships

### Issue: "Exercise data not found"

**Cause**: Exercise doesn't exist in Supabase `exercises` table

**Solutions**:
- Populate the `exercises` table in Supabase (see Step 2)
- The `_ensureExercisesExist` function in the app will copy exercises from Supabase to local DB when users view/start workouts

### Issue: "Workout started empty"

**Cause**: No set entries found in Supabase for that session

**Solution**:
- Check that set entries are being synced in `active_workout_provider.dart` (lines 1281-1307)
- Verify RLS policies allow users to read set entries
- Check network connectivity during workout completion

## Architecture Notes

### Data Flow

```
User completes workout
  ↓
1. Save to local SQLite database
  ↓
2. Sync to Supabase (background, with timeout)
   - workout_sessions table
   - set_entries table
  ↓
3. If "Share to Social" toggled:
   - Create post with workout_session_id
  ↓
Other users view post
  ↓
Click "View Workout"
  ↓
Fetch from Supabase:
   - set_entries with exercise details
  ↓
Display exercise breakdown
```

### Multi-User Sharing

- **Workout sessions** are visible to all users (RLS allows SELECT for all authenticated users)
- **Exercises** are global (user_id = NULL) or user-specific
- **Set entries** include all set details (reps, weight, etc.)
- **Posts** link to workout sessions via `workout_session_id`

### Privacy & Security

- RLS policies ensure users can only **write** their own data
- Users can **read** all shared workout data (needed for social features)
- Deleted workouts cascade properly (foreign keys with ON DELETE CASCADE)
- Personal notes and private data stay on device

## Files Modified

- `lib/src/features/social/presentation/widgets/post_card.dart` - View/start/save workouts
- `lib/src/features/workout/presentation/screens/active_workout_screen.dart` - Create posts with workout links
- `lib/src/features/workout/presentation/providers/active_workout_provider.dart` - Sync to Supabase
- `lib/src/features/social/presentation/providers/social_providers.dart` - Added `workoutSessionId` to `SupabasePost`
- `docs/sql/supabase_workout_tables_setup.sql` - Database schema setup
- `docs/sql/supabase_posts_workout_link.sql` - Add workout_session_id to posts

## Next Steps

1. Run the SQL migrations in Supabase
2. Populate the `exercises` table
3. Complete a test workout and share it
4. Verify the feature works end-to-end
5. Test with multiple users

## Future Enhancements

- [ ] Automatic exercise sync to Supabase
- [ ] Workout privacy settings (public/private/friends-only)
- [ ] Workout comments and reactions
- [ ] Workout challenges and leaderboards
- [ ] Exercise video demonstrations
- [ ] Custom exercise creation from social posts

