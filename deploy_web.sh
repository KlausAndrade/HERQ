#!/bin/bash

# 🚀 Deploy Web to GitHub Pages
# Usage: ./deploy_web.sh

echo "🚀 Deploying to GitHub Pages..."

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

# Build Web
flutter build web --release \
  --base-href "/" \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY

# Create CNAME file for custom domain
echo "herq.app" > build/web/CNAME

# Deploy to GitHub Pages using peaceiris/actions-gh-pages
# Note: This requires GITHUB_TOKEN to be set in your environment
if [ -z "$GITHUB_TOKEN" ]; then
  echo "❌ GITHUB_TOKEN not found. Please set it in your environment:"
  echo "   export GITHUB_TOKEN=your_github_token"
  echo "   Or add it to your .env file"
  exit 1
fi

# Use npx to run the GitHub Pages action locally
npx @peaceiris/actions-gh-pages@v3 \
  --token $GITHUB_TOKEN \
  --repo KlausAndrade/HERQ-web \
  --branch main \
  --dir build/web \
  --user-name "github-actions[bot]" \
  --user-email "github-actions[bot]@users.noreply.github.com" \
  --message "Deploy web app with admin support"

echo "✅ Deployed to GitHub Pages successfully!"
echo "🌐 Your app is live at: https://herq.app"