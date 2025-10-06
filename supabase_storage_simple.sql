-- =====================================================
-- SIMPLE Supabase Storage Setup (No Permission Errors)
-- =====================================================
-- This version works without needing table ownership
-- Run in Supabase SQL Editor
-- =====================================================

-- 1. Create buckets using Supabase Dashboard instead of SQL
-- Go to: Storage → Create bucket
-- Bucket name: post-images (make it PUBLIC)
-- Bucket name: avatars (make it PUBLIC)

-- 2. OR create buckets with INSERT (this should work)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('post-images', 'post-images', true, 52428800, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']),
  ('avatars', 'avatars', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- =====================================================
-- Verify buckets created
-- =====================================================
SELECT id, name, public, file_size_limit FROM storage.buckets;
