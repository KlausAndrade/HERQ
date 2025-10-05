# 🏋️ GymAI - Mobile-First Workout Tracker

[![CI/CD Pipeline](https://github.com/username/gym-ai/actions/workflows/ci.yml/badge.svg)](https://github.com/username/gym-ai/actions/workflows/ci.yml)
[![Flutter Version](https://img.shields.io/badge/flutter-3.13.0-blue.svg)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-ready, mobile-first workout tracker built with Flutter that runs seamlessly on iOS, Android, and Web. Designed to feel fast during workouts, flexible for power users, and ready to scale into social features and AI coaching.

## 📱 Screenshots

*[Screenshots will be added as the app develops]*

## ✨ Features

### ✅ Phase 1 - Core Workout Tracking (Current)
- **🏋️ Workout Management**
  - Create and run workouts from templates
  - Real-time set logging with weight, reps, and RPE tracking
  - Smart rest timer with background persistence
  - Volume and tonnage calculations
  
- **📊 Data & Persistence**
  - Offline-first architecture with local SQLite database
  - Zero-friction set entry optimized for mobile
  - Data persistence across app restarts
  
- **🎨 User Experience**
  - Mobile-first responsive design
  - Light/Dark theme support
  - Intuitive bottom navigation
  - Thumb-reachable controls

- **🏗️ Technical Foundation**
  - Clean Architecture implementation
  - Riverpod state management
  - Go Router navigation
  - Comprehensive test coverage

### ✅ Phase 2 - Sync & Analytics (Completed)
- **☁️ Cloud Sync & Authentication**
  - Supabase integration for data synchronization
  - User authentication (email + OAuth)
  - Conflict resolution with last-write-wins strategy
  - Offline queue with retry logic
  
- **📈 Progress Tracking**
  - Interactive charts with fl_chart
  - Personal record (PR) tracking
  - 1RM calculations (Epley/Brzycki formulas)
  - Workout history calendar
  - Volume and strength progression analytics

### ✅ Phase 3 - Social & AI Features (NEW!)
- **👥 Social Network**
  - Connect with friends and share achievements
  - Activity feed showing friends' workouts and PRs
  - User search and friend management
  - Achievement system with unlockable badges
  
- **🏆 Competitive Features**
  - Leaderboards (volume, workout count, streaks, PRs)
  - Rankings across different time periods
  - Social challenges and milestones
  - Performance comparisons with friends
  
- **🤖 AI-Powered Coaching**
  - Personalized workout recommendations
  - Progressive overload suggestions based on performance
  - Recovery analysis with fatigue assessment
  - Exercise substitutions for equipment limitations
  - Form tips and training advice
  - Smart deload week recommendations
  
- **🔄 Background Sync**
  - Optimistic UI updates
  - Background synchronization
  - Network-aware retry mechanisms

### ☐ Phase 3 - Social & AI (Planned)
- **👥 Social Features**
  - Friend connections and activity feeds
  - PR sharing and leaderboards
  - Workout plan sharing
  
- **🤖 AI Coaching**
  - Personalized workout suggestions
  - Recovery and fatigue analysis
  - Progressive overload recommendations
  - Smart exercise substitutions

## 🏗️ Architecture

The app follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── src/
│   ├── core/                    # Shared core functionality
│   │   ├── database/           # Drift database setup
│   │   ├── models/             # Domain entities
│   │   ├── providers/          # Core providers
│   │   ├── routing/            # Go Router configuration
│   │   └── theme/              # App theming
│   ├── features/               # Feature modules
│   │   ├── home/               # Home dashboard
│   │   ├── workout/            # Workout management
│   │   ├── exercises/          # Exercise library
│   │   ├── progress/           # Progress tracking
│   │   └── settings/           # App settings
│   └── generated/              # Generated code (l10n, etc.)
└── test/                       # Test files
```

### Data Flow Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Presentation  │────│   Application   │────│      Data       │
│   (Widgets)     │    │   (Providers)   │    │ (Repositories)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                      │
                              ┌─────────────────────┬─┴─────────────────────┐
                              │                     │                       │
                         ┌────▼────┐          ┌────▼────┐            ┌────▼────┐
                         │  Local  │          │  Remote │            │  Cache  │
                         │Database │          │   API   │            │ Manager │
                         │(Drift)  │          │(Supabase)│           │         │
                         └─────────┘          └─────────┘            └─────────┘
```

## 🚀 Tech Stack

- **Framework**: Flutter 3.13.0+ with sound null safety
- **State Management**: Riverpod (hooks_riverpod)
- **Routing**: go_router with deep links
- **Database**: Drift (SQLite) with schema versioning
- **Backend**: Supabase (Authentication + Postgres)
- **Charts**: fl_chart for progress visualization
- **Localization**: flutter_localizations + intl
- **Testing**: flutter_test + mocktail + golden_toolkit
- **CI/CD**: GitHub Actions

### Why These Choices?

- **Riverpod**: Compile-time safe state management with excellent testing support
- **Drift**: Type-safe SQL with robust migration system for offline-first apps
- **Supabase**: Open-source backend with real-time sync and PostgreSQL
- **Go Router**: Declarative routing with deep link support for web compatibility

## 🏃‍♂️ Getting Started

### Prerequisites

- Flutter SDK (3.13.0 or later)
- Dart SDK (included with Flutter)
- Android Studio / Xcode for mobile development
- Chrome for web development

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/username/gym-ai.git
   cd gym-ai
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the app**
   ```bash
   # Mobile (iOS/Android)
   flutter run
   
   # Web
   flutter run -d chrome
   ```

### Supabase Setup (Phase 2)

1. Create a new project at [supabase.com](https://supabase.com)
2. Copy your project URL and anon key to `.env`
3. Run the database migrations (coming in Phase 2)

## 🗃️ Database Schema

The app uses a robust SQLite schema with support for migrations:

### Core Tables

- **Users**: User profiles and preferences
- **Exercises**: Exercise library with muscle groups and equipment
- **WorkoutTemplates**: Reusable workout plans
- **WorkoutSessions**: Individual workout instances
- **SetEntries**: Individual set data (weight, reps, RPE)
- **PersonalRecords**: Best performances tracking

### Data Model Example

```dart
// Workout Session
WorkoutSession {
  id: String
  name: String
  startedAt: DateTime
  completedAt: DateTime?
  totalVolume: double
  totalTonnage: double
  totalSets: int
  totalReps: int
}

// Set Entry
SetEntry {
  id: String
  workoutSessionId: String
  exerciseId: String
  setNumber: int
  weight: double?
  reps: int
  rpe: int? // Rate of Perceived Exertion (1-10)
  restDurationSeconds: int?
  isWarmup: bool
  completedAt: DateTime
}
```

## 🔄 Offline-First & Sync Design

### Offline Strategy

The app is designed to work completely offline with intelligent sync:

1. **Local-First**: All data written to local SQLite first
2. **Optimistic UI**: Immediate feedback without waiting for network
3. **Sync Queue**: Background upload queue with retry logic
4. **Conflict Resolution**: Last-write-wins with field-level merging

### Sync Architecture (Phase 2)

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Local     │    │   Sync      │    │   Remote    │
│  Database   │◄──►│   Queue     │◄──►│  Database   │
│  (SQLite)   │    │ (Background)│    │ (Supabase)  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │
       │                   ▼
       │            ┌─────────────┐
       │            │  Conflict   │
       └───────────►│ Resolution  │
                    │  Engine     │
                    └─────────────┘
```

### Conflict Resolution Example

```dart
// Field-level merging for workout sessions
WorkoutSession mergeConflict(WorkoutSession local, WorkoutSession remote) {
  return WorkoutSession(
    id: local.id,
    name: remote.updatedAt.isAfter(local.updatedAt) ? remote.name : local.name,
    totalVolume: _mergeNumericField(local.totalVolume, remote.totalVolume),
    sets: _mergeSets(local.sets, remote.sets),
    // Last-write-wins for most fields
    updatedAt: [local.updatedAt, remote.updatedAt].reduce(max),
  );
}
```

## 🧪 Testing

Comprehensive testing strategy covering all architectural layers:

### Test Structure

```bash
test/
├── core/
│   ├── database/          # Database layer tests
│   └── repositories/      # Repository tests
├── features/
│   ├── workout/
│   │   ├── providers/     # State management tests
│   │   └── widgets/       # Widget tests
│   └── ...
├── integration/           # End-to-end tests
└── helpers/              # Test utilities
```

### Running Tests

```bash
# Unit and widget tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Coverage Goals

- **Data Layer**: 95%+ coverage
- **Business Logic**: 90%+ coverage
- **Widget Tests**: Key user flows
- **Golden Tests**: Visual regression for critical screens

## 📊 Performance Considerations

### Mobile Optimization

- **O(1) Set Inserts**: Optimized database writes during workouts
- **Lazy Loading**: List views with pagination for large datasets
- **Minimal Rebuilds**: Riverpod providers with precise dependencies
- **Background Timers**: Rest timer survives app backgrounding

### Web Compatibility

- **Responsive Design**: Breakpoint-based layouts
- **Keyboard Navigation**: Full keyboard support for web users
- **PWA Ready**: Service worker for offline web usage

## 📈 Roadmap

### Phase 1: Core Workout Tracking ✅
- [x] Database schema and migrations
- [x] Workout template system
- [x] Real-time set logging
- [x] Rest timer with background persistence
- [x] Basic UI with light/dark themes
- [x] Offline-first architecture
- [x] Test coverage for core features

### Phase 2: Sync & Analytics ✅
- [x] Supabase authentication integration
- [x] Cloud sync with conflict resolution
- [x] Interactive progress charts
- [x] Personal record tracking
- [x] Workout history calendar
- [x] 1RM calculations and strength metrics
- [x] Enhanced search and filtering
- [x] Data export functionality

### Phase 3: Social & AI ✅
- [x] User profiles and friend connections
- [x] Social feed with workout activity
- [x] Leaderboards and competitions
- [x] AI workout recommendations
- [x] Progressive overload suggestions
- [x] Recovery and fatigue analysis
- [x] Exercise substitutions
- [x] Achievement system

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format` for consistent formatting
- Add tests for new features
- Document public APIs with dartdoc comments

### Quality Gates

All PRs must pass:
- [ ] `flutter analyze` with zero issues
- [ ] `flutter test` with no failing tests
- [ ] Code review approval
- [ ] CI/CD pipeline success

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Supabase Documentation](https://supabase.com/docs)

---

**Built with ❤️ using Flutter**