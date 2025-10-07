# Web Implementation Strategy - Supabase-Only Approach

## ✅ RECOMMENDED: Supabase-Only Web Implementation

This document outlines the step-by-step strategy to make GymAI work on web using Supabase directly, without local database complexity.

## Current Status

- ✅ Mobile/Desktop: Works perfectly with SQLite + Supabase sync
- ✅ Web Simple: "Coming Soon" page works
- 🚧 Web Full App: Needs Supabase-only implementation

## Why Supabase-Only for Web?

**Pros:**
1. ✅ **Simpler** - One data source (Supabase)
2. ✅ **Less Code** - No sync logic needed for web
3. ✅ **Easier Maintenance** - Fewer places for bugs
4. ✅ **Modern Pattern** - Used by Linear, Notion, etc.
5. ✅ **Real-time by Default** - Supabase streams work great

**Cons:**
1. ❌ No offline support on web (acceptable for most users)
2. ❌ Different code paths for mobile vs web (mitigated by clean architecture)

## Implementation Steps

### Phase 1: Make Providers Web-Aware (Quick Win)

Update existing providers to check platform and use Supabase on web:

```dart
// Example: workout_providers.dart
final workoutSessionsProvider = StreamProvider<List<WorkoutSession>>((ref) {
  if (kIsWeb) {
    // Web: Use Supabase directly
    final supabase = Supabase.instance.client;
    return supabase
        .from('workout_sessions')
        .stream(primaryKey: ['id'])
        .order('started_at', ascending: false)
        .map((data) => data.map((json) => WorkoutSession.fromJson(json)).toList());
  } else {
    // Mobile: Use local database
    final database = ref.read(databaseProvider);
    return database!.select(database.workoutSessions).watch();
  }
});
```

**Files to Update:**
- [ ] `lib/src/features/workout/presentation/providers/workout_providers.dart`
- [ ] `lib/src/features/exercises/presentation/providers/exercise_providers.dart`
- [ ] `lib/src/features/progress/presentation/providers/progress_providers.dart`

### Phase 2: Add Supabase Schema

Ensure your Supabase database has the same schema as your Drift database:

```sql
-- Example: workout_sessions table
CREATE TABLE workout_sessions (
  id TEXT PRIMARY KEY,
  template_id TEXT REFERENCES workout_templates(id),
  name TEXT NOT NULL,
  notes TEXT,
  started_at TIMESTAMP NOT NULL,
  completed_at TIMESTAMP,
  total_duration_seconds INTEGER,
  total_volume REAL DEFAULT 0,
  total_tonnage REAL DEFAULT 0,
  total_sets INTEGER DEFAULT 0,
  total_reps INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Add RLS policies for user data
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own workouts"
  ON workout_sessions
  FOR SELECT
  USING (auth.uid()::text = user_id);
```

### Phase 3: Handle Model Conversion

Since Drift generates classes from tables, you'll need to handle JSON conversion for web:

**Option A: Add fromJson to Drift Models**
```dart
// In database.dart or companion file
extension WorkoutSessionJson on WorkoutSession {
  static WorkoutSession fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      templateId: json['template_id'] as String?,
      name: json['name'] as String,
      // ... map all fields
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_id': templateId,
      'name': name,
      // ... map all fields
    };
  }
}
```

**Option B: Use DTOs (More Work, Better Separation)**
- Create platform-agnostic data models
- Convert between Drift models and DTOs on mobile
- Use DTOs directly from Supabase JSON on web

### Phase 4: Test Web Features

**Priority 1 (Must Work):**
- [ ] Authentication (already works with Supabase)
- [ ] View workouts
- [ ] Create workout from template
- [ ] Log exercises and sets
- [ ] View progress

**Priority 2 (Nice to Have):**
- [ ] Social features (already Supabase-based)
- [ ] AI coaching
- [ ] Analytics

### Phase 5: Deploy Web App

```bash
# Build for production
flutter build web --target lib/main_web.dart --release

# Deploy to hosting (choose one)
- Firebase Hosting
- Vercel
- Netlify
- CloudFlare Pages

# Ensure environment variables are set in hosting platform
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Quick Implementation Guide

### Step 1: Fix One Provider First

Start with `workout_sessions_provider.dart`:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

final workoutSessionsProvider = StreamProvider<List<dynamic>>((ref) async* {
  if (kIsWeb) {
    final supabase = Supabase.instance.client;
    await for (final data in supabase
        .from('workout_sessions')
        .stream(primaryKey: ['id'])
        .order('started_at', ascending: false)) {
      yield data; // Return raw JSON for now
    }
  } else {
    final database = ref.read(databaseProvider);
    if (database != null) {
      await for (final sessions in database.select(database.workoutSessions).watch()) {
        yield sessions;
      }
    }
  }
});
```

### Step 2: Update UI to Handle Both Types

```dart
// In your widget
ref.watch(workoutSessionsProvider).when(
  data: (sessions) {
    if (kIsWeb) {
      // sessions is List<Map<String, dynamic>>
      return ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return ListTile(
            title: Text(session['name'] as String),
            subtitle: Text(session['started_at'] as String),
          );
        },
      );
    } else {
      // sessions is List<WorkoutSession>
      return ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index] as WorkoutSession;
          return ListTile(
            title: Text(session.name),
            subtitle: Text(session.startedAt.toString()),
          );
        },
      );
    }
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### Step 3: Gradually Migrate Screens

Do this screen by screen:
1. Home screen ✅
2. Workout templates
3. Active workout
4. Progress
5. Social feed (already Supabase)

## File Structure

```
lib/
├── main.dart                    # Mobile/Desktop entry
├── main_web.dart                # Web entry (use GymAIApp)
├── main_web_simple.dart         # "Coming Soon" page
└── src/
    ├── core/
    │   ├── data/
    │   │   ├── dto/            # Platform-agnostic models (optional)
    │   │   └── repositories/   # Repository pattern (optional)
    │   └── providers/
    │       └── repository_providers.dart
    └── features/
        └── workout/
            └── presentation/
                └── providers/
                    └── workout_providers.dart  # ← Make this web-aware
```

## Testing Strategy

1. **Test on Mobile First** - Ensure nothing breaks
2. **Test Authentication on Web** - Should already work
3. **Test Data Fetching on Web** - Start with read-only
4. **Test Data Writing on Web** - Create/update/delete
5. **Test Real-time Updates** - Supabase streams

## Common Pitfalls

### 1. Column Name Mismatch
- Drift uses camelCase: `templateId`
- Supabase uses snake_case: `template_id`
- **Solution**: Use `toJson()/fromJson()` to convert

### 2. Type Differences
- Drift generates type-safe classes
- Supabase returns `Map<String, dynamic>`
- **Solution**: Handle both types in UI or create conversion layer

### 3. Foreign Key Constraints
- Ensure Supabase schema matches Drift schema
- **Solution**: Export schema from Drift and apply to Supabase

### 4. Row Level Security
- Don't forget RLS policies on Supabase
- **Solution**: Test with different users

## Migration Checklist

- [ ] Backup current database schema
- [ ] Create matching Supabase schema
- [ ] Add RLS policies
- [ ] Update one provider to be web-aware
- [ ] Test provider on web
- [ ] Update corresponding UI
- [ ] Test end-to-end flow
- [ ] Repeat for each feature
- [ ] Deploy to staging
- [ ] User testing
- [ ] Deploy to production

## Performance Considerations

1. **Pagination**: Implement for large datasets
   ```dart
   .range(0, 49)  // Load 50 items at a time
   ```

2. **Selective Fetching**: Only fetch needed columns
   ```dart
   .select('id, name, started_at')
   ```

3. **Caching**: Use Riverpod's caching
   ```dart
   keepAlive: true,  // Keep data in memory
   ```

## Next Steps

1. **Immediate**: Run `flutter run -d chrome --target lib/main_web_simple.dart` to see "Coming Soon" page
2. **This Week**: Make `workout_sessions_provider` web-aware
3. **Next Week**: Migrate home screen to work on web
4. **This Month**: Full feature parity on web

## Resources

- [Supabase Dart Client Docs](https://supabase.com/docs/reference/dart/introduction)
- [Flutter Web Best Practices](https://docs.flutter.dev/platform-integration/web)
- [Riverpod Providers](https://riverpod.dev/docs/providers/provider)

---

**Remember**: Start small, test often, and gradually migrate features. Don't try to do everything at once!
