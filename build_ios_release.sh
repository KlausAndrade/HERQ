#!/bin/bash

# 🍎 Build iOS Release for Real Device (No Debug Tools)
# Usage: ./build_ios_release.sh [device-id]
# Example: ./build_ios_release.sh 00008140-000A798C38A2201C

DEVICE_ID="$1"

echo "🍎 Building iOS Release for Real Device..."

# Load environment variables from .env file (if it exists)
if [ -f .env ]; then
  echo "📋 Loading environment variables from .env..."
  export $(cat .env | grep -v '^#' | xargs)
else
  echo "⚠️  No .env file found. Using environment variables or compile-time constants."
fi

# Build iOS with release mode (no debug tools, optimized)
# Note: Code signing is required for real devices. Make sure your Apple Developer
# certificates are configured in Xcode before running this.
echo "🔨 Building Flutter app in release mode..."
flutter build ios --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY \
  --dart-define=ADMIN_EMAILS=$ADMIN_EMAILS

echo ""
echo "✅ Flutter build completed!"

# If device ID is provided, install directly to that device
if [ -n "$DEVICE_ID" ]; then
  echo ""
  echo "📱 Installing to device: $DEVICE_ID"
  flutter install --release --device-id="$DEVICE_ID"
  echo ""
  echo "✅ Installation complete!"
else
  echo ""
  echo "📱 To install to a specific device, run:"
  echo "   flutter install --release --device-id=<your-device-id>"
  echo ""
  echo "   Or run this script with device ID:"
  echo "   ./build_ios_release.sh <your-device-id>"
  echo ""
  echo "   To find your device ID, run: flutter devices"
fi

