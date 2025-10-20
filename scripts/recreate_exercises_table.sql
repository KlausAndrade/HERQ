-- Complete Supabase exercises table recreation
-- This will drop and recreate the table with the correct structure
-- ⚠️ WARNING: This will DELETE all existing exercises data!

-- Drop the existing table (if you're sure!)
DROP TABLE IF EXISTS exercises CASCADE;

-- Create exercises table with proper structure
CREATE TABLE exercises (
  -- Primary key
  id TEXT PRIMARY KEY,
  
  -- Basic info
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  type TEXT DEFAULT 'compound' CHECK (type IN ('compound', 'isolation', 'isometric', 'cardio')),
  difficulty TEXT DEFAULT 'intermediate' CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'expert')),
  
  -- Equipment and muscles
  equipment TEXT[] DEFAULT '{}',
  primary_muscle_group TEXT NOT NULL,
  secondary_muscle_groups TEXT[] DEFAULT '{}',
  
  -- Exercise details
  instructions TEXT,
  aliases TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  
  -- Bodyweight flag
  is_bodyweight BOOLEAN DEFAULT false,
  
  -- Exercise type for tracking
  exercise_type TEXT DEFAULT 'weight_reps' CHECK (exercise_type IN ('weight_reps', 'time', 'distance', 'bodyweight')),
  
  -- Variant system (for progressions/regressions)
  parent_exercise_id TEXT REFERENCES exercises(id) ON DELETE SET NULL,
  variant_type TEXT CHECK (variant_type IN ('progression', 'regression', 'equipment', 'angle', 'grip', 'tempo', 'range', 'stability', 'assisted', 'strict')),
  variant_detail TEXT,
  
  -- User ownership (NULL = global/public exercise)
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_exercises_category ON exercises(category);
CREATE INDEX idx_exercises_primary_muscle ON exercises(primary_muscle_group);
CREATE INDEX idx_exercises_difficulty ON exercises(difficulty);
CREATE INDEX idx_exercises_type ON exercises(type);
CREATE INDEX idx_exercises_user_id ON exercises(user_id);
CREATE INDEX idx_exercises_parent_id ON exercises(parent_exercise_id);
CREATE INDEX idx_exercises_equipment ON exercises USING GIN(equipment);
CREATE INDEX idx_exercises_tags ON exercises USING GIN(tags);
CREATE INDEX idx_exercises_created_at ON exercises(created_at DESC);

-- Enable Row Level Security
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- 1. Everyone can view global exercises (user_id IS NULL)
CREATE POLICY "Global exercises are viewable by everyone"
  ON exercises FOR SELECT
  USING (user_id IS NULL);

-- 2. Authenticated users can view their own exercises
CREATE POLICY "Users can view their own exercises"
  ON exercises FOR SELECT
  USING (auth.uid() = user_id);

-- 3. Authenticated users can create their own exercises
CREATE POLICY "Users can create their own exercises"
  ON exercises FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 4. Users can update their own exercises
CREATE POLICY "Users can update their own exercises"
  ON exercises FOR UPDATE
  USING (auth.uid() = user_id);

-- 5. Users can delete their own exercises
CREATE POLICY "Users can delete their own exercises"
  ON exercises FOR DELETE
  USING (auth.uid() = user_id);

-- 6. Admins can manage all exercises (create global exercises)
-- Note: You'll need to create an admin_users table first, or use a different admin check
-- CREATE POLICY "Admins can manage all exercises"
--   ON exercises FOR ALL
--   USING (
--     EXISTS (
--       SELECT 1 FROM admin_users 
--       WHERE admin_users.id = auth.uid()
--     )
--   );

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_exercises_updated_at
  BEFORE UPDATE ON exercises
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Verify the table structure
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default
FROM information_schema.columns 
WHERE table_name = 'exercises' 
ORDER BY ordinal_position;

-- Show the indexes
SELECT 
  indexname, 
  indexdef 
FROM pg_indexes 
WHERE tablename = 'exercises'
ORDER BY indexname;
