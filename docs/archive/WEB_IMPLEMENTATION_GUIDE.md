# GymAI Web Platform Implementation Guide

## Current Status

### ✅ Phase 1: Web Platform Running (COMPLETE)
The web app is now successfully running with a "Coming Soon" page that:
- Initializes Supabase for authentication and data sync
- Shows mobile app features and download links
- Avoids SQLite/FFI compilation issues on web

### 🚧 Phase 2: Production Web App (IN PROGRESS)

## Web Platform Architecture

### Challenge: SQLite Not Available on Web
- **Problem**: Flutter web doesn't support `dart:ffi`, which Drift/SQLite requires
- **Mobile Strategy**: Uses SQLite (Drift) + Supabase sync
- **Web Strategy Options**:
  1. **Supabase-only** (Recommended for MVP)
  2. **Drift Web** (Uses IndexedDB instead of SQLite)
  3. **Hybrid approach** (Supabase primary, IndexedDB cache)

### Current Implementation

#### Entry Points
1. **`lib/main.dart`** - Mobile/Desktop (uses SQLite)
2. **`lib/main_web.dart`** - Full web app (attempted, has compilation issues)
3. **`lib/main_web_simple.dart`** - Working "Coming Soon" page ✅

#### Files Created
- `/lib/main_web_simple.dart` - Simplified web entry point
- `/lib/src/core/database/database_web.dart` - Web database implementation (incomplete)
- `/lib/src/core/database/database_stub.dart` - Stub for web (fallback)
- `/lib/src/core/database.dart` - Conditional export library

## Next Steps to Production Web App

### Option A: Supabase-Only Web App (Fastest)

1. **Remove local database dependency on web**
   - All data stored/retrieved from Supabase directly
   - No offline support (requires internet)
   - Simpler architecture

2. **Create web-specific providers**
   ```dart
   // lib/src/features/workout/presentation/providers/workout_providers_web.dart
   final workoutSessionsProvider = StreamProvider<List<WorkoutSession>>((ref) {
     final supabase = Supabase.instance.client;
     return supabase
       .from('workout_sessions')
       .stream(primaryKey: ['id'])
       .map((data) => data.map((e) => WorkoutSession.fromJson(e)).toList());
   });
   ```

3. **Update main_web.dart**
   ```dart
   runApp(
     ProviderScope(
       overrides: [
         // Use web-specific providers
         workoutSessionsProvider.overrideWith(workoutSessionsWebProvider),
       ],
       child: const GymAIApp(),
     ),
   );
   ```

### Option B: Drift Web (IndexedDB) + Supabase (More Complex)

1. **Complete database_web.dart**
   - Uses `drift/web.dart` instead of `drift/native.dart`
   - Stores data in browser's IndexedDB
   - Syncs with Supabase in background

2. **Generate drift code for web**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

3. **Update conditional imports**
   ```dart
   import 'database/database.dart' 
     if (dart.library.html) 'database/database_web.dart';
   ```

### Option C: Feature-Flagged Rollout

1. **Phase 1: Auth only**
   - Web users can login/signup
   - View-only mode for workouts synced from mobile

2. **Phase 2: Core features**
   - Workout logging (Supabase-only)
   - Progress viewing

3. **Phase 3: Full feature parity**
   - Offline support via IndexedDB
   - All social features

## Running the Web App

### Current Working Version (Coming Soon Page)
```bash
flutter run -d chrome --web-port 8080 --target lib/main_web_simple.dart
```

### Production Version (When Ready)
```bash
flutter run -d chrome --web-port 8080 --target lib/main_web.dart
```

### Build for Deployment
```bash
flutter build web --target lib/main_web.dart --release
```

## Compilation Issues Encountered

### Issue: SQLite FFI on Web
**Error**: `Only JS interop members may be 'external'` in sqlite3 package

**Cause**: 
- `lib/main_web.dart` imports `src/app.dart`
- `app.dart` uses `app_router.dart`
- Router imports screens that import database
- Database imports `dart:io` and `drift/native.dart` (not web-compatible)

**Solutions Tried**:
1. ✅ Conditional imports in `database_provider.dart`
2. ✅ Created `database_stub.dart` for web
3. ❌ Conditional imports in all screens (too many files)
4. ✅ Simplified web entry point (working)
5. 🚧 Complete Drift web implementation (in progress)

## Recommendations

### For MVP (Fastest Path to Production Web)

1. **Use Supabase-Only Architecture**
   - No local database on web
   - Direct Supabase queries
   - Real-time subscriptions for updates

2. **Feature Subset**
   - Authentication ✅
   - Workout logging ✅
   - Progress viewing ✅
   - Social features ✅
   - Offline support ❌ (web limitation)

3. **Migration Path**
   ```dart
   // Check if database is available (null on web)
   final database = ref.watch(databaseProvider);
   
   if (database != null) {
     // Mobile: use local database
     return database.watchWorkouts();
   } else {
     // Web: use Supabase directly
     return supabase.from('workouts').stream();
   }
   ```

### For Full Feature Parity

1. **Implement Drift Web**
   - Complete `database_web.dart` with all migrations
   - Use IndexedDB for local storage
   - Sync with Supabase

2. **Update All Providers**
   - Make all providers web-aware
   - Handle both database and Supabase sources

3. **Service Workers**
   - Enable offline support on web
   - Cache API responses
   - Background sync when online

## Files to Modify for Production

### High Priority
- [ ] `/lib/main_web.dart` - Switch from GymAIApp to web-specific app or fix imports
- [ ] `/lib/src/core/database/database_web.dart` - Complete Drift web implementation
- [ ] `/lib/src/features/workout/presentation/providers/workout_providers.dart` - Add web support
- [ ] `/lib/src/features/auth/presentation/providers/auth_provider.dart` - Verify Supabase auth works

### Medium Priority
- [ ] `/lib/src/features/exercises/presentation/providers/*` - Web-aware exercise providers
- [ ] `/lib/src/features/progress/presentation/providers/*` - Web-aware progress providers
- [ ] `/lib/src/features/social/presentation/providers/*` - Already Supabase-based (should work)

### Low Priority
- [ ] Service worker for offline support
- [ ] PWA manifest updates
- [ ] Web-specific UI optimizations

## Testing Strategy

### Web-Specific Tests
```dart
testWidgets('Web platform uses Supabase', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(null), // Simulate web
      ],
      child: const GymAIApp(),
    ),
  );
  
  // Verify Supabase is used when database is null
  expect(find.text('Login'), findsOneWidget);
});
```

## Current Deployment

### Development
- **URL**: http://localhost:8080
- **Entry**: `lib/main_web_simple.dart`
- **Status**: ✅ Working "Coming Soon" page

### Production (When Ready)
- **Build**: `flutter build web --release --target lib/main_web.dart`
- **Deploy**: Upload `build/web/` to hosting (Vercel, Netlify, Firebase)
- **Env**: Ensure `.env` variables are configured in hosting platform

## Environment Variables

Required for web:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Browser Compatibility

### Supported
- ✅ Chrome 90+
- ✅ Edge 90+
- ✅ Firefox 88+
- ✅ Safari 14+

### Required Features
- IndexedDB (for Drift Web)
- Local Storage (for settings)
- WebSockets (for Supabase realtime)

## Known Limitations

1. **No Offline Support** (in current simple version)
   - Requires internet connection
   - Data not cached locally

2. **No Background Services**
   - No workout reminders
   - No background sync

3. **Limited File System Access**
   - Export/import must use downloads
   - No direct file picking

4. **Performance**
   - Slower than native
   - Large datasets may lag

## Future Enhancements

1. **Progressive Web App (PWA)**
   - Install as desktop app
   - Offline support
   - Push notifications (limited)

2. **Responsive Design**
   - Optimize for desktop screens
   - Better keyboard navigation
   - Mouse-friendly UI

3. **Web-Specific Features**
   - Print workout logs
   - Export to PDF
   - Share workout links

---

**Last Updated**: October 7, 2025
**Status**: Web platform running with "Coming Soon" page. Production implementation pending architecture decision (Supabase-only vs Drift Web).
