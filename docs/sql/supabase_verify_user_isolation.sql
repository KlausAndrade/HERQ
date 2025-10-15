-- Verify User Isolation Setup
-- Run this to check the current state of your database

-- Check if user_id columns exist
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

-- Check existing RLS policies
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

-- Check indexes on user_id columns
SELECT 
    indexname, 
    tablename, 
    indexdef
FROM pg_indexes 
WHERE tablename IN ('workout_sessions', 'set_entries', 'workout_templates', 'personal_records')
AND indexname LIKE '%user_id%'
ORDER BY tablename;

-- Check data distribution by user_id
SELECT 
    'workout_sessions' as table_name,
    user_id,
    COUNT(*) as record_count
FROM workout_sessions 
GROUP BY user_id
UNION ALL
SELECT 
    'set_entries' as table_name,
    user_id,
    COUNT(*) as record_count
FROM set_entries 
GROUP BY user_id
UNION ALL
SELECT 
    'workout_templates' as table_name,
    user_id,
    COUNT(*) as record_count
FROM workout_templates 
GROUP BY user_id
UNION ALL
SELECT 
    'personal_records' as table_name,
    user_id,
    COUNT(*) as record_count
FROM personal_records 
GROUP BY user_id
ORDER BY table_name, user_id;

-- Check if admin function exists
SELECT 
    routine_name, 
    routine_type, 
    data_type
FROM information_schema.routines 
WHERE routine_name = 'is_admin';
