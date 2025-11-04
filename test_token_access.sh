#!/bin/bash

# Test script to verify GitHub token has access to HERQ-web repository
# Usage: ./test_token_access.sh

if [ -z "$GITHUB_TOKEN" ]; then
  echo "❌ GITHUB_TOKEN not set"
  echo "   Set it with: export GITHUB_TOKEN=your_token"
  exit 1
fi

echo "🧪 Testing GitHub token access to HERQ-web..."
echo ""

# Test if we can access the repository
REPO_URL="https://${GITHUB_TOKEN}@github.com/KlausAndrade/HERQ-web.git"

echo "📦 Testing repository access..."
if git ls-remote "$REPO_URL" > /dev/null 2>&1; then
  echo "✅ Token has READ access to HERQ-web"
else
  echo "❌ Token does NOT have access to HERQ-web"
  echo "   Check:"
  echo "   1. Token has 'repo' scope"
  echo "   2. HERQ-web repository exists"
  echo "   3. You have access to the repository"
  exit 1
fi

echo ""
echo "📝 Testing write access (dry run)..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || exit 1

if git clone --depth 1 "$REPO_URL" test-repo > /dev/null 2>&1; then
  cd test-repo || exit 1
  echo "test" > test.txt
  git config user.name "test"
  git config user.email "test@test.com"
  git add test.txt
  git commit -m "Test write access" > /dev/null 2>&1
  
  if git push origin main > /dev/null 2>&1; then
    echo "✅ Token has WRITE access to HERQ-web"
    git push origin main --delete HEAD~1 > /dev/null 2>&1 || true
  else
    echo "❌ Token does NOT have WRITE access"
    echo "   Token might be read-only or repository might be protected"
  fi
  
  cd ..
  rm -rf test-repo
fi

cd - > /dev/null || true
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Token verification complete!"

