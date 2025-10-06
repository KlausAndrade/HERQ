# 🔧 Fix Storage Error - Dashboard Method (Easiest!)

## ❌ Error: "42501: must be owner of table objects"

This means you can't modify storage policies via SQL. **Use the Dashboard instead!**

---

## ✅ **Fix in 3 Minutes (No SQL Required):**

### **Step 1: Create Storage Buckets** ⏰ 1 min

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your **GymAI project**
3. Click **"Storage"** in left sidebar (bucket icon 🪣)
4. Click **"New bucket"** button

#### Create Bucket #1: post-images
- **Name:** `post-images`
- **Public bucket:** ✅ **Turn ON** (toggle to green)
- **File size limit:** 50 MB
- **Allowed MIME types:** (leave empty for all images)
- Click **"Create bucket"**

#### Create Bucket #2: avatars
- **Name:** `avatars`
- **Public bucket:** ✅ **Turn ON** (toggle to green)
- **File size limit:** 10 MB
- **Allowed MIME types:** (leave empty for all images)
- Click **"Create bucket"**

---

### **Step 2: Configure Bucket Policies** ⏰ 2 min

For **EACH bucket** (`post-images` and `avatars`):

1. Click on the bucket name
2. Click **"Policies"** tab at the top
3. Click **"New Policy"**
4. Click **"For full customization"**

#### Policy Configuration:

**Policy Name:** `Allow authenticated users to upload`

**Target roles:** `authenticated`

**Policy command:** `INSERT`

**Policy definition (USING):**
```sql
true
```

**WITH CHECK expression:**
```sql
true
```

5. Click **"Review"**
6. Click **"Save policy"**

#### Add Second Policy for Public Read:

1. Click **"New Policy"** again
2. **Policy Name:** `Allow public to read`
3. **Target roles:** `public`, `authenticated`
4. **Policy command:** `SELECT`
5. **USING expression:**
```sql
true
```
6. Click **"Save policy"**

#### Add Third Policy for Delete (Own Files):

1. Click **"New Policy"** again
2. **Policy Name:** `Allow users to delete own files`
3. **Target roles:** `authenticated`
4. **Policy command:** `DELETE`
5. **USING expression:**
```sql
(auth.uid())::text = (storage.foldername(name))[1]
```
6. Click **"Save policy"**

**Repeat for BOTH buckets!**

---

### **Step 3: Test It!** ⏰ 30 sec

1. **Hot restart your app** (not just reload)
   ```bash
   # In VS Code: Shift + Cmd + R
   # Or terminal:
   flutter run
   ```

2. **Try creating a post with an image**
3. Should work! ✅

---

## 🎯 **Visual Guide:**

```
Supabase Dashboard
  ↓
Storage (left sidebar)
  ↓
New Bucket
  ↓
Name: post-images
Public: ON ✅
  ↓
Click bucket → Policies
  ↓
New Policy → Full customization
  ↓
Set INSERT, SELECT, DELETE policies
  ↓
Repeat for "avatars" bucket
  ↓
Done! ✅
```

---

## 🚨 **Even Simpler Option:**

If the above is too complicated, just make the buckets **completely public**:

### Quick Public Setup:

1. **Create buckets** (post-images, avatars)
2. **Make them public** (toggle ON)
3. **Policies tab** → Click **"Add policy from template"**
4. Select: **"Enable read access for all users"**
5. Click **"Use this template"**
6. Select: **"Enable insert access for authenticated users"**
7. Click **"Use this template"**
8. Done! ✅

This is less secure but will work immediately.

---

## ✅ **Verification:**

After setup, you should see in Supabase Storage:

```
📦 Buckets
  📁 post-images (public)
     🔐 Policies: 3
  📁 avatars (public)
     🔐 Policies: 3
```

---

## 🐛 **Still Not Working?**

### Nuclear Option (Public Everything):

1. Go to bucket settings
2. **Public bucket:** ON ✅
3. Policies → Delete all policies
4. Add ONE policy:
   - Name: "Public Access"
   - Target: `public`, `authenticated`
   - Command: `ALL`
   - USING: `true`
   - WITH CHECK: `true`

This makes everything public (not recommended for production but fine for testing).

---

## 📝 **What's Happening:**

- **Before:** No buckets → RLS blocks uploads
- **After:** Buckets exist with public access → Uploads work! ✅

---

**Next:** Go to Supabase Dashboard → Storage → Create buckets → Set policies → Hot restart app → Test! 🚀

**Estimated Time:** 3 minutes
**Difficulty:** Easy (just clicking buttons)
