# 🛠️ Development Setup Guide

> **Last Updated:** October 8, 2025  
> **Prerequisites:** Flutter 3.24+, Dart 3.5+

This guide will help you set up your local development environment for GymAI.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Environment Configuration](#environment-configuration)
4. [Database Setup](#database-setup)
5. [Running the App](#running-the-app)
6. [Development Workflow](#development-workflow)
7. [Troubleshooting](#troubleshooting)

---

## ✅ Prerequisites

### Required Software

- **Flutter SDK**: 3.24.0 or later
- **Dart SDK**: 3.5.0+ (included with Flutter)
- **Git**: Latest version
- **IDE**: VS Code or Android Studio recommended

### Platform-Specific Requirements

#### iOS Development
- **macOS**: 12.0 (Monterey) or later
- **Xcode**: 15.0 or later
- **CocoaPods**: Latest version
- **iOS Simulator** or physical device

#### Android Development
- **Android Studio**: Latest version
- **Android SDK**: API 26 (Android 8.0) minimum
- **Java**: JDK 17 or later
- **Android Emulator** or physical device

#### Web Development
- **Chrome**: Latest version (for debugging)
- **Any modern browser** for testing

### Optional Tools

- **VS Code Extensions**:
  - Flutter
  - Dart
  - GitLens
  - Error Lens
  - Better Comments

- **macOS Utilities**:
  - Homebrew (package manager)
  - SourceTree or GitKraken (Git GUI)

---

## 🚀 Initial Setup

### 1. Install Flutter

```bash
# macOS (using Homebrew)
brew install flutter

# Or download from flutter.dev
# https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor
```

### 2. Clone the Repository

```bash
git clone https://github.com/KlausAndrade/gymai.git
cd gymai
```

### 3. Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# Install iOS dependencies (macOS only)
cd ios && pod install && cd ..
```

### 4. Run Code Generation

```bash
# Generate Drift database code, JSON serialization, etc.
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerates on file changes)
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

---

## 🔐 Environment Configuration

### 1. Create Environment File

```bash
cp .env.example .env
```

### 2. Configure `.env` File

Edit `.env` with your configuration:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Groq AI Configuration (for AI coaching)
GROQ_API_KEY=your-groq-api-key-here

# Environment
ENVIRONMENT=development

# Feature Flags
ENABLE_SOCIAL_FEATURES=true
ENABLE_AI_COACHING=true
ENABLE_ANALYTICS=true
```

### 3. Get API Keys

#### Supabase Setup

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Get your project URL and anon key from Settings → API
4. Run database migrations (see [Supabase Setup](../api/supabase-setup.md))

#### Groq AI Setup

1. Go to [console.groq.com](https://console.groq.com)
2. Create an account
3. Generate an API key
4. Add to `.env` file

See [Groq AI Setup Guide](../api/groq-ai-setup.md) for details.

---

## 🗄️ Database Setup

### Local Development (SQLite)

The app uses **Drift** (SQLite) for local database:

```dart
// Database is automatically created on first run
// Location:
// - iOS: /Library/Application Support/
// - Android: /data/data/com.gymAI.app/databases/
// - Web: IndexedDB (Supabase only)
```

### Database Migrations

Migrations are handled automatically by Drift:

```dart
// lib/src/core/database/database.dart

@DriftDatabase(tables: [
  WorkoutSessions,
  SetEntries,
  Exercises,
  // ...
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5; // Current version

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Run migrations based on version
      if (from < 2) {
        // Add columns for version 2
      }
      if (from < 3) {
        // Add columns for version 3
      }
      // ... etc
    },
  );
}
```

### Viewing Database (Debug)

#### iOS Simulator

```bash
# Find database file
xcrun simctl get_app_container booted com.gymAI.app data

# Copy database to desktop
cp ~/Library/Developer/CoreSimulator/.../gymAI.db ~/Desktop/
```

#### Android Emulator

```bash
adb shell
run-as com.gymAI.app
cd databases
cat gymAI.db > /sdcard/gymAI.db
exit
adb pull /sdcard/gymAI.db ~/Desktop/
```

#### Database Viewer Tools

- **DB Browser for SQLite** (Free, cross-platform)
- **TablePlus** (Paid, macOS/Windows)
- **DBeaver** (Free, cross-platform)

---

## ▶️ Running the App

### Mobile (iOS/Android)

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode (default)
flutter run

# Run in profile mode (performance testing)
flutter run --profile

# Run in release mode
flutter run --release

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
# Quit: Press 'q'
```

### Web

```bash
# Run in Chrome
flutter run -d chrome

# Run on specific port
flutter run -d chrome --web-port 8080

# Run in headless mode
flutter run -d web-server --web-port 8080
```

### Platform-Specific Builds

```bash
# iOS
flutter run -d iPhone

# Android
flutter run -d emulator-5554

# Web
flutter run -d chrome

# macOS (if enabled)
flutter run -d macos

# All platforms in watch mode
flutter run --hot
```

---

## 🔄 Development Workflow

### Daily Workflow

1. **Pull latest changes**
   ```bash
   git pull origin main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Run code generation (if needed)**
   ```bash
   flutter packages pub run build_runner watch
   ```

4. **Start development**
   ```bash
   flutter run
   ```

5. **Make changes, test, commit**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/your-feature-name
   ```

### Code Generation Commands

```bash
# Full rebuild (clean and generate)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter packages pub run build_runner watch

# Clean generated files
flutter packages pub run build_runner clean
```

### Common Commands

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Clean build cache
flutter clean
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

### VS Code Launch Configurations

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Debug)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": []
    },
    {
      "name": "Flutter (Profile)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "flutterMode": "profile"
    },
    {
      "name": "Flutter (Release)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "flutterMode": "release"
    },
    {
      "name": "Flutter Web",
      "type": "dart",
      "request": "launch",
      "program": "lib/main_web.dart",
      "args": ["-d", "chrome"]
    }
  ]
}
```

---

## 🐛 Troubleshooting

### Flutter Doctor Issues

```bash
# Run flutter doctor
flutter doctor -v

# Fix common issues
flutter doctor --android-licenses  # Accept Android licenses
sudo xcode-select --switch /Applications/Xcode.app  # Fix Xcode path
```

### Build Runner Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Pod Install Issues (iOS)

```bash
cd ios
pod deintegrate
pod repo update
pod install
cd ..
```

### Gradle Issues (Android)

```bash
cd android
./gradlew clean
./gradlew assembleDebug
cd ..
```

### Common Errors

#### Error: "Supabase URL not found"
- Check `.env` file exists
- Verify `SUPABASE_URL` is set
- Restart app after changing `.env`

#### Error: "Build runner conflicts"
- Delete `build` folder
- Run `flutter clean`
- Run build_runner with `--delete-conflicting-outputs`

#### Error: "Pod install failed"
- Update CocoaPods: `sudo gem install cocoapods`
- Clear cache: `pod cache clean --all`
- Try `pod install --repo-update`

#### Error: "Gradle build failed"
- Check Java version: `java -version` (need JDK 17)
- Clear Gradle cache: `rm -rf ~/.gradle/caches/`
- Sync gradle files in Android Studio

---

## 🧪 Testing Setup

### Unit Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/workout/workout_test.dart

# Run tests with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Widget Tests

```bash
# Run widget tests
flutter test test/features/workout/screens/

# Run with golden file generation
flutter test --update-goldens
```

### Integration Tests

```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d iPhone
```

---

## 📊 Performance Profiling

### DevTools

```bash
# Run app in profile mode
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Performance Overlay

```dart
// Add to MaterialApp
MaterialApp(
  showPerformanceOverlay: true,
  // ...
)
```

---

## 🔒 Security Best Practices

1. **Never commit `.env` file**
   - Add to `.gitignore`
   - Use `.env.example` for template

2. **Use environment-specific configs**
   - Development, Staging, Production
   - Different Supabase projects per environment

3. **Keep API keys secure**
   - Use Supabase RLS policies
   - Never expose keys in client code
   - Rotate keys regularly

---

## 📚 Next Steps

- [Architecture Guide](architecture.md) - Understand the codebase
- [Database Guide](database.md) - Learn about the database schema
- [Testing Guide](testing.md) - Write tests
- [Deployment Guide](../deployment/ios-deployment.md) - Deploy to production

---

## 🤝 Getting Help

- **Documentation**: Check other guides in `/docs`
- **Issues**: [GitHub Issues](https://github.com/KlausAndrade/gymai/issues)
- **Discussions**: [GitHub Discussions](https://github.com/KlausAndrade/gymai/discussions)
- **Discord**: [Join our server](#) (coming soon)

---

**Happy Coding! 🚀**

