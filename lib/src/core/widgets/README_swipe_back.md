# Swipe Back Functionality

This directory contains utilities for implementing swipe-right-to-go-back functionality throughout the HERQ app, similar to Facebook, WhatsApp, and other modern mobile apps.

## Components

### 1. SwipeBackWrapper
A simple wrapper widget that provides basic swipe-back functionality.

```dart
import '../../../../core/widgets/swipe_back_wrapper.dart';

// Wrap your Scaffold
return SwipeBackWrapper(
  onSwipeBack: () => context.go('/'),
  child: Scaffold(
    // ... your scaffold content
  ),
);
```

### 2. SwipeBackWrapperWithFeedback
An advanced wrapper with visual feedback during the swipe gesture.

```dart
import '../../../../core/widgets/swipe_back_wrapper.dart';

// Wrap with visual feedback
return SwipeBackWrapperWithFeedback(
  onSwipeBack: () => context.go('/'),
  child: Scaffold(
    // ... your scaffold content
  ),
);
```

### 3. Extension Methods
Easy-to-use extension methods for any widget.

```dart
import '../../../../core/widgets/swipe_back_wrapper.dart';

// Using the extension
return Scaffold(
  // ... your scaffold content
).withSwipeBack(
  onSwipeBack: () => context.go('/'),
  withFeedback: true, // Optional visual feedback
);
```

### 4. Utility Function
Simple utility function for wrapping any widget.

```dart
import '../../../../core/widgets/swipe_back_wrapper.dart';

return wrapWithSwipeBack(
  Scaffold(
    // ... your scaffold content
  ),
  onSwipeBack: () => context.go('/'),
);
```

## Configuration Options

- `onSwipeBack`: Custom callback for back navigation (optional)
- `enabled`: Enable/disable swipe functionality (default: true)
- `swipeThreshold`: Minimum distance for swipe (default: 100.0)
- `swipeVelocityThreshold`: Minimum velocity for swipe (default: 300.0)
- `withFeedback`: Enable visual feedback during swipe (default: false)

## Usage Examples

### Basic Implementation
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipeBackWrapper(
      onSwipeBack: () => context.go('/'),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: Text('My Screen'),
        ),
        body: // ... your content
      ),
    );
  }
}
```

### With Custom Navigation
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipeBackWrapper(
      onSwipeBack: () => _handleCustomBack(context),
      child: Scaffold(
        // ... your scaffold
      ),
    );
  }

  void _handleCustomBack(BuildContext context) {
    // Custom back logic
    if (hasUnsavedChanges) {
      _showSaveDialog(context);
    } else {
      context.go('/');
    }
  }
}
```

### Using Extension Method
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text('My Screen'),
      ),
      body: // ... your content
    ).withSwipeBack(
      onSwipeBack: () => context.go('/'),
      withFeedback: true,
    );
  }
}
```

## Implementation Notes

1. **Gesture Detection**: Swipe gestures are detected from the left edge (first 50px) of the screen
2. **Velocity Threshold**: Fast swipes trigger navigation even with short distances
3. **Visual Feedback**: The advanced wrapper provides subtle visual feedback during swipes
4. **Fallback Navigation**: If no custom callback is provided, uses standard GoRouter navigation
5. **Performance**: Minimal performance impact with efficient gesture detection

## Best Practices

1. **Consistent Behavior**: Use the same swipe behavior across all screens
2. **Custom Logic**: Override `onSwipeBack` for screens with special navigation requirements
3. **Visual Feedback**: Use `withFeedback: true` for important screens where users need confirmation
4. **Testing**: Test swipe functionality on both iOS and Android devices
5. **Accessibility**: Ensure swipe gestures don't interfere with accessibility features

## Screens Already Implemented

- ✅ Active Workout Screen
- ✅ Workout Summary Screen  
- ✅ AI Coaching Screen
- ✅ Progress Screen

## Future Implementations

Consider adding swipe-back to:
- Exercise Detail Screen
- Workout History Screen
- Settings Screen
- Social Feed Screen
- Analytics Screen
- Template Builder Screen
