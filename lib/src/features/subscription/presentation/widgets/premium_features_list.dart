import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class PremiumFeaturesList extends StatelessWidget {
  const PremiumFeaturesList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.premiumFeatures,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildFeatureItems(context, l10n),
          ],
        ),
      ),
    );
  }

      List<Widget> _buildFeatureItems(BuildContext context, dynamic l10n) {
    final features = [
      _FeatureItem(
        icon: Icons.psychology,
        title: l10n.unlimitedAICoaching,
        description: l10n.unlimitedAICoachingDescription,
        color: Colors.purple,
      ),
      _FeatureItem(
        icon: Icons.analytics,
        title: l10n.advancedAnalytics,
        description: l10n.advancedAnalyticsDescription,
        color: Colors.blue,
      ),
      _FeatureItem(
        icon: Icons.folder_open,
        title: l10n.unlimitedTemplates,
        description: l10n.unlimitedTemplatesDescription,
        color: Colors.green,
      ),
      _FeatureItem(
        icon: Icons.download,
        title: l10n.dataExport,
        description: l10n.dataExportDescription,
        color: Colors.orange,
      ),
      _FeatureItem(
        icon: Icons.support_agent,
        title: l10n.prioritySupport,
        description: l10n.prioritySupportDescription,
        color: Colors.red,
      ),
    ];

    return features.map((feature) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    )).toList();
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}
