import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mixin that provides swipe-back functionality to any screen
/// Usage: class MyScreen extends ConsumerWidget with SwipeBackMixin
mixin SwipeBackMixin<T extends StatefulWidget> on State<T> {
  /// Override this method to provide custom back navigation behavior
  void onSwipeBack() {
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  /// Wrap your Scaffold with swipe back functionality
  Widget buildWithSwipeBack(Widget child) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Only handle horizontal swipes from the left edge
        if (details.delta.dx > 0 && details.localPosition.dx < 50) {
          _handleSwipeGesture(details);
        }
      },
      onPanEnd: (details) {
        // Handle swipe completion
        if (details.velocity.pixelsPerSecond.dx > 300) {
          onSwipeBack();
        }
      },
      child: child,
    );
  }

  void _handleSwipeGesture(DragUpdateDetails details) {
    // This is called during the swipe gesture
    // We could add visual feedback here if needed
  }
}

/// Extension for easy swipe back functionality on any widget
extension SwipeBackMixinExtension on Widget {
  /// Add swipe back functionality to any widget
  Widget withSwipeBack({
    VoidCallback? onSwipeBack,
    bool enabled = true,
    double swipeThreshold = 100.0,
    double swipeVelocityThreshold = 300.0,
  }) {
    if (!enabled) return this;

    return GestureDetector(
      onPanUpdate: (details) {
        // Only handle horizontal swipes from the left edge
        if (details.delta.dx > 0 && details.localPosition.dx < 50) {
          // Visual feedback could be added here
        }
      },
      onPanEnd: (details) {
        // Handle swipe completion
        if (details.velocity.pixelsPerSecond.dx > swipeVelocityThreshold) {
          if (onSwipeBack != null) {
            onSwipeBack();
          } else {
            // Default back navigation behavior
            final context = this as BuildContext?;
            if (context != null) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            }
          }
        }
      },
      child: this,
    );
  }
}
