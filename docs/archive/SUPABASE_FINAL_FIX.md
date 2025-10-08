# ✅ FINAL FIX - Supabase Storage Policies

## 🎯 What You Need to Do:

### **Create These Policies in Supabase Dashboard:**

Go to: **Storage** → Click bucket (`post-images` or `avatars`) → **Policies** tab

---

## 📋 **For BOTH Buckets (post-images AND avatars):**

### **Policy 1: Allow Authenticated Upload**

```sql
CREATE POLICY "Allow authenticated upload"
ON storage.objects
FOR INSERT
TO authenticated
USING (bucket_id = 'post-images');
-- Change 'post-images' to 'avatars' for avatars bucket
```

**OR** in Dashboard UI:
- Policy name: `Allow authenticated upload`
- Target roles: `authenticated`
- Policy command: `INSERT`
- USING expression: `bucket_id = 'post-images'`

---

### **Policy 2: Allow Public Read**

```sql
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'post-images');
-- Change 'post-images' to 'avatars' for avatars bucket
```

**OR** in Dashboard UI:
- Policy name: `Allow public read`
- Target roles: `public`
- Policy command: `SELECT`
- USING expression: `bucket_id = 'post-images'`

---

### **Policy 3: Allow Users to Delete Own Files**

```sql
CREATE POLICY "Allow users to delete own files"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'post-images' 
  AND (auth.uid())::text = (storage.foldername(name))[1]
);
-- Change 'post-images' to 'avatars' for avatars bucket
```

**OR** in Dashboard UI:
- Policy name: `Allow users to delete own files`
- Target roles: `authenticated`
- Policy command: `DELETE`
- USING expression: 
  ```sql
  bucket_id = 'post-images' AND (auth.uid())::text = (storage.foldername(name))[1]
  ```

---

## 📁 **File Structure (After Code Fix):**

```
post-images/
  └── USER_ID_1/
      ├── 1696600000000.jpg
      └── 1696600001000.jpg
  └── USER_ID_2/
      ├── 1696600002000.jpg
      └── 1696600003000.jpg

avatars/
  └── USER_ID_1/
      └── avatar_1696600000000.jpg
  └── USER_ID_2/
      └── avatar_1696600001000.jpg
```

The policy checks: **First folder name** (`USER_ID`) === **Logged-in user's ID**

---

## ✅ **What I Fixed in Your Code:**

### **Before (WRONG):**
```dart
// ❌ Path: posts/USER_ID_timestamp.jpg
final path = 'posts/$fileName';
```

### **After (CORRECT):**
```dart
// ✅ Path: USER_ID/timestamp.jpg
final path = '${currentUser.id}/$fileName';
```

Now the RLS policy works because:
- File path: `abc123/1696600000000.jpg`
- Policy extracts: `(storage.foldername(name))[1]` = `abc123`
- Compares with: `auth.uid()` = `abc123`
- Match! ✅ User can delete

---

## 🔄 **Also Added:**

When you delete a post, it now:
1. ✅ Deletes from database
2. ✅ **Deletes image from storage** (NEW!)

Before, images stayed in storage even after post deletion.

---

## 🚀 **Next Steps:**

1. **Create the 3 policies** for BOTH buckets (use Dashboard UI)
2. **Hot restart your app:**
   ```bash
   flutter run
   ```
3. **Test:**
   - Upload a post with image ✅
   - Delete the post ✅
   - Image should be removed from storage too ✅

---

## 🐛 **Troubleshooting:**

### If upload still fails:
```sql
-- Nuclear option: Allow everything
CREATE POLICY "Public access"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'post-images');
```

### Check file uploaded correctly:
1. Supabase Dashboard → Storage → post-images
2. You should see folders named after user IDs
3. Inside: timestamp.jpg files

---

**Status:** ✅ Code fixed, policies ready to apply!
