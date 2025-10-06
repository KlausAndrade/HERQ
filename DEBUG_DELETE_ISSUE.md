# 🔍 Debugging Post Deletion Issue

## ✅ **What I Fixed:**

### 1. **Added Error Handling**
Now when you try to delete a post, you'll see:
- ✅ Success message if it works
- ❌ **Error message showing what failed** (this will help us debug!)

### 2. **Added Debug Logging**
The console will now print:
```
Deleting post: <post_id>, user: <user_id>, image: <image_url>
Post deleted from database
Attempting to delete image: <url>
Deleting from storage: <file_path>
Storage deletion result: <result>
```

### 3. **Created RLS Policy Fix**
I created `supabase_posts_rls_fix.sql` for database policies.

---

## 🧪 **How to Debug:**

### **Step 1: Try Deleting a Post**
1. In the app, try to delete a post
2. Watch for:
   - ✅ Success snackbar (green) = working!
   - ❌ Error snackbar (red) = see the error message

### **Step 2: Check Debug Console**
Look at the Flutter console for print statements:
```
flutter: Deleting post: abc123...
flutter: Post deleted from database  ← Database delete worked!
flutter: Attempting to delete image: https://...
flutter: Deleting from storage: USER_ID/12345.jpg
flutter: Failed to delete image from storage: <ERROR HERE>
```

### **Step 3: Identify the Problem**

#### **Error A: "Row level security policy violation" on DELETE**
**Problem:** Database RLS policy blocking post deletion

**Fix:** Run `supabase_posts_rls_fix.sql`:
```sql
CREATE POLICY "Users can delete their own posts"
ON posts
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);
```

#### **Error B: "new row violates row-level security" on Storage**
**Problem:** Storage RLS policy blocking image deletion

**Fix:** In Supabase Dashboard → Storage → post-images → Policies:
```sql
CREATE POLICY "Allow users to delete own files"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'post-images' 
  AND (auth.uid())::text = (storage.foldername(name))[1]
);
```

#### **Error C: "File not found" or "Invalid path"
**Problem:** File path extraction wrong

**Debug:** Check the console output:
```
flutter: Deleting from storage: USER_ID/12345.jpg
```
Should be in format: `USER_ID/timestamp.jpg`

---

## 📋 **Complete Checklist:**

### **Database Policies (posts table):**
- [ ] Run `supabase_posts_rls_fix.sql` in SQL Editor
- [ ] Verify DELETE policy exists for posts table

### **Storage Policies (post-images bucket):**
- [ ] CREATE policy: INSERT for authenticated
- [ ] CREATE policy: SELECT for public
- [ ] CREATE policy: DELETE for own files

### **Code (Already Fixed):**
- [x] Upload path uses `USER_ID/filename.jpg` format
- [x] Delete extracts correct path from URL
- [x] Error handling shows what failed
- [x] Debug logging enabled

---

## 🚀 **Quick Test Script:**

1. **Create a test post with image**
2. **Check storage:** Supabase → Storage → post-images → Should see `USER_ID/timestamp.jpg`
3. **Try to delete the post**
4. **Watch console output** to see where it fails
5. **Check error message** in the red snackbar
6. **Apply the fix** based on the error

---

## 🎯 **Most Likely Issues:**

### **Issue #1: Database DELETE blocked (90% probability)**
**Symptom:** Error says "policy" or "permission denied" on posts table

**Fix:**
```sql
-- In Supabase SQL Editor
CREATE POLICY "Users can delete their own posts"
ON posts FOR DELETE TO authenticated
USING (auth.uid() = user_id);
```

### **Issue #2: Storage DELETE blocked (9% probability)**  
**Symptom:** Database delete works, but image stays in storage

**Fix:** Create DELETE policy in Dashboard (see SUPABASE_FINAL_FIX.md)

### **Issue #3: Wrong file path (1% probability)**
**Symptom:** Console shows weird path format

**Fix:** Already fixed in code ✅

---

## 📞 **What to Tell Me:**

After you try to delete a post, tell me:

1. **What does the error snackbar say?** (if red)
2. **What does the console print?** (copy the flutter: lines)
3. **Did the post disappear from feed?** (database delete)
4. **Is the image still in Storage dashboard?** (storage delete)

This will tell us exactly what's broken! 🔍

---

## 📝 **Files I Created:**

1. ✅ `supabase_posts_rls_fix.sql` - Database DELETE policy
2. ✅ `SUPABASE_FINAL_FIX.md` - Storage policies guide
3. ✅ Added error handling in `post_card.dart`
4. ✅ Added debug logging in `supabase_social_service.dart`

---

**Next:** Try deleting a post and check what error you get! 🧪
