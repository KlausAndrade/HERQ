import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/analytics_models.dart';

/// Card displaying PR streaks with fire icons
class PRStreaksCard extends StatelessWidget {
  const PRStreaksCard({
    required this.streaks,
    super.key,
  });
  final List<PRStreak> streaks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topStreaks = streaks.take(3).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  '🔥',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(width: 8),
                Text(
                  'PR Streaks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...topStreaks.map(
              (streak) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        streak.exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: streak.isOnFire
                            ? Colors.orange
                            : theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${streak.currentStreak} PRs',
                        style: TextStyle(
                          color: streak.isOnFire
                              ? Colors.white
                              : theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
    properties.add(IterableProperty<PRStreak>('streaks', streaks));
  }
}
