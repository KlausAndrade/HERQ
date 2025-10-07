-- Add sort_order columns for template and folder reordering
-- Run this in your Supabase SQL Editor

-- Add sort_order to workout_templates
ALTER TABLE workout_templates 
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Add sort_order to template_folders
ALTER TABLE template_folders 
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Create indexes for better performance when ordering
CREATE INDEX IF NOT EXISTS idx_workout_templates_sort_order ON workout_templates(sort_order);
CREATE INDEX IF NOT EXISTS idx_template_folders_sort_order ON template_folders(sort_order);

-- Update existing templates to have sequential sort order per user
WITH numbered_templates AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (PARTITION BY user_id, folder_id ORDER BY created_at) - 1 as new_sort_order
  FROM workout_templates
)
UPDATE workout_templates
SET sort_order = numbered_templates.new_sort_order
FROM numbered_templates
WHERE workout_templates.id = numbered_templates.id;

-- Update existing folders to have sequential sort order per user
WITH numbered_folders AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) - 1 as new_sort_order
  FROM template_folders
)
UPDATE template_folders
SET sort_order = numbered_folders.new_sort_order
FROM numbered_folders
WHERE template_folders.id = numbered_folders.id;

COMMIT;
