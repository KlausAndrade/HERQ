-- Migration to support position/angle variants in exercise tracking
-- This adds support for inclined, declined, and suspended position variations
-- Run this on your Supabase database

-- Note: set_entries.variant_type is already TEXT with no constraints,
-- so it can accept values like "weight_reps:inclined", "timer:declined", etc.
-- No schema changes are needed for set_entries.

-- However, if you want to add validation or documentation, you can add a comment:
COMMENT ON COLUMN set_entries.variant_type IS 
  'Variant type for this set. Can be execution type (e.g., "weight_reps", "timer") or combined format "executionType:position" where position can be "inclined", "declined", or "suspended". Examples: "weight_reps:inclined", "timer:suspended"';

-- Optional: Add a check constraint to ensure position values are valid (if used as standalone)
-- This is commented out because we use combined format "executionType:position"
-- ALTER TABLE set_entries ADD CONSTRAINT check_variant_position 
--   CHECK (variant_type IS NULL OR 
--          variant_type NOT LIKE '%:%' OR 
--          SPLIT_PART(variant_type, ':', 2) IN ('inclined', 'declined', 'suspended', 'standard'));

-- Verify the column exists and is ready
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'set_entries' 
  AND column_name = 'variant_type';

-- Summary:
-- This migration documents that set_entries.variant_type now supports:
-- 1. Execution types: weight_reps, timer, duration_weight, distance_duration, weight_distance
-- 2. Position variants: inclined, declined, suspended
-- 3. Combined format: "executionType:position" (e.g., "weight_reps:inclined")
-- 
-- The variant_type field in exercises table remains unchanged - it's for exercise-level
-- variants (progression, regression, equipment, angle, grip, tempo, range, stability, assisted, strict)
-- and does NOT include workout-time position variations.

