#!/bin/bash

# 🚀 Deploy Web to GitHub Pages
# Usage: ./deploy_web.sh

echo "🚀 Deploying to GitHub Pages..."

# Load environment variables from .env file (if it exists)
if [ -f .env ]; then
  echo "📋 Loading environment variables from .env..."
  export $(cat .env | grep -v '^#' | xargs)
else
  echo "⚠️  No .env file found. Using environment variables or compile-time constants."
fi

# Build Web
flutter build web --release \
  --base-href "/" \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY

# Create CNAME file for custom domain
echo "herq.app" > build/web/CNAME

# Deploy to GitHub Pages using git
# Note: This requires GITHUB_TOKEN to be set in your environment
if [ -z "$GITHUB_TOKEN" ]; then
  echo "❌ GITHUB_TOKEN not found. Please set it in your environment:"
  echo "   export GITHUB_TOKEN=your_github_token"
  echo "   Or add it to your .env file"
  exit 1
fi

# Create a temporary directory for the deployment
TEMP_DIR=$(mktemp -d)
DEPLOY_REPO="https://${GITHUB_TOKEN}@github.com/KlausAndrade/HERQ-web.git"

echo "📦 Cloning HERQ-web repository..."
git clone --depth 1 --branch main "$DEPLOY_REPO" "$TEMP_DIR" || {
  echo "⚠️  Repository might not exist or branch might be different, creating fresh..."
  rm -rf "$TEMP_DIR"
  mkdir -p "$TEMP_DIR"
  cd "$TEMP_DIR"
  git init
  git remote add origin "$DEPLOY_REPO"
  git checkout -b main
  cd - > /dev/null
}

echo "📁 Copying build files..."
# Remove existing files except .git
cd "$TEMP_DIR"
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} + 2>/dev/null || true
cd - > /dev/null

# Copy all files from build/web to temp directory
cp -r build/web/* "$TEMP_DIR/"

echo "📝 Committing changes..."
cd "$TEMP_DIR"
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add -A
git commit -m "Deploy web app from local machine - $(date -u +"%Y-%m-%d %H:%M:%S UTC")" || {
  echo "⚠️  No changes to commit"
}

echo "🚀 Pushing to GitHub Pages..."
git push origin main --force || {
  echo "❌ Failed to push to GitHub Pages"
  cd - > /dev/null
  rm -rf "$TEMP_DIR"
  exit 1
}

cd - > /dev/null
rm -rf "$TEMP_DIR"

echo "✅ Deployed to GitHub Pages successfully!"
echo "🌐 Your app is live at: https://herq.app"