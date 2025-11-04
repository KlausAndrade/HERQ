#!/bin/bash

# 📱 Build Android APK Release
# Usage: ./build_apk.sh

echo "📱 Building Android APK Release..."

# Load environment variables from .env file (if it exists)
if [ -f .env ]; then
  echo "📋 Loading environment variables from .env..."
  export $(cat .env | grep -v '^#' | xargs)
else
  echo "⚠️  No .env file found. Using environment variables or compile-time constants."
fi

# Build APK with all environment variables and optimizations
# Using --split-per-abi to create smaller architecture-specific APKs
flutter build apk --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY \
  --dart-define=ADMIN_EMAILS=$ADMIN_EMAILS

echo "✅ APK built successfully!"
echo ""
echo "📁 Architecture-specific APKs created:"
echo "   - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (32-bit ARM)"
echo "   - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (64-bit ARM - most common)"
echo "   - build/app/outputs/flutter-apk/app-x86_64-release.apk (64-bit Intel)"
echo ""
echo "💡 Tip: Use app-arm64-v8a-release.apk for most modern Android devices"
echo "📊 Each APK is significantly smaller than a universal APK"
