#!/bin/bash

echo "🔧 Setting up environment variables..."

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo "📝 Creating .env from .env.example..."
    cp .env.example .env
    echo "✅ Created .env file"
    echo "⚠️  Please edit .env and add your actual Facebook App ID and Client Token"
    exit 1
fi

# Run the injection script
echo "💉 Injecting environment variables..."
dart scripts/inject_env.dart

echo "✅ Setup complete!"
echo "📱 You can now run: flutter run"
