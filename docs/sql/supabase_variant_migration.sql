-- Migration to add equipment_used and variant_type columns to set_entries table
-- Run this on your Supabase database

-- Add equipment_used column
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'set_entries' AND column_name = 'equipment_used'
  ) THEN
    ALTER TABLE set_entries ADD COLUMN equipment_used TEXT;
  END IF;
END $$;

-- Add variant_type column
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'set_entries' AND column_name = 'variant_type'
  ) THEN
    ALTER TABLE set_entries ADD COLUMN variant_type TEXT;
  END IF;
END $$;

-- Add index for better query performance (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_set_entries_equipment ON set_entries(equipment_used);
CREATE INDEX IF NOT EXISTS idx_set_entries_variant ON set_entries(variant_type);

-- Comment the columns
COMMENT ON COLUMN set_entries.equipment_used IS 'Equipment variant used for this set (barbell, dumbbell, cable, etc)';
COMMENT ON COLUMN set_entries.variant_type IS 'Variant type for this set (standard, assisted, weighted, etc)';

