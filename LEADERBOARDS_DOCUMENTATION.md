# 🏆 Leaderboards Feature Documentation

## Overview
The Leaderboards feature allows users to compete with each other and track their performance across various metrics. It uses real workout data from the Drift database to calculate rankings.

---

## 🎯 Leaderboard Types

### 1. **Total Volume** 📈
- **Metric:** Sum of (weight × reps) across all exercises
- **Unit:** kg
- **Formula:** `Σ(weight × reps)` for all completed sets
- **Best For:** Tracking overall training load

### 2. **Workout Count** 💪
- **Metric:** Number of completed workouts
- **Unit:** workouts
- **Best For:** Consistency and dedication tracking

### 3. **Streak** 🔥
- **Metric:** Consecutive days with at least one workout
- **Unit:** days
- **Logic:** 
  - Counts consecutive days from most recent workout
  - Must have workout today or yesterday to maintain streak
  - Breaks if more than 1 day gap
- **Best For:** Building consistent habits

### 4. **PR Count** 🎖️
- **Metric:** Number of Personal Records achieved
- **Unit:** PRs
- **Best For:** Tracking performance improvements

---

## ⏱️ Time Periods

- **Daily** - Today's activity only
- **Weekly** - Current week (Monday - Sunday)
- **Monthly** - Current month
- **All Time** - All recorded data

---

## 📊 Data Sources

### Database Tables Used
```dart
// Main data sources
- workout_sessions: For volume, workout count, and dates
  - totalVolume: pre-calculated sum
  - completedAt: workout completion timestamp
  
- personal_records: For PR count
  - achievedAt: when PR was set
  
- users: For user information
  - displayName: user's name
  - avatarUrl: user's profile picture
```

### Query Logic

#### Total Volume
```dart
1. Get all users
2. For each user:
   - Query workout_sessions in date range
   - Sum totalVolume from all sessions
3. Sort by total volume (descending)
4. Assign ranks
```

#### Workout Count
```dart
1. Get all users
2. For each user:
   - Count completed workout sessions in date range
3. Sort by count (descending)
4. Assign ranks
```

#### Streak Calculation
```dart
1. Get workout sessions ordered by date (descending)
2. Start from most recent workout
3. Check if workout was today or yesterday
4. Count consecutive days:
   - Same day = continue (don't increment)
   - Next day = increment streak
   - Gap > 1 day = break streak
5. Sort users by streak (descending)
```

#### PR Count
```dart
1. Get all users
2. For each user:
   - Count personal_records in date range
3. Sort by PR count (descending)
4. Assign ranks
```

---

## 🎨 UI Components

### Podium Display (Top 3)
- **1st Place:** Gold badge, center, tallest podium
- **2nd Place:** Silver badge, left, medium height
- **3rd Place:** Bronze badge, right, shortest height
- Shows user avatar, name, and score

### Leaderboard List (Rank 4+)
- Rank number (4, 5, 6, ...)
- User avatar
- Display name
- Formatted score with unit

### Period Selector
```dart
SegmentedButton<Period>(
  segments: [
    ButtonSegment(value: Period.daily, label: Text('Day')),
    ButtonSegment(value: Period.weekly, label: Text('Week')),
    ButtonSegment(value: Period.monthly, label: Text('Month')),
    ButtonSegment(value: Period.allTime, label: Text('All Time')),
  ],
)
```

---

## 🔧 Implementation Details

### Models

```dart
// Leaderboard Entry
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final double value;          // Numeric score
  final int rank;              // Position (1, 2, 3, ...)
  final String formattedValue; // Display text ("1,234 kg")
}

// Leaderboard
class Leaderboard {
  final LeaderboardType type;
  final Period period;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry; // Highlighted for current user
}
```

### Service Layer

```dart
class LeaderboardService {
  final AppDatabase _db;
  
  Future<Leaderboard> getLeaderboard({
    required LeaderboardType type,
    required Period period,
    String? currentUserId,
  });
}
```

### Provider Layer

```dart
// Service provider
final leaderboardServiceProvider = Provider<LeaderboardService?>;

// Data provider
final leaderboardProvider = 
  FutureProvider.autoDispose.family<Leaderboard, LeaderboardParams>;
```

---

## 📱 Platform Support

### Mobile (iOS/Android)
✅ **Fully Supported**
- Uses Drift (SQLite) database
- Real workout data
- All features available

### Web
⚠️ **Limited Support**
- Returns empty leaderboards
- SQLite not available on web
- Would need alternative backend (Supabase)

---

## 🚀 Performance Optimizations

1. **Top 100 Limit**
   ```dart
   entries: entries.take(100).toList()
   ```
   - Only shows top 100 users
   - Reduces memory usage
   - Faster rendering

2. **AutoDispose Provider**
   ```dart
   FutureProvider.autoDispose.family
   ```
   - Automatically cleans up when not in use
   - Prevents memory leaks

3. **Date Range Filtering**
   - SQL WHERE clauses for efficient queries
   - Indexes on date columns recommended

4. **In-Memory Sorting**
   - Sort in Dart after fetching
   - Simpler than complex SQL GROUP BY

---

## 🐛 Known Limitations

1. **User ID Matching**
   - Currently assumes workout session ID contains user ID
   - May need adjustment based on your auth setup

2. **Streak Edge Cases**
   - Timezone handling could affect streak calculation
   - Currently uses device local time

3. **No Historical Tracking**
   - Doesn't track rank changes over time
   - No "up/down" indicators

4. **Web Platform**
   - No data available on web
   - Needs Supabase integration for web support

---

## 🔄 Future Enhancements

### Planned Features
- [ ] Historical rank tracking (up/down arrows)
- [ ] Supabase integration for web platform
- [ ] Friends-only leaderboards
- [ ] Gym/location-based leaderboards
- [ ] Custom date range selector
- [ ] Export leaderboard as image
- [ ] Push notifications for rank changes

### Performance Improvements
- [ ] Add database indexes
  ```sql
  CREATE INDEX idx_sessions_completed ON workout_sessions(completedAt);
  CREATE INDEX idx_prs_achieved ON personal_records(achievedAt);
  ```
- [ ] Cache leaderboard data
- [ ] Paginate beyond top 100

---

## 🧪 Testing

### Test Scenarios

1. **Empty State**
   ```dart
   // No workouts in database
   expect(leaderboard.entries, isEmpty);
   ```

2. **Single User**
   ```dart
   // One user with workouts
   expect(leaderboard.entries.length, equals(1));
   expect(leaderboard.entries.first.rank, equals(1));
   ```

3. **Streak Calculation**
   ```dart
   // Workouts: [Today, Yesterday, 2 days ago]
   expect(streak, equals(3));
   
   // Workouts: [Today, 2 days ago]
   expect(streak, equals(1)); // Broken streak
   ```

4. **Period Filtering**
   ```dart
   // Daily: Only today's workouts
   // Weekly: Monday-Sunday
   // Monthly: 1st-last day of month
   // All Time: No filter
   ```

---

## 📝 Usage Example

```dart
// In UI
final leaderboardAsync = ref.watch(
  leaderboardProvider(
    LeaderboardParams(
      type: LeaderboardType.totalVolume,
      period: Period.weekly,
    ),
  ),
);

leaderboardAsync.when(
  data: (leaderboard) {
    // Show podium for top 3
    // Show list for rest
    // Highlight current user
  },
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
);
```

---

## 🎯 Success Metrics

Track these metrics to measure feature success:

1. **Engagement**
   - Daily active users viewing leaderboards
   - Average time spent on leaderboard screen
   - Tab switches (which leaderboard type most viewed)

2. **Motivation**
   - Workout completion rate before/after leaderboards
   - Streak improvements
   - PR frequency increase

3. **Social**
   - User comments on leaderboard rankings
   - Sharing leaderboard screenshots
   - Following other top users

---

## 🔗 Related Files

```
lib/src/features/social/
  ├── domain/models/
  │   └── leaderboard_models.dart       # Data models
  ├── data/
  │   └── leaderboard_service.dart      # Business logic & queries
  ├── presentation/
  │   ├── providers/
  │   │   └── leaderboard_providers.dart  # Riverpod providers
  │   └── screens/
  │       └── leaderboards_screen.dart    # UI implementation
```

---

## 📚 Additional Resources

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Riverpod Providers](https://riverpod.dev/)
- [Material Design - Data Tables](https://m3.material.io/components/data-tables)

---

**Status:** ✅ Fully Implemented  
**Version:** 1.0  
**Last Updated:** October 2025
