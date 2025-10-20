# Debug: Exercises Not Showing on Web

## Quick Checks

### 1. Verify Exercises in Supabase
Run this in Supabase SQL Editor:
```sql
SELECT COUNT(*) FROM exercises;
SELECT id, name, category FROM exercises LIMIT 5;
```
Expected: 26 exercises

### 2. Check RLS Policies
```sql
-- Check if RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'exercises';

-- Check policies
SELECT * FROM pg_policies WHERE tablename = 'exercises';
```

### 3. Test Supabase Query Directly
```sql
-- This is what the web app runs
SELECT * FROM exercises ORDER BY name;
```

### 4. Check if User Can See Exercises
The RLS policy allows:
- Global exercises (user_id IS NULL) - visible to everyone
- User's own exercises (user_id = auth.uid()) - visible to owner

### 5. Browser Console Check
Open Chrome DevTools (F12) → Console tab
Look for errors like:
- `Failed to fetch exercises`
- `RLS policy violation`
- `Permission denied`

## Common Issues

### Issue 1: RLS Blocking Anonymous Users
**Symptom**: No exercises visible, RLS error in console

**Fix**: The policy should allow SELECT for everyone on global exercises:
```sql
CREATE POLICY "Global exercises are viewable by everyone"
  ON exercises FOR SELECT
  USING (user_id IS NULL);
```

### Issue 2: Wrong Provider Being Used
**Web uses**: `exercise_web_provider.dart` (direct Supabase)
**Mobile uses**: `exercise_providers.dart` (Drift database)

Check which provider your web screen is using.

### Issue 3: Web App Entry Point
Check `lib/main_web.dart` - does it use the mobile router or web router?

The web app should use web-specific screens that fetch from Supabase.

## Debug Steps

### Step 1: Check Browser Console
```javascript
// Open Console and run:
const { data, error } = await supabase.from('exercises').select();
console.log('Exercises:', data, 'Error:', error);
```

### Step 2: Check Authentication
```javascript
// In Console:
const user = supabase.auth.getUser();
console.log('Current user:', user);
```

### Step 3: Test RLS
```sql
-- In Supabase SQL Editor, run as your user:
SELECT * FROM exercises WHERE user_id IS NULL;
```

Should return 26 global exercises.

### Step 4: Temporarily Disable RLS (Testing Only!)
```sql
ALTER TABLE exercises DISABLE ROW LEVEL SECURITY;
```

If exercises appear now, the issue is RLS policies.

Don't forget to re-enable:
```sql
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
```

## Web App Architecture

The web app has two paths:

**Path 1: Simple Web (main_web_simple.dart)**
- Landing page only
- No exercise functionality

**Path 2: Full Web (main_web.dart)**  
- Full app functionality
- Uses Supabase directly
- Should use `exercise_web_provider.dart`

## Where Exercises Are Used on Web

1. **Template Creation** - When building a workout template
2. **Workout Screen** - During active workout
3. **Exercise Library** - If there's a web exercise library screen

## Fix RLS Issues

If RLS is blocking, ensure these policies exist:

```sql
-- Allow everyone to view global exercises
CREATE POLICY "Global exercises viewable by all"
  ON exercises FOR SELECT
  USING (user_id IS NULL);

-- Allow authenticated users to view their own
CREATE POLICY "Users view own exercises"
  ON exercises FOR SELECT
  USING (auth.uid() = user_id);
```

## Expected Behavior

- ✅ User opens web app
- ✅ Logs in (test@test.com)
- ✅ Goes to Templates or Workout
- ✅ Sees 26 exercises from Supabase
- ✅ Can select exercises for workout

## Still Not Working?

1. Check `lib/main_web.dart` - which routes are defined?
2. Find which screen shows exercises
3. Check which provider that screen uses
4. Verify the provider fetches from Supabase correctly
5. Check browser Network tab for failed requests
