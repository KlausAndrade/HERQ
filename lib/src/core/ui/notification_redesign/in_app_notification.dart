import 'package:flutter/widgets.dart';

/// Lightweight in-app notification model used for rendering NotificationCard
class InAppNotification {
  final String id;
  final String title;
  final String body;
  final Widget? leading;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.leading,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });
}
