# 🚀 Multi-User Leaderboards - Quick Setup Checklist

## ✅ Step-by-Step Setup (5 minutes)

### 1️⃣ Run Supabase Migration
- [ ] Open Supabase Dashboard (https://app.supabase.com)
- [ ] Go to **SQL Editor**
- [ ] Click **"New Query"**
- [ ] Copy content of `supabase_leaderboard_schema.sql`
- [ ] Paste and click **"Run"**
- [ ] Wait for ✅ Success message

**Expected Output:**
```
Success. No rows returned
```

---

### 2️⃣ Clean Up Local Data
- [ ] Open GymAI app
- [ ] Go to **Settings**
- [ ] Scroll to **Maintenance** section
- [ ] Tap **"Clean Duplicate Stats"**
- [ ] Confirm ✅
- [ ] Wait for success message

**Expected:** "Cleaned up X duplicate entries!"

---

### 3️⃣ Refresh Stats
- [ ] Still in **Settings → Maintenance**
- [ ] Tap **"Refresh Leaderboard Stats"**
- [ ] Wait for loading dialog
- [ ] See success message with workout count

**Expected:** "✅ Stats refreshed! X workouts, Y kg volume"

---

### 4️⃣ Sync to Cloud
- [ ] Still in **Settings → Maintenance**
- [ ] Tap **"Sync to Supabase"**
- [ ] Wait for loading dialog
- [ ] See success message

**Expected:** "✅ Successfully synced to Supabase!"

---

### 5️⃣ Verify Leaderboards
- [ ] Go to **Social** tab
- [ ] Tap **Leaderboards**
- [ ] Check **Total Volume** tab
- [ ] Pull to refresh

**Expected in Console:**
```
🌐 Using Supabase leaderboard service (MULTI-USER)
📊 Supabase leaderboard result: X entries
```

---

## 🎯 You're Done! 

**What happens now:**
- ✅ Every workout automatically syncs to Supabase
- ✅ Leaderboards show real multi-user data
- ✅ Stats persist across devices
- ✅ Real-time competition

---

## 🧪 Test It (Optional)

### Test Automatic Sync:
1. [ ] Start a workout
2. [ ] Complete a few sets
3. [ ] Finish workout
4. [ ] Check console logs
5. [ ] Look for: "✅ Stats synced to Supabase"

### Test Leaderboards:
1. [ ] Open Leaderboards
2. [ ] Switch between tabs (Volume, Workouts, Streak, PRs)
3. [ ] Pull to refresh
4. [ ] Check console for "🌐 Using Supabase"

---

## 📊 Verify in Supabase

### Check Data in Supabase Dashboard:
1. [ ] Go to **Table Editor**
2. [ ] Find **user_stats** table
3. [ ] See your data with your `user_id`
4. [ ] Check columns: `total_workouts`, `total_volume`, `current_streak`

---

## 🚨 If Something Goes Wrong

### Leaderboard Shows "No Data"
1. ✅ Run Step 3 (Refresh Stats)
2. ✅ Run Step 4 (Sync to Supabase)
3. ✅ Pull to refresh Leaderboards

### Console Shows "local leaderboard service (SIMULATED)"
1. ✅ Check internet connection
2. ✅ Verify Supabase migration ran successfully
3. ✅ Run Step 4 (Sync to Supabase)

### Still Seeing Duplicate Entries
1. ✅ Run Step 2 (Clean Duplicate Stats) again
2. ✅ Tap **"Debug: Show User Stats"** to verify
3. ✅ Should only see 1 entry (your user)

---

## 📱 Daily Usage

**You don't need to do anything!** 🎉

- Workouts sync automatically ✅
- Leaderboards update in real-time ✅
- No manual steps required ✅

**Optional:** Manually sync anytime in Settings → "Sync to Supabase"

---

**Questions? Check `MULTI_USER_LEADERBOARDS_GUIDE.md` for details!**
