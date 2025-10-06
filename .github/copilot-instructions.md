# GymAI - Mobile-First Workout Tracker

## Architecture Overview

This is a **Flutter 3.24+ multi-platform app** (iOS, Android, Web) built with **Clean Architecture** and **offline-first design**. The app follows a strict feature-based module structure with clear separation of concerns.

### Core Tech Stack
- **State Management**: Riverpod (hooks_riverpod) - providers are the single source of truth
- **Database**: Drift (SQLite) for local storage + Supabase (PostgreSQL) for cloud sync
- **Navigation**: go_router with deep links and route parameters
- **Backend**: Supabase for auth, storage, and real-time sync
- **Code Generation**: build_runner for Drift, JSON serialization

## Key Architectural Patterns

### 1. Database-First Design
- **Drift schema** is defined in `lib/src/core/database/database.dart` 
- All models extend Drift tables (e.g., `WorkoutSessions`, `SetEntries`)
- **Critical**: Run `flutter packages pub run build_runner build` after schema changes
- Database migrations are handled in `AppDatabase.migration` strategy

### 2. Feature Module Structure
```
lib/src/features/[feature]/
├── domain/           # Business logic, entities
├── presentation/     # Screens, widgets, providers
```

### 3. Provider Hierarchy
- **Core providers** in `lib/src/core/providers/` (database, auth)
- **Feature providers** follow naming: `[entity][Action]Provider` (e.g., `workoutSessionProvider`)
- **Always** watch providers in widgets, don't call `.read()` in build methods

### 4. Offline-First with Sync
- Local SQLite is primary data store
- Supabase sync happens in background via repository pattern
- Optimistic UI updates - write local first, sync later
- Web platform uses Supabase directly (no SQLite)

## Development Workflows

### Essential Commands
```bash
# Code generation (required after model/database changes)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Clean build (if build_runner issues)
flutter packages pub run build_runner clean
flutter clean && flutter pub get

# Testing with coverage
flutter test --coverage

# Format code (enforced in CI)
dart format .
```

### Environment Setup
1. Copy `.env.example` to `.env` and configure Supabase credentials
2. For Supabase: Set up storage bucket `gym-images` with public access
3. Web builds require CORS configuration in Supabase dashboard

### Platform-Specific Considerations
- **Web**: Database provider returns `null`, falls back to Supabase-only
- **Mobile**: Uses SQLite + Supabase sync
- **Testing**: Use `AppDatabase.forTesting()` for in-memory database

## Critical Code Patterns

### 1. Database Operations
```dart
// Always use repositories, not direct database access
final repository = ref.watch(workoutRepositoryProvider);
await repository.createWorkoutSession(session);

// Drift queries use generated code
final sessions = await database.select(database.workoutSessions).get();
```

### 2. Riverpod State Management
```dart
// Provider definition
final workoutSessionProvider = StreamProvider.family<WorkoutSession?, String>((ref, id) {
  final database = ref.watch(databaseProvider);
  return database.watchWorkoutSession(id);
});

// Usage in widgets
class WorkoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider(sessionId));
    return session.when(
      data: (data) => WorkoutView(session: data),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### 3. Navigation Patterns
- Use `context.goNamed()` with route names, not paths
- Pass data via route parameters or query parameters
- Route definitions in `lib/src/core/routing/app_router.dart`

### 4. Exercise System Architecture
- **Comprehensive exercise library** with 100+ exercises across categories (strength, calisthenics, yoga, cardio)
- **Exercise variants**: Parent-child relationships for progressions/regressions
- **Categories**: `strength`, `calisthenics`, `yoga`, `cardio`
- **Types**: `reps`, `timer`, `body_weighted`, `assisted`
- **Difficulty levels**: `beginner`, `intermediate`, `advanced`, `expert`

## Data Model Key Concepts

### Exercise System
- **Base exercises** (e.g., `chest_dips`) with **variants** (`weighted_dips`, `assisted_dips`)
- **Muscle groups**: Primary and secondary targeting
- **Equipment types**: From `bodyweight` to specialized gear
- **Exercise types** determine UI: `reps` (weight/reps), `timer` (duration), `body_weighted` (additional weight)

### Workout Flow
1. **Templates** → **Sessions** → **Set Entries**
2. Templates are reusable workout plans
3. Sessions are actual workout instances
4. Set entries contain weight, reps, RPE data

### Social Features (Phase 3)
- **Posts** with images stored in Supabase Storage
- **User profiles** with avatar upload
- **Follow/followers** system with RLS security
- **Real-time updates** via Supabase subscriptions

## Testing Strategy

### Test Structure
- **Unit tests**: Data layer and business logic
- **Widget tests**: UI components with `WidgetTester`
- **Integration tests**: End-to-end user flows
- Use `mocktail` for mocking dependencies

### Critical Testing Points
- Database migrations between schema versions
- Offline/online sync scenarios
- Provider state management edge cases
- Image upload to Supabase Storage

## Common Gotchas

1. **Code Generation**: Always run build_runner after model changes
2. **Web Platform**: Check for `kIsWeb` before using database provider
3. **Riverpod**: Don't call `.read()` in build methods, use `.watch()`
4. **Supabase Storage**: Ensure CORS is configured for web uploads
5. **Navigation**: Use route names, not direct paths for type safety
6. **Database Migrations**: Test migration paths when changing schema
7. **Analysis Options**: Code must pass strict lint rules - no implicit casts/dynamics

## Key Files to Understand
- `lib/src/core/database/database.dart` - Schema and migrations
- `lib/src/core/routing/app_router.dart` - Navigation structure  
- `lib/src/app.dart` - App-level configuration
- `pubspec.yaml` - Dependencies and versions
- `analysis_options.yaml` - Strict linting rules
- `.env.example` - Required environment variables

When working on this codebase, prioritize understanding the Drift database schema, Riverpod provider relationships, and the offline-first architecture patterns.