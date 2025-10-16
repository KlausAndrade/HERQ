#!/bin/bash

# 🚀 HERQ Build & Deploy Helper
# Usage: ./build.sh [option]

echo "🚀 HERQ Build & Deploy Helper"
echo "=============================="

case "$1" in
  "dev"|"emulator")
    echo "📱 Starting development on emulator..."
    ./run_dev.sh
    ;;
  "apk"|"android")
    echo "📱 Building Android APK..."
    ./build_apk.sh
    ;;
  "ios"|"apple")
    echo "🍎 Building iOS..."
    ./build_ios.sh
    ;;
  "web"|"gh-pages")
    echo "🌐 Building Web..."
    ./build_web.sh
    ;;
  "deploy"|"publish")
    echo "🚀 Deploying to GitHub Pages..."
    ./deploy_web.sh
    ;;
  *)
    echo "Usage: ./build.sh [option]"
    echo ""
    echo "Options:"
    echo "  dev, emulator    - Run on emulator"
    echo "  apk, android     - Build Android APK"
    echo "  ios, apple       - Build iOS"
    echo "  web, gh-pages    - Build Web"
    echo "  deploy, publish  - Deploy to GitHub Pages"
    echo ""
    echo "Examples:"
    echo "  ./build.sh dev      # Run on emulator"
    echo "  ./build.sh apk      # Build Android APK"
    echo "  ./build.sh deploy   # Deploy to GitHub Pages"
    ;;
esac
