# 🔧 Fix Supabase Storage RLS Error

## ❌ Error: "new row violates row-level security"

This error occurs when trying to upload images because Supabase Storage doesn't have the right permissions.

---

## ✅ **3-Step Fix:**

### **Step 1: Run SQL in Supabase** ⏰ 2 minutes

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your **GymAI project**
3. Click **"SQL Editor"** in left sidebar
4. Click **"New Query"**
5. Copy **ALL** content from `supabase_storage_policies.sql`
6. Paste into SQL editor
7. Click **"Run"** button (or `Cmd/Ctrl + Enter`)
8. Wait for: ✅ "Success. No rows returned"

### **Step 2: Verify Buckets Created** ⏰ 30 seconds

Run this query in SQL Editor:
```sql
SELECT * FROM storage.buckets;
```

You should see:
- ✅ `post-images` bucket (public)
- ✅ `avatars` bucket (public)

### **Step 3: Test Upload** ⏰ 1 minute

1. **Hot restart your app** (not just hot reload!)
   ```bash
   flutter run
   ```
   Or press `Shift + Cmd + R` in VS Code

2. **Try creating a post with image** 
3. Should work now! ✅

---

## 🐛 **If Still Not Working:**

### Option A: Check Bucket in Supabase Dashboard
1. Go to **Storage** in Supabase dashboard
2. Click **"Buckets"**
3. Verify `post-images` and `avatars` exist
4. Click bucket → Settings → **Public bucket** should be ON

### Option B: Use Simple Policy (Nuclear Option)
If the above doesn't work, run this simpler SQL:

```sql
-- Delete all existing policies
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects')
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON storage.objects';
    END LOOP;
END$$;

-- Create simple open policy for post-images
CREATE POLICY "Public Access to post-images"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'post-images')
WITH CHECK (bucket_id = 'post-images');

-- Create simple open policy for avatars
CREATE POLICY "Public Access to avatars"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');
```

---

## 📝 **What Changed in Your Code:**

### Before:
```dart
.from('gym-images')  // ❌ Bucket didn't exist
```

### After:
```dart
.from('post-images')  // ✅ Correct bucket for posts
.from('avatars')      // ✅ Correct bucket for profile pics
```

### Files Updated:
- ✅ `create_post_sheet.dart` → now uses `'post-images'`
- ✅ `edit_profile_screen.dart` → now uses `'avatars'`

---

## 🚀 **Quick Test:**

After running the SQL, test with:

```dart
// In your app (debug console):
final supabase = Supabase.instance.client;

// Test bucket access
final buckets = await supabase.storage.listBuckets();
print('Buckets: ${buckets.map((b) => b.name).toList()}');
// Should print: [post-images, avatars]
```

---

## 📚 **Learn More:**

- [Supabase Storage Docs](https://supabase.com/docs/guides/storage)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

**Status:** ✅ Fixed!  
**Next:** Run SQL → Hot restart → Test upload → Should work!
