-- GymAI Supabase Schema for Web
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Exercises table
CREATE TABLE IF NOT EXISTS exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  primary_muscle_group TEXT NOT NULL,
  secondary_muscle_groups JSONB DEFAULT '[]'::jsonb,
  equipment_type TEXT NOT NULL,
  exercise_type TEXT DEFAULT 'weight_reps',
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  is_custom BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workout Templates table
CREATE TABLE IF NOT EXISTS workout_templates (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  folder_id TEXT,
  exercise_ids JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workout Sessions table
CREATE TABLE IF NOT EXISTS workout_sessions (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  template_id TEXT REFERENCES workout_templates(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  notes TEXT,
  started_at TIMESTAMP WITH TIME ZONE NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  total_duration_seconds INTEGER,
  total_volume REAL DEFAULT 0,
  total_tonnage REAL DEFAULT 0,
  total_sets INTEGER DEFAULT 0,
  total_reps INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Set Entries table
CREATE TABLE IF NOT EXISTS set_entries (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  workout_session_id TEXT REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id TEXT REFERENCES exercises(id) ON DELETE CASCADE,
  set_number INTEGER NOT NULL,
  weight REAL,
  reps INTEGER,
  duration_seconds INTEGER,
  distance REAL,
  assistance_weight REAL,
  added_weight REAL,
  rpe INTEGER,
  notes TEXT,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Exercise Favorites table
CREATE TABLE IF NOT EXISTS exercise_favorites (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id TEXT REFERENCES exercises(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, exercise_id)
);

-- Template Folders table
CREATE TABLE IF NOT EXISTS template_folders (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Personal Records table
CREATE TABLE IF NOT EXISTS personal_records (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id TEXT REFERENCES exercises(id) ON DELETE CASCADE,
  record_type TEXT NOT NULL,
  value REAL NOT NULL,
  reps INTEGER,
  achieved_at TIMESTAMP WITH TIME ZONE NOT NULL,
  workout_session_id TEXT REFERENCES workout_sessions(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE workout_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE set_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE template_folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;

-- Exercises are public (read-only for non-custom, full access for custom)
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read exercises"
  ON exercises FOR SELECT
  USING (true);

CREATE POLICY "Users can insert custom exercises"
  ON exercises FOR INSERT
  WITH CHECK (is_custom = true);

CREATE POLICY "Users can update their custom exercises"
  ON exercises FOR UPDATE
  USING (is_custom = true);

CREATE POLICY "Users can delete their custom exercises"
  ON exercises FOR DELETE
  USING (is_custom = true);

-- Workout Templates policies
CREATE POLICY "Users can view their own templates"
  ON workout_templates FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own templates"
  ON workout_templates FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own templates"
  ON workout_templates FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own templates"
  ON workout_templates FOR DELETE
  USING (auth.uid() = user_id);

-- Workout Sessions policies
CREATE POLICY "Users can view their own sessions"
  ON workout_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sessions"
  ON workout_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sessions"
  ON workout_sessions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sessions"
  ON workout_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- Set Entries policies
CREATE POLICY "Users can view their own sets"
  ON set_entries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sets"
  ON set_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sets"
  ON set_entries FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sets"
  ON set_entries FOR DELETE
  USING (auth.uid() = user_id);

-- Exercise Favorites policies
CREATE POLICY "Users can view their own favorites"
  ON exercise_favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can add favorites"
  ON exercise_favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove favorites"
  ON exercise_favorites FOR DELETE
  USING (auth.uid() = user_id);

-- Template Folders policies
CREATE POLICY "Users can view their own folders"
  ON template_folders FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own folders"
  ON template_folders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own folders"
  ON template_folders FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own folders"
  ON template_folders FOR DELETE
  USING (auth.uid() = user_id);

-- Personal Records policies
CREATE POLICY "Users can view their own PRs"
  ON personal_records FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own PRs"
  ON personal_records FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own PRs"
  ON personal_records FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own PRs"
  ON personal_records FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- INDEXES for Performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_started_at ON workout_sessions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_set_entries_workout_session_id ON set_entries(workout_session_id);
CREATE INDEX IF NOT EXISTS idx_set_entries_user_id ON set_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_templates_user_id ON workout_templates(user_id);
CREATE INDEX IF NOT EXISTS idx_exercise_favorites_user_id ON exercise_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_personal_records_user_id ON personal_records(user_id);

-- ============================================
-- FUNCTIONS for auto-updating timestamps
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_workout_templates_updated_at BEFORE UPDATE ON workout_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_sessions_updated_at BEFORE UPDATE ON workout_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_template_folders_updated_at BEFORE UPDATE ON template_folders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- INITIAL DATA - Sample Exercises
-- ============================================

INSERT INTO exercises (id, name, description, primary_muscle_group, secondary_muscle_groups, equipment_type, category, difficulty, is_custom)
VALUES
  ('bench_press', 'Bench Press', 'Classic chest exercise', 'chest', '["triceps", "shoulders"]'::jsonb, 'barbell', 'strength', 'intermediate', false),
  ('squat', 'Squat', 'Compound leg exercise', 'quadriceps', '["glutes", "hamstrings"]'::jsonb, 'barbell', 'strength', 'intermediate', false),
  ('deadlift', 'Deadlift', 'Full body compound movement', 'back', '["glutes", "hamstrings", "core"]'::jsonb, 'barbell', 'strength', 'advanced', false),
  ('pull_up', 'Pull Up', 'Bodyweight back exercise', 'back', '["biceps", "forearms"]'::jsonb, 'bodyweight', 'calisthenics', 'intermediate', false),
  ('push_up', 'Push Up', 'Classic bodyweight push exercise', 'chest', '["triceps", "shoulders"]'::jsonb, 'bodyweight', 'calisthenics', 'beginner', false)
ON CONFLICT (id) DO NOTHING;

COMMIT;
