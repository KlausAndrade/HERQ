#!/bin/bash

# 🌐 Build Web for GitHub Pages
# Usage: ./build_web.sh

echo "🌐 Building Web for GitHub Pages..."

# Load environment variables from .env file (if it exists)
if [ -f .env ]; then
  echo "📋 Loading environment variables from .env..."
  export $(cat .env | grep -v '^#' | xargs)
else
  echo "⚠️  No .env file found. Using environment variables or compile-time constants."
fi

# Get version from package.json
VERSION=$(node -p "require('./package.json').version")
BUILD_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
BUILD_NUMBER=$(git rev-parse --short HEAD 2>/dev/null || echo "local")

echo "📦 Version: $VERSION"
echo "📅 Build Date: $BUILD_DATE"
echo "🔢 Build Number: $BUILD_NUMBER"

# Build Web with all environment variables
flutter build web --release \
  --base-href "/" \
  --dart-define=APP_VERSION=$VERSION \
  --dart-define=BUILD_DATE="$BUILD_DATE" \
  --dart-define=BUILD_NUMBER=$BUILD_NUMBER \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY \
  --dart-define=ADMIN_EMAILS=$ADMIN_EMAILS

# Create CNAME file for custom domain
echo "herq.app" > build/web/CNAME

# Copy all architecture-specific APKs to web directory if they exist
echo "📱 Copying APKs to web directory..."
APK_COUNT=0

# Copy arm64-v8a (most common - 64-bit ARM)
if [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ]; then
  cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk build/web/app-arm64-v8a-release.apk
  echo "  ✅ ARM64 (64-bit) APK copied"
  APK_COUNT=$((APK_COUNT + 1))
fi

# Copy armeabi-v7a (older devices - 32-bit ARM)
if [ -f "build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk" ]; then
  cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk build/web/app-armeabi-v7a-release.apk
  echo "  ✅ ARMv7 (32-bit) APK copied"
  APK_COUNT=$((APK_COUNT + 1))
fi

# Copy x86_64 (Intel-based Android devices)
if [ -f "build/app/outputs/flutter-apk/app-x86_64-release.apk" ]; then
  cp build/app/outputs/flutter-apk/app-x86_64-release.apk build/web/app-x86_64-release.apk
  echo "  ✅ x86_64 (Intel) APK copied"
  APK_COUNT=$((APK_COUNT + 1))
fi

if [ $APK_COUNT -eq 0 ]; then
  echo "⚠️  No APKs found. Build APK first with './build_apk.sh' if you need the download links."
else
  echo "✅ $APK_COUNT APK(s) copied successfully!"
fi

echo "✅ Web build completed successfully!"
echo "📁 Location: build/web/"
echo "🌐 Ready for GitHub Pages deployment!"
