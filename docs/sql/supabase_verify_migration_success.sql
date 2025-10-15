-- Verify User Isolation Migration Success
-- Run this in Supabase SQL Editor to check if everything is working

-- Check if user_id columns exist and their types
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records')
AND column_name = 'user_id'
ORDER BY table_name;

-- Check if RLS is enabled
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records')
ORDER BY tablename;

-- Check if policies exist
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records')
ORDER BY tablename, policyname;

-- Check if indexes exist
SELECT 
    indexname,
    tablename,
    indexdef
FROM pg_indexes 
WHERE tablename IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records')
AND indexname LIKE '%user_id%'
ORDER BY tablename;

-- Check if admin function exists
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_name = 'is_admin';

-- Check if update function exists
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines 
WHERE routine_name = 'update_user_data_ownership';

-- Count records with user_id
SELECT 
    'workout_sessions' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN user_id IS NOT NULL THEN 1 END) as records_with_user_id,
    COUNT(CASE WHEN user_id = '00000000-0000-0000-0000-000000000000'::uuid THEN 1 END) as default_user_records
FROM workout_sessions
UNION ALL
SELECT 
    'set_entries' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN user_id IS NOT NULL THEN 1 END) as records_with_user_id,
    COUNT(CASE WHEN user_id = '00000000-0000-0000-0000-000000000000'::uuid THEN 1 END) as default_user_records
FROM set_entries
UNION ALL
SELECT 
    'workout_templates' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN user_id IS NOT NULL THEN 1 END) as records_with_user_id,
    COUNT(CASE WHEN user_id = '00000000-0000-0000-0000-000000000000'::uuid THEN 1 END) as default_user_records
FROM workout_templates
UNION ALL
SELECT 
    'personal_records' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN user_id IS NOT NULL THEN 1 END) as records_with_user_id,
    COUNT(CASE WHEN user_id = '00000000-0000-0000-0000-000000000000'::uuid THEN 1 END) as default_user_records
FROM personal_records;
