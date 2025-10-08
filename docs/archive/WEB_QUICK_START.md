# GymAI Web Implementation - Quick Start Guide

## ✅ What's Ready

1. **SQL Schema**: `supabase_web_schema.sql` - Complete database schema with RLS policies
2. **Web Provider**: `active_workout_web_provider.dart` - Platform-aware workout provider
3. **Web Entry Point**: `lib/main_web.dart` - Working web app with Supabase
4. **Landing Page**: Shows setup instructions

## 🚀 Quick Start (5 minutes)

### Step 1: Set Up Supabase Database

1. Go to your Supabase Dashboard → SQL Editor
2. Copy and paste the entire content of `supabase_web_schema.sql`
3. Click "Run" to create all tables and policies

**What this creates:**
- `exercises` table (public, read-only for built-in exercises)
- `workout_templates` table (user-specific)
- `workout_sessions` table (user-specific)
- `set_entries` table (user-specific)
- Row Level Security (RLS) policies for data isolation
- Sample exercises (bench press, squat, deadlift, pull-up, push-up)

### Step 2: Run the Web App

```bash
# Make sure Supabase credentials are in .env
flutter run -d chrome --web-port 8080 --target lib/main_web.dart
```

### Step 3: Test Basic Functionality

The current web app shows a landing page. To enable full functionality, you need to:

1. **Populate exercises**: Run the SQL schema (includes 5 sample exercises)
2. **Add authentication**: Already handled by Supabase
3. **Use web providers**: See migration guide below

## 📋 How It Works

### Platform Detection

The web provider uses `kIsWeb` to automatically choose the right data source:

```dart
if (kIsWeb) {
  // Use Supabase directly
  final data = await supabase.from('workout_templates').select();
} else {
  // Use Drift/SQLite
  final data = await database.select(database.workoutTemplates).get();
}
```

### Web-Aware Provider Example

**File**: `lib/src/features/workout/presentation/providers/active_workout_web_provider.dart`

Key features:
- ✅ Works on both web and mobile
- ✅ Automatic platform detection
- ✅ Supabase for web, Drift for mobile
- ✅ Shared business logic
- ✅ No duplicate code

### Data Flow

**Mobile (Current)**:
```
UI → Provider → Drift (SQLite) → Background Sync → Supabase
```

**Web (New)**:
```
UI → Provider → Supabase (Direct)
```

## 🔄 Migration Guide

### Converting a Provider to Web-Aware

**Before** (Mobile-only):
```dart
final myProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  // Uses database only
});
```

**After** (Web + Mobile):
```dart
final myProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  final supabase = ref.watch(supabaseClientProvider);
  
  if (kIsWeb) {
    return MyWebService(supabase);
  } else {
    return MyMobileService(database);
  }
});
```

### Real Example from active_workout_web_provider.dart

```dart
Future<void> startWorkoutFromTemplate(String templateId) async {
  if (kIsWeb) {
    // Fetch from Supabase
    final templateData = await supabase
        .from('workout_templates')
        .select()
        .eq('id', templateId)
        .maybeSingle();
    
    final exerciseIds = List<String>.from(templateData['exercise_ids']);
    final exercisesData = await supabase
        .from('exercises')
        .select()
        .inFilter('id', exerciseIds);
  } else {
    // Fetch from Drift
    final template = await (database.select(database.workoutTemplates)
          ..where((tbl) => tbl.id.equals(templateId)))
        .getSingleOrNull();
    
    final exercises = await (database.select(database.exercises)
          ..where((tbl) => tbl.id.isIn(template.exerciseIds)))
        .get();
  }
  
  // Shared business logic continues...
}
```

## 📊 Database Schema

### Key Tables

**exercises**
- Public read access for built-in exercises
- Users can create custom exercises
- Fields: id, name, description, muscle groups, equipment, category, difficulty

**workout_templates**
- User-specific workout plans
- Contains array of exercise IDs
- Fields: id, user_id, name, description, exercise_ids[]

**workout_sessions**
- Completed workout records
- Auto-calculated stats
- Fields: id, user_id, name, started_at, completed_at, volume, tonnage, sets, reps

**set_entries**
- Individual set data
- Links to sessions and exercises
- Fields: id, user_id, workout_session_id, exercise_id, weight, reps, rpe

### Row Level Security (RLS)

All tables have RLS enabled:
```sql
-- Users can only see their own data
CREATE POLICY "Users can view their own sessions"
  ON workout_sessions FOR SELECT
  USING (auth.uid() = user_id);

-- Users can only insert their own data
CREATE POLICY "Users can insert their own sessions"
  ON workout_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## 🔍 Testing Checklist

### Database Setup
- [ ] SQL schema executed in Supabase
- [ ] Sample exercises visible in `exercises` table
- [ ] RLS policies active (check Supabase → Authentication → Policies)

### Web App
- [ ] `flutter run -d chrome` starts without errors
- [ ] Supabase initialized (check console for "✅ Web platform initialized")
- [ ] Landing page displays

### Authentication
- [ ] Users can sign up/login (when auth UI added)
- [ ] User ID correctly stored in `user_id` fields
- [ ] RLS prevents accessing other users' data

### Data Operations
- [ ] Templates load from Supabase
- [ ] Can start workout from template
- [ ] Sets save to `set_entries` table
- [ ] Workout completion saves to `workout_sessions`

## 🐛 Troubleshooting

### "Database not available" error on web
✅ **Expected!** Web uses Supabase, not SQLite. Check that:
- `kIsWeb` block is handling the operation
- Supabase client is initialized

### "Row Level Security policy violation"
Check that:
- User is authenticated (`supabase.auth.currentUser != null`)
- `user_id` field matches authenticated user ID
- RLS policies are created (run SQL schema)

### "Table does not exist"
Run the SQL schema in Supabase SQL Editor:
```bash
cat supabase_web_schema.sql
# Copy output and paste into Supabase SQL Editor
```

### "inFilter not found" error
Use `.inFilter()` not `.in_()` for Supabase:
```dart
.inFilter('id', exerciseIds)  // ✅ Correct
.in_('id', exerciseIds)       // ❌ Wrong
```

## 📈 Next Steps

### Phase 1: Core Features (1-2 days)
1. ✅ Database schema (DONE)
2. ✅ Web provider example (DONE)
3. ⏳ Add authentication UI
4. ⏳ Migrate template provider to web
5. ⏳ Migrate exercise provider to web

### Phase 2: Workout Features (2-3 days)
6. ⏳ Active workout screen (web compatible)
7. ⏳ Set tracking and completion
8. ⏳ Rest timer (simplified for web)
9. ⏳ Workout summary

### Phase 3: History & Analytics (2-3 days)
10. ⏳ Workout history from Supabase
11. ⏳ Charts and stats
12. ⏳ Personal records tracking

### Phase 4: Polish (1-2 days)
13. ⏳ Responsive design
14. ⏳ Error handling
15. ⏳ Loading states
16. ⏳ Offline indicator

## 🎯 Success Criteria

**Minimal Web MVP** (Can ship this):
- [ ] User can login/signup
- [ ] View exercise library
- [ ] Create workout templates
- [ ] Start and track workouts
- [ ] View workout history

**Full Web Parity** (Future):
- [ ] All mobile features available on web
- [ ] Shared workout templates between platforms
- [ ] Real-time sync across devices
- [ ] Social features (posts, following)

## 📝 Quick Commands

```bash
# Run web app
flutter run -d chrome --web-port 8080 --target lib/main_web.dart

# Run simple landing page
flutter run -d chrome --web-port 8080 --target lib/main_web_simple.dart

# View SQL schema
cat supabase_web_schema.sql

# Check for web compilation issues
flutter analyze

# Build for web deployment
flutter build web --release
```

## 🔗 Related Files

- `supabase_web_schema.sql` - Complete database setup
- `lib/main_web.dart` - Web entry point
- `lib/src/features/workout/presentation/providers/active_workout_web_provider.dart` - Example web-aware provider
- `WEB_IMPLEMENTATION_STRATEGY.md` - Detailed technical guide
- `WEB_README.md` - Documentation index

## 💡 Pro Tips

1. **Use Supabase Dashboard**: View real-time data during development
2. **Test RLS**: Try accessing data from different users to verify security
3. **Browser DevTools**: Use Network tab to debug Supabase queries
4. **Hot Reload**: Works great on web - use `r` in terminal
5. **Supabase Studio**: Use the table editor to manually test data

---

**Ready to start?** Run the SQL schema, then start the web app! 🚀
