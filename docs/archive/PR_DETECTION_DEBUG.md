# PR Detection - Debugging Guide

## Understanding "Always Double PR" Issue

### Why It Happens

The PR detection shows **Double PR (🏆②)** when BOTH conditions are true:
1. **Weight PR**: Current weight > any previous weight for this exercise
2. **Reps PR**: Current reps > any previous reps at current weight or heavier

### Common Causes

#### 1. **First Time Doing Exercise** ✅ Expected Behavior
If you've never completed this exercise before, your first set is ALWAYS a double PR.

**Example**:
- Exercise: Bench Press
- Previous workouts: None
- Current set: 60kg × 10 reps
- Result: 🏆② Double PR (correct!)

#### 2. **No Completed Workouts** ✅ Expected Behavior
If you have workout sessions but haven't COMPLETED them (saved them), PR detection treats each session as "first time".

**Example**:
- You started 5 workouts but never clicked "Finish Workout"
- Database has 0 completed workouts
- Result: Every session shows double PR (correct!)

#### 3. **Exercise Never Done Before** ✅ Expected Behavior  
Even if you have 100 completed workouts, if THIS specific exercise wasn't in any of them, it's a PR.

**Example**:
- Completed workouts: 50
- Exercises done: Squats, Deadlifts, Pull-ups
- Current exercise: Bench Press (first time)
- Result: 🏆② Double PR (correct!)

### How to Check What's Happening

#### Step 1: Check Console Logs
When you complete a set, look for these logs:

```
🔍 PR Check for exercise bench_press: Current 60.0kg × 10 reps
📊 Found 5 previous sets from completed workouts
📈 Historical best: 55.0kg (max weight), 8 reps (at 60.0kg or heavier)
✅ Results: Weight PR=true, Reps PR=true
```

#### Step 2: Interpret the Logs

**Scenario A: First Time**
```
📊 Found 0 previous sets from completed workouts
🏆 FIRST TIME! Both weight and reps are PRs
```
→ This is correct! You've never done this exercise before.

**Scenario B: Actual Double PR**
```
📊 Found 10 previous sets from completed workouts
📈 Historical best: 50.0kg (max weight), 8 reps (at 60.0kg or heavier)
✅ Results: Weight PR=true, Reps PR=true
```
→ You beat BOTH your max weight (60 > 50) AND max reps (10 > 8)

**Scenario C: Weight PR Only**
```
📊 Found 10 previous sets from completed workouts
📈 Historical best: 50.0kg (max weight), 12 reps (at 60.0kg or heavier)
✅ Results: Weight PR=true, Reps PR=false
```
→ New max weight, but you've done more reps before at this weight or heavier

**Scenario D: Bug (Should Not Happen)**
```
📊 Found 10 previous sets from completed workouts
📈 Historical best: 70.0kg (max weight), 15 reps (at 60.0kg or heavier)
✅ Results: Weight PR=true, Reps PR=true
```
→ This is wrong! Current 60kg is less than previous 70kg

### Verification Steps

#### 1. Check Workout History
```
Settings → Workout History → Look for completed workouts
```
- If list is empty → You have no completed workouts (every workout will show PR)
- If list has workouts → Check which exercises were in them

#### 2. Check Exercise in Previous Workouts
- Open a completed workout from history
- See which exercises were tracked
- Note the weights and reps

#### 3. Complete the Current Workout
- Finish your workout properly
- Start a NEW workout with the same exercise
- Complete a set with SAME or LOWER stats
- Should NOT show PR anymore

### Expected Behavior Examples

#### Example 1: Progressive Overload
```
Workout 1 (Completed):
- Bench Press: 50kg × 10, 50kg × 8, 50kg × 6

Workout 2 (Active):
- Bench Press Set 1: 52.5kg × 10
- Result: 🏆② Double PR
  - Weight: 52.5 > 50 ✅
  - Reps: 10 = best at this weight (first time at 52.5kg) ✅
```

#### Example 2: Weight Increase, Reps Decrease
```
Workout 1 (Completed):
- Bench Press: 50kg × 12, 50kg × 10, 50kg × 8

Workout 2 (Active):
- Bench Press Set 1: 55kg × 8
- Result: 💪 Weight PR only
  - Weight: 55 > 50 ✅
  - Reps: 8 ≤ 12 (you've done more reps before) ❌
```

#### Example 3: Same Weight, More Reps
```
Workout 1 (Completed):
- Bench Press: 50kg × 8, 50kg × 8, 50kg × 6

Workout 2 (Active):
- Bench Press Set 1: 50kg × 10
- Result: 🔥 Reps PR only
  - Weight: 50 = 50 (not greater) ❌
  - Reps: 10 > 8 ✅
```

## Troubleshooting

### Issue: Every set shows Double PR

**Diagnosis**:
```
📊 Found 0 previous sets from completed workouts
```

**Solutions**:
1. **Finish workouts properly**
   - Click "Finish Workout" button
   - Don't just close the app
   - Check that workout appears in history

2. **Verify database**
   - Settings → Workout History
   - Should see completed workouts
   - Click into workout to see exercises

3. **Check exercise ID**
   - Make sure you're using the same exercise
   - "Bench Press" vs "Incline Bench Press" are different
   - Check exercise names match exactly

### Issue: No PRs detected when should be

**Diagnosis**:
```
📊 Found 20 previous sets from completed workouts
📈 Historical best: 100.0kg (max weight), 15 reps (at 50.0kg or heavier)
✅ Results: Weight PR=false, Reps PR=false
```

**Solutions**:
1. **Check if stats actually improved**
   - Current: 50kg × 10 reps
   - Previous best: 100kg (current is less!)
   - Previous reps: 15 (current is less!)
   - Result: No PR (correct)

2. **Understand reps PR logic**
   - Reps PR checks: "max reps at current weight OR HEAVIER"
   - If you did 100kg × 15 before, doing 50kg × 20 is NOT a reps PR
   - Logic: Lifting heavier weight is harder, so past reps at heavier weight count

### Issue: Database shows no workouts but I've done many

**Cause**: Workouts not marked as complete

**Solution**:
```dart
// When finishing workout:
ref.read(activeWorkoutProvider.notifier).finishWorkout();

// This sets completedAt timestamp
// Without this, workouts are "abandoned" and not counted
```

## Technical Details

### Database Query
```sql
SELECT set_entries.*
FROM set_entries
INNER JOIN workout_sessions ON workout_sessions.id = set_entries.workout_session_id
WHERE set_entries.exercise_id = ?
  AND workout_sessions.completed_at IS NOT NULL  -- Only finished workouts
ORDER BY workout_sessions.started_at DESC
```

### PR Logic Pseudocode
```dart
// Weight PR
isPRWeight = currentWeight > maxWeightEverLifted

// Reps PR  
maxRepsAtCurrentOrHigherWeight = previous sets
  .where(set.weight >= currentWeight)
  .max(set.reps)
  
isPRReps = currentReps > maxRepsAtCurrentOrHigherWeight
```

### Edge Cases

1. **Zero previous sets**: Double PR ✅
2. **First time at this weight**: Reps PR even with fewer reps than at lighter weight ✅
3. **Same stats as before**: No PR ✅
4. **Incomplete current workout**: Not counted in PR check ✅

## How to Test Properly

### Test 1: First Exercise Ever
```
1. Start new workout
2. Add exercise never done before
3. Complete first set with any weight/reps
4. Should see: 🏆② Double PR
5. Logs: "Found 0 previous sets"
```

### Test 2: Beat Previous Weight
```
1. Complete workout with: Bench 50kg × 10
2. Finish workout properly
3. Start new workout
4. Complete set with: 55kg × 8
5. Should see: 💪 Weight PR (or 🏆② if also reps PR)
```

### Test 3: Same Weight, More Reps
```
1. Complete workout with: Bench 50kg × 8
2. Finish workout
3. Start new workout  
4. Complete set with: 50kg × 10
5. Should see: 🔥 Reps PR only
```

### Test 4: No PR
```
1. Complete workout with: Bench 60kg × 12
2. Finish workout
3. Start new workout
4. Complete set with: 55kg × 10
5. Should see: Normal checkmark (no PR)
```

## Summary

**Why you might see Double PR every time**:
1. ✅ **Expected**: First time doing this exercise
2. ✅ **Expected**: No completed workouts in database
3. ✅ **Expected**: You're genuinely improving both weight and reps
4. ❌ **Bug**: Check console logs to diagnose

**Next steps**:
1. Complete a set and check console logs
2. Verify workout history has completed workouts
3. Ensure you're comparing same exercise
4. Report console log output if issue persists
