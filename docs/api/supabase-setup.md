# ☁️ Supabase Setup Guide

> **Last Updated:** October 8, 2025  
> **Required for:** Cloud sync, auth, social features, AI coaching

This guide walks you through setting up Supabase as the backend for GymAI.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Create Supabase Project](#create-supabase-project)
3. [Database Setup](#database-setup)
4. [Storage Setup](#storage-setup)
5. [Authentication](#authentication)
6. [Row Level Security](#row-level-security)
7. [Environment Configuration](#environment-configuration)
8. [Verification](#verification)

---

## 🌐 Overview

### What is Supabase?

Supabase is an open-source Firebase alternative providing:
- **PostgreSQL Database**: Relational database with full SQL support
- **Authentication**: Email, OAuth (Google, Apple, Facebook, GitHub)
- **Storage**: File storage with CDN
- **Real-time**: Live data subscriptions
- **Row Level Security**: PostgreSQL RLS for data protection

### Why Supabase for GymAI?

- ✅ **Offline-first compatible**: Works with local SQLite sync
- ✅ **PostgreSQL**: Powerful queries and relationships
- ✅ **Built-in auth**: No custom auth server needed
- ✅ **File storage**: Profile pictures, workout images
- ✅ **Real-time**: Live social feed updates
- ✅ **Free tier**: Generous limits for development

---

## 🚀 Create Supabase Project

### 1. Sign Up

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with GitHub (recommended) or email

### 2. Create New Project

1. Click "New Project"
2. Fill in details:
   - **Name**: `gymai-dev` (or your preferred name)
   - **Database Password**: Generate a strong password (save it!)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Free tier is sufficient for development

3. Click "Create new project"
4. Wait ~2 minutes for provisioning

### 3. Get API Credentials

1. Go to **Settings** → **API**
2. Copy these values:
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon/public key**: `eyJhbG...` (long JWT token)
   - **service_role key**: Only use server-side (don't expose!)

3. Add to your `.env` file:
   ```env
   SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbG...your-anon-key
   ```

---

## 🗄️ Database Setup

### Schema Overview

GymAI uses these main tables:
- `profiles` - User profiles
- `workout_sessions` - Completed workouts
- `set_entries` - Individual sets
- `exercises` - Exercise library
- `posts` - Social posts
- `comments` - Post comments
- `likes` - Post likes
- `follows` - User relationships
- `achievements` - User badges

### Run Migrations

#### Option 1: SQL Editor (Recommended)

1. Go to **SQL Editor** in Supabase dashboard
2. Click "New Query"
3. Copy and paste migration SQL (see below)
4. Click "Run"

#### Option 2: Migration Files

```bash
# Use Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

### Migration SQL

Create a new SQL query with this schema:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  display_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  settings JSONB DEFAULT '{}'::jsonb
);

-- Exercises table
CREATE TABLE public.exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  type TEXT NOT NULL,
  difficulty TEXT,
  equipment TEXT[],
  primary_muscles TEXT[],
  secondary_muscles TEXT[],
  instructions TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workout sessions table
CREATE TABLE public.workout_sessions (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  total_duration_seconds INTEGER,
  total_volume DOUBLE PRECISION DEFAULT 0,
  total_sets INTEGER DEFAULT 0,
  total_reps INTEGER DEFAULT 0,
  notes TEXT,
  template_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Set entries table
CREATE TABLE public.set_entries (
  id TEXT PRIMARY KEY,
  workout_session_id TEXT REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
  exercise_id TEXT REFERENCES public.exercises(id),
  set_number INTEGER NOT NULL,
  weight DOUBLE PRECISION,
  reps INTEGER NOT NULL,
  rpe INTEGER,
  is_warmup BOOLEAN DEFAULT FALSE,
  is_completed BOOLEAN DEFAULT TRUE,
  rest_duration_seconds INTEGER,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Posts table
CREATE TABLE public.posts (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT,
  image_urls TEXT[],
  workout_session_id TEXT REFERENCES public.workout_sessions(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Comments table
CREATE TABLE public.comments (
  id TEXT PRIMARY KEY,
  post_id TEXT REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Likes table
CREATE TABLE public.likes (
  id TEXT PRIMARY KEY,
  post_id TEXT REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Follows table
CREATE TABLE public.follows (
  follower_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  following_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id != following_id)
);

-- Achievements table
CREATE TABLE public.achievements (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  achievement_type TEXT NOT NULL,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, achievement_type)
);

-- Create indexes for performance
CREATE INDEX idx_workout_sessions_user_id ON public.workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_completed_at ON public.workout_sessions(completed_at DESC);
CREATE INDEX idx_set_entries_workout_session_id ON public.set_entries(workout_session_id);
CREATE INDEX idx_posts_user_id ON public.posts(user_id);
CREATE INDEX idx_posts_created_at ON public.posts(created_at DESC);
CREATE INDEX idx_comments_post_id ON public.comments(post_id);
CREATE INDEX idx_likes_post_id ON public.likes(post_id);
CREATE INDEX idx_follows_follower_id ON public.follows(follower_id);
CREATE INDEX idx_follows_following_id ON public.follows(following_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_sessions_updated_at BEFORE UPDATE ON public.workout_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON public.posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

## 📦 Storage Setup

### Create Storage Bucket

1. Go to **Storage** in Supabase dashboard
2. Click "New bucket"
3. Name: `gym-images`
4. Public bucket: **Yes** (for profile pictures and posts)
5. Click "Create bucket"

### Configure CORS (for Web)

1. Go to **Storage** → **Policies**
2. Add CORS policy:

```sql
-- Allow CORS for gym-images bucket
INSERT INTO storage.cors (bucket_id, origin, methods)
VALUES (
  'gym-images',
  '*',
  ARRAY['GET', 'POST', 'PUT', 'DELETE']
);
```

### Storage Policies

```sql
-- Allow authenticated users to upload images
CREATE POLICY "Users can upload own images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'gym-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow public read access
CREATE POLICY "Public can view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'gym-images');

-- Allow users to delete own images
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'gym-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
```

---

## 🔐 Authentication

### Enable Auth Providers

1. Go to **Authentication** → **Providers**
2. Enable providers you want:

#### Email/Password
- Already enabled by default
- Configure email templates in **Email Templates**

#### Google OAuth
1. Enable Google provider
2. Get OAuth credentials from [Google Cloud Console](https://console.cloud.google.com)
3. Add Client ID and Client Secret

#### Apple Sign In
1. Enable Apple provider
2. Get credentials from [Apple Developer](https://developer.apple.com)
3. Configure Service ID and Team ID

#### Facebook Login
1. Enable Facebook provider
2. Get App ID and Secret from [Facebook Developers](https://developers.facebook.com)

### Auth Settings

1. Go to **Authentication** → **Settings**
2. Configure:
   - **Site URL**: Your app URL (for redirects)
   - **Redirect URLs**: Add allowed redirect URLs
   - **JWT expiry**: Default 3600s (1 hour)
   - **Refresh token rotation**: Enabled

---

## 🔒 Row Level Security (RLS)

### Enable RLS

```sql
-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.set_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
```

### RLS Policies

```sql
-- Profiles: Users can view all, edit own
CREATE POLICY "Public profiles are viewable by everyone"
ON public.profiles FOR SELECT
TO public
USING (true);

CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- Workout Sessions: Users can only see own workouts
CREATE POLICY "Users can view own workout sessions"
ON public.workout_sessions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workout sessions"
ON public.workout_sessions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workout sessions"
ON public.workout_sessions FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own workout sessions"
ON public.workout_sessions FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Set Entries: Inherit from workout session
CREATE POLICY "Users can view own sets"
ON public.set_entries FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.workout_sessions
    WHERE id = workout_session_id AND user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert own sets"
ON public.set_entries FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.workout_sessions
    WHERE id = workout_session_id AND user_id = auth.uid()
  )
);

-- Posts: Public or friends-only based on privacy
CREATE POLICY "Posts are viewable by friends or public"
ON public.posts FOR SELECT
TO authenticated
USING (
  user_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM public.follows
    WHERE follower_id = auth.uid() AND following_id = user_id
  )
);

CREATE POLICY "Users can create own posts"
ON public.posts FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
ON public.posts FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
ON public.posts FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Comments: Anyone can read, authenticated can create
CREATE POLICY "Comments are viewable by everyone"
ON public.comments FOR SELECT
TO public
USING (true);

CREATE POLICY "Authenticated users can create comments"
ON public.comments FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
ON public.comments FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Likes: Similar to comments
CREATE POLICY "Likes are viewable by everyone"
ON public.likes FOR SELECT
TO public
USING (true);

CREATE POLICY "Authenticated users can like posts"
ON public.likes FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike posts"
ON public.likes FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Follows: Users can follow anyone, view all
CREATE POLICY "Follows are viewable by everyone"
ON public.follows FOR SELECT
TO public
USING (true);

CREATE POLICY "Users can follow others"
ON public.follows FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can unfollow"
ON public.follows FOR DELETE
TO authenticated
USING (auth.uid() = follower_id);
```

---

## ⚙️ Environment Configuration

Add to your `.env` file:

```env
# Supabase Configuration
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Optional: For server-side operations only
# NEVER expose this in client code!
# SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

---

## ✅ Verification

### Test Database Connection

```dart
// In your app
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testSupabaseConnection() async {
  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .limit(1);
    
    print('✅ Supabase connection successful!');
    print('Response: $response');
  } catch (e) {
    print('❌ Supabase connection failed: $e');
  }
}
```

### Test Authentication

```dart
// Test sign up
final response = await Supabase.instance.client.auth.signUp(
  email: 'test@example.com',
  password: 'testpassword123',
);

if (response.user != null) {
  print('✅ Authentication working!');
}
```

### Test Storage

```dart
// Test image upload
final bytes = await File('test.jpg').readAsBytes();

final path = await Supabase.instance.client.storage
    .from('gym-images')
    .uploadBinary(
      '${auth.currentUser!.id}/test.jpg',
      bytes,
    );

print('✅ Storage upload successful! Path: $path');
```

---

## 🚨 Common Issues

### Issue: "Invalid API key"
- Verify `SUPABASE_ANON_KEY` is correct
- Check for extra spaces or newlines
- Ensure key is the **anon key**, not service_role

### Issue: "Table does not exist"
- Run migrations in SQL Editor
- Check table names are lowercase
- Verify schema is `public`

### Issue: "RLS policy denying access"
- Check RLS policies are created
- Verify user is authenticated
- Test with RLS disabled temporarily:
  ```sql
  ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;
  ```

### Issue: "CORS error on web"
- Add your domain to allowed origins
- Configure CORS in Storage settings
- Check Supabase project settings

---

## 📚 Next Steps

- [Groq AI Setup](groq-ai-setup.md) - Configure AI coaching
- [Development Setup](../developer/setup.md) - Complete dev environment
- [Database Guide](../developer/database.md) - Learn about the schema

---

## 🔗 Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)

---

**Need help?** Join the [Supabase Discord](https://discord.supabase.com) or check the [community forum](https://github.com/supabase/supabase/discussions).

