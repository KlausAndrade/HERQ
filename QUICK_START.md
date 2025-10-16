# 🚀 Quick Start Commands

## Easy Development & Deployment

### 📱 **Development (Emulator)**
```bash
./run_dev.sh
```
*Runs the app on your emulator with all environment variables*

### 📱 **Build Android APK**
```bash
./build_apk.sh
```
*Creates release APK with admin support*

### 🍎 **Build iOS**
```bash
./build_ios.sh
```
*Creates iOS release build with admin support*

### 🌐 **Build Web**
```bash
./build_web.sh
```
*Creates web build for GitHub Pages*

### 🚀 **Deploy to GitHub Pages**
```bash
./deploy_web.sh
```
*Builds and deploys to herq.app*

## 🔧 **Setup Required**

1. **Create `.env` file** with your Supabase credentials:
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

2. **For GitHub Pages deployment**, also add:
```bash
GITHUB_TOKEN=your_github_token
```

## 🎯 **That's it!**

- ✅ **No more long commands** - Just run the scripts
- ✅ **All platforms supported** - Android, iOS, Web
- ✅ **Environment variables handled** - Automatically loaded from .env
- ✅ **GitHub Pages ready** - Custom domain support
- ✅ **Admin dashboard works** - Real Supabase data

## 📋 **Available Scripts**

| Script | Purpose | Output |
|--------|---------|--------|
| `./run_dev.sh` | Development on emulator | Live app |
| `./build_apk.sh` | Android APK release | `build/app/outputs/flutter-apk/app-release.apk` |
| `./build_ios.sh` | iOS release build | `build/ios/` |
| `./build_web.sh` | Web build for GitHub Pages | `build/web/` |
| `./deploy_web.sh` | Deploy to GitHub Pages | Live at herq.app |

**Just run the script you need!** 🎉
