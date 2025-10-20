# Web Blank Page Troubleshooting Guide

## Issue: Flutter web app loads JS files but shows blank page

This is a common issue with Flutter web apps. Here's how to diagnose and fix it.

## 🔍 **Quick Diagnosis Steps**

### Step 1: Open Browser Console
1. Open Chrome DevTools (F12 or Cmd+Option+I on Mac)
2. Go to the **Console** tab
3. Look for error messages (red text)

### Step 2: Check Network Tab
1. Go to the **Network** tab in DevTools
2. Reload the page
3. Look for:
   - Failed requests (red status codes)
   - 404 errors
   - CORS errors

### Step 3: Check Console Logs
Look for these specific messages:
```
✅ Web platform initialized with Supabase
   URL: configured
   Anon Key: configured
   Current session: None
```

If you see errors instead, that's your issue!

## 🚨 **Common Causes & Fixes**

### 1. **Supabase Initialization Error**

**Symptoms:**
- Blank page
- Console shows: `⚠️ Web initialization error`
- Or: `Supabase connection test failed`

**Fix:**
```bash
# Make sure .env file exists with Supabase credentials
echo "SUPABASE_URL=https://vvgxvunvzhtvwvdvtlrm.supabase.co" > .env
echo "SUPABASE_ANON_KEY=your-anon-key" >> .env

# Or run with dart-define
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://vvgxvunvzhtvwvdvtlrm.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### 2. **Router Redirect Loop**

**Symptoms:**
- Blank page
- Console shows: `❌ Router redirect error`
- URL keeps changing

**Fix:**
The code now has a try-catch in the router redirect. If you still see this, check:
```dart
// lib/main_web.dart - line 95
redirect: (context, state) {
  try {
    // ... redirect logic
  } catch (e) {
    print('❌ Router redirect error: $e');
    return '/auth'; // Fallback to auth page
  }
}
```

### 3. **Canvas/WebGL Issues**

**Symptoms:**
- Black or blank page
- Console shows canvas-related errors

**Fix:**
```bash
# Run with HTML renderer instead of CanvasKit
flutter run -d chrome --web-renderer html
```

### 4. **CORS Errors**

**Symptoms:**
- Console shows: `Access to fetch at ... has been blocked by CORS policy`

**Fix:**
1. Go to Supabase Dashboard
2. Settings → API → URL Configuration
3. Add your local development URL:
   - `http://localhost:3000`
   - `http://localhost:8080`
   - `http://127.0.0.1:3000`

### 5. **Service Worker Issues**

**Symptoms:**
- Blank page after update
- Old content cached

**Fix:**
```javascript
// Open browser console and run:
navigator.serviceWorker.getRegistrations().then(function(registrations) {
  for(let registration of registrations) {
    registration.unregister();
  }
});
// Then reload the page
```

### 6. **Browser Storage Full or Blocked**

**Symptoms:**
- Errors about localStorage or sessionStorage
- Quota exceeded errors

**Fix:**
1. Open DevTools → Application tab
2. Clear Storage → Clear site data
3. Or use incognito/private mode

## 🛠️ **Debugging Tools**

### Use the Diagnostic Page
Navigate to: `http://localhost:PORT/diagnostic.html`

This page will show you:
- JavaScript status
- Storage availability
- Supabase connectivity
- Console logs
- Storage contents

### Use the Debug Route
Navigate to: `http://localhost:PORT/#/debug`

This Flutter route provides:
- Supabase connection test
- Session validation
- Storage analysis
- URL inspection

## 📝 **Step-by-Step Debug Process**

1. **Clear Everything:**
   ```javascript
   // In browser console:
   localStorage.clear();
   sessionStorage.clear();
   location.reload();
   ```

2. **Check Supabase:**
   - Open `http://localhost:PORT/diagnostic.html`
   - Click "Test Supabase"
   - Should see "✅ Supabase connection successful"

3. **Check Console on App Load:**
   - Open console BEFORE loading app
   - Reload the app
   - Watch for the initialization messages
   - First error you see is usually the culprit

4. **Try Different Renderers:**
   ```bash
   # Try HTML renderer
   flutter run -d chrome --web-renderer html
   
   # Try CanvasKit (default)
   flutter run -d chrome --web-renderer canvaskit
   
   # Try auto (Flutter decides)
   flutter run -d chrome --web-renderer auto
   ```

5. **Test in Incognito:**
   - Open Chrome incognito window
   - Navigate to your app
   - If it works, issue is cached data/extensions

## 🔧 **Quick Fixes**

### Fix 1: Run with HTML Renderer
```bash
flutter run -d chrome --web-renderer html --web-port 3000
```

### Fix 2: Clear Flutter Build Cache
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Fix 3: Use Diagnostic Page
```bash
# Navigate to:
http://localhost:PORT/diagnostic.html
```

### Fix 4: Check for JavaScript Errors
Look in console for:
- `ReferenceError`
- `TypeError`
- `Uncaught Error`
- `Failed to load`

## 📱 **If Still Blank**

1. **Check your main_web.dart:**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Make sure Supabase initializes
     await Supabase.initialize(
       url: 'YOUR_URL',
       anonKey: 'YOUR_KEY',
     );
     
     runApp(MyApp());
   }
   ```

2. **Add Error Boundary:**
   The code now includes an ErrorBoundary widget that will catch and display errors instead of showing a blank page.

3. **Check Flutter Version:**
   ```bash
   flutter doctor -v
   # Make sure web is enabled
   ```

4. **Try Production Build:**
   ```bash
   flutter build web
   cd build/web
   python3 -m http.server 8000
   # Then open http://localhost:8000
   ```

## 🎯 **Most Likely Causes (in order)**

1. ✅ **Supabase not initialized** - Check console for init errors
2. ✅ **Router redirect loop** - Now fixed with try-catch
3. ✅ **Canvas/WebGL issues** - Try HTML renderer
4. ✅ **JavaScript error on load** - Check console for errors
5. ✅ **CORS blocking API calls** - Add localhost to Supabase allowed origins

## 💡 **Pro Tips**

- Always keep DevTools console open when debugging
- Check Network tab for failed requests
- Use incognito to rule out cache/extension issues
- The diagnostic page is your friend - use it!
- When in doubt, clear storage and reload

## 🆘 **Emergency Recovery**

If nothing works:
```bash
# Nuclear option - complete reset
flutter clean
rm -rf build/
rm -rf .dart_tool/
flutter pub get
flutter run -d chrome --web-renderer html --verbose
```

This will give you detailed output of what's happening during initialization.
