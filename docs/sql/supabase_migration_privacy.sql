-- ================================================
-- HERQ Database Migration - Privacy & Updates
-- ================================================
-- Run this in your Supabase SQL Editor
-- ================================================

-- 1. Add is_private column to profiles
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS is_private BOOLEAN DEFAULT false;

-- 2. Add updated_at to profiles (if not exists)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 3. Add updated_at to posts (for edit tracking)
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 4. Add updated_at triggers for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 5. Create trigger for profiles table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 6. Create trigger for posts table
DROP TRIGGER IF EXISTS update_posts_updated_at ON posts;
CREATE TRIGGER update_posts_updated_at 
    BEFORE UPDATE ON posts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- Row Level Security (RLS) Policies
-- ================================================

-- 7. Update posts policies to respect privacy settings
-- Drop existing policy if needed and recreate
DROP POLICY IF EXISTS "Users can view posts from public accounts or followed accounts" ON posts;

-- Policy: Users can view posts from:
-- - Public accounts (is_private = false or null)
-- - Accounts they follow (if account is private)
-- - Their own posts
CREATE POLICY "Users can view posts based on privacy" ON posts
    FOR SELECT
    USING (
        -- Own posts
        auth.uid() = user_id
        OR
        -- Posts from public accounts
        (
            SELECT COALESCE(is_private, false) 
            FROM profiles 
            WHERE id = posts.user_id
        ) = false
        OR
        -- Posts from private accounts that user follows
        (
            SELECT COALESCE(is_private, false) 
            FROM profiles 
            WHERE id = posts.user_id
        ) = true
        AND
        EXISTS (
            SELECT 1 FROM follows 
            WHERE follower_id = auth.uid() 
            AND following_id = posts.user_id
        )
    );

-- 8. Update profiles visibility policy
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON profiles;

-- Policy: All profiles are viewable (but posts might be private)
CREATE POLICY "Profiles are viewable by everyone" ON profiles
    FOR SELECT
    USING (true);

-- 9. Policy: Users can only update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE
    USING (auth.uid() = id);

-- 10. Policy: Users can only edit their own posts
DROP POLICY IF EXISTS "Users can update own posts" ON posts;

CREATE POLICY "Users can update own posts" ON posts
    FOR UPDATE
    USING (auth.uid() = user_id);

-- ================================================
-- Indexes for Performance
-- ================================================

-- 11. Index for privacy lookups
CREATE INDEX IF NOT EXISTS idx_profiles_is_private 
    ON profiles(is_private);

-- 12. Index for updated_at sorting
CREATE INDEX IF NOT EXISTS idx_posts_updated_at 
    ON posts(updated_at DESC);

-- 13. Composite index for feed queries with privacy
CREATE INDEX IF NOT EXISTS idx_posts_user_created 
    ON posts(user_id, created_at DESC);

-- ================================================
-- Verification
-- ================================================

-- 14. Verify columns exist
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'profiles' 
AND column_name IN ('is_private', 'updated_at');

SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'posts' 
AND column_name = 'updated_at';

-- 15. Check policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('posts', 'profiles')
ORDER BY tablename, policyname;

-- ================================================
-- Sample Data for Testing
-- ================================================

-- 16. (Optional) Set some test accounts to private
-- UPDATE profiles 
-- SET is_private = true 
-- WHERE id = 'YOUR_TEST_USER_ID';

-- ================================================
-- Rollback (if needed)
-- ================================================

-- To rollback this migration, run:
-- DROP POLICY IF EXISTS "Users can view posts based on privacy" ON posts;
-- DROP POLICY IF EXISTS "Users can update own posts" ON posts;
-- DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
-- DROP TRIGGER IF EXISTS update_posts_updated_at ON posts;
-- DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
-- DROP FUNCTION IF EXISTS update_updated_at_column();
-- DROP INDEX IF EXISTS idx_profiles_is_private;
-- DROP INDEX IF EXISTS idx_posts_updated_at;
-- DROP INDEX IF EXISTS idx_posts_user_created;
-- ALTER TABLE profiles DROP COLUMN IF EXISTS is_private;
-- ALTER TABLE profiles DROP COLUMN IF EXISTS updated_at;
-- ALTER TABLE posts DROP COLUMN IF EXISTS updated_at;

-- ================================================
-- Complete! 🎉
-- ================================================
