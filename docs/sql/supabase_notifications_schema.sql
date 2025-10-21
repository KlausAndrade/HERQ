-- =====================================================
-- Social Notifications Schema for Supabase
-- =====================================================
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('like', 'comment', 'follow', 'mention', 'reply')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  from_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  from_user_name TEXT,
  from_user_avatar TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id 
ON notifications(user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at 
ON notifications(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_is_read 
ON notifications(is_read);

-- 3. Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies

-- Users can only see their own notifications
CREATE POLICY "Users can view their own notifications" ON notifications
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- Users can only update their own notifications (mark as read)
CREATE POLICY "Users can update their own notifications" ON notifications
FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- System can insert notifications for any user
CREATE POLICY "Authenticated users can create notifications" ON notifications
FOR INSERT TO authenticated
WITH CHECK (true);

-- Users can delete their own notifications
CREATE POLICY "Users can delete their own notifications" ON notifications
FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- 5. Create function to automatically create notifications
CREATE OR REPLACE FUNCTION create_like_notification()
RETURNS TRIGGER AS $$
DECLARE
  post_owner_id UUID;
  liker_name TEXT;
  liker_avatar TEXT;
BEGIN
  -- Get post owner
  SELECT user_id INTO post_owner_id FROM posts WHERE id = NEW.post_id;
  
  -- Don't notify if user likes their own post
  IF post_owner_id = NEW.user_id THEN
    RETURN NEW;
  END IF;
  
  -- Get liker's profile info
  SELECT display_name, avatar_url INTO liker_name, liker_avatar
  FROM profiles WHERE id = NEW.user_id;
  
  -- Create notification
  INSERT INTO notifications (
    user_id,
    type,
    title,
    body,
    post_id,
    from_user_id,
    from_user_name,
    from_user_avatar
  ) VALUES (
    post_owner_id,
    'like',
    'New Like',
    COALESCE(liker_name, 'Someone') || ' liked your post',
    NEW.post_id,
    NEW.user_id,
    liker_name,
    liker_avatar
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Create trigger for likes
DROP TRIGGER IF EXISTS on_post_liked ON likes;
CREATE TRIGGER on_post_liked
  AFTER INSERT ON likes
  FOR EACH ROW
  EXECUTE FUNCTION create_like_notification();

-- 7. Create function for comment notifications
CREATE OR REPLACE FUNCTION create_comment_notification()
RETURNS TRIGGER AS $$
DECLARE
  post_owner_id UUID;
  commenter_name TEXT;
  commenter_avatar TEXT;
BEGIN
  -- Get post owner
  SELECT user_id INTO post_owner_id FROM posts WHERE id = NEW.post_id;
  
  -- Don't notify if user comments on their own post
  IF post_owner_id = NEW.user_id THEN
    RETURN NEW;
  END IF;
  
  -- Get commenter's profile info
  SELECT display_name, avatar_url INTO commenter_name, commenter_avatar
  FROM profiles WHERE id = NEW.user_id;
  
  -- Create notification
  INSERT INTO notifications (
    user_id,
    type,
    title,
    body,
    post_id,
    comment_id,
    from_user_id,
    from_user_name,
    from_user_avatar
  ) VALUES (
    post_owner_id,
    'comment',
    'New Comment',
    COALESCE(commenter_name, 'Someone') || ' commented on your post',
    NEW.post_id,
    NEW.id,
    NEW.user_id,
    commenter_name,
    commenter_avatar
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. Create trigger for comments
DROP TRIGGER IF EXISTS on_post_commented ON comments;
CREATE TRIGGER on_post_commented
  AFTER INSERT ON comments
  FOR EACH ROW
  EXECUTE FUNCTION create_comment_notification();

-- 9. Create function for follow notifications
CREATE OR REPLACE FUNCTION create_follow_notification()
RETURNS TRIGGER AS $$
DECLARE
  follower_name TEXT;
  follower_avatar TEXT;
BEGIN
  -- Get follower's profile info
  SELECT display_name, avatar_url INTO follower_name, follower_avatar
  FROM profiles WHERE id = NEW.follower_id;
  
  -- Create notification
  INSERT INTO notifications (
    user_id,
    type,
    title,
    body,
    from_user_id,
    from_user_name,
    from_user_avatar
  ) VALUES (
    NEW.following_id,
    'follow',
    'New Follower',
    COALESCE(follower_name, 'Someone') || ' started following you',
    NEW.follower_id,
    follower_name,
    follower_avatar
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 10. Create trigger for follows
DROP TRIGGER IF EXISTS on_user_followed ON follows;
CREATE TRIGGER on_user_followed
  AFTER INSERT ON follows
  FOR EACH ROW
  EXECUTE FUNCTION create_follow_notification();

-- =====================================================
-- Verification Queries
-- =====================================================

-- Check if table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_name = 'notifications'
);

-- Check policies
SELECT policyname, cmd
FROM pg_policies
WHERE tablename = 'notifications';

-- Check triggers
SELECT trigger_name, event_manipulation
FROM information_schema.triggers
WHERE event_object_table IN ('likes', 'comments', 'follows');

