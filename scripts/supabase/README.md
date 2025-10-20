# Supabase SQL Scripts for HERQ Web Support

## 📋 Overview

These SQL scripts create the necessary tables in Supabase to enable full workout template functionality on the web version of HERQ.

## 🚀 Quick Start

### Step 1: Open Supabase SQL Editor
1. Go to your Supabase project: https://supabase.com/dashboard
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New query**

### Step 2: Run Scripts in Order

**IMPORTANT:** Run these scripts in the exact order listed below!

#### Script 1: Workout Templates Table
```bash
File: 01_create_workout_templates_table.sql
```

**What it does:**
- Creates `workout_templates` table
- Sets up indexes for performance
- Configures Row Level Security (RLS)
- Adds automatic `updated_at` triggers

**To run:**
1. Copy the entire contents of `01_create_workout_templates_table.sql`
2. Paste into Supabase SQL Editor
3. Click **Run** (or press Cmd/Ctrl + Enter)
4. Wait for "✅ Success" message

#### Script 2: Template Folders Table  
```bash
File: 02_create_template_folders_table.sql
```

**What it does:**
- Creates `template_folders` table
- Sets up indexes and RLS
- Links to `workout_templates` table

**To run:**
1. Copy the entire contents of `02_create_template_folders_table.sql`
2. Paste into Supabase SQL Editor
3. Click **Run**
4. Wait for "✅ Success" message

---

## 📊 Table Schemas

### workout_templates

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | Foreign key to auth.users |
| `name` | TEXT | Template name (required) |
| `description` | TEXT | Optional description |
| `category` | TEXT | Category (default: 'Custom') |
| `folder_id` | UUID | Foreign key to template_folders |
| `exercise_ids` | TEXT[] | Array of exercise IDs |
| `estimated_duration` | INTEGER | Duration in minutes |
| `sort_order` | INTEGER | For ordering templates |
| `tags` | TEXT[] | Array of tags |
| `is_default` | BOOLEAN | Admin-created templates |
| `created_at` | TIMESTAMP | Auto-generated |
| `updated_at` | TIMESTAMP | Auto-updated |

### template_folders

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | Foreign key to auth.users |
| `name` | TEXT | Folder name (required) |
| `description` | TEXT | Optional description |
| `color` | TEXT | Hex color code |
| `sort_order` | INTEGER | For ordering folders |
| `is_expanded` | BOOLEAN | UI state (default: true) |
| `created_at` | TIMESTAMP | Auto-generated |
| `updated_at` | TIMESTAMP | Auto-updated |

---

## 🔒 Security (RLS Policies)

### What RLS Does:
Row Level Security ensures users can only access their own data. The scripts automatically configure:

**workout_templates:**
- ✅ Users can view their own templates
- ✅ Users can view default (admin-created) templates
- ✅ Users can create/update/delete only their own templates
- ❌ Users CANNOT see other users' templates

**template_folders:**
- ✅ Users can view/create/update/delete only their own folders
- ❌ Users CANNOT see other users' folders

---

## ✅ Verification

After running both scripts, verify everything worked:

### Check Tables Exist
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('workout_templates', 'template_folders');
```

**Expected output:** 2 rows (both tables)

### Check RLS is Enabled
```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('workout_templates', 'template_folders');
```

**Expected output:** Both tables show `rowsecurity = true`

### Check Policies
```sql
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('workout_templates', 'template_folders');
```

**Expected output:** 8-10 policies total

---

## 🧪 Test the Setup

### Test 1: Create a Template (from Supabase SQL Editor)

**Note:** This will only work if you're authenticated. Use the HERQ web app instead.

```sql
-- This is just to test - don't run if not authenticated
INSERT INTO workout_templates (
  user_id,
  name,
  category,
  exercise_ids
) VALUES (
  auth.uid(), -- Your user ID
  'Test Workout',
  'Custom',
  ARRAY['push_up', 'pull_up', 'barbell_squat']
);
```

### Test 2: Query Your Templates
```sql
SELECT 
  id,
  name,
  category,
  array_length(exercise_ids, 1) as exercise_count,
  created_at
FROM workout_templates 
WHERE user_id = auth.uid()
ORDER BY created_at DESC;
```

### Test 3: Create a Folder
```sql
INSERT INTO template_folders (
  user_id,
  name,
  color
) VALUES (
  auth.uid(),
  'My Strength Programs',
  '#3B82F6'
);
```

---

## 🔧 Troubleshooting

### Error: "relation does not exist"
**Solution:** Make sure you ran Script 1 before Script 2. Template folders needs the templates table to exist first.

### Error: "permission denied"
**Solution:** 
1. Check if you're authenticated in Supabase
2. RLS policies might be too restrictive
3. Try running as service role (be careful!)

### Error: "column does not exist"
**Solution:** The Flutter app might expect different column names. Check the error message and update the schema accordingly.

### Templates not showing in web app
**Checklist:**
1. ✅ Both SQL scripts ran successfully
2. ✅ User is authenticated (test@test.com)
3. ✅ RLS policies are enabled
4. ✅ Flutter app restarted after SQL changes
5. ✅ No errors in browser console

---

## 🔄 After Running Scripts

### 1. Update Flutter Providers (Optional)
The providers are already set up to work with these tables! No code changes needed if you followed the naming conventions.

### 2. Restart Flutter Web App
```bash
# Stop current process (press 'q' or Ctrl+C)
npm run web
```

### 3. Test in Web App
1. Sign in as `test@test.com`
2. Navigate to "Workouts" tab
3. Click "Create Template"
4. Add exercises
5. Save template
6. ✅ Should work now!

---

## 📚 Additional Resources

### Supabase Documentation
- [Supabase SQL Editor](https://supabase.com/docs/guides/database/overview)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Arrays](https://www.postgresql.org/docs/current/arrays.html)

### HERQ Documentation
- [Complete Bug Report](/docs/WEB_APP_COMPLETE_BUG_REPORT.md)
- [Bug Fixes Summary](/docs/WEB_APP_BUG_FIXES_SUMMARY.md)

---

## 🎯 What These Scripts Enable

✅ **Create workout templates** on web  
✅ **Save templates** to Supabase  
✅ **Load templates** from Supabase  
✅ **Edit existing templates**  
✅ **Delete templates**  
✅ **Organize templates in folders**  
✅ **Share default templates** (admin feature)  
✅ **Sync templates** across devices  

---

## 🚨 IMPORTANT NOTES

1. **Backup First:** If you already have data in these tables, back it up before running DROP commands
2. **Run in Order:** Always run Script 1 before Script 2
3. **Test on Staging:** If you have a staging environment, test there first
4. **RLS is Critical:** Never disable RLS in production - it's your security layer
5. **Auth Required:** All operations require a valid auth.uid()

---

## 💡 Pro Tips

- **Seed Default Templates:** Create default templates with `is_default = TRUE` for all users
- **Add More Indexes:** If queries are slow, add indexes for frequently queried columns
- **Monitor Performance:** Use Supabase's built-in monitoring to track query performance
- **Backup Regularly:** Enable automatic backups in Supabase dashboard

---

## ✅ Success Checklist

After running the scripts, you should have:

- [ ] `workout_templates` table created
- [ ] `template_folders` table created  
- [ ] RLS enabled on both tables
- [ ] 8-10 RLS policies created
- [ ] Indexes created for performance
- [ ] `updated_at` triggers working
- [ ] Foreign key relationship set up
- [ ] Verified with test queries
- [ ] Flutter app restarted
- [ ] Templates working in web app

---

**Need help?** Check the troubleshooting section or refer to the complete bug report in `/docs/WEB_APP_COMPLETE_BUG_REPORT.md`

**All done?** Your HERQ web app should now have full template functionality! 🎉

