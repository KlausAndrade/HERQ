import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'haptic_service.dart';

enum SnackbarType {
  success,
  error,
  warning,
  info,
}

/// Centralized snackbar service for consistent feedback messages
class SnackbarService {
  /// Show a snackbar with customizable type and haptic feedback
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    bool enableHaptics = true,
  }) {
    if (!context.mounted) return;

    if (enableHaptics) {
      switch (type) {
        case SnackbarType.success:
          HapticService.success();
          break;
        case SnackbarType.error:
          HapticService.error();
          break;
        case SnackbarType.warning:
          HapticService.warning();
          break;
        case SnackbarType.info:
          HapticService.lightImpact();
          break;
      }
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSM),
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(type),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(
              _getIcon(type),
              color: _getIconColor(type),
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getTextColor(type),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(type),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
              textColor: _getTextColor(type),
            )
          : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Show success message
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show error message
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show info message
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show warning message
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show custom message with action
  static void showWithAction({
    required BuildContext context,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Color? backgroundColor,
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMD),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onAction,
        ),
      ),
    );
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_outlined;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  static Color _getIconColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Colors.white;
      case SnackbarType.error:
        return Colors.white;
      case SnackbarType.warning:
        return Colors.black87;
      case SnackbarType.info:
        return Colors.white;
    }
  }

  static Color _getIconBackgroundColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
  return Colors.white.withAlpha((0.2 * 255).round());
      case SnackbarType.error:
  return Colors.white.withAlpha((0.2 * 255).round());
      case SnackbarType.warning:
  return Colors.black.withAlpha((0.2 * 255).round());
      case SnackbarType.info:
  return Colors.white.withAlpha((0.2 * 255).round());
    }
  }

  static Color _getTextColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Colors.white;
      case SnackbarType.error:
        return Colors.white;
      case SnackbarType.warning:
        return Colors.black87;
      case SnackbarType.info:
        return Colors.white;
    }
  }

  static Color _getBackgroundColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppTheme.secondaryColor;
      case SnackbarType.error:
        return AppTheme.errorColor;
      case SnackbarType.warning:
        return AppTheme.accentColor;
      case SnackbarType.info:
        return AppTheme.primaryColor;
    }
  }
}
