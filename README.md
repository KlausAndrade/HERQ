# HERQ

A strength training app for logging workouts and tracking progress. Built with Flutter, runs on iOS, Android and web, and works offline.

**Demo:** https://youtube.com/shorts/n8AfpkKckw0

## Features

- Workout templates and set logging (weight, reps, RPE)
- Rest timer that keeps running in the background
- Works offline with a local SQLite database, syncs to Supabase when online
- Progress charts, personal records and 1RM estimates
- Workout history calendar
- Friends, activity feed and leaderboards
- Workout suggestions based on recent training
- Light and dark theme

## Tech stack

- Flutter / Dart
- Riverpod for state management
- go_router for navigation
- Drift (SQLite) for local storage
- Supabase for auth and sync
- fl_chart for charts
- GitHub Actions for CI

## Project structure

```
lib/src/
├── core/        # database, models, routing, theme
└── features/    # home, workout, exercises, progress, settings
```

## Getting started

Requires Flutter 3.13 or later.

```bash
git clone https://github.com/KlausAndrade/HERQ.git
cd HERQ
flutter pub get
cp .env.example .env   # add your Supabase URL and anon key
flutter packages pub run build_runner build
flutter run            # or: flutter run -d chrome
```

See [ENV_SETUP.md](ENV_SETUP.md) and [QUICK_START.md](QUICK_START.md) for more detail.

## Tests

```bash
flutter test
```

## License

MIT
