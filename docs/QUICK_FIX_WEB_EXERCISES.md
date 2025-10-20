# Quick Fix: Web Exercises Not Showing

## Current Status
- ✅ Exercises exist in Supabase (26 exercises verified)
- ✅ Web app loads successfully
- ✅ Authentication working (test@test.com)
- ❌ Exercises not appearing in exercise picker

## Root Cause
The web app's exercise picker was using the mobile provider which returns empty on web.

## Fix Applied
Created `exercise_unified_provider.dart` that:
- Uses `exercisesWebProvider` on web (fetches from Supabase)
- Uses local database on mobile
- Converts Supabase Map to Exercise objects

## Testing Steps

### 1. Open Web App
- Should be running on Chrome
- Login with: test@test.com / Asdf1234!

### 2. Navigate to Templates
- Click "Templates" from home
- Or go to: `http://localhost:PORT/templates`

### 3. Create Template
- Click "+ Create Template" button
- Click "Add Exercises" button
- **Check if exercises appear**

### 4. Check Browser Console
Press F12 and look for:
```
✅ Should see: Exercise data loading messages
❌ Check for: Any errors about exercises, RLS, or permissions
```

## If Still No Exercises

### Debug Step 1: Check Console Logs
Look for these messages:
```javascript
// Should see in console
"Fetching exercises from Supabase..."
"Found X exercises"
```

### Debug Step 2: Test Supabase Directly
Open Console (F12) and run:
```javascript
const { data, error } = await supabase.from('exercises').select();
console.log('Exercises:', data?.length, 'Error:', error);
```

Should show: `Exercises: 26`

### Debug Step 3: Check RLS
If you see "row-level security policy" errors:
```sql
-- Run in Supabase SQL Editor
ALTER TABLE exercises DISABLE ROW LEVEL SECURITY;
```

Then refresh web app. If exercises appear, RLS is the issue.

### Debug Step 4: Verify Data Structure
Run in Supabase:
```sql
SELECT id, name, category, primary_muscle_group 
FROM exercises 
LIMIT 3;
```

Should return 3 exercises with all fields populated.

## Manual Test Query

If still not working, test the exact query the app runs:

```javascript
// In browser console:
const supabase = window.supabase || Supabase.instance.client;
const { data, error } = await supabase
  .from('exercises')
  .select()
  .order('name');
  
console.log('Data:', data);
console.log('Error:', error);
console.log('Count:', data?.length);
```

## Expected Result
You should see 26 exercises in the picker dialog, grouped by category:
- Arms (5)
- Back (4)
- Chest (4)
- Core (4)
- Legs (5)
- Shoulders (4)

## If Exercises Appear But Look Wrong
Check the mapping in `mapToExercise()` function - it might need adjustment for your specific Supabase schema.

## Next Steps After Fix
1. ✅ Create a template with exercises
2. ✅ Start a workout
3. ✅ Track sets
4. ✅ Complete workout
5. ✅ View in history

The exercises should now sync properly between Supabase and the web app!
