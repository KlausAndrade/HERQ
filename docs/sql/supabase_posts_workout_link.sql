-- =====================================================
-- Add Workout Session Link to Posts Table
-- =====================================================
-- Run this in Supabase SQL Editor to link posts to workouts
-- =====================================================

-- 1. Add workout_session_id column to posts table
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS workout_session_id TEXT;

-- 2. Add foreign key constraint (optional, but recommended)
-- Note: Only add if workout_sessions table exists in Supabase
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'workout_sessions'
    ) THEN
        ALTER TABLE posts
        ADD CONSTRAINT fk_posts_workout_session
        FOREIGN KEY (workout_session_id) 
        REFERENCES workout_sessions(id) 
        ON DELETE SET NULL;
    END IF;
END $$;

-- 3. Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_posts_workout_session_id 
ON posts(workout_session_id);

-- 4. Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'posts' 
  AND column_name = 'workout_session_id';

-- =====================================================
-- Optional: Update RLS policies if needed
-- =====================================================
-- If you have RLS policies that need to consider workout_session_id,
-- you can update them here. For example:

-- COMMENT: Posts linked to workouts are visible based on workout privacy
-- CREATE POLICY "Users can view workout posts" ON posts
-- FOR SELECT
-- USING (
--   workout_session_id IS NULL OR
--   workout_session_id IN (
--     SELECT id FROM workout_sessions 
--     WHERE user_id = auth.uid()
--   )
-- );

-- =====================================================
-- Verification Query
-- =====================================================
-- Run this to see posts with workout links
SELECT 
  id,
  user_id,
  caption,
  workout_session_id,
  created_at
FROM posts
WHERE workout_session_id IS NOT NULL
LIMIT 10;

