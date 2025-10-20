-- Run this to see what columns your exercises table actually has
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'exercises' 
ORDER BY ordinal_position;
