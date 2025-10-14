import 'package:flutter/material.dart';

import '../../domain/models/analytics_models.dart';

/// Card showing strength balance across muscle groups
class StrengthBalanceCard extends StatelessWidget {
  const StrengthBalanceCard({
    required this.balance,
    super.key,
  });
  final StrengthBalance balance;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Strength Balance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Balance Score:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${balance.balanceScore.toInt()}/100',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(balance.balanceScore),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Top muscle groups
              ...balance.volumeDistribution.entries.take(5).map((entry) {
                final percentage = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatMuscleGroup(entry.key),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getPercentageColor(percentage),
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getPercentageColor(double percentage) {
    if (percentage > 25) return Colors.red;
    if (percentage > 20) return Colors.orange;
    return Colors.green;
  }

  String _formatMuscleGroup(String key) => key
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<StrengthBalance>('balance', balance));
  }
}
