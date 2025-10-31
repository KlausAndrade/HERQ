import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../theme/app_animations.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.illustration,
    this.actionText,
    this.onAction,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onAction;
  final EdgeInsets? padding;

  @override
  State<EmptyState> createState() => _EmptyStateState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('subtitle', subtitle));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
    properties.add(StringProperty('actionText', actionText));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onAction', onAction));
    properties.add(DiagnosticsProperty<EdgeInsets?>('padding', padding));
  }
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppDurations.slow, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.8, curve: AppCurves.smooth),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 1, curve: AppCurves.smooth),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: AppCurves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fadeAnimation,
    child: SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Illustration
            ScaleTransition(
              scale: _scaleAnimation,
              child:
                  widget.illustration ??
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.1 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon ?? Icons.inbox_outlined,
                      size: 60,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.6 * 255).round()),
                    ),
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Title
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (widget.subtitle != null) ...[
              const SizedBox(height: AppTheme.spacingMD),
              Text(
                widget.subtitle!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action Button
            if (widget.actionText != null && widget.onAction != null) ...[
              const SizedBox(height: AppTheme.spacingXL),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _PulsingButton(
                  onPressed: widget.onAction!,
                  child: Text(widget.actionText!),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _PulsingButton extends StatefulWidget {
  const _PulsingButton({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed),
    );
  }
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start pulsing after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _pulseAnimation,
    child: SizedBox(
      width: double.infinity, // Full width to prevent clipping
      child: AppButton(
        onPressed: widget.onPressed,
        size: AppButtonSize.large,
        child: widget.child,
      ),
    ),
  );
}
