-- =====================================================
-- MULTI-USER LEADERBOARD SCHEMA FOR SUPABASE
-- =====================================================
-- This schema enables real multi-user leaderboards by:
-- 1. Storing aggregated user stats in Supabase
-- 2. Creating views for leaderboard queries
-- 3. Enabling real-time updates
-- =====================================================

-- Step 1: Create user_stats table in Supabase (if not exists)
CREATE TABLE IF NOT EXISTS user_stats (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  total_workouts INT DEFAULT 0,
  total_volume NUMERIC DEFAULT 0,
  total_sets INT DEFAULT 0,
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  experience_points INT DEFAULT 0,
  level INT DEFAULT 1,
  last_workout_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all stats (for leaderboards)
CREATE POLICY "Anyone can view stats" ON user_stats
  FOR SELECT USING (true);

-- Policy: Users can only update their own stats
CREATE POLICY "Users can update own stats" ON user_stats
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats update" ON user_stats
  FOR UPDATE USING (auth.uid() = user_id);

-- Step 2: Create indexes for fast leaderboard queries
CREATE INDEX IF NOT EXISTS idx_user_stats_volume ON user_stats(total_volume DESC);
CREATE INDEX IF NOT EXISTS idx_user_stats_workouts ON user_stats(total_workouts DESC);
CREATE INDEX IF NOT EXISTS idx_user_stats_streak ON user_stats(current_streak DESC);
CREATE INDEX IF NOT EXISTS idx_user_stats_updated ON user_stats(updated_at DESC);

-- Step 3: Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_stats_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_stats_updated_at
  BEFORE UPDATE ON user_stats
  FOR EACH ROW
  EXECUTE FUNCTION update_user_stats_updated_at();

-- Step 4: Create leaderboard views for efficient queries

-- Volume Leaderboard View
CREATE OR REPLACE VIEW leaderboard_volume AS
SELECT 
  us.user_id,
  us.total_volume as value,
  us.total_workouts,
  us.current_streak,
  p.display_name,
  p.avatar_url,
  ROW_NUMBER() OVER (ORDER BY us.total_volume DESC) as rank
FROM user_stats us
LEFT JOIN profiles p ON p.id = us.user_id
WHERE us.total_volume > 0
ORDER BY us.total_volume DESC
LIMIT 100;

-- Workout Count Leaderboard View
CREATE OR REPLACE VIEW leaderboard_workouts AS
SELECT 
  us.user_id,
  us.total_workouts as value,
  us.total_volume,
  us.current_streak,
  p.display_name,
  p.avatar_url,
  ROW_NUMBER() OVER (ORDER BY us.total_workouts DESC) as rank
FROM user_stats us
LEFT JOIN profiles p ON p.id = us.user_id
WHERE us.total_workouts > 0
ORDER BY us.total_workouts DESC
LIMIT 100;

-- Streak Leaderboard View
CREATE OR REPLACE VIEW leaderboard_streak AS
SELECT 
  us.user_id,
  us.current_streak as value,
  us.total_workouts,
  us.total_volume,
  p.display_name,
  p.avatar_url,
  ROW_NUMBER() OVER (ORDER BY us.current_streak DESC) as rank
FROM user_stats us
LEFT JOIN profiles p ON p.id = us.user_id
WHERE us.current_streak > 0
ORDER BY us.current_streak DESC
LIMIT 100;

-- Step 5: Create function to get user rank
CREATE OR REPLACE FUNCTION get_user_rank(
  p_user_id UUID,
  p_stat_type TEXT -- 'volume', 'workouts', or 'streak'
)
RETURNS TABLE(
  user_id UUID,
  rank BIGINT,
  value NUMERIC,
  display_name TEXT,
  avatar_url TEXT
) AS $$
BEGIN
  IF p_stat_type = 'volume' THEN
    RETURN QUERY
    WITH ranked AS (
      SELECT 
        us.user_id,
        ROW_NUMBER() OVER (ORDER BY us.total_volume DESC) as rank,
        us.total_volume as value,
        p.display_name,
        p.avatar_url
      FROM user_stats us
      LEFT JOIN profiles p ON p.id = us.user_id
      WHERE us.total_volume > 0
    )
    SELECT * FROM ranked WHERE ranked.user_id = p_user_id;
    
  ELSIF p_stat_type = 'workouts' THEN
    RETURN QUERY
    WITH ranked AS (
      SELECT 
        us.user_id,
        ROW_NUMBER() OVER (ORDER BY us.total_workouts DESC) as rank,
        us.total_workouts::NUMERIC as value,
        p.display_name,
        p.avatar_url
      FROM user_stats us
      LEFT JOIN profiles p ON p.id = us.user_id
      WHERE us.total_workouts > 0
    )
    SELECT * FROM ranked WHERE ranked.user_id = p_user_id;
    
  ELSIF p_stat_type = 'streak' THEN
    RETURN QUERY
    WITH ranked AS (
      SELECT 
        us.user_id,
        ROW_NUMBER() OVER (ORDER BY us.current_streak DESC) as rank,
        us.current_streak::NUMERIC as value,
        p.display_name,
        p.avatar_url
      FROM user_stats us
      LEFT JOIN profiles p ON p.id = us.user_id
      WHERE us.current_streak > 0
    )
    SELECT * FROM ranked WHERE ranked.user_id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 6: Create PR count leaderboard function
CREATE OR REPLACE FUNCTION get_pr_leaderboard()
RETURNS TABLE(
  user_id UUID,
  pr_count BIGINT,
  display_name TEXT,
  avatar_url TEXT,
  rank BIGINT
) AS $$
BEGIN
  RETURN QUERY
  WITH pr_counts AS (
    SELECT 
      pr.user_id,
      COUNT(*) as pr_count
    FROM personal_records pr
    GROUP BY pr.user_id
  ),
  ranked AS (
    SELECT 
      pc.user_id,
      pc.pr_count,
      p.display_name,
      p.avatar_url,
      ROW_NUMBER() OVER (ORDER BY pc.pr_count DESC) as rank
    FROM pr_counts pc
    LEFT JOIN profiles p ON p.id = pc.user_id
  )
  SELECT * FROM ranked
  ORDER BY rank
  LIMIT 100;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 7: Grant permissions
GRANT SELECT ON leaderboard_volume TO authenticated;
GRANT SELECT ON leaderboard_workouts TO authenticated;
GRANT SELECT ON leaderboard_streak TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_rank TO authenticated;
GRANT EXECUTE ON FUNCTION get_pr_leaderboard TO authenticated;

-- Step 7: Create initial stats for existing users
INSERT INTO user_stats (user_id, total_workouts, total_volume, total_sets)
SELECT 
  user_id,
  COUNT(*) as total_workouts,
  COALESCE(SUM(total_volume), 0) as total_volume,
  COALESCE(SUM(total_sets), 0) as total_sets
FROM workout_sessions
WHERE completed_at IS NOT NULL
GROUP BY user_id
ON CONFLICT (user_id) DO UPDATE SET
  total_workouts = EXCLUDED.total_workouts,
  total_volume = EXCLUDED.total_volume,
  total_sets = EXCLUDED.total_sets,
  updated_at = NOW();

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these to verify the setup:

-- Check user stats
-- SELECT * FROM user_stats ORDER BY total_volume DESC LIMIT 10;

-- Check volume leaderboard
-- SELECT * FROM leaderboard_volume LIMIT 10;

-- Check workout count leaderboard
-- SELECT * FROM leaderboard_workouts LIMIT 10;

-- Check streak leaderboard
-- SELECT * FROM leaderboard_streak LIMIT 10;

-- Get specific user's rank
-- SELECT * FROM get_user_rank('your-user-id-here', 'volume');

-- =====================================================
-- NOTES
-- =====================================================
-- 1. This creates a Supabase-based leaderboard system
-- 2. Stats are aggregated in user_stats table
-- 3. Views provide fast leaderboard queries
-- 4. RLS ensures users can only update their own stats
-- 5. Everyone can read all stats (public leaderboards)
-- 6. Indexes optimize queries for large user bases
-- =====================================================

