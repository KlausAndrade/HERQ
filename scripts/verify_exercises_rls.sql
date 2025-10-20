-- Quick verification and fix for RLS issues
-- Run this in Supabase SQL Editor

-- 1. Check if exercises exist
SELECT 'Exercise Count:' as check_type, COUNT(*)::text as result FROM exercises
UNION ALL
SELECT 'Global Exercises:', COUNT(*)::text FROM exercises WHERE user_id IS NULL
UNION ALL
SELECT 'User Exercises:', COUNT(*)::text FROM exercises WHERE user_id IS NOT NULL;

-- 2. Check if RLS is enabled
SELECT 'RLS Enabled:' as check_type, rowsecurity::text as result 
FROM pg_tables 
WHERE tablename = 'exercises';

-- 3. List all RLS policies
SELECT 'Policy:' as check_type, policyname as result 
FROM pg_policies 
WHERE tablename = 'exercises';

-- 4. Test if you can query exercises
SELECT 'Can Query:' as check_type, 
       CASE WHEN COUNT(*) > 0 THEN 'YES - ' || COUNT(*)::text || ' exercises found'
            ELSE 'NO - Cannot see any exercises'
       END as result
FROM exercises;

-- 5. Sample exercises (first 3)
SELECT id, name, category, user_id 
FROM exercises 
ORDER BY name 
LIMIT 3;

-- If no results above, RLS might be blocking. 
-- Temporarily disable RLS to test (NOT FOR PRODUCTION!):
-- ALTER TABLE exercises DISABLE ROW LEVEL SECURITY;
-- Then query again to confirm exercises exist

-- Re-enable with:
-- ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
