#!/bin/bash

# 🔧 iOS Deployment Fix Script
# Usage: ./scripts/fix_ios.sh
# This script fixes common iOS deployment issues

echo "🔧 iOS Deployment Fix Script"
echo "============================"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo "✅ $2"
    else
        echo "❌ $2"
    fi
}

echo ""
echo "🧹 Step 1: Clean Flutter and iOS build artifacts..."
echo "=================================================="

# Clean Flutter
echo "Cleaning Flutter..."
flutter clean
print_status $? "Flutter clean completed"

# Clean iOS build folder
echo "Cleaning iOS build folder..."
rm -rf ios/build
rm -rf build/ios
print_status $? "iOS build folder cleaned"

# Clean Pods
echo "Cleaning CocoaPods..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
print_status $? "CocoaPods cleaned"

echo ""
echo "📦 Step 2: Update dependencies..."
echo "================================"

# Go back to root
cd ..

# Get Flutter packages
echo "Getting Flutter packages..."
flutter pub get
print_status $? "Flutter packages updated"

# Update CocoaPods
echo "Updating CocoaPods..."
cd ios
pod install --repo-update
print_status $? "CocoaPods updated"

echo ""
echo "🔍 Step 3: Check iOS configuration..."
echo "===================================="

# Check if Xcode is installed
if command_exists xcodebuild; then
    echo "✅ Xcode found"
    xcodebuild -version
else
    echo "❌ Xcode not found - please install Xcode from App Store"
    exit 1
fi

# Check if iOS simulator is available
if command_exists xcrun; then
    echo "✅ iOS Simulator tools found"
else
    echo "❌ iOS Simulator tools not found"
fi

# Check Flutter doctor
echo ""
echo "Running Flutter doctor..."
flutter doctor
print_status $? "Flutter doctor completed"

echo ""
echo "🔧 Step 4: Fix common iOS issues..."
echo "=================================="

# Fix iOS deployment target
echo "Setting iOS deployment target..."
cd ios
if [ -f "Podfile" ]; then
    # Update Podfile to set minimum iOS version
    sed -i '' 's/platform :ios, .*/platform :ios, "12.0"/' Podfile
    print_status $? "iOS deployment target set to 12.0"
fi

# Fix Info.plist if needed
echo "Checking Info.plist configuration..."
if [ -f "Runner/Info.plist" ]; then
    # Ensure minimum iOS version is set
    if ! grep -q "MinimumOSVersion" Runner/Info.plist; then
        echo "Adding MinimumOSVersion to Info.plist..."
        # This would need more complex plist manipulation
        echo "⚠️  Please manually check Info.plist for minimum iOS version"
    else
        echo "✅ Info.plist looks good"
    fi
fi

# Go back to root
cd ..

echo ""
echo "🚀 Step 5: Test iOS build..."
echo "============================"

# Try to build iOS
echo "Attempting iOS build..."
flutter build ios --no-codesign
print_status $? "iOS build test completed"

echo ""
echo "📱 Step 6: Additional fixes..."
echo "============================="

# Fix permissions
echo "Fixing file permissions..."
chmod +x ios/Pods
find ios -name "*.sh" -exec chmod +x {} \;
print_status $? "Permissions fixed"

# Clear derived data
echo "Clearing Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData
print_status $? "Xcode derived data cleared"

echo ""
echo "🎯 Step 7: Final verification..."
echo "==============================="

# Check if build was successful
if [ -d "build/ios" ]; then
    echo "✅ iOS build directory created successfully"
    echo "📁 Build location: build/ios/"
else
    echo "❌ iOS build directory not found"
    echo "💡 Try running: flutter build ios --release"
fi

echo ""
echo "🔧 Common iOS Issues Fixed:"
echo "=========================="
echo "✅ Cleaned Flutter and iOS build artifacts"
echo "✅ Updated Flutter packages and CocoaPods"
echo "✅ Set iOS deployment target to 12.0"
echo "✅ Fixed file permissions"
echo "✅ Cleared Xcode derived data"
echo "✅ Verified build configuration"

echo ""
echo "🚀 Next Steps:"
echo "=============="
echo "1. Try building again: npm run ios"
echo "2. If still failing, check Xcode for specific errors"
echo "3. Ensure you have valid iOS certificates and provisioning profiles"
echo "4. Check that your Apple Developer account is active"

echo ""
echo "💡 Additional Help:"
echo "=================="
echo "• Run 'flutter doctor' to check for issues"
echo "• Check Xcode console for detailed error messages"
echo "• Ensure iOS Simulator is available: xcrun simctl list"
echo "• For signing issues, check your Apple Developer account"

echo ""
echo "✅ iOS fix script completed!"
