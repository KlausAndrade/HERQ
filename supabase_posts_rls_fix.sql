-- =====================================================
-- Supabase RLS Policies for Posts Deletion
-- =====================================================
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Check existing policies on posts table
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'posts';

-- 2. Enable RLS on posts table (if not already enabled)
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- 3. Drop existing delete policy if any
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;

-- 4. CREATE DELETE POLICY: Allow users to delete their own posts
CREATE POLICY "Users can delete their own posts"
ON posts
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- 5. Verify the policy was created
SELECT 
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'posts' AND cmd = 'DELETE';

-- =====================================================
-- If you also need SELECT, INSERT, UPDATE policies:
-- =====================================================

-- Allow users to see public posts
CREATE POLICY "Anyone can view posts" ON posts
FOR SELECT TO public
USING (true);

-- Allow authenticated users to create posts
CREATE POLICY "Authenticated users can create posts" ON posts
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own posts
CREATE POLICY "Users can update their own posts" ON posts
FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- Verification - Run this to test
-- =====================================================

-- Check all posts policies
SELECT 
  policyname,
  cmd as command,
  CASE 
    WHEN cmd = 'SELECT' THEN 'Read'
    WHEN cmd = 'INSERT' THEN 'Create'
    WHEN cmd = 'UPDATE' THEN 'Update'
    WHEN cmd = 'DELETE' THEN 'Delete'
  END as operation,
  roles as "applies_to"
FROM pg_policies
WHERE tablename = 'posts'
ORDER BY cmd;
