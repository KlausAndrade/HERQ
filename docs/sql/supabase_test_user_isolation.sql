-- Test User Data Isolation
-- This script tests that RLS policies are working correctly

-- Test 1: Check current user context
SELECT 
    'Current User Context' as test_name,
    auth.uid() as current_user_id,
    auth.role() as current_role;

-- Test 2: Try to access workout_sessions (should only see own data)
SELECT 
    'Workout Sessions Access Test' as test_name,
    COUNT(*) as visible_sessions,
    COUNT(CASE WHEN user_id = auth.uid() THEN 1 END) as own_sessions,
    COUNT(CASE WHEN user_id != auth.uid() THEN 1 END) as other_users_sessions
FROM workout_sessions;

-- Test 3: Try to access set_entries (should only see own data)
SELECT 
    'Set Entries Access Test' as test_name,
    COUNT(*) as visible_entries,
    COUNT(CASE WHEN user_id = auth.uid() THEN 1 END) as own_entries,
    COUNT(CASE WHEN user_id != auth.uid() THEN 1 END) as other_users_entries
FROM set_entries;

-- Test 4: Try to access workout_templates (should only see own data)
SELECT 
    'Workout Templates Access Test' as test_name,
    COUNT(*) as visible_templates,
    COUNT(CASE WHEN user_id = auth.uid() THEN 1 END) as own_templates,
    COUNT(CASE WHEN user_id != auth.uid() THEN 1 END) as other_users_templates
FROM workout_templates;

-- Test 5: Try to access personal_records (should only see own data)
SELECT 
    'Personal Records Access Test' as test_name,
    COUNT(*) as visible_records,
    COUNT(CASE WHEN user_id = auth.uid() THEN 1 END) as own_records,
    COUNT(CASE WHEN user_id != auth.uid() THEN 1 END) as other_users_records
FROM personal_records;

-- Test 6: Test admin function
SELECT 
    'Admin Function Test' as test_name,
    is_admin() as is_current_user_admin;

-- Test 7: Test data ownership update function
-- This will update any default user data to the current user
SELECT 
    'Data Ownership Update Test' as test_name,
    update_user_data_ownership() as update_result;

-- Test 8: Verify data ownership after update
SELECT 
    'Post-Update Verification' as test_name,
    COUNT(*) as total_sessions,
    COUNT(CASE WHEN user_id = auth.uid() THEN 1 END) as owned_sessions,
    COUNT(CASE WHEN user_id = '00000000-0000-0000-0000-000000000000'::uuid THEN 1 END) as default_user_sessions
FROM workout_sessions;
