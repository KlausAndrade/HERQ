# 🧪 User Isolation Testing Guide

This guide will help you test that user data isolation is working correctly in HERQ.

## 🎯 Testing Objectives

1. **Verify Migration Success**: Ensure all database changes were applied correctly
2. **Test User Data Isolation**: Confirm users can only see their own data
3. **Test Admin Access**: Verify admin users can still see all data
4. **Test App Functionality**: Ensure the Flutter app works with user isolation

## 🔍 Step 1: Verify Migration Success

### 1.1 Run Verification Query
```sql
-- Copy and run: supabase_verify_migration_success.sql
-- This will show you the current state of your database
```

**Expected Results:**
- ✅ All tables have `user_id` columns of type `UUID`
- ✅ RLS is enabled on all user-specific tables
- ✅ Policies exist for all tables
- ✅ Indexes are created for performance
- ✅ Admin and update functions exist

### 1.2 Check Migration Output
Look for these success indicators:
- `Migration completed successfully!`
- Column types show as `uuid`
- RLS enabled shows as `true`
- Policies exist for all tables

## 🧪 Step 2: Test User Data Isolation

### 2.1 Run Isolation Test
```sql
-- Copy and run: supabase_test_user_isolation.sql
-- This will test that RLS policies are working
```

**Expected Results:**
- ✅ `visible_sessions` = `own_sessions` (no other users' data visible)
- ✅ `other_users_sessions` = 0 (no cross-user data contamination)
- ✅ Same pattern for all tables (set_entries, workout_templates, personal_records)

### 2.2 Test with Multiple Users
1. **Create Test Users:**
   - Create 2-3 test users in Supabase Auth
   - Note their user IDs

2. **Test Data Creation:**
   - Login as User A, create some workout data
   - Login as User B, create some workout data
   - Login as User A again, verify you only see User A's data

3. **Test Data Access:**
   - Each user should only see their own:
     - Workout sessions
     - Set entries
     - Workout templates
     - Personal records

## 🔧 Step 3: Test Admin Access

### 3.1 Set Admin Role
```sql
-- Update a user to have admin role
UPDATE auth.users 
SET raw_user_meta_data = jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb), 
    '{role}', 
    '"admin"'::jsonb
) 
WHERE email = 'your-admin-email@example.com';
```

### 3.2 Test Admin Dashboard
1. **Login as Admin User**
2. **Access Admin Dashboard**
3. **Verify Admin Can See:**
   - All users' workout sessions
   - All users' set entries
   - All users' workout templates
   - All users' personal records

## 📱 Step 4: Test Flutter App

### 4.1 Build and Run App
```bash
# Build the app
flutter build apk --debug

# Run on device/emulator
flutter run -d android
# or
flutter run -d ios
# or
flutter run -d macos
```

### 4.2 Test App Features
1. **User Registration/Login:**
   - Create new user account
   - Login with existing user
   - Verify user context is working

2. **Workout Features:**
   - Create workout session
   - Add exercises and sets
   - Save workout template
   - Check personal records

3. **Data Isolation:**
   - Switch between users
   - Verify each user sees only their data
   - Test that data doesn't leak between users

### 4.3 Test Admin Features
1. **Admin Dashboard:**
   - Login as admin user
   - Access admin dashboard
   - Verify admin can see all users' data
   - Test user management features

## 🚨 Troubleshooting

### Common Issues and Solutions

#### Issue 1: "No data visible"
**Cause:** User ID not being set correctly
**Solution:** Check `UserContextService.instance.getCurrentUserId()`

#### Issue 2: "Admin can't see all data"
**Cause:** Admin role not set correctly
**Solution:** Verify admin role in user metadata

#### Issue 3: "Cross-user data visible"
**Cause:** RLS policies not working
**Solution:** Check policy creation and user_id column types

#### Issue 4: "App crashes on data access"
**Cause:** Missing userId parameter in database operations
**Solution:** Check all database insert/update operations include userId

### Debug Queries

#### Check User Context
```sql
SELECT auth.uid(), auth.role();
```

#### Check RLS Status
```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records');
```

#### Check Policies
```sql
SELECT tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records');
```

## ✅ Success Criteria

### Database Level
- [ ] All tables have `user_id` columns
- [ ] RLS is enabled on all user tables
- [ ] Policies exist and are working
- [ ] Admin function works correctly

### Application Level
- [ ] App builds without errors
- [ ] Users can only see their own data
- [ ] Admin can see all users' data
- [ ] No cross-user data contamination
- [ ] All features work correctly

### User Experience
- [ ] Users can create and view their workouts
- [ ] Users can create and view their templates
- [ ] Users can view their personal records
- [ ] Admin can manage all users
- [ ] No data privacy issues

## 🎉 Completion

Once all tests pass, your user isolation is working correctly! Users will only see their own data, and admins can still access everything they need for management.

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Run the verification queries
3. Check the Flutter app logs
4. Verify Supabase RLS policies are active
