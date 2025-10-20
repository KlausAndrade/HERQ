-- Add missing columns to exercises table
-- Run this FIRST in Supabase SQL Editor before the seed script

-- Add the type column
ALTER TABLE exercises 
ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'compound';

-- Add the equipment column (array of text)
ALTER TABLE exercises 
ADD COLUMN IF NOT EXISTS equipment TEXT[] DEFAULT '{}';

-- Add the primary_muscles column (array of text)
ALTER TABLE exercises 
ADD COLUMN IF NOT EXISTS primary_muscles TEXT[] DEFAULT '{}';

-- Add the secondary_muscles column (array of text)
ALTER TABLE exercises 
ADD COLUMN IF NOT EXISTS secondary_muscles TEXT[] DEFAULT '{}';

-- Add the difficulty column
ALTER TABLE exercises 
ADD COLUMN IF NOT EXISTS difficulty TEXT DEFAULT 'intermediate';

-- Add the instructions column
ALTER TABLE exercises 
ADD COLUMN IF NOT EXISTS instructions TEXT;

-- Verify the columns were added
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'exercises' 
ORDER BY ordinal_position;

-- You should now see these columns:
-- id, name, category, type, difficulty, equipment, primary_muscles, secondary_muscles, instructions, created_at

-- Now you can run the seed_supabase_exercises.sql script!
