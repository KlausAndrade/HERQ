import 'package:flutter/material.dart';

/// Lightweight in-app notification model used for rendering NotificationCard
class InAppNotification {
  final String id;
  final String title;
  final String body;
  final Widget? leading;
  final Color? backgroundColor;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.leading,
    this.backgroundColor,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });
}
