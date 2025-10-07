# Sort Order Migration - Required for Template/Folder Reordering

## Problem
The app is trying to sync `sort_order` to Supabase, but the columns don't exist in the database, causing this error:
```
PostgrestException: Could not find the 'sort_order' column of 'workout_templates' in the schema cache
```

## Solution
Run the migration script to add the missing columns.

## Steps to Fix

### 1. Open Supabase Dashboard
1. Go to https://supabase.com/dashboard
2. Select your GymAI project
3. Go to **SQL Editor** in the left sidebar

### 2. Run the Migration
1. Click **New Query**
2. Copy the entire contents of `supabase_add_sort_order.sql`
3. Paste into the SQL Editor
4. Click **Run** (or press Cmd/Ctrl + Enter)

### 3. Verify
You should see a success message. The migration will:
- ✅ Add `sort_order` column to `workout_templates`
- ✅ Add `sort_order` column to `template_folders`
- ✅ Create indexes for performance
- ✅ Initialize sort order for existing data (based on creation date)

### 4. Test the App
After running the migration:
1. Hot restart the Flutter app (press `R` in terminal)
2. Go to Templates screen
3. Tap **Edit** button
4. Drag templates/folders to reorder
5. ✅ Order should now persist!

## What the Migration Does

### Adds Columns
```sql
ALTER TABLE workout_templates ADD COLUMN sort_order INTEGER DEFAULT 0;
ALTER TABLE template_folders ADD COLUMN sort_order INTEGER DEFAULT 0;
```

### Initializes Existing Data
For existing templates and folders, it sets `sort_order` based on creation date:
- First created = 0
- Second created = 1
- Third created = 2
- etc.

This preserves the current order while enabling future reordering.

## Rollback (if needed)
If you need to remove the columns:
```sql
ALTER TABLE workout_templates DROP COLUMN sort_order;
ALTER TABLE template_folders DROP COLUMN sort_order;
```

## Notes
- This is a **one-time migration**
- Safe to run multiple times (uses `IF NOT EXISTS`)
- Does not delete any data
- Existing templates/folders will maintain their current order
- Future reordering will now work correctly across all devices
