# Workout Resume - User Guide

## Overview
The app now intelligently tracks your active workouts and makes it easy to resume where you left off, while also preventing accidental workout conflicts.

## Features

### 🏋️ Smart Resume Button
When you have a workout in progress, the home screen automatically shows a **"Resume Workout"** button instead of "Start Workout".

#### Visual Indicators:
- **Orange color** - Immediately shows you have an active workout
- **Filled play icon** - Different from the regular play arrow
- **Workout name** - Shows which workout you're currently doing (e.g., "Continue Push Day")

### ⚡ Quick Actions

#### No Active Workout
1. Open the app
2. See "Start Workout" quick action on home screen
3. Tap to browse workout templates
4. Select a template to begin

#### Active Workout
1. Open the app while workout is running
2. See "Resume Workout" with your workout name
3. Tap to go directly back to your active workout
4. Continue logging sets right where you left off

### ⚠️ Conflict Prevention

#### The Problem We Solve
Previously, you could accidentally start a new workout and lose progress on your current one.

#### How It Works Now
1. You're in the middle of a Push Day workout
2. You browse to workout templates
3. You select "Leg Day" template
4. **NEW**: A warning dialog appears:
   - Title: "Workout in Progress"
   - Message: Shows your active workout name and warns it will end
   - Options:
     - **Cancel** - Go back, keep current workout
     - **Start New Workout** - Confirm you want to switch

## User Scenarios

### Scenario 1: Resume After Break
**Situation**: You started a workout, took a phone call, now want to continue

**Steps**:
1. Open GymAI app
2. Home screen shows "Resume Workout - Continue Push Day"
3. Tap the orange resume button
4. You're back in your workout, all sets preserved

**Benefit**: One tap to get back to your workout from anywhere in the app

---

### Scenario 2: Intentional Workout Switch
**Situation**: You started Leg Day but decided to do Push Day instead

**Steps**:
1. Navigate to Workout Templates
2. Select "Push Day"
3. Dialog appears: "You have an active workout 'Leg Day' in progress..."
4. Tap "Start New Workout" to confirm
5. Leg Day is abandoned, Push Day begins

**Benefit**: Prevents accidental data loss while allowing intentional switches

---

### Scenario 3: Accidental Template Tap
**Situation**: You're doing Push Day, browsing templates, accidentally tap one

**Steps**:
1. Browsing templates while workout is active
2. Accidentally tap "Leg Day"
3. Dialog appears with warning
4. Tap "Cancel"
5. Stay on templates screen, Push Day still active

**Benefit**: Mistake protection - one extra tap prevents losing progress

## Visual Design Guide

### Color Meanings
| State | Color | Meaning |
|-------|-------|---------|
| No active workout | Primary (Blue/Purple) | Ready to start |
| Active workout | Orange | Action in progress, resume available |

### Icon Meanings
| State | Icon | Meaning |
|-------|------|---------|
| Start Workout | ▶️ (play_arrow) | Begin new session |
| Resume Workout | ⏯️ (play_circle_filled) | Continue existing session |

## Tips & Best Practices

### ✅ Do's
- **Check home screen** before starting new workout to see if one is active
- **Use resume button** to quickly get back to active workouts
- **Read confirmation dialogs** carefully before confirming workout switches
- **Let workouts finish naturally** by completing all sets and finishing properly

### ❌ Don'ts
- **Don't panic** if you see the confirmation dialog - your data is safe
- **Don't ignore** the orange resume button - it means you have unfinished work
- **Don't rush** through confirmation dialogs - they're there to protect your progress

## Frequently Asked Questions

### Q: What happens to my current workout when I start a new one?
**A**: After confirming the dialog, the current workout is ended (not saved as completed). All logged sets are preserved in history, but it won't count as a finished workout.

### Q: Can I have multiple workouts running at once?
**A**: No, you can only have one active workout at a time. This prevents confusion and data conflicts.

### Q: What if I accidentally confirmed starting a new workout?
**A**: The previous workout's data is saved in history. You can view it in the workout history screen, though it won't be marked as completed.

### Q: Does the resume button work if I close the app completely?
**A**: Yes! The active workout state is preserved even if you close the app or restart your device. The resume button will be there when you open the app again.

### Q: Where can I see my active workout if I navigate away?
**A**: 
- **Home screen** - Orange "Resume Workout" quick action
- **Bottom navigation** - Navigate to active workout screen directly
- **Notifications** (future feature) - Quick access from notification

### Q: What if I want to abandon a workout without finishing it?
**A**: Currently, start a different workout and confirm. Future versions may add a dedicated "Abandon Workout" button.

## Troubleshooting

### Issue: Resume button shows but no workout is actually active
**Solution**: 
1. Tap the resume button
2. If workout is truly finished, end it properly
3. If it's a bug, report it with the workout details

### Issue: Started new workout but dialog didn't appear
**Possible causes**:
- No workout was actually active
- Previous workout was already finished
- App state needs refresh

**Solution**: Check active workout screen to confirm current state

### Issue: Wrong workout name showing in resume button
**Solution**: This shouldn't happen. If it does:
1. Note the displayed name and actual workout
2. Report as a bug with screenshots
3. Finish or abandon the workout to reset state

## Privacy & Data

### What's Tracked
- Whether a workout is currently active
- The name of the active workout
- Time workout was started
- All logged sets and exercises

### What's NOT Tracked
- How many times you view the confirmation dialog
- Whether you cancel or confirm dialogs
- Navigation patterns during workouts

### Data Persistence
- Active workout state: Stored locally on device
- Workout history: Synced to cloud (Supabase)
- Dialog preferences: Not stored (shows every time)

## Feedback

We're constantly improving the workout experience. If you have suggestions for:
- Better warning messages
- Additional quick actions
- Workout state indicators
- Resume functionality improvements

Please share your feedback through the app settings or GitHub issues!

---

**Last Updated**: December 2024  
**Feature Version**: 1.0  
**Compatible With**: GymAI v3.0+
