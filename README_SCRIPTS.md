# 📦 HERQ Scripts - Multiple Ways to Run

## 🚀 **2 Different Ways to Use Scripts**

### 1. **Master Script (Simple & Clean)**
```bash
./build.sh dev         # Run development
./build.sh apk          # Build Android APK
./build.sh deploy      # Deploy to GitHub Pages
./build.sh              # Show help
```

### 2. **Individual Scripts (Direct)**
```bash
./run_dev.sh           # Run development
./build_apk.sh         # Build Android APK
./deploy_web.sh         # Deploy to GitHub Pages
```

## 📋 **All Available Commands**

| Command | Master Script | Individual Script | Purpose |
|---------|---------------|-------------------|---------|
| **Development** | `./build.sh dev` | `./run_dev.sh` | Run on emulator |
| **Android APK** | `./build.sh apk` | `./build_apk.sh` | Build Android APK |
| **iOS Build** | `./build.sh ios` | `./build_ios.sh` | Build iOS |
| **iOS Fix** | `./build.sh fix` | `./scripts/fix_ios.sh` | Fix iOS deployment issues |
| **Web Build** | `./build.sh web` | `./build_web.sh` | Build Web |
| **Deploy** | `./build.sh deploy` | `./deploy_web.sh` | Deploy to GitHub Pages |

## 🎯 **Quick Reference**

### **Most Common Commands:**
```bash
# Development
./build.sh dev          # or ./run_dev.sh

# Build Android
./build.sh apk           # or ./build_apk.sh

# Fix iOS Issues
./build.sh fix           # or ./scripts/fix_ios.sh

# Deploy Web
./build.sh deploy        # or ./deploy_web.sh
```

### **Show All Options:**
```bash
./build.sh              # Show all master script options
```

## 🔧 **Setup Required**

1. **Create `.env` file:**
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
GITHUB_TOKEN=your_github_token  # Optional, for deployment
```

2. **That's it!** All scripts handle the rest automatically.

## 📁 **File Structure**

```
HERQ/
├── package.json          # NPM-style script definitions (can use npm run <script>)
├── build.sh             # Master script runner
├── run_dev.sh           # Development script
├── build_apk.sh        # Android APK script
├── build_ios.sh          # iOS build script
├── build_web.sh         # Web build script
├── deploy_web.sh         # Deployment script
└── .env                 # Environment variables (gitignored)
```

## 🔧 **iOS Fix Command**

If you encounter iOS deployment issues, use the fix command:

```bash
# Fix iOS deployment issues
./build.sh fix           # or ./scripts/fix_ios.sh
```

This comprehensive fix script will:
- Clean Flutter and iOS build artifacts
- Update Flutter packages and CocoaPods
- Set iOS deployment target to 12.0
- Fix file permissions
- Clear Xcode derived data
- Verify build configuration

## 🎉 **Choose Your Style!**

- **Simple & Clean**: Use `./build.sh [command]` (master script)
- **Direct Control**: Use individual scripts like `./run_dev.sh`
- **NPM Style**: Use `npm run <script>` from package.json

**All ways do the same thing - pick what feels most comfortable!** 🚀
