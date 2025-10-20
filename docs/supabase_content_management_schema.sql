-- Enhanced Supabase Schema for Global Content Management
-- This allows you to manage exercise data remotely without app deployments

-- Content versioning table
CREATE TABLE IF NOT EXISTS content_versions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  version TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enhanced exercises table with versioning
CREATE TABLE IF NOT EXISTS exercises (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  primary_muscle_group TEXT NOT NULL,
  secondary_muscle_groups TEXT[] DEFAULT '{}',
  equipment TEXT NOT NULL,
  instructions TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  aliases TEXT[] DEFAULT '{}',
  is_bodyweight BOOLEAN DEFAULT FALSE,
  exercise_type TEXT DEFAULT 'weight_reps',
  category TEXT DEFAULT 'strength',
  difficulty TEXT DEFAULT 'intermediate',
  content_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enhanced workout templates table with versioning
CREATE TABLE IF NOT EXISTS workout_templates (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  folder_id TEXT,
  exercise_ids TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  category TEXT,
  estimated_duration_minutes INTEGER,
  is_default BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  content_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Admin users table for content management
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role TEXT DEFAULT 'content_manager',
  permissions TEXT[] DEFAULT '{"manage_exercises", "manage_templates"}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content management logs
CREATE TABLE IF NOT EXISTS content_management_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  admin_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  action TEXT NOT NULL, -- 'create', 'update', 'delete', 'bulk_import'
  entity_type TEXT NOT NULL, -- 'exercise', 'template'
  entity_id TEXT NOT NULL,
  changes JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_exercises_user_id ON exercises(user_id);
CREATE INDEX IF NOT EXISTS idx_exercises_category ON exercises(category);
CREATE INDEX IF NOT EXISTS idx_exercises_updated_at ON exercises(updated_at);
CREATE INDEX IF NOT EXISTS idx_templates_user_id ON workout_templates(user_id);
CREATE INDEX IF NOT EXISTS idx_templates_category ON workout_templates(category);
CREATE INDEX IF NOT EXISTS idx_templates_updated_at ON workout_templates(updated_at);

-- Row Level Security (RLS) policies
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_management_logs ENABLE ROW LEVEL SECURITY;

-- Policies for exercises
CREATE POLICY "Global exercises are viewable by everyone" ON exercises
  FOR SELECT USING (user_id IS NULL);

CREATE POLICY "Users can view their own exercises" ON exercises
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all exercises" ON exercises
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

CREATE POLICY "Users can manage their own exercises" ON exercises
  FOR ALL USING (auth.uid() = user_id);

-- Policies for templates
CREATE POLICY "Global templates are viewable by everyone" ON workout_templates
  FOR SELECT USING (user_id IS NULL);

CREATE POLICY "Users can view their own templates" ON workout_templates
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all templates" ON workout_templates
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

CREATE POLICY "Users can manage their own templates" ON workout_templates
  FOR ALL USING (auth.uid() = user_id);

-- Policies for admin users
CREATE POLICY "Only admins can view admin users" ON admin_users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

-- Policies for content management logs
CREATE POLICY "Admins can view all logs" ON content_management_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

CREATE POLICY "Admins can insert logs" ON content_management_logs
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

-- Functions for content management
CREATE OR REPLACE FUNCTION update_content_version()
RETURNS TRIGGER AS $$
BEGIN
  -- Update the content version when exercises or templates are modified
  INSERT INTO content_versions (version, description)
  VALUES (
    'v' || EXTRACT(EPOCH FROM NOW())::TEXT,
    'Auto-generated version from ' || TG_TABLE_NAME || ' update'
  )
  ON CONFLICT (version) DO NOTHING;
  
  -- Update the content_version field in the modified record
  NEW.content_version = 'v' || EXTRACT(EPOCH FROM NOW())::TEXT;
  NEW.updated_at = NOW();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for automatic versioning
CREATE TRIGGER exercises_version_trigger
  BEFORE UPDATE ON exercises
  FOR EACH ROW
  EXECUTE FUNCTION update_content_version();

CREATE TRIGGER templates_version_trigger
  BEFORE UPDATE ON workout_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_content_version();

-- Function to get latest content version
CREATE OR REPLACE FUNCTION get_latest_content_version()
RETURNS TEXT AS $$
BEGIN
  RETURN (
    SELECT version FROM content_versions 
    ORDER BY updated_at DESC 
    LIMIT 1
  );
END;
$$ LANGUAGE plpgsql;

-- Function to check if content needs updating
CREATE OR REPLACE FUNCTION content_needs_update(client_version TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT COUNT(*) > 0 FROM content_versions 
    WHERE version != client_version 
    OR updated_at > NOW() - INTERVAL '1 hour'
  );
END;
$$ LANGUAGE plpgsql;

-- Insert initial content version
INSERT INTO content_versions (version, description) 
VALUES ('v1.0.0', 'Initial content version')
ON CONFLICT (version) DO NOTHING;

-- Sample admin user (replace with your actual admin user ID)
-- INSERT INTO admin_users (id, role, permissions) 
-- VALUES ('your-admin-user-id', 'super_admin', '{"manage_exercises", "manage_templates", "manage_users"}')
-- ON CONFLICT (id) DO NOTHING;
