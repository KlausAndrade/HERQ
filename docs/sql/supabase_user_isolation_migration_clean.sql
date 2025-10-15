-- Clean User Isolation Migration for HERQ
-- This migration properly handles UUID/TEXT type casting issues

-- First, let's check the current state and column types
DO $$ 
DECLARE
    workout_sessions_type text;
    set_entries_type text;
    workout_templates_type text;
    personal_records_type text;
BEGIN
    -- Check the data type of user_id columns
    SELECT data_type INTO workout_sessions_type
    FROM information_schema.columns 
    WHERE table_name = 'workout_sessions' AND column_name = 'user_id';
    
    SELECT data_type INTO set_entries_type
    FROM information_schema.columns 
    WHERE table_name = 'set_entries' AND column_name = 'user_id';
    
    SELECT data_type INTO workout_templates_type
    FROM information_schema.columns 
    WHERE table_name = 'workout_templates' AND column_name = 'user_id';
    
    SELECT data_type INTO personal_records_type
    FROM information_schema.columns 
    WHERE table_name = 'personal_records' AND column_name = 'user_id';
    
    RAISE NOTICE 'Column types:';
    RAISE NOTICE 'workout_sessions.user_id: %', COALESCE(workout_sessions_type, 'NOT EXISTS');
    RAISE NOTICE 'set_entries.user_id: %', COALESCE(set_entries_type, 'NOT EXISTS');
    RAISE NOTICE 'workout_templates.user_id: %', COALESCE(workout_templates_type, 'NOT EXISTS');
    RAISE NOTICE 'personal_records.user_id: %', COALESCE(personal_records_type, 'NOT EXISTS');
END $$;

-- Add user_id columns if they don't exist
-- Use UUID type for consistency with auth.uid()
DO $$ 
BEGIN
    -- Add user_id to workout_sessions if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'workout_sessions' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE workout_sessions ADD COLUMN user_id UUID;
        RAISE NOTICE 'Added user_id column to workout_sessions';
    ELSE
        RAISE NOTICE 'user_id column already exists in workout_sessions';
    END IF;

    -- Add user_id to set_entries if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'set_entries' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE set_entries ADD COLUMN user_id UUID;
        RAISE NOTICE 'Added user_id column to set_entries';
    ELSE
        RAISE NOTICE 'user_id column already exists in set_entries';
    END IF;

    -- Add user_id to workout_templates if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'workout_templates' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE workout_templates ADD COLUMN user_id UUID;
        RAISE NOTICE 'Added user_id column to workout_templates';
    ELSE
        RAISE NOTICE 'user_id column already exists in workout_templates';
    END IF;

    -- Add user_id to personal_records if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'personal_records' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE personal_records ADD COLUMN user_id UUID;
        RAISE NOTICE 'Added user_id column to personal_records';
    ELSE
        RAISE NOTICE 'user_id column already exists in personal_records';
    END IF;
END $$;

-- Set default user_id for existing data (only if NULL)
-- Use a valid UUID for the default
DO $$
BEGIN
    -- For workout_sessions
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_sessions' AND column_name = 'user_id') THEN
        UPDATE workout_sessions SET user_id = '00000000-0000-0000-0000-000000000000'::uuid WHERE user_id IS NULL;
        RAISE NOTICE 'Updated workout_sessions with default user_id';
    END IF;
    
    -- For set_entries
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'set_entries' AND column_name = 'user_id') THEN
        UPDATE set_entries SET user_id = '00000000-0000-0000-0000-000000000000'::uuid WHERE user_id IS NULL;
        RAISE NOTICE 'Updated set_entries with default user_id';
    END IF;
    
    -- For workout_templates
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_templates' AND column_name = 'user_id') THEN
        UPDATE workout_templates SET user_id = '00000000-0000-0000-0000-000000000000'::uuid WHERE user_id IS NULL;
        RAISE NOTICE 'Updated workout_templates with default user_id';
    END IF;
    
    -- For personal_records
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_records' AND column_name = 'user_id') THEN
        UPDATE personal_records SET user_id = '00000000-0000-0000-0000-000000000000'::uuid WHERE user_id IS NULL;
        RAISE NOTICE 'Updated personal_records with default user_id';
    END IF;
END $$;

-- Create indexes for better performance (only if they don't exist)
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_set_entries_user_id ON set_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_templates_user_id ON workout_templates(user_id);
CREATE INDEX IF NOT EXISTS idx_personal_records_user_id ON personal_records(user_id);

-- Enable Row Level Security (RLS) on all user-specific tables
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE set_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own workout sessions" ON workout_sessions;
DROP POLICY IF EXISTS "Users can insert own workout sessions" ON workout_sessions;
DROP POLICY IF EXISTS "Users can update own workout sessions" ON workout_sessions;
DROP POLICY IF EXISTS "Users can delete own workout sessions" ON workout_sessions;
DROP POLICY IF EXISTS "Admins can view all workout sessions" ON workout_sessions;

DROP POLICY IF EXISTS "Users can view own set entries" ON set_entries;
DROP POLICY IF EXISTS "Users can insert own set entries" ON set_entries;
DROP POLICY IF EXISTS "Users can update own set entries" ON set_entries;
DROP POLICY IF EXISTS "Users can delete own set entries" ON set_entries;
DROP POLICY IF EXISTS "Admins can view all set entries" ON set_entries;

DROP POLICY IF EXISTS "Users can view own workout templates" ON workout_templates;
DROP POLICY IF EXISTS "Users can insert own workout templates" ON workout_templates;
DROP POLICY IF EXISTS "Users can update own workout templates" ON workout_templates;
DROP POLICY IF EXISTS "Users can delete own workout templates" ON workout_templates;
DROP POLICY IF EXISTS "Admins can view all workout templates" ON workout_templates;

DROP POLICY IF EXISTS "Users can view own personal records" ON personal_records;
DROP POLICY IF EXISTS "Users can insert own personal records" ON personal_records;
DROP POLICY IF EXISTS "Users can update own personal records" ON personal_records;
DROP POLICY IF EXISTS "Users can delete own personal records" ON personal_records;
DROP POLICY IF EXISTS "Admins can view all personal records" ON personal_records;

-- Create RLS policies for user data isolation
-- Use proper UUID comparison (auth.uid() returns UUID, user_id is UUID)
CREATE POLICY "Users can view own workout sessions" ON workout_sessions
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own workout sessions" ON workout_sessions
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own workout sessions" ON workout_sessions
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete own workout sessions" ON workout_sessions
    FOR DELETE USING (user_id = auth.uid());

-- Set entries policies
CREATE POLICY "Users can view own set entries" ON set_entries
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own set entries" ON set_entries
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own set entries" ON set_entries
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete own set entries" ON set_entries
    FOR DELETE USING (user_id = auth.uid());

-- Workout templates policies
CREATE POLICY "Users can view own workout templates" ON workout_templates
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own workout templates" ON workout_templates
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own workout templates" ON workout_templates
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete own workout templates" ON workout_templates
    FOR DELETE USING (user_id = auth.uid());

-- Personal records policies
CREATE POLICY "Users can view own personal records" ON personal_records
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own personal records" ON personal_records
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own personal records" ON personal_records
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete own personal records" ON personal_records
    FOR DELETE USING (user_id = auth.uid());

-- Create admin function if it doesn't exist
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users 
    WHERE auth.users.id = auth.uid() 
    AND auth.users.raw_user_meta_data->>'role' = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Admin policies (for admin dashboard access)
CREATE POLICY "Admins can view all workout sessions" ON workout_sessions
    FOR SELECT USING (is_admin());

CREATE POLICY "Admins can view all set entries" ON set_entries
    FOR SELECT USING (is_admin());

CREATE POLICY "Admins can view all workout templates" ON workout_templates
    FOR SELECT USING (is_admin());

CREATE POLICY "Admins can view all personal records" ON personal_records
    FOR SELECT USING (is_admin());

-- Create a function to update user_id for existing data
CREATE OR REPLACE FUNCTION update_user_data_ownership()
RETURNS void AS $$
BEGIN
    -- Update workout sessions
    UPDATE workout_sessions 
    SET user_id = auth.uid() 
    WHERE user_id = '00000000-0000-0000-0000-000000000000'::uuid 
    AND auth.uid() IS NOT NULL;
    
    -- Update set entries
    UPDATE set_entries 
    SET user_id = auth.uid() 
    WHERE user_id = '00000000-0000-0000-0000-000000000000'::uuid 
    AND auth.uid() IS NOT NULL;
    
    -- Update workout templates
    UPDATE workout_templates 
    SET user_id = auth.uid() 
    WHERE user_id = '00000000-0000-0000-0000-000000000000'::uuid 
    AND auth.uid() IS NOT NULL;
    
    -- Update personal records
    UPDATE personal_records 
    SET user_id = auth.uid() 
    WHERE user_id = '00000000-0000-0000-0000-000000000000'::uuid 
    AND auth.uid() IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION update_user_data_ownership() TO authenticated;

-- Final verification
SELECT 
    'Migration completed successfully!' as status,
    COUNT(*) as total_workout_sessions,
    COUNT(CASE WHEN user_id IS NOT NULL THEN 1 END) as sessions_with_user_id,
    COUNT(CASE WHEN user_id = '00000000-0000-0000-0000-000000000000'::uuid THEN 1 END) as default_user_sessions
FROM workout_sessions;
