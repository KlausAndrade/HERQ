# Web Authentication Troubleshooting Guide

## Issue: "Failed to decode response on login web"

This error typically occurs due to JSON parsing issues in the web browser when communicating with Supabase.

## ✅ Solutions Implemented

### 1. Enhanced Web Auth Helper
- **File**: `lib/src/core/utils/enhanced_web_auth_helper.dart`
- **Features**:
  - Robust JSON error handling
  - Session data validation
  - Storage cleanup on errors
  - Network error detection

### 2. Web Configuration
- **File**: `web/supabase-config.js`
- **Features**:
  - Custom fetch handler for JSON parsing
  - CORS configuration
  - Error handling for unhandled promise rejections

### 3. Debug Screen
- **File**: `lib/src/features/workout/presentation/screens/web_debug_screen.dart`
- **Access**: Navigate to `/debug` in your web app
- **Features**:
  - Connection testing
  - Session validation
  - Storage analysis
  - URL inspection

## 🔧 Quick Fixes

### Fix 1: Clear Browser Storage
```javascript
// Open browser console and run:
localStorage.clear();
sessionStorage.clear();
location.reload();
```

### Fix 2: Check Supabase Configuration
1. Verify your Supabase URL and anon key are correct
2. Ensure CORS is properly configured in Supabase dashboard
3. Check that your domain is added to allowed origins

### Fix 3: Use Debug Screen
1. Navigate to `your-domain.com/debug`
2. Click "Run Diagnostics"
3. Review the logs for specific error messages

## 🚨 Common Causes

### 1. CORS Issues
- **Symptom**: Network errors or blocked requests
- **Solution**: Add your domain to Supabase allowed origins

### 2. Malformed JSON Response
- **Symptom**: "Format exception" or "unexpected character"
- **Solution**: Enhanced auth helper handles this automatically

### 3. Session Conflicts
- **Symptom**: Authentication loops or invalid sessions
- **Solution**: Clear storage and retry

### 4. Network Timeouts
- **Symptom**: Connection errors
- **Solution**: Check internet connection and Supabase status

## 🔍 Debugging Steps

### Step 1: Check Browser Console
1. Open Developer Tools (F12)
2. Go to Console tab
3. Look for red error messages
4. Check Network tab for failed requests

### Step 2: Test Supabase Connection
1. Go to `/debug` page
2. Click "Run Diagnostics"
3. Check if "Connection test passed"

### Step 3: Verify Configuration
```dart
// Check your Supabase initialization in main_web.dart
await Supabase.initialize(
  url: 'your-supabase-url',
  anonKey: 'your-anon-key',
);
```

### Step 4: Test Authentication
1. Use the debug screen's "Test Sign In" button
2. Check the logs for specific error messages
3. Try clearing storage if errors persist

## 🛠️ Advanced Troubleshooting

### 1. Manual Storage Clear
```javascript
// In browser console:
Object.keys(localStorage).forEach(key => {
  if (key.includes('supabase')) {
    localStorage.removeItem(key);
  }
});
```

### 2. Force Session Refresh
```dart
// In your Flutter code:
await Supabase.instance.client.auth.signOut();
await Supabase.instance.client.auth.getSession();
```

### 3. Check Network Requests
1. Open Developer Tools
2. Go to Network tab
3. Try logging in
4. Look for failed requests (red status codes)
5. Check request/response headers

## 📋 Checklist

- [ ] Supabase URL and key are correct
- [ ] CORS is configured in Supabase dashboard
- [ ] Domain is added to allowed origins
- [ ] Browser storage is cleared
- [ ] Network connection is stable
- [ ] No ad blockers interfering
- [ ] JavaScript is enabled
- [ ] Cookies are enabled

## 🆘 Still Having Issues?

1. **Check Supabase Status**: Visit [status.supabase.com](https://status.supabase.com)
2. **Review Logs**: Use the debug screen to get detailed error information
3. **Test in Incognito**: Try in a private/incognito browser window
4. **Different Browser**: Test in Chrome, Firefox, Safari
5. **Clear Everything**: Clear all browser data and cookies

## 📞 Support

If you're still experiencing issues:
1. Run the debug screen diagnostics
2. Copy the error logs
3. Check the browser console for additional errors
4. Verify your Supabase project settings

The enhanced authentication system should handle most JSON decoding issues automatically, but the debug screen will help identify any remaining problems.
