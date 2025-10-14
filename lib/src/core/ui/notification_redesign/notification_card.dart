import 'package:flutter/material.dart';

/// A compact, modern notification card with swipe-to-dismiss.
///
/// Features:
/// - Compact design with minimal padding
/// - Title and body with smart text overflow
/// - Optional leading icon (smaller, 24x24)
/// - Optional action buttons (inline, compact)
/// - Swipe to dismiss gesture
/// - Smooth animations
/// - Modern glassmorphic design
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.id,
    required this.title,
    required this.body,
    super.key,
    this.leading,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.backgroundColor,
    this.onDismiss,
  });
  final String id;
  final String title;
  final String body;
  final Widget? leading;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine if we have actions
    final hasActions =
        (primaryActionLabel != null && onPrimaryAction != null) ||
            (secondaryActionLabel != null && onSecondaryAction != null);

    return Dismissible(
      key: Key(id),
      onDismissed: (direction) {
        onDismiss?.call();
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isDark
                  ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.95)
                  : Colors.white.withOpacity(0.95)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: hasActions ? null : onDismiss,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Leading icon (compact)
                  if (leading != null) ...[
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 10),
                      child: IconTheme(
                        data: IconThemeData(
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        child: leading!,
                      ),
                    ),
                  ],

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Body
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.8),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Actions (compact, inline)
                        if (hasActions) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (secondaryActionLabel != null &&
                                  onSecondaryAction != null)
                                _CompactActionButton(
                                  label: secondaryActionLabel!,
                                  onPressed: onSecondaryAction!,
                                  isPrimary: false,
                                ),
                              if (secondaryActionLabel != null &&
                                  onSecondaryAction != null &&
                                  primaryActionLabel != null &&
                                  onPrimaryAction != null)
                                const SizedBox(width: 8),
                              if (primaryActionLabel != null &&
                                  onPrimaryAction != null)
                                _CompactActionButton(
                                  label: primaryActionLabel!,
                                  onPressed: onPrimaryAction!,
                                  isPrimary: true,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Close button (only if no actions)
                  if (!hasActions) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      iconSize: 18,
                      splashRadius: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('id', id));
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('body', body));
    properties.add(StringProperty('primaryActionLabel', primaryActionLabel));
    properties.add(ObjectFlagProperty<VoidCallback?>.has(
        'onPrimaryAction', onPrimaryAction));
    properties
        .add(StringProperty('secondaryActionLabel', secondaryActionLabel));
    properties.add(ObjectFlagProperty<VoidCallback?>.has(
        'onSecondaryAction', onSecondaryAction));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties
        .add(ObjectFlagProperty<VoidCallback?>.has('onDismiss', onDismiss));
  }
}

/// Compact action button for notification cards
class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isPrimary) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties
        .add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
    properties.add(DiagnosticsProperty<bool>('isPrimary', isPrimary));
  }
}
