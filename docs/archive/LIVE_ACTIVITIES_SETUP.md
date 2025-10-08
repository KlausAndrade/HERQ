# Live Activities Setup Guide

This guide will help you set up iOS Live Activities for the rest timer. Live Activities provide a native iOS experience with Dynamic Island and lock screen widgets, just like the Hevy app!

## What You'll Get

- ✅ **Dynamic Island** integration (iPhone 14 Pro+)
- ✅ **Lock screen widget** with timer countdown
- ✅ **Interactive buttons**: -15s, +15s, Skip
- ✅ **Native iOS** look and feel
- ✅ **Android support** via RemoteViews (persistent notification widget)

## Prerequisites

- iOS 16.1+ (for Live Activities)
- Xcode 14.1+
- iPhone 14 Pro+ for Dynamic Island (all devices get lock screen widget)

## Step 1: Create Widget Extension in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target
3. Select **Widget Extension**
4. Configuration:
   - Product Name: `TimerWidget`
   - Include Configuration Intent: **No** (unchecked)
   - Click **Finish**
   - When asked "Activate scheme?", click **Activate**

## Step 2: Configure App Group

Both the main app and widget need to share data via App Groups.

### In Xcode:

1. Select **Runner** target → **Signing & Capabilities**
2. Click **+ Capability** → Add **App Groups**
3. Click **+** and enter: `group.com.klausandrade.gymai`
4. Check the box next to the group

5. Select **TimerWidget** target → **Signing & Capabilities**
6. Click **+ Capability** → Add **App Groups**
7. Use the same group: `group.com.klausandrade.gymai`
8. Check the box

### Update Info.plist:

1. Open `ios/Runner/Info.plist`
2. Add before the closing `</dict>`:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
```

## Step 3: Create the Widget Code

Replace the contents of `ios/TimerWidget/TimerWidget.swift` with:

```swift
import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes
struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var exerciseName: String
        var currentSet: Int
        var totalSets: Int
        var targetReps: Int
    }
}

// MARK: - Widget Views
struct TimerLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner view
            LockScreenTimerView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.8))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.state.exerciseName)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Set \(context.state.currentSet)/\(context.state.totalSets) • \(context.state.targetReps) reps")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatTime(context.state.remainingSeconds))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .monospacedDigit()
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        Button(intent: SubtractTimeIntent()) {
                            Label("-15s", systemImage: "minus.circle.fill")
                                .font(.caption)
                        }
                        .tint(.orange)
                        
                        Spacer()
                        
                        Button(intent: AddTimeIntent()) {
                            Label("+15s", systemImage: "plus.circle.fill")
                                .font(.caption)
                        }
                        .tint(.orange)
                        
                        Spacer()
                        
                        Button(intent: SkipTimerIntent()) {
                            Label("Skip", systemImage: "forward.fill")
                                .font(.caption)
                        }
                        .tint(.red)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                // Compact leading (small pill on dynamic island)
                Image(systemName: "timer")
                    .foregroundColor(.orange)
            } compactTrailing: {
                // Compact trailing (small pill on dynamic island)
                Text(formatTime(context.state.remainingSeconds))
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .monospacedDigit()
            } minimal: {
                // Minimal view (when multiple activities)
                Image(systemName: "timer")
                    .foregroundColor(.orange)
            }
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct LockScreenTimerView: View {
    let context: ActivityViewContext<TimerActivityAttributes>
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.exerciseName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Set \(context.state.currentSet) of \(context.state.totalSets) • \(context.state.targetReps) reps")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(formatTime(context.state.remainingSeconds))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                    .monospacedDigit()
            }
            
            HStack(spacing: 12) {
                Button(intent: SubtractTimeIntent()) {
                    HStack {
                        Image(systemName: "minus.circle.fill")
                        Text("-15s")
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Button(intent: AddTimeIntent()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("+15s")
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Button(intent: SkipTimerIntent()) {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("Skip")
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
    
    func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - App Intents for button actions
struct SubtractTimeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Subtract 15 seconds"
    
    func perform() async throws -> some IntentResult {
        // Send action via URL scheme
        if let url = URL(string: "gymAI://timer/subtract_15") {
            await UIApplication.shared.open(url)
        }
        return .result()
    }
}

struct AddTimeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Add 15 seconds"
    
    func perform() async throws -> some IntentResult {
        if let url = URL(string: "gymAI://timer/add_15") {
            await UIApplication.shared.open(url)
        }
        return .result()
    }
}

struct SkipTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Skip timer"
    
    func perform() async throws -> some IntentResult {
        if let url = URL(string: "gymAI://timer/skip") {
            await UIApplication.shared.open(url)
        }
        return .result()
    }
}

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerLiveActivityWidget()
    }
}
```

## Step 4: Configure URL Scheme

1. Open `ios/Runner/Info.plist`
2. Add the URL scheme configuration:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>gymAI</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.klausandrade.gymai</string>
    </dict>
</array>
```

## Step 5: Test the Implementation

1. **Build and run** the app on a physical iOS device (Live Activities don't work in simulator)
2. Start a workout and complete a set
3. The rest timer should now show as:
   - **Dynamic Island** widget (iPhone 14 Pro+)
   - **Lock screen** widget (all devices)
4. Try the buttons: -15s, +15s, Skip

## Troubleshooting

### Live Activity doesn't appear
- Check that you're on iOS 16.1+
- Make sure you're on a physical device (not simulator)
- Verify App Groups are configured correctly
- Check that `NSSupportsLiveActivities` is in Info.plist

### Buttons don't work
- Verify URL scheme is configured in Info.plist
- Check that the scheme matches: `gymAI://timer/...`
- Look at Xcode console for error messages

### App crashes
- Make sure Widget Extension target has the correct deployment target (iOS 16.1+)
- Verify all code is properly saved and compiled
- Clean build folder: Product → Clean Build Folder

## Android Support

The `live_activities` package also supports Android via RemoteViews. Android users will get a persistent notification widget with the same interactive buttons. No additional setup needed!

## Next Steps

Once Live Activities are working:
- Customize colors to match your app theme
- Add haptic feedback on button taps
- Consider adding more timer presets
- Add completion animations

## Resources

- [Apple Live Activities Documentation](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [live_activities Package](https://pub.dev/packages/live_activities)
- [Dynamic Island Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/live-activities)
