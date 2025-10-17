#!/bin/bash

# 📱 Build Android APK Release
# Usage: ./build_apk.sh

echo "📱 Building Android APK Release..."

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

# Build APK with all environment variables
flutter build apk --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY \
  --dart-define=ADMIN_EMAILS=$ADMIN_EMAILS

echo "✅ APK built successfully!"
echo "📁 Location: build/app/outputs/flutter-apk/app-release.apk"
