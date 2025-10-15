-- =====================================================
-- Supabase Storage Policies for Post Images
-- =====================================================
-- Run this in your Supabase SQL Editor to fix the 
-- "new row violates row-level security" error
-- =====================================================

-- 1. Create the storage bucket for post images (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('post-images', 'post-images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Enable RLS on the storage.objects table (should already be enabled)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 3. Drop existing policies (if any) to start fresh
DROP POLICY IF EXISTS "Allow authenticated users to upload post images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public to view post images" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to update their own post images" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to delete their own post images" ON storage.objects;

-- 4. CREATE POLICY: Allow authenticated users to UPLOAD images
CREATE POLICY "Allow authenticated users to upload post images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'post-images'
);

-- 5. CREATE POLICY: Allow PUBLIC to VIEW/READ images
CREATE POLICY "Allow public to view post images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'post-images');

-- 6. CREATE POLICY: Allow users to UPDATE their own images
CREATE POLICY "Allow users to update their own post images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'post-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'post-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 7. CREATE POLICY: Allow users to DELETE their own images
CREATE POLICY "Allow users to delete their own post images"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'post-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================================
-- Verification Queries
-- =====================================================

-- Check if bucket exists
SELECT * FROM storage.buckets WHERE id = 'post-images';

-- Check RLS policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%post images%';

-- =====================================================
-- Alternative: More Permissive Policies (If Above Doesn't Work)
-- =====================================================

-- If the above policies are too restrictive, use these instead:

-- DROP POLICY IF EXISTS "Public Access" ON storage.objects;
-- DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;

-- CREATE POLICY "Public Access"
-- ON storage.objects
-- FOR ALL
-- TO public
-- USING (bucket_id = 'post-images');

-- CREATE POLICY "Authenticated Upload"
-- ON storage.objects
-- FOR INSERT
-- TO authenticated
-- WITH CHECK (bucket_id = 'post-images');

-- =====================================================
-- Profile Images Bucket (Bonus)
-- =====================================================

-- Create bucket for profile avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Avatar upload policy
CREATE POLICY "Users can upload their own avatar"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Public can view avatars
CREATE POLICY "Anyone can view avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Users can update their own avatar
CREATE POLICY "Users can update their own avatar"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete their own avatar
CREATE POLICY "Users can delete their own avatar"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================================
-- CORS Configuration (Do in Supabase Dashboard)
-- =====================================================
-- Go to: Storage → Configuration → CORS
-- Add allowed origins:
-- - http://localhost:* (for local development)
-- - https://yourdomain.com (for production)
-- 
-- Or use SQL:
-- UPDATE storage.buckets 
-- SET allowed_mime_types = ARRAY[
--   'image/jpeg',
--   'image/png', 
--   'image/gif',
--   'image/webp'
-- ]
-- WHERE id IN ('post-images', 'avatars');

-- =====================================================
-- Test Upload (Optional)
-- =====================================================
-- After applying policies, test in your app with:
-- 
-- final file = File('path/to/image.jpg');
-- await supabase.storage
--   .from('post-images')
--   .upload('${userId}/test.jpg', file);
