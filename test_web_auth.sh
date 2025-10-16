#!/bin/bash

echo "🧪 Testing Web Auth Screen"
echo "=========================="

echo "1. Building web app..."
flutter build web --target lib/main_web.dart

echo "2. Starting web server..."
echo "   Open: http://localhost:8080"
echo "   Look for: 'DEBUG: This is WebAuthScreen with APK download'"
echo "   Look for: 'Download Android APK' button"
echo "   Look for: 'Get the full mobile experience' section"

# Start a simple web server
cd build/web
python3 -m http.server 8080
