#!/bin/bash

echo "🔑 Generating Facebook Key Hash for Android"
echo "=========================================="

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "❌ keytool not found. Please install Java JDK"
    exit 1
fi

# Find the debug keystore
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
if [ ! -f "$DEBUG_KEYSTORE" ]; then
    echo "❌ Debug keystore not found at: $DEBUG_KEYSTORE"
    echo "💡 Make sure you've built your Android app at least once"
    exit 1
fi

echo "✅ Found debug keystore: $DEBUG_KEYSTORE"

# Generate key hash
echo "🔧 Generating key hash..."
KEYHASH=$(keytool -exportcert -alias androiddebugkey -keystore "$DEBUG_KEYSTORE" -storepass android -keypass android | openssl sha1 -binary | openssl base64)

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Key Hash Generated Successfully!"
    echo "=================================="
    echo "📋 Add this key hash to your Facebook App:"
    echo ""
    echo "   $KEYHASH"
    echo ""
    echo "🔗 Facebook Developer Console:"
    echo "   1. Go to: https://developers.facebook.com/apps/"
    echo "   2. Select your app: 763767083324283"
    echo "   3. Go to Settings → Basic"
    echo "   4. Scroll down to Android platform"
    echo "   5. Add this key hash in the 'Key Hashes' field"
    echo ""
    echo "📱 For production, generate key hash with your release keystore"
else
    echo "❌ Failed to generate key hash"
    echo "💡 Make sure openssl is installed"
fi
