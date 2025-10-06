import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_animations.dart';
import '../services/haptic_service.dart';

enum AppCardVariant {
  elevated,
  flat,
  outlined,
  glass,
}

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.onTap,
    this.padding,
    this.margin,
    this.gradient,
    this.borderRadius,
    this.heroTag,
    this.enableHaptics = true,
    this.animateOnTap = true,
  });

  final Widget child;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final bool enableHaptics;
  final bool animateOnTap;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.snappy),
    );
    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.smooth),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.animateOnTap) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.animateOnTap) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.animateOnTap) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.animateOnTap ? _scaleAnimation.value : 1.0,
            child: Container(
              decoration: _getDecoration(context),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap != null ? _handleTap : null,
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  borderRadius: widget.borderRadius ??
                      BorderRadius.circular(AppTheme.radiusMD),
                  child: Container(
                    padding: widget.padding ??
                        const EdgeInsets.all(AppTheme.spacingMD),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.heroTag != null) {
      card = Hero(
        tag: widget.heroTag!,
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _getDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = widget.borderRadius ??
        BorderRadius.circular(AppTheme.radiusMD);

    switch (widget.variant) {
      case AppCardVariant.elevated:
        return BoxDecoration(
          color: widget.gradient == null ? theme.colorScheme.surface : null,
          gradient: widget.gradient,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: widget.animateOnTap ? _elevationAnimation.value : 8,
              offset: Offset(0, widget.animateOnTap ? _elevationAnimation.value / 2 : 4),
            ),
          ],
        );
      case AppCardVariant.flat:
        return BoxDecoration(
          color: widget.gradient == null ? theme.colorScheme.surface : null,
          gradient: widget.gradient,
          borderRadius: borderRadius,
        );
      case AppCardVariant.outlined:
        return BoxDecoration(
          color: widget.gradient == null ? theme.colorScheme.surface : null,
          gradient: widget.gradient,
          borderRadius: borderRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        );
      case AppCardVariant.glass:
        return BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.8),
          borderRadius: borderRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        );
    }
  }

  Future<void> _handleTap() async {
    if (widget.enableHaptics) {
      await HapticService.lightImpact();
    }
    widget.onTap?.call();
  }
}