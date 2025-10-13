-- Migration to add exercise type support with distance, assistance_weight, and added_weight fields
-- Run this on your existing Supabase database to add the new fields

BEGIN;

-- Add new columns to set_entries table if they don't exist
DO $$ 
BEGIN
    -- Add distance column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='set_entries' AND column_name='distance') THEN
        ALTER TABLE set_entries ADD COLUMN distance REAL;
    END IF;

    -- Add assistance_weight column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='set_entries' AND column_name='assistance_weight') THEN
        ALTER TABLE set_entries ADD COLUMN assistance_weight REAL;
    END IF;

    -- Add added_weight column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='set_entries' AND column_name='added_weight') THEN
        ALTER TABLE set_entries ADD COLUMN added_weight REAL;
    END IF;
END $$;

-- Add exercise_type column to exercises table if it doesn't exist
DO $$ 
BEGIN
    -- Add exercise_type column with default value
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='exercises' AND column_name='exercise_type') THEN
        ALTER TABLE exercises ADD COLUMN exercise_type TEXT DEFAULT 'weight_reps';
    END IF;
END $$;

-- Update exercises table exercise_type values to new naming convention
-- Old values: 'reps', 'timer', 'body_weighted', 'assisted'
-- New values: 'weight_reps', 'duration', 'weighted_bodyweight', 'assisted_bodyweight', 
--             'bodyweight_reps', 'duration_weight', 'distance_duration', 'weight_distance'

-- Map old exercise types to new ones
UPDATE exercises SET exercise_type = 'weight_reps' WHERE exercise_type = 'reps' OR exercise_type IS NULL OR exercise_type = '';
UPDATE exercises SET exercise_type = 'duration' WHERE exercise_type = 'timer';
UPDATE exercises SET exercise_type = 'weighted_bodyweight' WHERE exercise_type = 'body_weighted';
UPDATE exercises SET exercise_type = 'assisted_bodyweight' WHERE exercise_type = 'assisted';

COMMIT;

-- Print confirmation
DO $$
BEGIN
    RAISE NOTICE 'Exercise types migration completed successfully!';
    RAISE NOTICE 'New columns added: distance, assistance_weight, added_weight';
    RAISE NOTICE 'Exercise types updated to new naming convention';
END $$;

