import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/haptic_service.dart';
import '../theme/app_animations.dart';
import '../theme/app_theme.dart';

enum AppCardVariant {
  elevated,
  flat,
  outlined,
  glass,
}

class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    super.key,
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<AppCardVariant>('variant', variant));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(DiagnosticsProperty<EdgeInsets?>('padding', padding));
    properties.add(DiagnosticsProperty<EdgeInsets?>('margin', margin));
    properties.add(DiagnosticsProperty<Gradient?>('gradient', gradient));
    properties
        .add(DiagnosticsProperty<BorderRadius?>('borderRadius', borderRadius));
    properties.add(StringProperty('heroTag', heroTag));
    properties.add(DiagnosticsProperty<bool>('enableHaptics', enableHaptics));
    properties.add(DiagnosticsProperty<bool>('animateOnTap', animateOnTap));
  }
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.snappy),
    );
    _elevationAnimation = Tween<double>(begin: 2, end: 8).animate(
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
        builder: (context, child) => Transform.scale(
          scale: widget.animateOnTap ? _scaleAnimation.value : 1.0,
          child: DecoratedBox(
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
        ),
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
    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusMD);

    switch (widget.variant) {
      case AppCardVariant.elevated:
        return BoxDecoration(
          color: widget.gradient == null ? theme.colorScheme.surface : null,
          gradient: widget.gradient,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: widget.animateOnTap ? _elevationAnimation.value : 8,
              offset: Offset(
                0,
                widget.animateOnTap ? _elevationAnimation.value / 2 : 4,
              ),
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
            color: theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
          ),
        );
      case AppCardVariant.glass:
        return BoxDecoration(
          color: theme.colorScheme.surface.withAlpha((0.8 * 255).round()),
          borderRadius: borderRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha((0.1 * 255).round()),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
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
