# Seeding Supabase with Exercises

## Problem
Your web app shows an empty exercise library because Supabase database has no exercises yet.

## Solution
You need to populate the Supabase `exercises` table with initial data.

## 🚀 **Quick Steps**

### Option 1: Run SQL Script (Recommended)

1. **Go to Supabase Dashboard:**
   - Visit: https://supabase.com/dashboard/project/vvgxvunvzhtvwvdvtlrm/sql

2. **Open SQL Editor:**
   - Click "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Copy & Paste the Script:**
   - Open `scripts/seed_supabase_exercises.sql`
   - Copy all the content
   - Paste into SQL Editor

4. **Run the Script:**
   - Click "Run" button (or Cmd+Enter)
   - You should see: "Success. Rows affected: 15"

5. **Verify:**
   - The last SELECT should show 15 exercises
   - Refresh your web app - exercises should appear!

### Option 2: Use Supabase API (Programmatic)

If you prefer to seed programmatically, create a script:

```javascript
// scripts/seed_exercises.js
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://vvgxvunvzhtvwvdvtlrm.supabase.co',
  'YOUR_SERVICE_ROLE_KEY' // Use service_role key for admin operations
);

const exercises = [
  {
    id: 'barbell_bench_press',
    user_id: null, // Global exercise
    name: 'Barbell Bench Press',
    primary_muscle_group: 'chest',
    secondary_muscle_groups: ['triceps', 'shoulders'],
    equipment: 'barbell',
    instructions: 'Lie on a flat bench. Lower the barbell to your chest, then press it back up.',
    tags: ['compound', 'push'],
    aliases: ['bench press', 'flat bench'],
    is_bodyweight: false,
    exercise_type: 'weight_reps',
    category: 'strength',
    difficulty: 'intermediate',
  },
  // ... add more exercises
];

async function seedExercises() {
  const { data, error } = await supabase
    .from('exercises')
    .upsert(exercises);
  
  if (error) {
    console.error('Error:', error);
  } else {
    console.log('✅ Seeded', exercises.length, 'exercises');
  }
}

seedExercises();
```

Then run: `node scripts/seed_exercises.js`

## 📋 **What Gets Seeded**

The script adds 15 core exercises:

**Chest (3):**
- Barbell Bench Press
- Push-Up
- Dumbbell Fly

**Back (3):**
- Pull-Up
- Barbell Row
- Deadlift

**Legs (3):**
- Barbell Squat
- Leg Press
- Lunge

**Shoulders (2):**
- Overhead Press
- Lateral Raise

**Arms (2):**
- Barbell Curl
- Tricep Dip

**Core (2):**
- Plank
- Ab Wheel Rollout

## 🔍 **Verify It Worked**

### Check in Supabase:
```sql
-- Run this in SQL Editor
SELECT COUNT(*) FROM exercises WHERE user_id IS NULL;
-- Should return: 15

SELECT name, category FROM exercises WHERE user_id IS NULL;
-- Should show all exercises
```

### Check in Web App:
1. Refresh your web app
2. Go to Exercise Library
3. You should see 15 exercises!

## 👤 **Admin vs Regular Users**

### Regular Users (like test@test.com):
- ✅ Can see global exercises (user_id IS NULL)
- ✅ Can create their own custom exercises
- ❌ Cannot modify global exercises

### Admin Users:
- ✅ Can see all exercises
- ✅ Can create global exercises
- ✅ Can modify global exercises
- ✅ Can manage content for all users

## 🔐 **Making Yourself Admin**

If you want admin access to manage exercises from the web app:

1. **Go to Supabase Dashboard:**
   - Table Editor → `admin_users`

2. **Insert Your User:**
   ```sql
   INSERT INTO admin_users (id, role, permissions)
   VALUES (
     'YOUR_USER_ID', -- Get this from auth.users table
     'content_manager',
     ARRAY['manage_exercises', 'manage_templates']
   );
   ```

3. **Or use the `.env` file:**
   - The app checks `ADMIN_EMAILS` environment variable
   - Add your email: `ADMIN_EMAILS=test@test.com,klaus.dev@outlook.com`

## 🎯 **Next Steps**

After seeding:
1. ✅ Refresh web app
2. ✅ Check Exercise Library
3. ✅ Try creating a workout with these exercises
4. ✅ (Optional) Add more custom exercises for your needs

## 💡 **Pro Tips**

- **Global exercises** (user_id = NULL) appear for ALL users
- **Custom exercises** (user_id = UUID) only appear for that user
- You can add more exercises anytime by running the SQL again
- The script uses `ON CONFLICT DO UPDATE` so it's safe to run multiple times

## 🆘 **Troubleshooting**

**Still no exercises after seeding?**
1. Check browser console for errors
2. Verify Supabase connection: Check console for "✅ Supabase init completed"
3. Check RLS policies: Make sure exercises table allows SELECT for authenticated users
4. Hard refresh: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)

**Permission denied error?**
- Check Row Level Security (RLS) policies on `exercises` table
- Should allow authenticated users to SELECT global exercises

**Want more exercises?**
- Copy the format from the SQL script
- Add your own exercises
- Run the script again!
