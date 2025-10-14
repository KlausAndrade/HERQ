import 'package:flutter/material.dart';

import '../../domain/models/analytics_models.dart';

/// Card displaying user's Power Score with tier badge
class PowerScoreCard extends StatelessWidget {
  const PowerScoreCard({
    required this.powerScore,
    super.key,
  });
  final PowerScore powerScore;

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(powerScore.tier);
    final isPositiveChange = powerScore.change30Days >= 0;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tierColor.withOpacity(0.1),
              tierColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with tier badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Power Score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: tierColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        powerScore.tierEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        powerScore.tier,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current score
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  powerScore.current.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: tierColor,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'points',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 30-day change
            Row(
              children: [
                Icon(
                  isPositiveChange ? Icons.trending_up : Icons.trending_down,
                  color: isPositiveChange ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositiveChange ? '+' : ''}${powerScore.change30Days.toStringAsFixed(1)} this month',
                  style: TextStyle(
                    color: isPositiveChange ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress to next tier
            if (powerScore.pointsToNextTier > 0) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next Tier',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${powerScore.pointsToNextTier} points to go',
                    style: TextStyle(
                      color: tierColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _calculateProgress(powerScore),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _calculateProgress(PowerScore score) {
    // Calculate progress towards next tier
    final tierThresholds = {
      'Bronze': 50.0,
      'Silver': 150.0,
      'Gold': 300.0,
      'Platinum': 500.0,
      'Diamond': 1000.0,
    };

    final currentThreshold = tierThresholds[score.tier] ?? 0;
    final nextTierIndex = tierThresholds.keys.toList().indexOf(score.tier) + 1;

    if (nextTierIndex >= tierThresholds.length) {
      return 1; // Already at max tier
    }

    final nextThreshold = tierThresholds.values.elementAt(nextTierIndex);
    final progress =
        (score.current - currentThreshold) / (nextThreshold - currentThreshold);

    return progress.clamp(0.0, 1.0);
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.grey;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PowerScore>('powerScore', powerScore));
  }
}
