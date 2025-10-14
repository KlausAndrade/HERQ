import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/haptic_service.dart';
import '../theme/app_animations.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatefulWidget {
  const AppButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.enableHaptics = true,
    this.gradient,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final bool enableHaptics;
  final Gradient? gradient;

  @override
  State<AppButton> createState() => _AppButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
    properties.add(EnumProperty<AppButtonVariant>('variant', variant));
    properties.add(EnumProperty<AppButtonSize>('size', size));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(DiagnosticsProperty<bool>('isDisabled', isDisabled));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
    properties.add(DoubleProperty('width', width));
    properties.add(DiagnosticsProperty<bool>('enableHaptics', enableHaptics));
    properties.add(DiagnosticsProperty<Gradient?>('gradient', gradient));
  }
}

class _AppButtonState extends State<AppButton>
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
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
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
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) => Container(
          width: widget.width,
          constraints: BoxConstraints(minHeight: _getHeight()),
          decoration: _getDecoration(context),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? _handleTap : null,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              child: Container(
                padding: _getPadding(),
                child: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppTheme.radiusSM;
      case AppButtonSize.medium:
        return AppTheme.radiusMD;
      case AppButtonSize.large:
        return AppTheme.radiusLG;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: AppTheme.spacingSM,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLG,
          vertical: AppTheme.spacingMD,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXL,
          vertical: AppTheme.spacingLG,
        );
    }
  }

  BoxDecoration _getDecoration(BuildContext context) {
    final isEnabled = !widget.isDisabled && !widget.isLoading;
    final theme = Theme.of(context);

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: widget.gradient ?? AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary
                        .withAlpha((0.3 * 255).round()),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ]
              : null,
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          gradient: widget.gradient ?? AppTheme.successGradient,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: theme.colorScheme.secondary
                        .withAlpha((0.3 * 255).round()),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ]
              : null,
        );
      case AppButtonVariant.outline:
        return BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color: isEnabled
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1.5,
          ),
          boxShadow: isEnabled ? AppTheme.softShadow : null,
        );
      case AppButtonVariant.text:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
      case AppButtonVariant.danger:
        return BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppTheme.errorColor.withAlpha((0.3 * 255).round()),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ]
              : null,
        );
    }
  }

  Color _getTextColor(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !widget.isDisabled && !widget.isLoading;

    if (!isEnabled) {
      return theme.colorScheme.onSurface.withOpacity(0.38);
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.outline:
        return theme.colorScheme.primary;
      case AppButtonVariant.text:
        return theme.colorScheme.primary;
    }
  }

  Widget _buildContent(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: _getTextColor(context),
          fontWeight: FontWeight.w600,
        );

    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(context),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSM),
          DefaultTextStyle(
            style: textStyle ?? const TextStyle(),
            child: widget.child,
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: 20,
            color: _getTextColor(context),
          ),
          const SizedBox(width: AppTheme.spacingSM),
          DefaultTextStyle(
            style: textStyle ?? const TextStyle(),
            child: widget.child,
          ),
        ],
      );
    }

    return Center(
      child: DefaultTextStyle(
        style: textStyle ?? const TextStyle(),
        child: widget.child,
      ),
    );
  }

  Future<void> _handleTap() async {
    if (widget.enableHaptics) {
      await HapticService.lightImpact();
    }
    widget.onPressed?.call();
  }
}
