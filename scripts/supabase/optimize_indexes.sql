-- ============================================================================
-- PERFORMANCE OPTIMIZATION - Database Indexes
-- ============================================================================
--
-- Purpose: Add missing indexes to improve query performance
-- Run this in Supabase SQL Editor to optimize database queries
--
-- Expected Impact:
-- - 10-100x faster queries on workout_templates
-- - 5-50x faster queries on template_folders
-- - Reduced server load and costs
-- ============================================================================

-- Index for fetching user's templates with folder filtering
CREATE INDEX IF NOT EXISTS idx_workout_templates_user_folder 
  ON workout_templates(user_id, folder_id);

-- Index for ordering templates by sort_order within folders
CREATE INDEX IF NOT EXISTS idx_workout_templates_folder_sort 
  ON workout_templates(folder_id, sort_order) 
  WHERE folder_id IS NOT NULL;

-- Index for templates without folders
CREATE INDEX IF NOT EXISTS idx_workout_templates_no_folder 
  ON workout_templates(user_id, sort_order) 
  WHERE folder_id IS NULL;

-- Index for template folders ordering
CREATE INDEX IF NOT EXISTS idx_template_folders_user_sort 
  ON template_folders(user_id, sort_order);

-- Index for exercise lookups by name (for search functionality)
CREATE INDEX IF NOT EXISTS idx_exercises_name_trgm 
  ON exercises USING gin(name gin_trgm_ops);

-- Index for exercises by primary muscle group
CREATE INDEX IF NOT EXISTS idx_exercises_primary_muscle 
  ON exercises(primary_muscle_group);

-- Verify indexes were created
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('workout_templates', 'template_folders', 'exercises')
ORDER BY tablename, indexname;

-- ============================================================================
-- Additional Recommendations
-- ============================================================================
--
-- 1. Enable pg_trgm extension for fuzzy text search (if not already enabled):
--    CREATE EXTENSION IF NOT EXISTS pg_trgm;
--
-- 2. Monitor query performance in Supabase Dashboard:
--    Settings → Database → Query Performance
--
-- 3. Consider adding composite indexes if you have specific frequent queries
--
-- ============================================================================

