# 📱 Deploy GymAI to Real iPhone

## Quick Start Guide

### **Prerequisites**
- ✅ Mac with Xcode installed
- ✅ iPhone with iOS 12.0 or later
- ✅ USB cable to connect iPhone to Mac
- ✅ Apple ID (free or paid developer account)

---

## 🚀 **Deployment Steps**

### **Step 1: Connect iPhone**

1. **Connect iPhone to Mac** via USB cable
2. **Unlock your iPhone**
3. **Tap "Trust This Computer"** when prompted on iPhone
4. **Enter iPhone passcode** to confirm

### **Step 2: Verify Connection**

```bash
flutter devices
```

You should see output like:
```
Klaus's iPhone • 00008030-001A... • ios • iOS 17.x
```

If you only see simulators, make sure:
- iPhone is unlocked
- USB cable is properly connected
- You've trusted the computer

---

### **Step 3: Configure Code Signing (First Time Only)**

#### **Option A: Using Xcode (Recommended)**

1. **Open Xcode workspace:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **In Xcode:**
   - Select **"Runner"** project in left sidebar
   - Select **"Runner"** target under TARGETS
   - Go to **"Signing & Capabilities"** tab

3. **Add your Apple ID:**
   - Click **"Team"** dropdown
   - Select **"Add Account..."**
   - Sign in with your **Apple ID**
   - Select your team from dropdown

4. **Configure Bundle ID:**
   - Change Bundle Identifier to something unique
   - Example: `com.yourname.gymai` or `com.klausandrade.gymai`
   - ⚠️ Must be globally unique

5. **Enable Automatic Signing:**
   - Check ✅ **"Automatically manage signing"**
   - Xcode will create certificates automatically

#### **Option B: Using Command Line**

```bash
# Set your team ID (find in Xcode or developer.apple.com)
export DEVELOPMENT_TEAM="YOUR_TEAM_ID"

# Build with specific team
flutter build ios --release --codesign="iPhone Developer"
```

---

### **Step 4: Deploy to iPhone**

#### **Method 1: Flutter CLI (Easiest)**

1. **Get your device ID:**
   ```bash
   flutter devices
   ```

2. **Run on your iPhone:**
   ```bash
   flutter run -d <YOUR_DEVICE_ID>
   ```
   
   Or just:
   ```bash
   flutter run
   ```
   Then select your iPhone from the list.

#### **Method 2: Using Xcode**

1. **Open Xcode workspace:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select your iPhone** as deployment target (top toolbar)

3. **Click ▶️ Run button** or press `Cmd + R`

---

### **Step 5: Trust Developer on iPhone (First Time)**

After installation, you'll see "Untrusted Developer" error:

1. **On iPhone, go to:**
   ```
   Settings → General → VPN & Device Management
   ```

2. **Find your developer profile** (your Apple ID email)

3. **Tap it and select "Trust"**

4. **Confirm by tapping "Trust" again**

5. **Now you can open the app!**

---

## 🐛 **Common Issues & Solutions**

### **Issue 1: "No development team selected"**

**Solution:**
```bash
# Open Xcode and add your Apple ID
open ios/Runner.xcworkspace
```
Then follow Step 3 above.

---

### **Issue 2: "Bundle identifier already in use"**

**Solution:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Change Bundle Identifier to something unique:
   - Example: `com.yourname.gymai`
   - Or: `com.klausandrade.gymai.app`

---

### **Issue 3: "Untrusted Developer"**

**Solution:**
```
iPhone Settings → General → VPN & Device Management → Trust Developer
```

---

### **Issue 4: "iPhone is locked"**

**Solution:**
- Unlock your iPhone
- Keep it unlocked during deployment
- Re-run `flutter run`

---

### **Issue 5: "Provisioning profile doesn't include signing certificate"**

**Solution:**
1. In Xcode: Signing & Capabilities
2. Uncheck "Automatically manage signing"
3. Re-check it
4. Xcode will recreate certificates

---

### **Issue 6: Free Apple ID - "App already installed"**

Free developer accounts have limitations:
- Maximum 3 apps per device
- Apps expire after 7 days
- Need to re-deploy every week

**Solution:**
- Delete old test apps from iPhone
- Or upgrade to paid Apple Developer Program ($99/year)

---

## 📋 **Quick Command Reference**

```bash
# 1. Check connected devices
flutter devices

# 2. Run on iPhone (debug mode)
flutter run -d <device-id>

# 3. Build release version
flutter build ios --release

# 4. Install release build via Xcode
open ios/Runner.xcworkspace
# Then: Product → Archive → Distribute App → Development

# 5. Clean build (if issues occur)
flutter clean
cd ios && pod install && cd ..
flutter build ios
```

---

## 🔐 **Bundle ID Recommendations**

Current: `com.example.gymAi`

Change to one of:
- `com.yourname.gymai`
- `com.klausandrade.gymai`
- `com.yourdomain.gymai`
- `io.github.klausandrade.gymai`

**To change:**
1. Xcode → Runner target → Signing & Capabilities → Bundle Identifier
2. Or edit: `ios/Runner.xcodeproj/project.pbxproj`

---

## 🚀 **Production Deployment (TestFlight/App Store)**

### **For TestFlight (Beta Testing):**

```bash
# 1. Build for release
flutter build ios --release

# 2. Open Xcode
open ios/Runner.xcworkspace

# 3. In Xcode:
# Product → Archive
# Wait for archive to complete
# Click "Distribute App"
# Select "App Store Connect"
# Upload to TestFlight
```

### **For App Store:**

1. **Archive in Xcode** (same as TestFlight)
2. **Upload to App Store Connect**
3. **Fill in app information:**
   - Screenshots
   - Description
   - Privacy policy
   - etc.
4. **Submit for Review**

---

## 📱 **Device Requirements**

**Minimum iOS Version:** iOS 12.0
**Supported Devices:** iPhone 6s and newer

To change minimum iOS version:
```
ios/Podfile:
platform :ios, '12.0'  # Change this line
```

---

## 🔄 **Hot Reload on Real Device**

Once deployed, hot reload works just like simulator:

```bash
# In terminal where flutter run is running:
r  # Hot reload
R  # Hot restart
q  # Quit
```

---

## ✅ **Deployment Checklist**

Before deploying:
- [ ] iPhone connected and unlocked
- [ ] iPhone trusts this computer
- [ ] Apple ID added to Xcode
- [ ] Bundle ID is unique
- [ ] Signing certificates configured
- [ ] iPhone developer mode enabled (iOS 16+)

First run:
- [ ] App installed successfully
- [ ] Trust developer in Settings
- [ ] App launches without errors
- [ ] All features work as expected

---

## 📚 **Additional Resources**

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Program](https://developer.apple.com/programs/)
- [TestFlight Guide](https://developer.apple.com/testflight/)
- [App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

## 🆘 **Need Help?**

If you encounter issues:

1. **Check flutter doctor:**
   ```bash
   flutter doctor -v
   ```

2. **Clean and rebuild:**
   ```bash
   flutter clean
   cd ios && pod install && cd ..
   flutter run
   ```

3. **Check Xcode issues:**
   ```bash
   open ios/Runner.xcworkspace
   # Look for red errors in Xcode
   ```

4. **Enable verbose logging:**
   ```bash
   flutter run -v
   ```

---

**Good luck with your deployment! 🚀**
