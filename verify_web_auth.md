# 🔍 Web Auth Screen Verification

## Issue: "Skip for now" instead of APK download

### ✅ What Should Be Visible

When you run the web app, you should see:

1. **Debug Indicator** (in debug mode):
   - Blue box with text: "DEBUG: This is WebAuthScreen with APK download"

2. **APK Download Section**:
   - Green "Download Android APK" button
   - "Get the full mobile experience" section with mobile icon

3. **NO "Skip for now" button** - this should not appear

### 🧪 How to Test

1. **Run the web app**:
   ```bash
   flutter run -d chrome --target lib/main_web.dart
   ```

2. **Navigate to auth screen**:
   - Go to `/auth` or let the app redirect you there

3. **Look for these elements**:
   - ✅ Debug indicator (blue box)
   - ✅ "Download Android APK" button (green)
   - ✅ Mobile app info section
   - ❌ NO "Skip for now" button

### 🐛 If You Still See "Skip for now"

This means you're looking at the wrong screen. Check:

1. **URL**: Should be `http://localhost:port/auth`
2. **Console**: Look for "DEBUG: This is WebAuthScreen" message
3. **Entry point**: Make sure you're using `lib/main_web.dart`

### 🔧 Troubleshooting

If you see "Skip for now":

1. **Clear browser cache**
2. **Restart the Flutter app**
3. **Check the URL** - should be `/auth`
4. **Look for debug indicator** - should show "WebAuthScreen"

### 📱 Expected UI Elements

```
┌─────────────────────────────┐
│        HERQ Logo           │
│                             │
│    Email: [____________]    │
│    Password: [_________]    │
│                             │
│    [Sign In] Button         │
│                             │
│    [Sign Up/Sign In] Toggle │
│                             │
│    ─────────────────────    │
│                             │
│    [Debug Tests] (debug)    │
│                             │
│    Prefer the mobile app?   │
│    [Download Android APK]   │
│                             │
│    📱 Get the full mobile    │
│       experience            │
└─────────────────────────────┘
```

### ❌ What You Should NOT See

- "Skip for now" button
- Any reference to the old `AuthScreen`
- Missing APK download section
