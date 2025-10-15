#!/bin/bash

echo "🔍 Facebook Configuration Check"
echo "================================"

# Check .env file
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo "📝 Please run: cp .env.example .env"
    exit 1
fi

echo "✅ .env file found"

# Check if values are still placeholders
FACEBOOK_ID=$(grep "FACEBOOK_ID=" .env | cut -d'=' -f2)
FACEBOOK_TOKEN=$(grep "FACEBOOK_CLIENT_TOKEN=" .env | cut -d'=' -f2)

echo ""
echo "📋 Current Values:"
echo "  FACEBOOK_ID: $FACEBOOK_ID"
echo "  FACEBOOK_CLIENT_TOKEN: $FACEBOOK_TOKEN"

if [[ "$FACEBOOK_ID" == *"your_facebook_app_id_here"* ]]; then
    echo "⚠️  FACEBOOK_ID still has placeholder value!"
fi

if [[ "$FACEBOOK_TOKEN" == *"your_facebook_client_token_here"* ]]; then
    echo "⚠️  FACEBOOK_CLIENT_TOKEN still has placeholder value!"
fi

echo ""
echo "📱 Platform Configuration:"

# Check Android
if grep -q "your_facebook_app_id_here" android/app/src/main/res/values/strings.xml; then
    echo "❌ Android strings.xml still has placeholder values"
    echo "💡 Run: ./scripts/setup_env.sh"
else
    echo "✅ Android strings.xml looks good"
fi

# Check iOS
if grep -q "YOUR_FACEBOOK_APP_ID" ios/Runner/Info.plist; then
    echo "❌ iOS Info.plist still has placeholder values"
    echo "💡 Run: ./scripts/setup_env.sh"
else
    echo "✅ iOS Info.plist looks good"
fi

echo ""
echo "🚀 Next Steps:"
echo "1. Get your Facebook App ID and Client Token from:"
echo "   https://developers.facebook.com/apps/"
echo "2. Edit .env file with real values"
echo "3. Run: ./scripts/setup_env.sh"
echo "4. Test: flutter run"
