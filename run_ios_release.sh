#!/bin/bash

# 🍎 Run iOS Release on Device
# Usage: ./run_ios_release.sh [device_id]

echo "🍎 Running iOS Release on Device..."

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

# Get device ID from parameter or use default
DEVICE_ID=${1:-"00008140-000A798C38A2201C"}

echo "📱 Target Device: $DEVICE_ID"

# Run iOS release with all environment variables
flutter run --release \
  -d $DEVICE_ID \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY \
  --dart-define=ADMIN_EMAILS=$ADMIN_EMAILS

echo "✅ iOS release deployed to device!"
