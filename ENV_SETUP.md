# Environment Setup Guide

## 🚀 Quick Setup

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit .env with your actual values:**
   ```bash
   # Replace these with your actual Facebook App credentials
   FACEBOOK_ID=123456789012345
   FACEBOOK_CLIENT_TOKEN=abc123def456ghi789
   
   # Your Supabase credentials
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Inject environment variables:**
   ```bash
   ./scripts/setup_env.sh
   ```

4. **Run your app:**
   ```bash
   flutter run
   ```

## 📱 How It Works

### Environment Variables
- All sensitive data is stored in `.env` (not committed to git)
- Build-time injection replaces placeholders in platform configs
- Flutter code can access variables via `EnvConfig` class

### Platform Configuration
- **Android**: `android/app/src/main/res/values/strings.xml`
- **iOS**: `ios/Runner/Info.plist`
- **Flutter**: `lib/src/core/config/env_config.dart`

### Security Benefits
- ✅ No secrets in source code
- ✅ Different values per environment
- ✅ Easy to manage and update
- ✅ Git-safe (`.env` in `.gitignore`)

## 🔧 Manual Setup

If you prefer to set up manually:

1. **Edit Android strings.xml:**
   ```xml
   <string name="facebook_app_id">YOUR_ACTUAL_FACEBOOK_APP_ID</string>
   <string name="facebook_client_token">YOUR_ACTUAL_FACEBOOK_CLIENT_TOKEN</string>
   ```

2. **Edit iOS Info.plist:**
   ```xml
   <key>FacebookAppID</key>
   <string>YOUR_ACTUAL_FACEBOOK_APP_ID</string>
   <key>FacebookClientToken</key>
   <string>YOUR_ACTUAL_FACEBOOK_CLIENT_TOKEN</string>
   ```

## 🐛 Troubleshooting

- **Missing .env**: Copy from `.env.example`
- **Build fails**: Run `./scripts/setup_env.sh` before building
- **Facebook login fails**: Check your App ID and Client Token in `.env`
