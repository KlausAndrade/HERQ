-- =====================================================
-- HERQ: Template Folders Table for Web Support  
-- =====================================================
-- This script creates the template_folders table in Supabase
-- Run this AFTER 01_create_workout_templates_table.sql
-- =====================================================

-- Drop existing table if you want to recreate (BE CAREFUL - THIS DELETES DATA!)
-- DROP TABLE IF EXISTS template_folders CASCADE;

-- Create template_folders table
CREATE TABLE IF NOT EXISTS template_folders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT, -- Hex color code like '#FF5733'
  sort_order INTEGER DEFAULT 0 NOT NULL,
  is_expanded BOOLEAN DEFAULT TRUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_template_folders_user_id ON template_folders(user_id);
CREATE INDEX IF NOT EXISTS idx_template_folders_sort_order ON template_folders(sort_order);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_template_folders_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS template_folders_updated_at ON template_folders;
CREATE TRIGGER template_folders_updated_at
  BEFORE UPDATE ON template_folders
  FOR EACH ROW
  EXECUTE FUNCTION update_template_folders_updated_at();

-- =====================================================
-- Row Level Security (RLS) Policies
-- =====================================================

-- Enable RLS
ALTER TABLE template_folders ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own folders
CREATE POLICY "Users can view their own folders"
  ON template_folders
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own folders
CREATE POLICY "Users can insert their own folders"
  ON template_folders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own folders
CREATE POLICY "Users can update their own folders"
  ON template_folders
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own folders
CREATE POLICY "Users can delete their own folders"
  ON template_folders
  FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- Add foreign key constraint to workout_templates
-- =====================================================

-- Now that template_folders exists, add the foreign key
ALTER TABLE workout_templates 
DROP CONSTRAINT IF EXISTS fk_workout_templates_folder_id;

ALTER TABLE workout_templates 
ADD CONSTRAINT fk_workout_templates_folder_id 
FOREIGN KEY (folder_id) REFERENCES template_folders(id) ON DELETE SET NULL;

-- =====================================================
-- Verification Queries
-- =====================================================

-- Verify table structure
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'template_folders'
-- ORDER BY ordinal_position;

-- Verify indexes
-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE tablename = 'template_folders';

-- Verify RLS policies
-- SELECT policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies
-- WHERE tablename = 'template_folders';

-- =====================================================
-- Example Queries
-- =====================================================

-- Insert a test folder (will only work if you're authenticated)
-- INSERT INTO template_folders (name, description, color)
-- VALUES (
--   'Strength Programs',
--   'All my strength-focused workout templates',
--   '#3B82F6'
-- );

-- Query your folders
-- SELECT * FROM template_folders WHERE user_id = auth.uid() ORDER BY sort_order;

-- Query templates in a folder
-- SELECT t.*, f.name as folder_name
-- FROM workout_templates t
-- LEFT JOIN template_folders f ON t.folder_id = f.id
-- WHERE t.user_id = auth.uid()
-- ORDER BY f.sort_order, t.sort_order;

-- =====================================================
-- Success Message
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '✅ template_folders table created successfully!';
  RAISE NOTICE '📋 Both tables are now ready for use!';
  RAISE NOTICE '💡 You can now create workout templates on the web!';
END $$;

