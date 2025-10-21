#!/bin/bash

# 🌐 Build Web for GitHub Pages
# Usage: ./build_web.sh

echo "🌐 Building Web for GitHub Pages..."

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

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

echo "✅ Web build completed successfully!"
echo "📁 Location: build/web/"
echo "🌐 Ready for GitHub Pages deployment!"
