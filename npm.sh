#!/bin/bash

# 📦 NPM-style Script Runner for HERQ
# Usage: ./npm.sh [script_name]

# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo "❌ package.json not found!"
  exit 1
fi

# Get the script from package.json
SCRIPT_NAME="$1"

if [ -z "$SCRIPT_NAME" ]; then
  echo "📦 Available scripts:"
  echo "===================="
  
  # Extract scripts from package.json and display them
  cat package.json | grep -A 20 '"scripts"' | grep -E '^\s*"[^"]+":' | sed 's/.*"\([^"]*\)":.*/\1/' | while read script; do
    if [ ! -z "$script" ]; then
      echo "  $script"
    fi
  done
  
  echo ""
  echo "Usage: ./npm.sh [script_name]"
  echo "Example: ./npm.sh dev"
  exit 0
fi

# Extract the command for the script
COMMAND=$(cat package.json | grep -A 20 '"scripts"' | grep "\"$SCRIPT_NAME\":" | sed 's/.*": *"\([^"]*\)".*/\1/')

if [ -z "$COMMAND" ]; then
  echo "❌ Script '$SCRIPT_NAME' not found!"
  echo "Run './npm.sh' to see available scripts."
  exit 1
fi

echo "🚀 Running: $COMMAND"
echo "===================="

# Execute the command
eval $COMMAND
