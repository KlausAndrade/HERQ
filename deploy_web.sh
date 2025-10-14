#!/bin/bash
# Script to manually deploy Flutter web to GitHub Pages

echo "🚀 Deploying Flutter Web to GitHub Pages..."

# Build the web app
echo "📦 Building web app..."
flutter build web --release --base-href "/HERQ/"

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create or checkout gh-pages branch
echo "📝 Preparing gh-pages branch..."
if git show-ref --verify --quiet refs/heads/gh-pages; then
    git checkout gh-pages
else
    git checkout --orphan gh-pages
fi

# Remove all files except build/web
git rm -rf . 2>/dev/null || true

# Copy web build to root
cp -r build/web/* .

# Add .nojekyll to prevent GitHub from processing with Jekyll
touch .nojekyll

# Commit and push
git add .
git commit -m "Deploy Flutter web app to GitHub Pages"
git push origin gh-pages --force

# Return to main branch
git checkout main

echo "✅ Deployment complete!"
echo "🌐 Your app will be available at: https://klausandrade.github.io/HERQ/"

