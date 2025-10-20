## 🏋️ Exercises Table Setup for Supabase

Complete setup script to recreate the exercises table with proper structure, indexes, and Row Level Security.

---

## 📋 **Files Overview**

1. **`recreate_exercises_table.sql`** - Drops and recreates the exercises table
2. **`seed_exercises_final.sql`** - Seeds 26 core exercises
3. **`check_exercises_schema.sql`** - Helper to verify table structure

---

## 🚀 **Quick Start (2 Steps)**

### Step 1: Recreate the Table
```sql
-- Run: recreate_exercises_table.sql
-- ⚠️ WARNING: This DELETES all existing data!
```

### Step 2: Seed Exercises
```sql
-- Run: seed_exercises_final.sql
-- Adds 26 core exercises
```

---

## 📊 **Table Structure**

### Columns:

| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT | Primary key (e.g., 'barbell_bench_press') |
| `name` | TEXT | Display name (e.g., 'Barbell Bench Press') |
| `category` | TEXT | chest, back, legs, shoulders, arms, core |
| `type` | TEXT | compound, isolation, isometric, cardio |
| `difficulty` | TEXT | beginner, intermediate, advanced, expert |
| `equipment` | TEXT[] | Array of required equipment |
| `primary_muscle_group` | TEXT | Main muscle worked (NOT NULL) |
| `secondary_muscle_groups` | TEXT[] | Supporting muscles |
| `instructions` | TEXT | How to perform the exercise |
| `aliases` | TEXT[] | Alternative names |
| `tags` | TEXT[] | Searchable tags |
| `is_bodyweight` | BOOLEAN | True if no equipment needed |
| `exercise_type` | TEXT | weight_reps, time, distance, bodyweight |
| `parent_exercise_id` | TEXT | For variants/progressions |
| `variant_type` | TEXT | progression, regression, equipment, etc. |
| `variant_detail` | TEXT | Description of variant |
| `user_id` | UUID | NULL = global exercise, UUID = user's custom |
| `created_at` | TIMESTAMP | Auto-generated |
| `updated_at` | TIMESTAMP | Auto-updated on changes |

---

## 🔍 **Indexes Created**

Performance optimizations:
- `idx_exercises_category` - Fast filtering by category
- `idx_exercises_primary_muscle` - Filter by muscle group
- `idx_exercises_difficulty` - Filter by difficulty
- `idx_exercises_type` - Filter by exercise type
- `idx_exercises_user_id` - Filter user's exercises
- `idx_exercises_parent_id` - Find variants
- `idx_exercises_equipment` (GIN) - Array search
- `idx_exercises_tags` (GIN) - Tag search
- `idx_exercises_created_at` - Sort by newest

---

## 🔐 **Row Level Security (RLS)**

### Policies Created:

1. **Global exercises viewable by everyone**
   - Anyone can see exercises where `user_id IS NULL`

2. **Users can view their own exercises**
   - Authenticated users see their custom exercises

3. **Users can create their own exercises**
   - Users can add custom exercises with their `user_id`

4. **Users can update their own exercises**
   - Users can only modify exercises they created

5. **Users can delete their own exercises**
   - Users can only delete exercises they created

### Admin Policy (Optional):
Uncomment the admin policy in the script if you have an `admin_users` table.

---

## 🎯 **Exercise Breakdown**

After seeding, you'll have:

| Category | Count | Examples |
|----------|-------|----------|
| **Chest** | 4 | Bench Press, Push-Ups, Flyes, Incline Press |
| **Back** | 4 | Pull-Ups, Rows, Deadlift, Lat Pulldown |
| **Legs** | 5 | Squats, Leg Press, Lunges, Leg Curl, Calf Raise |
| **Shoulders** | 4 | Overhead Press, Lateral Raise, Front Raise, Face Pull |
| **Arms** | 5 | Curls, Hammer Curls, Dips, Extensions, Skull Crushers |
| **Core** | 4 | Plank, Ab Wheel, Crunches, Russian Twist |

**Total: 26 exercises**

---

## 💪 **Exercise Type Distribution**

- **15 Compound** movements (multi-joint, efficient)
- **10 Isolation** exercises (single-joint, targeted)
- **1 Isometric** hold (static strength)

---

## 🔗 **Relationships**

### Foreign Keys:
- `parent_exercise_id` → `exercises(id)`
  - Used for exercise variants/progressions
  - Example: Regular Push-Up → One-Arm Push-Up (progression)

- `user_id` → `auth.users(id)`
  - Links custom exercises to users
  - NULL = global exercise (visible to all)

---

## 🛠️ **Variant System**

The table supports exercise progressions/regressions:

### Variant Types:
- `progression` - Harder version
- `regression` - Easier version
- `equipment` - Different equipment
- `angle` - Different angle (incline/decline)
- `grip` - Different grip position
- `tempo` - Different speed
- `range` - Partial vs full range
- `stability` - More/less stable
- `assisted` - With assistance
- `strict` - Stricter form

### Example Usage:
```sql
-- Create a progression variant
INSERT INTO exercises (
  id, name, category, type, difficulty,
  parent_exercise_id, variant_type, variant_detail, ...
VALUES (
  'archer_pushup', 'Archer Push-Up', 'chest', 'compound', 'advanced',
  'push_up', 'progression', 'One arm takes more weight', ...
);
```

---

## 📱 **Web App Integration**

The web app fetches exercises from Supabase:

```dart
// lib/src/features/exercises/presentation/providers/exercise_web_provider.dart
final exercisesWebProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final data = await supabase.from('exercises').select().order('name');
  return List<Map<String, dynamic>>.from(data);
});
```

### Filtering Examples:
```dart
// By category
await supabase.from('exercises').select().eq('category', 'chest');

// By muscle group
await supabase.from('exercises').select().eq('primary_muscle_group', 'chest');

// By difficulty
await supabase.from('exercises').select().eq('difficulty', 'beginner');

// Bodyweight only
await supabase.from('exercises').select().eq('is_bodyweight', true);

// Global exercises only
await supabase.from('exercises').select().is_('user_id', null);
```

---

## ✅ **Verification Queries**

After running the scripts, verify:

```sql
-- Check table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'exercises' 
ORDER BY ordinal_position;

-- Check indexes
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'exercises';

-- Check RLS policies
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'exercises';

-- Check exercise counts
SELECT category, COUNT(*) 
FROM exercises 
GROUP BY category 
ORDER BY category;

-- View all exercises
SELECT name, category, primary_muscle_group, difficulty, is_bodyweight
FROM exercises 
ORDER BY category, name;
```

---

## 🚨 **Important Notes**

1. **Data Loss Warning**: `recreate_exercises_table.sql` will DELETE all existing data!
2. **Run in Order**: Always run `recreate_exercises_table.sql` BEFORE `seed_exercises_final.sql`
3. **User ID**: Global exercises have `user_id = NULL`, custom exercises have a UUID
4. **Arrays**: Empty arrays must be cast as `ARRAY[]::TEXT[]`
5. **Triggers**: The `updated_at` column auto-updates on changes

---

## 🎨 **Customization**

### Add More Exercises:
```sql
INSERT INTO exercises (id, name, category, type, difficulty, ...)
VALUES ('your_exercise_id', 'Your Exercise Name', ...);
```

### Add Admin Policy:
1. Create `admin_users` table
2. Uncomment the admin policy in `recreate_exercises_table.sql`
3. Run the CREATE POLICY statement

### Modify Constraints:
Edit the CHECK constraints in `recreate_exercises_table.sql`:
```sql
CHECK (type IN ('compound', 'isolation', 'isometric', 'cardio'))
CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'expert'))
```

---

## 📖 **Next Steps**

1. ✅ Run `recreate_exercises_table.sql`
2. ✅ Run `seed_exercises_final.sql`
3. ✅ Refresh your web app
4. ✅ Exercises should appear in the library!
5. 🎯 (Optional) Add more custom exercises
6. 🎯 (Optional) Set up admin users
7. 🎯 (Optional) Create exercise variants/progressions

---

## 🆘 **Troubleshooting**

**Problem**: Table already exists
```sql
-- Just run recreate_exercises_table.sql - it includes DROP TABLE
```

**Problem**: RLS blocking inserts
```sql
-- Check if you're authenticated
SELECT auth.uid(); -- Should return a UUID

-- Temporarily disable RLS for testing (not recommended for production)
ALTER TABLE exercises DISABLE ROW LEVEL SECURITY;
```

**Problem**: Foreign key constraint error
```sql
-- Make sure parent_exercise_id references an existing exercise
SELECT id FROM exercises WHERE id = 'parent_id_here';
```

**Problem**: Array type error
```sql
-- Use explicit casting for empty arrays
ARRAY[]::TEXT[]
```
