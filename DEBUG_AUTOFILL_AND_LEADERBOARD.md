# Debug Guide: Auto-Fill & Leaderboard Issues 🔍

## Auto-Fill Debug Process

I've added comprehensive logging to see exactly what's happening. 

### What to Do:

1. **Start a workout** with duration/distance exercise (e.g., Running, Cycling)
2. **Fill Set 1**: Enter Distance (M) and Time
3. **Complete Set 1** (checkmark it)
4. **Check the console** immediately

### What You Should See in Console:

```
🔄 Set 1 completed! Checking auto-fill...
  Updated set values: weight=null, reps=0, duration=1800, distance=30.0, assistance=null, added=null
  ✅ No other completed sets - AUTO-FILL TRIGGERED!
  📋 Checking set 2: weight=null, reps=0, duration=null, distance=null, completed=false
    hasWeight=false, hasReps=false, hasDuration=false, hasDistance=false, isEmpty=true
  ✅ Auto-filling set 2 with values from set 1
    Set 2 after auto-fill: weight=null, reps=0, duration=1800, distance=30.0
  📋 Checking set 3: weight=null, reps=0, duration=null, distance=null, completed=false
    hasWeight=false, hasReps=false, hasDuration=false, hasDistance=false, isEmpty=true
  ✅ Auto-filling set 3 with values from set 1
    Set 3 after auto-fill: weight=null, reps=0, duration=1800, distance=30.0
  📋 Checking set 4: weight=null, reps=0, duration=null, distance=null, completed=false
    hasWeight=false, hasReps=false, hasDuration=false, hasDistance=false, isEmpty=true
  ✅ Auto-filling set 4 with values from set 1
    Set 4 after auto-fill: weight=null, reps=0, duration=1800, distance=30.0
```

### If It's NOT Working:

**Share the EXACT console output** - it will show me:
- ✅ What values are being set
- ✅ Why sets are being skipped
- ✅ If the logic is even triggering

### Common Issues:

1. **Set 2 has default values** (reps=0, weight=0)
   - Console will show `hasReps=true` or `hasWeight=true`
   - Fix: Sets should start completely null

2. **Values not being passed**
   - Console will show `duration=null, distance=null` even after filling
   - This means the UI isn't updating the state correctly

3. **Auto-fill triggers but values don't show**
   - Console shows auto-fill happening
   - But UI doesn't update
   - This is a state refresh issue

---

## Leaderboard Debug Process

I fixed the provider invalidation issue.

### What to Do:

1. **Settings → Maintenance → Refresh Leaderboard Stats**
2. **Wait for success message**
3. **Open Social → Leaderboards**
4. **Check all 4 tabs**

### What You Should See in Console:

```
🔄 Refresh Leaderboard Stats button clicked
📊 Recalculating user stats...
  User ID: 25a4a3af-04dd-42e4-a108-ed47382473d2
  Found 23 completed workouts
  Total workouts: 23
  Total volume: 42966.0 kg
  Total sets: 450
  Current streak: 1 days
  ✅ User stats updated
✅ Stats recalculated: 23 workouts, 42966.0 kg
✅ Leaderboard service provider invalidated - all tabs will refresh
```

### When You Open Leaderboards:

```
🏆 Getting volume leaderboard...
  Found 0 users, 1 stats entries
  Stats: userId=25a4a3af-04dd-42e4-a108-ed47382473d2, volume=42966.0, workouts=23
  ✅ Adding entry: You - 42966.0 kg
  Total entries: 1
```

### If Still Showing UUIDs:

**Check console for:**
- Are users being found? `Found X users`
- Is email present? `user.email=your@email.com`
- What's the display name? `Adding entry: XXXXX`

**Possible Causes:**
1. **No user in database** → Shows "User #XXX"
2. **No email set** → Shows "User #XXX"
3. **Display name empty** → Falls back to email prefix

### If Not Clickable:

**Check:**
1. Are you tapping "You"? (Your own entry is NOT clickable)
2. Are there other users? (Need 2+ entries for clickability to matter)

**To test:**
- Tap any entry that is NOT "You"
- Console should show: `🔍 Navigating to profile: [userId]`
- Should navigate to profile screen

---

## Quick Tests

### Test 1: Auto-Fill with Duration
```
Exercise: Plank
Set 1: Duration = 60 seconds
Action: Complete Set 1
Expected: Sets 2, 3, 4 auto-fill with 60 seconds
```

### Test 2: Auto-Fill with Distance + Duration
```
Exercise: Running
Set 1: Distance = 5 km, Duration = 30 minutes
Action: Complete Set 1
Expected: Sets 2, 3, 4 auto-fill with 5 km, 30 minutes
```

### Test 3: Leaderboard User Names
```
Action: Refresh Stats → Open Leaderboards
Expected: See real names (or email prefixes), not "Athlete #XXX"
```

### Test 4: Click to Profile
```
Action: Tap any leaderboard entry (not "You")
Expected: Navigate to user profile with stats
```

---

## Report Back

**For Auto-Fill Issue:**
Share the console output from completing set 1, specifically:
- The "Set 1 completed!" line
- The "Updated set values" line
- All the "Checking set X" lines

**For Leaderboard Issue:**
1. What do you see on leaderboards? (User names or UUIDs?)
2. When you tap an entry, does it navigate?
3. Console output from refresh stats
4. Console output from opening leaderboards

This will tell me EXACTLY what's wrong! 🎯
