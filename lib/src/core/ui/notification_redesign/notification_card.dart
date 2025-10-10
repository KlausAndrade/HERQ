import 'package:flutter/material.dart';

/// A compact, accessible notification card used across the app.
///
/// Features:
/// - Title, body (multiline) and optional leading icon.
/// - Up to two optional action buttons (primary/secondary).
/// - Built for accessibility: semantic labels, hints and respects textScaleFactor.
/// - Responsive padding and typography for mobile & web.
class NotificationCard extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final Widget? leading;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? backgroundColor;

  const NotificationCard({
    Key? key,
    required this.id,
    required this.title,
    required this.body,
    this.leading,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScaleFactorOf(context);

    return Semantics(
      container: true,
      label: 'Notification: $title',
      hint: body,
      child: Card(
        color: backgroundColor ?? theme.cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Semantics(
                    label: 'Notification icon',
                    child: SizedBox(width: 40, height: 40, child: leading),
                  ),
                )
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: textScale,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: textScale,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (secondaryActionLabel != null && onSecondaryAction != null)
                          TextButton(
                            onPressed: onSecondaryAction,
                            child: Text(secondaryActionLabel!),
                          ),
                        const Spacer(),
                        if (primaryActionLabel != null && onPrimaryAction != null)
                          ElevatedButton(
                            onPressed: onPrimaryAction,
                            child: Text(primaryActionLabel!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
