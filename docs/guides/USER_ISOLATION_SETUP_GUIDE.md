# 🔒 User Isolation Setup Guide

This guide will help you complete the user data isolation implementation by running the necessary Supabase SQL migrations.

## 📋 Prerequisites

1. **Supabase Project**: Make sure you have access to your Supabase project dashboard
2. **Database Access**: You need to be able to run SQL queries in your Supabase database
3. **Admin Rights**: You need admin access to create RLS policies

## 🚀 Step 1: Run Supabase Migrations

### Option A: Using Supabase Dashboard (Recommended)

1. **Open Supabase Dashboard**
   - Go to [supabase.com](https://supabase.com)
   - Navigate to your project
   - Go to **SQL Editor** in the left sidebar

2. **Run the Migration Script**
   - **First, run the verification script**: Copy contents of `supabase_verify_user_isolation.sql` and run it to check current state
   - **Then run the clean migration**: Copy contents of `supabase_user_isolation_migration_clean.sql` and run it
   - Click **Run** to execute the migration

### Option B: Using Supabase CLI

```bash
# Install Supabase CLI if you haven't already
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref YOUR_PROJECT_REF

# Run the verification first
supabase db push --file supabase_verify_user_isolation.sql

# Then run the clean migration
supabase db push --file supabase_user_isolation_migration_clean.sql
```

## 🔧 Step 2: Verify Migration Success

After running the migration, verify that:

1. **Tables Updated**: Check that `user_id` columns were added to:
   - `workout_sessions`
   - `set_entries` 
   - `workout_templates`
   - `personal_records`

2. **RLS Policies Created**: Verify Row Level Security policies are active:
   ```sql
   SELECT schemaname, tablename, rowsecurity 
   FROM pg_tables 
   WHERE tablename IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records');
   ```

3. **Indexes Created**: Check that performance indexes were created:
   ```sql
   SELECT indexname, tablename 
   FROM pg_indexes 
   WHERE tablename IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records')
   AND indexname LIKE '%user_id%';
   ```

## 👥 Step 3: Set Up Admin Users (Optional)

If you want admin users to access all data for the admin dashboard:

1. **Create Admin Role Function**:
   ```sql
   -- Create a function to check if user is admin
   CREATE OR REPLACE FUNCTION is_admin()
   RETURNS boolean AS $$
   BEGIN
     RETURN EXISTS (
       SELECT 1 FROM auth.users 
       WHERE auth.users.id = auth.uid() 
       AND auth.users.raw_user_meta_data->>'role' = 'admin'
     );
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;
   ```

2. **Assign Admin Role to Users**:
   ```sql
   -- Update a user to have admin role
   UPDATE auth.users 
   SET raw_user_meta_data = raw_user_meta_data || '{"role": "admin"}'::jsonb
   WHERE email = 'admin@yourdomain.com';
   ```

## 🧪 Step 4: Test User Isolation

### Test 1: Create Test Users
```sql
-- Create test users (this would normally be done through your app's auth)
-- For testing purposes, you can manually insert test data
```

### Test 2: Verify Data Isolation
```sql
-- Test that users can only see their own data
-- This should only return data for the current user
SELECT * FROM workout_sessions WHERE user_id = auth.uid()::text;
```

### Test 3: Test Admin Access
```sql
-- Test that admin users can see all data
-- This should return all data for admin users
SELECT * FROM workout_sessions;
```

## 🔍 Step 5: Monitor and Debug

### Check RLS Policies
```sql
-- View all RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records');
```

### Check User Data Ownership
```sql
-- See which user owns which data
SELECT user_id, COUNT(*) as record_count 
FROM workout_sessions 
GROUP BY user_id;
```

## 🚨 Troubleshooting

### Issue: Users can't see their data
**Solution**: Check that RLS policies are correctly applied and user authentication is working.

### Issue: Admin users can't see all data
**Solution**: Verify that admin role is properly set in user metadata and admin policies are active.

### Issue: Performance issues
**Solution**: Ensure indexes on `user_id` columns are created and being used.

### Issue: Migration fails
**Solution**: Check for existing columns or policies that might conflict. You may need to drop existing policies first.

## 📊 Expected Results

After successful migration:

✅ **User Isolation**: Each user can only see their own data  
✅ **Admin Access**: Admin users can see all data  
✅ **Performance**: Queries are optimized with proper indexes  
✅ **Security**: Row Level Security prevents data leakage  
✅ **App Functionality**: All features work with proper user context  

## 🔄 Next Steps

1. **Test the App**: Run the app and verify that user data is properly isolated
2. **Monitor Performance**: Check query performance with the new indexes
3. **Update Documentation**: Document any custom admin procedures
4. **Train Team**: Ensure your team understands the new user isolation system

## 📞 Support

If you encounter issues:

1. **Check Supabase Logs**: Look for errors in the Supabase dashboard
2. **Verify SQL Syntax**: Ensure all SQL commands executed successfully
3. **Test Incrementally**: Run parts of the migration separately to isolate issues
4. **Contact Support**: Reach out to Supabase support for database-specific issues

---

**🎉 Congratulations!** Your app now has complete user data isolation with proper security measures in place.
