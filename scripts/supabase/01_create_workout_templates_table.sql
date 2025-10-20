-- =====================================================
-- HERQ: Workout Templates Table for Web Support
-- =====================================================
-- This script creates the workout_templates table in Supabase
-- Run this in your Supabase SQL Editor
-- =====================================================

-- Drop existing table if you want to recreate (BE CAREFUL - THIS DELETES DATA!)
-- DROP TABLE IF EXISTS workout_templates CASCADE;

-- Create workout_templates table (without folder_id foreign key for now)
CREATE TABLE IF NOT EXISTS workout_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT DEFAULT 'Custom' NOT NULL,
  folder_id UUID, -- Will add foreign key after template_folders is created
  exercise_ids TEXT[] NOT NULL DEFAULT '{}',
  estimated_duration INTEGER, -- in minutes
  sort_order INTEGER DEFAULT 0 NOT NULL,
  tags TEXT[] DEFAULT '{}',
  is_default BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_workout_templates_user_id ON workout_templates(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_templates_folder_id ON workout_templates(folder_id);
CREATE INDEX IF NOT EXISTS idx_workout_templates_category ON workout_templates(category);
CREATE INDEX IF NOT EXISTS idx_workout_templates_is_default ON workout_templates(is_default);
CREATE INDEX IF NOT EXISTS idx_workout_templates_created_at ON workout_templates(created_at DESC);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_workout_templates_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS workout_templates_updated_at ON workout_templates;
CREATE TRIGGER workout_templates_updated_at
  BEFORE UPDATE ON workout_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_workout_templates_updated_at();

-- =====================================================
-- Row Level Security (RLS) Policies
-- =====================================================

-- Enable RLS
ALTER TABLE workout_templates ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own templates AND default templates
CREATE POLICY "Users can view their own templates and defaults"
  ON workout_templates
  FOR SELECT
  USING (
    auth.uid() = user_id OR 
    is_default = TRUE
  );

-- Policy: Users can insert their own templates
CREATE POLICY "Users can insert their own templates"
  ON workout_templates
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own templates
CREATE POLICY "Users can update their own templates"
  ON workout_templates
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own templates
CREATE POLICY "Users can delete their own templates"
  ON workout_templates
  FOR DELETE
  USING (auth.uid() = user_id);

-- Policy: Admins can do everything (optional - if you have admin roles)
-- Uncomment if you have an admin role setup
-- CREATE POLICY "Admins can do everything"
--   ON workout_templates
--   FOR ALL
--   USING (
--     EXISTS (
--       SELECT 1 FROM auth.users
--       WHERE id = auth.uid()
--       AND raw_user_meta_data->>'role' = 'admin'
--     )
--   );

-- =====================================================
-- Verification Queries
-- =====================================================

-- Verify table structure
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'workout_templates'
-- ORDER BY ordinal_position;

-- Verify indexes
-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE tablename = 'workout_templates';

-- Verify RLS policies
-- SELECT policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies
-- WHERE tablename = 'workout_templates';

-- =====================================================
-- Example Queries
-- =====================================================

-- Insert a test template (will only work if you're authenticated)
-- INSERT INTO workout_templates (name, description, category, exercise_ids)
-- VALUES (
--   'Push Day',
--   'Chest, shoulders, and triceps workout',
--   'Push Pull Legs',
--   ARRAY['barbell_bench_press', 'overhead_press', 'tricep_dip']
-- );

-- Query your templates
-- SELECT * FROM workout_templates WHERE user_id = auth.uid();

-- Query default templates
-- SELECT * FROM workout_templates WHERE is_default = TRUE;

-- =====================================================
-- Success Message
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '✅ workout_templates table created successfully!';
  RAISE NOTICE '📋 Next step: Run 02_create_template_folders_table.sql';
END $$;

