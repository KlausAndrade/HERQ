# 🗓️ Workout Calendar - User Guide

## Where to Find the Calendar

### Option 1: Workout History Screen
1. Tap **"Workout History"** from the home screen bottom navigation
2. Tap the **view mode icon** in the top-right (cycles through list → monthly → calendar)
3. Calendar appears with full-screen view

### Option 2: Gamification/Progress Screen
1. Go to **Home screen**
2. Tap **"Achievements"** quick action card (or navigate to `/gamification`)
3. Select the **"Calendar"** tab (third tab)
4. Calendar displays alongside your stats and achievements

## How to Use the Calendar

### Navigating Months
```
┌────────────────────────────┐
│  ◀  October 2025    ▶      │  ← Tap arrows to change month
└────────────────────────────┘
```
- **Left arrow**: Previous month
- **Right arrow**: Next month (disabled for future months)
- **Month/Year**: Shows current viewing period

### Understanding the Day Cells

#### Day with No Workout
```
┌─────┐
│  15 │  ← Normal day (white/light background)
└─────┘
```

#### Day with Single Workout
```
┌─────┐
│  16 │  ← Blue background, bold text
│  •  │  ← One dot
└─────┘
```

#### Day with Multiple Workouts
```
┌─────┐
│ [2] │  ← Badge shows count
│  17 │  ← Blue background
│ ••• │  ← Three dots
└─────┘
```

#### Today (Current Date)
```
┌─────┐
│┃ 6 ┃│  ← Red/primary color border
└─────┘
```

#### Selected Day
```
┌─────┐
│  15 │  ← Purple/primary fill, white text
└─────┘
```

#### Future Day
```
┌─────┐
│  25 │  ← Gray text, not clickable
└─────┘
```

### Viewing Workouts on a Day

1. **Tap any day** that has workouts (blue background)
2. **Bottom sheet appears** showing:
   ```
   October 6, 2025 • 2 workouts
   
   🏋️ Push Day
   12 sets • 850 kg
   14:30
   
   🏋️ Cardio Session
   8 sets • 200 kg
   18:15
   ```
3. **Tap any workout** to view full details

### Quick Tips

✅ **Track Streaks**: Look for consecutive blue days
✅ **Spot Patterns**: See which days you typically work out
✅ **Find Gaps**: Gray days show rest days or missed workouts
✅ **Review Volume**: More dots = more sessions that day
✅ **Quick Navigation**: Use month arrows to browse history

## Visual Legend

| Symbol | Meaning |
|--------|---------|
| 🔵 Blue cell | Day with workout(s) |
| 🔴 Red border | Today's date |
| 🟣 Purple fill | Currently selected day |
| ⚪ Gray text | Future date (disabled) |
| • | One workout |
| •• | Two workouts |
| ••• | Three+ workouts |
| [2] | Exact count badge |

## Example Calendar

```
        October 2025
   S   M   T   W   T   F   S
              1   2 [3]  4   5
   6 [7]  8   9  10  11  12
  13  14  15  16  17  18  19
  20  21  22  23  24  25  26
  27  28  29  30  31

Legend:
• Plain numbers = No workout
• [Bold in brackets] = Has workout(s)
```

In this example:
- **Oct 2**: 1 workout
- **Oct 3**: Multiple workouts (3+)
- **Oct 7**: Multiple workouts (2+)
- **Oct 6**: Today (if viewing in October 2025)

## Common Workflows

### 1. Check Today's Progress
1. Open calendar
2. Find today (red border)
3. If blue, tap to see workouts completed
4. If white, no workouts yet today

### 2. Review This Week
1. Look at current week row
2. Count blue vs. white days
3. Tap blue days to review details

### 3. Verify Streak
1. Find today
2. Look backward for consecutive blue days
3. Each consecutive day = +1 to streak

### 4. Browse History
1. Tap left arrow to go to previous months
2. Scan for blue days
3. Tap any day to see what you did
4. Tap workout to see full details

### 5. Plan Ahead
1. Look at this week's pattern
2. Find white (rest) days
3. Plan next workout accordingly

## Keyboard Shortcuts (Desktop)

- `←` : Previous month
- `→` : Next month
- `Esc` : Close workout details
- `Enter` : Select day / open workout

## Accessibility

- ✅ Screen reader compatible
- ✅ High contrast mode support
- ✅ Keyboard navigation
- ✅ Touch target size (44x44)
- ✅ Color-blind friendly (uses shapes + colors)

---

**Pro Tip**: Use the calendar view alongside the streak counter in the gamification section to visualize your consistency and stay motivated! 🔥
