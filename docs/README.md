# 📚 HERQ Documentation

Welcome to the HERQ documentation! This guide will help you understand, use, and contribute to HERQ.

## 📖 Table of Contents

### For Users
- **[Getting Started](guides/user/getting-started.md)** - Installation and first workout
- **[Features Guide](guides/user/features-guide.md)** - Complete feature walkthrough
- **[Workout Guide](guides/user/workout-guide.md)** - How to log and track workouts

### For Developers
- **[Development Setup](guides/developer/setup.md)** - Local development environment
- **[Architecture](guides/developer/architecture.md)** - Code structure and patterns
- **[Database](guides/developer/database.md)** - Schema and migrations
- **[Testing](guides/developer/testing.md)** - Testing strategy and coverage

### Features Documentation
- **[Workout Tracking](features/workout-tracking.md)** - Core workout features
- **[Templates & Folders](features/templates-and-folders.md)** - Template management
- **[Calendar & History](features/calendar-and-history.md)** - Progress tracking
- **[AI Coaching](features/ai-coaching.md)** - AI-powered recommendations
- **[Social Features](features/social-features.md)** - Friends and leaderboards
- **[Background Features](features/background-features.md)** - Timers, notifications, sync

### Deployment
- **[iOS Deployment](guides/deployment/ios-deployment.md)** - Deploy to App Store
- **[Android Deployment](guides/deployment/android-deployment.md)** - Deploy to Play Store
- **[Web Deployment](guides/deployment/web-deployment.md)** - Deploy to web

### API & Services
- **[Supabase Setup](api/supabase-setup.md)** - Backend configuration
- **[Groq AI Setup](api/groq-ai-setup.md)** - AI coaching integration

### Database & Migrations
- **[SQL Files](sql/README.md)** - All database migration and setup files
- **[User Isolation Setup](guides/USER_ISOLATION_SETUP_GUIDE.md)** - Multi-user data isolation
- **[User Isolation Testing](guides/USER_ISOLATION_TESTING_GUIDE.md)** - Testing procedures

### Setup & Configuration
- **[Multi-Language Setup](guides/MULTI_LANGUAGE_IMPLEMENTATION_SUMMARY.md)** - Internationalization
- **[Translation Testing](guides/TRANSLATION_TESTING_GUIDE.md)** - Translation testing
- **[Exercise Variant System](guides/EXERCISE_VARIANT_SYSTEM.md)** - Exercise management
- **[Email Protection](guides/EMAIL_PROTECTION_GUIDE.md)** - Privacy and security

## 🚀 Quick Links

- [Main README](../README.md) - Project overview
- [Contributing Guide](../CONTRIBUTING.md) - How to contribute
- [License](../LICENSE) - MIT License

## 📦 Project Structure

```
HERQ/
├── lib/src/
│   ├── core/              # Shared functionality
│   ├── features/          # Feature modules
│   └── generated/         # Generated code
├── test/                  # Tests
├── docs/                  # This documentation
│   ├── sql/              # SQL migration files
│   ├── guides/           # Setup and usage guides
│   └── archive/          # Archived documentation
└── README.md             # Project overview
```

## 🔍 Finding What You Need

### I want to...
- **Use the app** → Start with [Getting Started](guides/user/getting-started.md)
- **Understand features** → Check [Features Guide](guides/user/features-guide.md)
- **Develop locally** → Read [Development Setup](guides/developer/setup.md)
- **Deploy the app** → See deployment guides for your platform
- **Understand the code** → Review [Architecture](guides/developer/architecture.md)
- **Add a feature** → Check [Architecture](guides/developer/architecture.md) + [Testing](guides/developer/testing.md)

## 📝 Documentation Standards

- All guides use clear headings and code examples
- Screenshots included for UI-heavy features
- Code snippets are tested and up-to-date
- Each document has a "Last Updated" date

## 🤝 Improving Documentation

Found an error or want to improve docs? 
1. Edit the markdown file
2. Submit a PR with your changes
3. We'll review and merge!

---

Last Updated: October 8, 2025
