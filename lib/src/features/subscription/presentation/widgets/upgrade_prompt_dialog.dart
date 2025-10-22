import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../l10n/app_localizations.dart';

class UpgradePromptDialog extends ConsumerWidget {
  const UpgradePromptDialog({
    super.key,
    required this.title,
    required this.message,
    this.featureIcon,
    this.onUpgrade,
  });

  final String title;
  final String message;
  final IconData? featureIcon;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Feature Icon
          if (featureIcon != null) ...[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                featureIcon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Premium Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'HERQ Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.maybeLater),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onUpgrade != null) {
              onUpgrade!();
            } else {
              context.go('/premium');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(l10n.upgradeNow),
        ),
      ],
    );
  }
}

/// AI Limit Reached Dialog
class AILimitReachedDialog extends StatelessWidget {
  const AILimitReachedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;

    return UpgradePromptDialog(
      title: l10n.aiLimitReached,
      message: l10n.aiLimitReachedMessage,
      featureIcon: Icons.psychology,
    );
  }
}

/// Template Limit Reached Dialog
class TemplateLimitReachedDialog extends StatelessWidget {
  const TemplateLimitReachedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;

    return UpgradePromptDialog(
      title: l10n.templateLimitReached,
      message: l10n.templateLimitReachedMessage,
      featureIcon: Icons.folder_open,
    );
  }
}

/// Premium Feature Dialog
class PremiumFeatureDialog extends StatelessWidget {
  const PremiumFeatureDialog({
    super.key,
    required this.featureName,
    required this.featureIcon,
  });

  final String featureName;
  final IconData featureIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;

    return UpgradePromptDialog(
      title: l10n.premiumFeature,
      message: l10n.premiumFeatureMessage,
      featureIcon: featureIcon,
    );
  }
}

/// Upgrade Banner Widget
class UpgradeBanner extends StatelessWidget {
  const UpgradeBanner({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.upgradePrompt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.upgradePromptMessage,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
