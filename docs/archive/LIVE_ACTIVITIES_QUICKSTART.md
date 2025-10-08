# Quick Start: Live Activities for Rest Timer

## What You Need to Do

The Flutter code is **already done**! ✅ 

Now you just need to configure the native iOS widget in Xcode.

## 5-Minute Setup

### 1. Open Xcode
```bash
cd ios
open Runner.xcworkspace
```

### 2. Add Widget Extension
- File → New → Target
- Choose "Widget Extension"
- Name: `TimerWidget`
- Uncheck "Include Configuration Intent"
- Click Finish → Activate

### 3. Add App Groups
**Runner target:**
- Signing & Capabilities → + Capability → App Groups
- Add: `group.com.klausandrade.gymai`
- Check the box

**TimerWidget target:**
- Signing & Capabilities → + Capability → App Groups
- Use same: `group.com.klausandrade.gymai`
- Check the box

### 4. Update Info.plist
Add to `ios/Runner/Info.plist`:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>gymAI</string>
        </array>
    </dict>
</array>
```

### 5. Replace Widget Code
Copy the Swift code from **LIVE_ACTIVITIES_SETUP.md** Step 3 and paste into `ios/TimerWidget/TimerWidget.swift`

### 6. Test on Physical Device
- iOS 16.1+ required
- Doesn't work in simulator
- iPhone 14 Pro+ gets Dynamic Island
- All devices get Lock Screen widget

## What You'll See

**When timer starts:**
- Dynamic Island shows compact timer (iPhone 14 Pro+)
- Lock Screen shows full widget with buttons
- Pull down on Dynamic Island to expand

**Interactive buttons:**
- **-15s** - Subtract 15 seconds
- **+15s** - Add 15 seconds  
- **Skip** - End timer immediately

**Dynamic updates:**
- Timer counts down in real-time
- Changes every 5 seconds (or 1s when ≤10s left)
- Looks exactly like Hevy!

## If You Get Stuck

See the full detailed guide: **LIVE_ACTIVITIES_SETUP.md**

## Testing Without Native Setup

The app works right now! It just falls back to regular notifications:
- ✅ Android gets RemoteViews (persistent widget)
- ⚠️ iOS gets basic notification (no action buttons)

Once you add the native widget, iOS will automatically upgrade to Live Activities! 🎉
