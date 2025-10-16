#!/bin/bash

# 🚀 Easy Development - Run on Emulator
# Usage: ./run_dev.sh

echo "🚀 Starting development on emulator..."

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

# Run Flutter with all environment variables
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY