# Fixed: Yoga Poses & Back Squat Exercise Types 🔧

## Issues Fixed

### 1. ✅ Yoga Poses Now Duration Exercises

**Problem:** All yoga poses were showing "kg & reps" (weight_reps)

**Root Cause:** The exercise type mapper didn't recognize yoga poses as duration exercises

**Fix Applied:**
- ✅ Added **category-based check**: If `category` contains "yoga" or "acroyoga" → duration
- ✅ Added **33+ yoga pose keywords** to duration exercise detection
- ✅ Now includes: Bird Pose, Throne Pose, Star Pose, Warrior Pose, Downward Dog, Tree Pose, etc.

**Code Changes:**
```dart
// NEW: Category-based check
if (category.contains('yoga') || category.contains('acroyoga')) {
  return ExerciseType.duration;
}

// NEW: Yoga pose keywords
'bird pose', 'throne pose', 'folded leaf', 'star pose',
'whale pose', 'warrior pose', 'downward dog', 'upward dog',
'tree pose', 'triangle pose', 'cobra pose', 'mountain pose',
// ... and many more
```

### 2. ✅ Back Squat Now Weight & Reps

**Problem:** "Back Squat" was showing as bodyweight exercise

**Root Cause:** Generic `'squat'` keyword matched ALL squats (back squat, front squat, barbell squat, etc.)

**Fix Applied:**
- ❌ Removed generic `'squat'` keyword
- ✅ Added specific bodyweight squat variations only:
  - `'air squat'`
  - `'bodyweight squat'`
  - `'pistol squat'`
  - `'sissy squat'`

**Code Changes:**
```dart
// BEFORE (BAD)
'squat' // Matched ALL squats! ❌

// AFTER (GOOD)
'air squat',        // Specific bodyweight squat ✅
'bodyweight squat', // Specific bodyweight squat ✅
'pistol squat',     // Single-leg bodyweight squat ✅
'sissy squat',      // Bodyweight squat variation ✅
```

**Result:**
- ✅ "Back Squat" → Weight & Reps
- ✅ "Front Squat" → Weight & Reps
- ✅ "Barbell Squat" → Weight & Reps
- ✅ "Goblet Squat" → Weight & Reps
- ✅ "Air Squat" → Bodyweight Reps
- ✅ "Pistol Squat" → Bodyweight Reps

---

## How to Apply the Fixes

### IMPORTANT: Update Existing Exercises

**These fixes only apply to:**
- ❌ **NOT** exercises already in your database
- ✅ **NEW** exercises created after this fix

**To fix existing exercises:**

1. **Open Settings**
2. **Scroll to Maintenance**
3. **Tap "Update Exercise Types"**
4. **Confirm the update**
5. **Wait for "Exercise types updated!" message**

This will re-run the assignment logic for ALL exercises in your database.

---

## Verification

### Test Yoga Poses:

1. **Settings → Maintenance → Debug Exercise Types**
2. **Find any yoga pose** (e.g., "Bird Pose", "Throne Pose")
3. **Check Type column:**
   - ✅ Should say: `Type: duration | Category: yoga`
   - ❌ If it says: `Type: weight_reps` → Run "Update Exercise Types"

### Test Back Squat:

1. **Settings → Maintenance → Debug Exercise Types**
2. **Find "Back Squat"**
3. **Check Type column:**
   - ✅ Should say: `Type: weight_reps`
   - ❌ If it says: `Type: bodyweight_reps` → Run "Update Exercise Types"

### Test in Workout:

**Yoga Pose (e.g., Bird Pose):**
```
Should show:
┌─────────────┬──────────┬─────┐
│ SET         │ DURATION │ ✓   │
├─────────────┼──────────┼─────┤
│ Set 1       │ [   s]   │ [ ] │
└─────────────┴──────────┴─────┘
```

**Back Squat:**
```
Should show:
┌─────────────┬──────┬──────┬─────┐
│ SET         │ KG   │ REPS │ ✓   │
├─────────────┼──────┼──────┼─────┤
│ Set 1       │ [  ] │ [ ]  │ [ ] │
└─────────────┴──────┴──────┴─────┘
```

---

## Files Modified

### 1. `exercise_type_mapper.dart`

**Changes:**
- Line 18-21: Added category-based duration check
- Line 57-110: Added yoga pose keywords and category check to `_isDurationExercise`
- Line 240-243: Replaced generic `'squat'` with specific bodyweight squat variations

**Impact:**
- ✅ All yoga/acroyoga category exercises → duration
- ✅ 33+ yoga pose names recognized
- ✅ Only specific bodyweight squats are bodyweight_reps
- ✅ Barbell/weighted squats default to weight_reps

---

## Exercise Types Reference

### Now Correctly Assigned:

**Duration (Yoga/AcroYoga):**
- Bird Pose, Throne Pose, Star Pose
- Warrior Pose, Tree Pose, Triangle Pose
- Downward Dog, Upward Dog, Cobra Pose
- Mountain Pose, Child Pose
- And ANY exercise with category="yoga"

**Weight & Reps (Squats):**
- Back Squat ✅
- Front Squat ✅
- Barbell Squat ✅
- Goblet Squat ✅
- Bulgarian Split Squat ✅
- Overhead Squat ✅

**Bodyweight Reps (Specific Squats):**
- Air Squat ✅
- Bodyweight Squat ✅
- Pistol Squat ✅
- Sissy Squat ✅

---

## Summary

### What Changed:
✅ **Yoga poses** → Duration exercises (hold for time)
✅ **Back Squat** → Weight & Reps (with barbell)
✅ **Category-based logic** → "yoga" category = duration
✅ **Specific bodyweight squats** → Only air/pistol/sissy squats are bodyweight

### What You Need to Do:
1. **Run "Update Exercise Types"** in Settings → Maintenance
2. **Verify** using "Debug Exercise Types"
3. **Test in a workout** to confirm inputs are correct

**Both issues completely fixed!** 🎉
