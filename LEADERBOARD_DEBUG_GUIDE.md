# Leaderboard Debugging Guide 🔍

## What I Just Added

Added detailed logging to ALL leaderboard queries:
- Volume leaderboard
- Workout count leaderboard
- Streak leaderboard
- PR count leaderboard

## What to Do Now

1. **Open the Leaderboards screen** (Social tab → Leaderboards)
2. **Switch between ALL 4 tabs**: Volume, Workouts, Streaks, PRs
3. **Check the console** and share the complete output

## What the Logs Will Show

For each tab, you'll see:

### Volume Tab:
```
🏆 Getting volume leaderboard...
  Found X users, X stats entries
  Stats: userId=XXX, volume=42966.0, workouts=23
  ✅ Adding entry: You - 42966 kg
  Total entries: 1
```

### Workouts Tab:
```
🏆 Getting workout count leaderboard...
  Found X users, X stats entries
  ✅ Adding entry: XXX - 23 workouts
```

### Streaks Tab:
```
🏆 Getting streak leaderboard...
  Found X users, X stats entries
  Stats: userId=XXX, streak=X
  ✅ Adding streak entry: XXX - X days
```

### PRs Tab:
```
🏆 Getting PR count leaderboard...
  Found X users, X PRs
  ✅ Adding PR entry: You - X PRs
  Total PR entries: 1
```

## What I'm Looking For

1. **How many stats entries?** Should be at least 1
2. **What are the values?** Should match your 23 workouts, 42966 kg
3. **Are entries being added?** Look for "✅ Adding entry"
4. **Are entries being skipped?** Look for "⏭️ Skipping entry"

## Possible Issues

1. **Stats entries = 0**: User stats table is empty (but we just updated it!)
2. **Volume = 0**: Stats updated but volume is 0
3. **No entries added**: Values don't meet the criteria (e.g., volume > 0)
4. **Users not found**: User table might be empty

## Next Steps

Share the console output and I'll know exactly what's wrong! 🚀
