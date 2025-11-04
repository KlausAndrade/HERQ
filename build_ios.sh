#!/bin/bash

# 🍎 Build iOS Release
# Usage: ./build_ios.sh

echo "🍎 Building iOS Release..."

# Load environment variables from .env file (if it exists)
if [ -f .env ]; then
  echo "📋 Loading environment variables from .env..."
  export $(cat .env | grep -v '^#' | xargs)
else
  echo "⚠️  No .env file found. Using environment variables or compile-time constants."
fi

# Build iOS with all environment variables
flutter build ios --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY \
  --dart-define=ADMIN_EMAILS=$ADMIN_EMAILS

echo "✅ iOS build completed successfully!"
echo "📁 Location: build/ios/"
