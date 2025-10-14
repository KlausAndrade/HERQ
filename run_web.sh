#!/bin/bash

# Script to run HERQ on Chrome (web platform)
# Uses the web-specific entry point that doesn't require SQLite

echo "🌐 Launching HERQ on Chrome..."
flutter run -d chrome -t lib/main_web.dart
