import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A wrapper widget that provides swipe-right-to-go-back functionality
/// Similar to Facebook, WhatsApp, and other modern apps
class SwipeBackWrapper extends StatelessWidget {
  const SwipeBackWrapper({
    required this.child,
    super.key,
    this.onSwipeBack,
    this.enabled = true,
    this.swipeThreshold = 100.0,
    this.swipeVelocityThreshold = 300.0,
  });

  final Widget child;
  final VoidCallback? onSwipeBack;
  final bool enabled;
  final double swipeThreshold;
  final double swipeVelocityThreshold;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return GestureDetector(
      onPanUpdate: (details) {
        // Only handle horizontal swipes from the left edge
        if (details.delta.dx > 0 && details.localPosition.dx < 50) {
          _handleSwipeGesture(context, details);
        }
      },
      onPanEnd: (details) {
        // Handle swipe completion
        if (details.velocity.pixelsPerSecond.dx > swipeVelocityThreshold) {
          _performBackNavigation(context);
        }
      },
      child: child,
    );
  }

  void _handleSwipeGesture(BuildContext context, DragUpdateDetails details) {
    // This is called during the swipe gesture
    // We could add visual feedback here if needed
  }

  void _performBackNavigation(BuildContext context) {
    if (onSwipeBack != null) {
      onSwipeBack!();
    } else {
      // Default back navigation behavior
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }
}

/// A more advanced swipe back wrapper with visual feedback
class SwipeBackWrapperWithFeedback extends StatefulWidget {
  const SwipeBackWrapperWithFeedback({
    required this.child,
    super.key,
    this.onSwipeBack,
    this.enabled = true,
    this.swipeThreshold = 100.0,
    this.swipeVelocityThreshold = 300.0,
  });

  final Widget child;
  final VoidCallback? onSwipeBack;
  final bool enabled;
  final double swipeThreshold;
  final double swipeVelocityThreshold;

  @override
  State<SwipeBackWrapperWithFeedback> createState() =>
      _SwipeBackWrapperWithFeedbackState();
}

class _SwipeBackWrapperWithFeedbackState
    extends State<SwipeBackWrapperWithFeedback> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  double _dragDistance = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      onPanStart: (details) {
        // Only start tracking if swipe starts from the left edge
        if (details.localPosition.dx < 50) {
          setState(() {
            _isDragging = true;
            _dragDistance = 0.0;
          });
        }
      },
      onPanUpdate: (details) {
        if (_isDragging && details.delta.dx > 0) {
          setState(() {
            _dragDistance += details.delta.dx;
          });

          // Update animation based on drag distance
          final progress =
              (_dragDistance / widget.swipeThreshold).clamp(0.0, 1.0);
          _animationController.value = progress;
        }
      },
      onPanEnd: (details) {
        if (_isDragging) {
          setState(() {
            _isDragging = false;
          });

          // Check if swipe should trigger back navigation
          if (_dragDistance > widget.swipeThreshold ||
              details.velocity.pixelsPerSecond.dx >
                  widget.swipeVelocityThreshold) {
            _performBackNavigation();
          } else {
            // Animate back to original position
            _animationController.reverse();
          }
        }
      },
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          // Calculate the actual drag distance for smooth following
          final screenWidth = MediaQuery.of(context).size.width;
          final dragOffset = _isDragging
              ? _dragDistance.clamp(0.0, screenWidth * 0.3)
              : _slideAnimation.value * screenWidth * 0.3;

          return Stack(
            children: [
              // Background shadow effect
              if (_isDragging && _dragDistance > 0)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(
                      (_dragDistance / widget.swipeThreshold).clamp(0.0, 0.1),
                    ),
                  ),
                ),
              // Main content with slide animation
              Transform.translate(
                offset: Offset(dragOffset, 0),
                child: Opacity(
                  opacity: _isDragging
                      ? (1.0 -
                          (_dragDistance / widget.swipeThreshold)
                              .clamp(0.0, 0.3))
                      : (1.0 - _slideAnimation.value * 0.3),
                  child: widget.child,
                ),
              ),
              // Swipe indicator
              if (_isDragging && _dragDistance > 10)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.withOpacity(0.8),
                          Colors.blue.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _performBackNavigation() {
    _animationController.forward().then((_) {
      if (widget.onSwipeBack != null) {
        widget.onSwipeBack!();
      } else {
        // Default back navigation behavior
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    });
  }
}

/// Extension to easily add swipe back functionality to any screen
extension SwipeBackExtension on Widget {
  Widget withSwipeBack({
    VoidCallback? onSwipeBack,
    bool enabled = true,
    double swipeThreshold = 100.0,
    double swipeVelocityThreshold = 300.0,
    bool withFeedback = false,
  }) {
    if (withFeedback) {
      return SwipeBackWrapperWithFeedback(
        onSwipeBack: onSwipeBack,
        enabled: enabled,
        swipeThreshold: swipeThreshold,
        swipeVelocityThreshold: swipeVelocityThreshold,
        child: this,
      );
    } else {
      return SwipeBackWrapper(
        onSwipeBack: onSwipeBack,
        enabled: enabled,
        swipeThreshold: swipeThreshold,
        swipeVelocityThreshold: swipeVelocityThreshold,
        child: this,
      );
    }
  }
}

/// Utility function to wrap any screen with swipe back functionality
Widget wrapWithSwipeBack(
  Widget child, {
  VoidCallback? onSwipeBack,
  bool enabled = true,
  double swipeThreshold = 100.0,
  double swipeVelocityThreshold = 300.0,
  bool withFeedback = false,
}) {
  return child.withSwipeBack(
    onSwipeBack: onSwipeBack,
    enabled: enabled,
    swipeThreshold: swipeThreshold,
    swipeVelocityThreshold: swipeVelocityThreshold,
    withFeedback: withFeedback,
  );
}
