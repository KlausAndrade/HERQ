# 🧪 Supabase Migration Testing Checklist

## ✅ Pre-Testing Setup

### 1. Verify Supabase Configuration
- [ ] `.env` file has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- [ ] Database schema is applied (run `supabase_schema_verification.sql`)
- [ ] Storage bucket `gym-images` is created and public
- [ ] OAuth providers are configured (Facebook, Google, Apple)

### 2. Database Schema Verification
```sql
-- Run in Supabase SQL Editor
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'posts', 'comments', 'likes', 'follows');
```
Expected: All 5 tables should exist

---

## 🔐 Authentication Testing

### Email/Password Authentication
- [ ] **Sign Up**: Create new account with email/password
- [ ] **Verify**: Profile is auto-created in `profiles` table
- [ ] **Sign In**: Log in with created credentials
- [ ] **Sign Out**: Successfully log out

### OAuth Authentication (Facebook)
- [ ] **Facebook Login**: Click Facebook button, authorize app
- [ ] **Profile Creation**: Verify profile created with Facebook data
- [ ] **Avatar**: Check if Facebook avatar is imported

### OAuth Authentication (Google - Optional)
- [ ] **Google Login**: Click Google button, authorize app
- [ ] **Profile Creation**: Verify profile created with Google data

---

## 👤 Profile Management

### View Profile
- [ ] Navigate to own profile (click avatar or user icon)
- [ ] Profile displays: avatar, display name, bio
- [ ] Shows correct follower/following counts
- [ ] Shows user's posts

### Edit Profile
- [ ] Click "Edit" icon in profile screen
- [ ] **Update Display Name**: Change name, save successfully
- [ ] **Update Bio**: Add/edit bio, save successfully
- [ ] **Upload Avatar**: Select image from gallery, save successfully
- [ ] **Verify**: Changes appear immediately in profile
- [ ] **Verify**: Changes appear in posts (username, avatar)

### Profile Completion
- [ ] New user sees "Complete your profile" banner
- [ ] Click "Edit" button opens edit profile screen
- [ ] After completing profile, banner disappears

---

## 📝 Post Management

### Create Post
- [ ] Click FAB (floating action button) in social feed
- [ ] **Text Only**: Create post with caption only
- [ ] **Image Only**: Create post with image only
- [ ] **Text + Image**: Create post with both
- [ ] **Verify**: Post appears in feed immediately
- [ ] **Verify**: Post appears in Explore tab
- [ ] **Verify**: Post appears in user profile

### Image Upload
- [ ] Select image from gallery
- [ ] Image preview shows correctly
- [ ] Image uploads to Supabase Storage (`gym-images/posts/`)
- [ ] Image displays correctly in post
- [ ] **Cross-platform**: Test on Web browser (if applicable)

### Delete Post
- [ ] Click three dots on own post
- [ ] Select "Delete"
- [ ] Confirm deletion
- [ ] **Verify**: Post removed from feed
- [ ] **Verify**: Post removed from profile

---

## 💬 Interactions

### Like/Unlike Posts
- [ ] Click heart icon on a post
- [ ] **Verify**: Heart fills in, count increases
- [ ] Click heart again to unlike
- [ ] **Verify**: Heart empties, count decreases
- [ ] **Verify**: Like state persists after refresh

### Comments
- [ ] Click comment icon on a post
- [ ] Add a comment, submit
- [ ] **Verify**: Comment appears in list with your name
- [ ] **Verify**: Comment count increases on post
- [ ] Delete own comment
- [ ] **Verify**: Comment removed, count decreases

### Follow/Unfollow
- [ ] Search for another user
- [ ] Click "Follow" button
- [ ] **Verify**: Button changes to "Following"
- [ ] **Verify**: User's posts appear in Feed tab
- [ ] **Verify**: Follower count increases on their profile
- [ ] Click "Following" to unfollow
- [ ] **Verify**: User's posts disappear from Feed

---

## 🔍 Search & Discovery

### User Search
- [ ] Click search icon in social feed
- [ ] Type username in search box
- [ ] **Verify**: Matching users appear
- [ ] Click on a user to view their profile
- [ ] **Verify**: Can follow from search results

### Explore Tab
- [ ] Switch to Explore tab
- [ ] **Verify**: Shows all recent posts (not just followed users)
- [ ] **Verify**: Can like and comment on posts
- [ ] Click on post to view comments

---

## 📊 Profile Stats

### Followers/Following
- [ ] Click on "Followers" count
- [ ] **Verify**: Opens followers list
- [ ] **Verify**: Shows correct users
- [ ] Click on "Following" count
- [ ] **Verify**: Opens following list
- [ ] **Verify**: Can unfollow from this list

### Posts Count
- [ ] **Verify**: Posts count matches actual posts
- [ ] Create new post
- [ ] **Verify**: Count increments

---

## 🔄 Real-time Updates

### Manual Refresh
- [ ] Pull to refresh on feed
- [ ] **Verify**: New posts appear
- [ ] Pull to refresh on profile
- [ ] **Verify**: Updated data loads

### Navigation
- [ ] Navigate from feed → profile → comments → back
- [ ] **Verify**: No data loss or errors
- [ ] **Verify**: State is preserved correctly

---

## ⚠️ Error Handling

### Network Errors
- [ ] Turn off internet
- [ ] Try to create post
- [ ] **Verify**: Error message shows
- [ ] Try to load feed
- [ ] **Verify**: Error state displays

### Validation
- [ ] Try to create post without caption or image
- [ ] **Verify**: Error message shows
- [ ] Try to save empty display name in edit profile
- [ ] **Verify**: Validation error shows

### Edge Cases
- [ ] View profile of user with no posts
- [ ] **Verify**: "No posts yet" message shows
- [ ] View post with no comments
- [ ] **Verify**: "No comments yet" message shows

---

## 🚀 Performance

### Image Loading
- [ ] Scroll through feed with many images
- [ ] **Verify**: Images load smoothly
- [ ] **Verify**: No memory leaks or crashes

### Large Lists
- [ ] View profile with many posts
- [ ] **Verify**: Scrolling is smooth
- [ ] View user with many followers
- [ ] **Verify**: List loads and scrolls smoothly

---

## 🔐 Security (Row Level Security)

### Permissions
- [ ] **Verify**: Can only delete own posts
- [ ] **Verify**: Can only delete own comments
- [ ] **Verify**: Can only edit own profile
- [ ] **Verify**: Can view all public profiles
- [ ] **Verify**: Cannot access posts table directly without auth

---

## 📱 Cross-Platform (if applicable)

### Web
- [ ] All features work on web browser
- [ ] Image upload works (uses File API)
- [ ] OAuth redirect works correctly

### Mobile (iOS/Android)
- [ ] All features work on mobile
- [ ] Image picker works
- [ ] Native feel and performance

---

## ✅ Final Checks

- [ ] No compile errors
- [ ] No runtime errors in console
- [ ] All user flows work end-to-end
- [ ] Data persists after app restart
- [ ] Sign out and sign in maintains data
- [ ] Profile images display correctly everywhere

---

## 🐛 Known Issues

### To Monitor:
- [ ] Check Supabase dashboard for error logs
- [ ] Monitor storage usage for uploaded images
- [ ] Check RLS policies are working (in Supabase logs)

### Report Issues:
If you find any bugs, note them here with:
- **What happened**: Description
- **Expected**: What should happen
- **Steps to reproduce**: 1, 2, 3...
- **Error message**: Any error shown

---

## 📈 Success Criteria

✅ All checkboxes above are completed without errors
✅ App is stable and performant
✅ Data is properly stored in Supabase
✅ Users can complete full social workflow: sign up → edit profile → create posts → interact

---

**Last Updated**: October 6, 2025
**Tester**: _____________
**Date Tested**: _____________
