import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/analytics_models.dart';

/// Card displaying near-miss PRs for motivation
class NearMissCard extends StatelessWidget {
  const NearMissCard({
    required this.nearMisses,
    super.key,
  });
  final List<NearMissPR> nearMisses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topMisses = nearMisses.take(3).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.near_me, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'So Close!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'You almost beat these PRs',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...topMisses.map(
              (miss) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withAlpha((0.3 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        miss.exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Only ${(miss.currentBest - miss.attemptedWeight).toStringAsFixed(1)} kg away!',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${miss.percentageClose.toInt()}%',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<NearMissPR>('nearMisses', nearMisses));
  }
}
