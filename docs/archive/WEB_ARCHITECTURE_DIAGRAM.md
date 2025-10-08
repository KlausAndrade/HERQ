# GymAI Cross-Platform Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           GymAI Application                              │
│                                                                          │
│  ┌──────────────────────┐              ┌──────────────────────┐        │
│  │   Mobile/Desktop     │              │        Web            │        │
│  │   (iOS/Android/Mac)  │              │     (Browser)         │        │
│  └──────────────────────┘              └──────────────────────┘        │
│           │                                       │                      │
│           │                                       │                      │
│  ┌────────▼────────────┐              ┌──────────▼──────────┐          │
│  │                     │              │                     │          │
│  │   UI Layer (Widgets)│              │   UI Layer (Widgets)│          │
│  │                     │              │                     │          │
│  └────────┬────────────┘              └──────────┬──────────┘          │
│           │                                       │                      │
│           │                                       │                      │
│  ┌────────▼────────────┐              ┌──────────▼──────────┐          │
│  │                     │              │                     │          │
│  │  Riverpod Providers │              │  Riverpod Providers │          │
│  │  (Business Logic)   │              │  (Business Logic)   │          │
│  │                     │              │                     │          │
│  │  if (!kIsWeb) {     │              │  if (kIsWeb) {      │          │
│  │    use Drift        │              │    use Supabase     │          │
│  │  }                  │              │  }                  │          │
│  └────────┬────────────┘              └──────────┬──────────┘          │
│           │                                       │                      │
│      ┌────┴─────┐                            ┌───┴─────┐               │
│      │          │                            │         │               │
│  ┌───▼───┐  ┌──▼──────┐                  ┌──▼─────────▼───┐           │
│  │ Drift │  │ Supabase│                  │    Supabase     │           │
│  │ (SQLite)│  │ Sync    │                  │  Direct Access  │           │
│  └───┬───┘  └──┬──────┘                  └─────────┬───────┘           │
│      │          │                                   │                   │
│      │ ┌────────▼──────────────────────────────────▼────────┐          │
│      │ │                                                     │          │
│      │ │         Supabase Backend (PostgreSQL)              │          │
│      │ │                                                     │          │
│      │ │  • User Authentication (Auth)                      │          │
│      │ │  • Data Storage (Database)                         │          │
│      │ │  • File Storage (Storage)                          │          │
│      │ │  • Real-time Subscriptions                         │          │
│      │ │  • Row Level Security (RLS)                        │          │
│      │ │                                                     │          │
│      │ └─────────────────────────────────────────────────────┘          │
│      │                                                                  │
│      └── Background Sync (when online)                                 │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Mobile/Desktop Flow

```
┌─────────────┐
│   User      │
│  Action     │
└──────┬──────┘
       │
       │  1. User logs workout
       ▼
┌──────────────────┐
│   Provider       │  Check platform
│  if (!kIsWeb)    │
└──────┬───────────┘
       │
       │  2. Write to local DB
       ▼
┌──────────────────┐
│  Drift (SQLite)  │  ← Fast, Offline-capable
│  Local Database  │
└──────┬───────────┘
       │
       │  3. Background sync
       ▼
┌──────────────────┐
│    Supabase      │  ← Cloud backup
│   PostgreSQL     │
└──────────────────┘
```

### Web Flow

```
┌─────────────┐
│   User      │
│  Action     │
└──────┬──────┘
       │
       │  1. User logs workout
       ▼
┌──────────────────┐
│   Provider       │  Check platform
│  if (kIsWeb)     │
└──────┬───────────┘
       │
       │  2. Direct write to Supabase
       ▼
┌──────────────────┐
│    Supabase      │  ← Only source of truth
│   PostgreSQL     │
│                  │
│  • Real-time     │
│  • No sync needed│
│  • Requires net  │
└──────────────────┘
```

## Provider Pattern

### Example: Workout Sessions Provider

```dart
final workoutSessionsProvider = StreamProvider<List>((ref) async* {
  // ┌─────────────────────────────────┐
  // │   Platform Detection            │
  // └─────────────────────────────────┘
  
  if (kIsWeb) {
    // ┌─────────────────────────────────┐
    // │   WEB PATH                      │
    // │   Direct Supabase Access        │
    // └─────────────────────────────────┘
    final supabase = Supabase.instance.client;
    
    await for (final data in supabase
        .from('workout_sessions')
        .stream(primaryKey: ['id'])
        .order('started_at', ascending: false)) {
      yield data; // Returns List<Map<String, dynamic>>
    }
    
  } else {
    // ┌─────────────────────────────────┐
    // │   MOBILE/DESKTOP PATH           │
    // │   Local Database (Drift)        │
    // └─────────────────────────────────┘
    final database = ref.read(databaseProvider);
    
    if (database != null) {
      await for (final sessions in 
          database.select(database.workoutSessions).watch()) {
        yield sessions; // Returns List<WorkoutSession>
      }
    }
  }
});
```

## File Structure

```
lib/
├── main.dart                          # Mobile/Desktop entry point
├── main_web.dart                      # Web entry point (production)
├── main_web_simple.dart               # Web entry point (landing page)
│
└── src/
    ├── core/
    │   ├── database/
    │   │   ├── database.dart          # Drift schema (mobile only)
    │   │   └── database_stub.dart     # Empty stub for web
    │   │
    │   ├── providers/
    │   │   ├── database_provider.dart # Mobile: Drift, Web: null
    │   │   └── auth_provider.dart     # Shared: Supabase auth
    │   │
    │   └── data/                      # Optional: Repository pattern
    │       ├── dto/                   # Platform-agnostic models
    │       └── repositories/          # Abstract data access
    │
    └── features/
        └── workout/
            └── presentation/
                └── providers/
                    └── workout_providers.dart  # Platform-aware!
                                                # Check kIsWeb inside
```

## Migration Strategy

### Phase 1: Current State ✅
```
Mobile: [SQLite] → [Supabase Sync]
Web:    [Coming Soon Page]
```

### Phase 2: After Migration 🎯
```
Mobile: [SQLite] → [Supabase Sync]
Web:    [Supabase Direct] ← Same backend!
```

### Benefits
```
┌─────────────────────────────────────┐
│  Single Source of Truth             │
│  • All data in Supabase             │
│  • Mobile syncs to it               │
│  • Web reads/writes directly        │
│  • Real-time updates everywhere     │
└─────────────────────────────────────┘
```

## Code Patterns

### Pattern 1: Platform Check in Provider

```dart
if (kIsWeb) {
  // Web logic - use Supabase
} else {
  // Mobile logic - use Drift
}
```

### Pattern 2: Repository Pattern (Optional)

```dart
abstract class WorkoutRepository {
  Stream<List> watchWorkouts();
}

class MobileWorkoutRepository implements WorkoutRepository {
  // Uses Drift
}

class WebWorkoutRepository implements WorkoutRepository {
  // Uses Supabase
}

// Provider selects implementation
final workoutRepo = kIsWeb 
  ? WebWorkoutRepository()
  : MobileWorkoutRepository();
```

### Pattern 3: Direct in Widget (Not Recommended)

```dart
Widget build(BuildContext context) {
  if (kIsWeb) {
    // Fetch from Supabase
  } else {
    // Fetch from Drift
  }
}
```

## Security Model

```
┌──────────────────────────────────────────────────────────────┐
│                    Supabase Security                          │
│                                                               │
│  ┌────────────────────┐         ┌──────────────────────┐    │
│  │  Authentication    │         │  Row Level Security   │    │
│  │                    │         │  (RLS)                │    │
│  │  • Email/Password  │         │                       │    │
│  │  • OAuth (Google)  │────────▶│  Users can only see   │    │
│  │  • Magic Links     │         │  their own data       │    │
│  └────────────────────┘         └──────────────────────┘    │
│           │                                │                 │
│           │                                │                 │
│           ▼                                ▼                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              PostgreSQL Database                      │   │
│  │                                                       │   │
│  │  CREATE POLICY "user_workouts"                       │   │
│  │    ON workout_sessions                               │   │
│  │    USING (auth.uid() = user_id);                     │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

## Performance Considerations

### Mobile
- ✅ Local queries are instant (SQLite)
- ✅ Works offline
- ⚠️ Sync latency (but async, so user doesn't wait)

### Web  
- ⚠️ Network latency (~50-200ms)
- ✅ Real-time updates via WebSocket
- ✅ Supabase caching layer
- 💡 Can add browser caching later

## Summary

| Feature | Mobile | Web |
|---------|--------|-----|
| **Primary Data Store** | SQLite (Drift) | Supabase |
| **Backup/Sync** | Supabase | N/A |
| **Offline Support** | ✅ Full | ❌ No |
| **Real-time** | Via sync | ✅ Built-in |
| **Complexity** | Medium | Low |
| **Speed** | Very Fast | Fast |
| **Maintenance** | More code | Less code |

---

**Key Insight**: Both platforms ultimately use Supabase, but mobile has a local cache for offline support and better performance.
