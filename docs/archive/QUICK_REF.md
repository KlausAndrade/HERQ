# 🚀 GymAI Web - Quick Reference Card

## 📋 5-Minute Setup

### 1. Database Setup
```bash
# Open: https://app.supabase.com
# Go to: SQL Editor → New Query
# Copy/Paste: supabase_web_schema.sql
# Click: Run
# Verify: Table Editor shows 7 tables, 5 exercises
```

### 2. Run Web App
```bash
flutter run -d chrome --web-port 8080 --target lib/main_web.dart
```

### 3. Verify
```
✅ Console shows: "Web platform initialized with Supabase"
✅ Browser opens with landing page
✅ Supabase has 7 tables with RLS enabled
```

## 📁 Key Files

| File | Purpose | Action |
|------|---------|--------|
| `supabase_web_schema.sql` | Database schema | Run in Supabase SQL Editor |
| `ACTION_PLAN.md` | Step-by-step guide | Read this first! |
| `WEB_QUICK_START.md` | Setup & migration | Technical reference |
| `DELIVERY_SUMMARY.md` | What was delivered | Overview |
| `lib/main_web.dart` | Web entry point | Modify for features |
| `active_workout_web_provider.dart` | Example provider | Copy this pattern |

## 🔧 Platform-Aware Code Pattern

```dart
// 1. Import platform detection
import 'package:flutter/foundation.dart' show kIsWeb;

// 2. Get both clients
final database = ref.watch(databaseProvider);  // Mobile
final supabase = ref.watch(supabaseClientProvider);  // Web

// 3. Branch logic
if (kIsWeb) {
  // Web: Direct Supabase
  final data = await supabase.from('table').select();
} else {
  // Mobile: Drift/SQLite
  final data = await database.select(database.table).get();
}
```

## 📊 Database Schema Quick Ref

| Table | Primary Use | Key Fields |
|-------|------------|------------|
| `exercises` | Exercise library | id, name, muscle_group, category |
| `workout_templates` | Reusable plans | id, user_id, name, exercise_ids[] |
| `workout_sessions` | Completed workouts | id, user_id, started_at, completed_at, stats |
| `set_entries` | Individual sets | id, workout_session_id, exercise_id, weight, reps |
| `exercise_favorites` | User favorites | user_id, exercise_id |
| `template_folders` | Organization | id, user_id, name |
| `personal_records` | PRs | id, user_id, exercise_id, value, achieved_at |

## 🔍 Common Supabase Queries

### Fetch User's Templates
```dart
final templates = await supabase
    .from('workout_templates')
    .select('*, exercises(*)')
    .order('name');
```

### Create Template
```dart
await supabase.from('workout_templates').insert({
  'id': const Uuid().v4(),
  'user_id': supabase.auth.currentUser!.id,
  'name': 'My Template',
  'exercise_ids': ['bench_press', 'squat'],
});
```

### Save Workout Session
```dart
await supabase.from('workout_sessions').insert({
  'id': sessionId,
  'user_id': userId,
  'name': 'Morning Workout',
  'started_at': startTime.toIso8601String(),
  'completed_at': endTime.toIso8601String(),
  'total_sets': 15,
  'total_volume': 2500.0,
});
```

### Watch Templates (Real-time)
```dart
supabase
    .from('workout_templates')
    .stream(primaryKey: ['id'])
    .eq('user_id', userId)
    .listen((data) {
      print('Templates updated: ${data.length}');
    });
```

## 🛠️ Quick Commands

```bash
# Run web app
flutter run -d chrome --web-port 8080 --target lib/main_web.dart

# Run simple landing
flutter run -d chrome --web-port 8080 --target lib/main_web_simple.dart

# Stop all Flutter
pkill -f "flutter run"

# View schema
cat supabase_web_schema.sql

# Check for errors
flutter analyze

# Build for production
flutter build web --release
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Database not available" | Expected on web! Use `kIsWeb` branch |
| "RLS policy violation" | Check user is authenticated, user_id matches auth.uid() |
| "Table does not exist" | Run SQL schema in Supabase |
| "inFilter not found" | Use `.inFilter()` not `.in_()` |
| Web won't start | Check `.env` has SUPABASE_URL and SUPABASE_ANON_KEY |

## ✅ Development Checklist

### Setup Phase
- [ ] SQL schema executed in Supabase
- [ ] 7 tables created
- [ ] 5 sample exercises inserted
- [ ] RLS policies active
- [ ] Web app runs without errors

### Auth Phase
- [ ] Can signup/login
- [ ] User ID stored correctly
- [ ] RLS prevents cross-user access

### Feature Phase
- [ ] Templates load from Supabase
- [ ] Can start workout
- [ ] Sets save to database
- [ ] History displays correctly

## 🎯 Build Priority

1. **Auth UI** (30 min)
   - Login/signup screen
   - Show current user

2. **Templates** (1 hour)
   - List templates
   - Create new template
   - Select template to start

3. **Workout Tracking** (1 hour)
   - Use `activeWorkoutWebProvider`
   - Track sets
   - Save to Supabase

4. **History** (1 hour)
   - Fetch sessions
   - Display stats
   - Show charts

## 📈 Progress Tracking

```
✅ Foundation (100%)
   ✅ SQL Schema
   ✅ Platform Detection
   ✅ Example Provider
   ✅ Documentation

⏳ MVP (0%)
   ⏳ Auth UI
   ⏳ Templates
   ⏳ Workout Tracking
   ⏳ History

⏳ Full Web (0%)
   ⏳ All Providers
   ⏳ Feature Parity
   ⏳ Deployment
```

## 🔗 Documentation Links

**Start Here:**
- `ACTION_PLAN.md` - What to do next
- `WEB_QUICK_START.md` - Setup guide

**Technical:**
- `WEB_IMPLEMENTATION_STRATEGY.md` - Step-by-step
- `WEB_ARCHITECTURE_DIAGRAM.md` - Diagrams

**Reference:**
- `active_workout_web_provider.dart` - Code example
- `web_repository.dart` - Supabase queries
- `WEB_README.md` - All docs index

## 💡 Pro Tips

1. **Supabase Dashboard** → Real-time data view
2. **Browser DevTools** → Network tab for queries
3. **Hot Reload** → Works great on web (press `r`)
4. **Test RLS** → Try different users
5. **Console Logs** → Debug Supabase operations

## 🚀 Next Actions

```bash
# 1. Setup database (2 min)
# Open Supabase → SQL Editor → Paste schema → Run

# 2. Start app (1 min)
flutter run -d chrome --web-port 8080 --target lib/main_web.dart

# 3. Read guide (2 min)
cat ACTION_PLAN.md

# 4. Start building! 🎉
```

---

**📚 Full docs in `ACTION_PLAN.md` | Example code in `active_workout_web_provider.dart`**
