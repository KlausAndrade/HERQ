-- =====================================================
-- Create Workout Tables in Supabase (Safe Version)
-- =====================================================
-- This script safely creates tables and policies
-- It drops existing policies before recreating them
-- =====================================================

-- 1. Create workout_sessions table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS workout_sessions (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  template_id TEXT,
  name TEXT NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  total_sets INTEGER DEFAULT 0,
  total_reps INTEGER DEFAULT 0,
  total_volume REAL DEFAULT 0,
  total_tonnage REAL DEFAULT 0,
  duration_seconds INTEGER DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create exercises table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  exercise_type TEXT NOT NULL DEFAULT 'reps',
  equipment TEXT NOT NULL DEFAULT 'bodyweight',
  primary_muscle_group TEXT NOT NULL DEFAULT 'other',
  secondary_muscle_groups TEXT[] DEFAULT '{}',
  instructions TEXT DEFAULT '',
  category TEXT DEFAULT 'Other',
  difficulty TEXT DEFAULT 'intermediate',
  aliases TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create set_entries table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS set_entries (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  workout_session_id TEXT NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id TEXT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  set_number INTEGER NOT NULL,
  reps INTEGER NOT NULL DEFAULT 0,
  weight REAL,
  duration_seconds INTEGER,
  distance REAL,
  is_completed BOOLEAN DEFAULT true,
  is_warmup BOOLEAN DEFAULT false,
  rpe INTEGER,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_created_at ON workout_sessions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_exercises_user_id ON exercises(user_id);
CREATE INDEX IF NOT EXISTS idx_exercises_name ON exercises(name);
CREATE INDEX IF NOT EXISTS idx_set_entries_workout_session_id ON set_entries(workout_session_id);
CREATE INDEX IF NOT EXISTS idx_set_entries_exercise_id ON set_entries(exercise_id);
CREATE INDEX IF NOT EXISTS idx_set_entries_user_id ON set_entries(user_id);

-- 5. Enable Row Level Security (RLS)
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE set_entries ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Drop existing policies (if they exist)
-- =====================================================

-- Drop workout_sessions policies
DROP POLICY IF EXISTS "Anyone can view workout sessions" ON workout_sessions;
DROP POLICY IF EXISTS "Users can insert their own workout sessions" ON workout_sessions;
DROP POLICY IF EXISTS "Users can update their own workout sessions" ON workout_sessions;
DROP POLICY IF EXISTS "Users can delete their own workout sessions" ON workout_sessions;

-- Drop exercises policies
DROP POLICY IF EXISTS "Anyone can view exercises" ON exercises;
DROP POLICY IF EXISTS "Users can insert exercises" ON exercises;
DROP POLICY IF EXISTS "Users can update their own exercises" ON exercises;
DROP POLICY IF EXISTS "Users can delete their own exercises" ON exercises;

-- Drop set_entries policies
DROP POLICY IF EXISTS "Anyone can view set entries" ON set_entries;
DROP POLICY IF EXISTS "Users can insert their own set entries" ON set_entries;
DROP POLICY IF EXISTS "Users can update their own set entries" ON set_entries;
DROP POLICY IF EXISTS "Users can delete their own set entries" ON set_entries;

-- =====================================================
-- Create RLS Policies
-- =====================================================

-- 6. RLS Policies for workout_sessions
CREATE POLICY "Anyone can view workout sessions"
ON workout_sessions FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can insert their own workout sessions"
ON workout_sessions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own workout sessions"
ON workout_sessions FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own workout sessions"
ON workout_sessions FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- 7. RLS Policies for exercises
CREATE POLICY "Anyone can view exercises"
ON exercises FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can insert exercises"
ON exercises FOR INSERT
TO authenticated
WITH CHECK (user_id IS NULL OR auth.uid() = user_id);

CREATE POLICY "Users can update their own exercises"
ON exercises FOR UPDATE
TO authenticated
USING (user_id IS NULL OR auth.uid() = user_id)
WITH CHECK (user_id IS NULL OR auth.uid() = user_id);

CREATE POLICY "Users can delete their own exercises"
ON exercises FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- 8. RLS Policies for set_entries
CREATE POLICY "Anyone can view set entries"
ON set_entries FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can insert their own set entries"
ON set_entries FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own set entries"
ON set_entries FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own set entries"
ON set_entries FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- =====================================================
-- Verification queries
-- =====================================================

SELECT 'Tables created:' AS status;

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('workout_sessions', 'exercises', 'set_entries')
ORDER BY table_name;

SELECT 'RLS Policies created:' AS status;

SELECT tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename IN ('workout_sessions', 'exercises', 'set_entries')
ORDER BY tablename, policyname;

SELECT 'Foreign key relationships:' AS status;

SELECT
    tc.table_name, 
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name IN ('workout_sessions', 'set_entries');

-- =====================================================
-- SUCCESS!
-- =====================================================
-- Now you can:
-- 1. Complete a workout and share to social
-- 2. View workout details from social posts
-- 3. Save templates from other users' workouts
-- 4. Start workouts from social posts
-- =====================================================

