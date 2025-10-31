import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/models/analytics_models.dart';

/// Card showing volume trends over time with chart
class VolumeChartCard extends StatelessWidget {
  const VolumeChartCard({required this.volumeTrends, super.key});
  final List<VolumeAnalysis> volumeTrends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (volumeTrends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Volume Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Last 12 weeks',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: volumeTrends
                          .asMap()
                          .entries
                          .map(
                            (entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.totalVolume / 1000, // Convert to tons
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
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
    properties.add(
      IterableProperty<VolumeAnalysis>('volumeTrends', volumeTrends),
    );
  }
}
