import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/analytics_provider.dart';
import '../widgets/power_score_card.dart';
import '../widgets/pr_predictions_card.dart';
import '../widgets/pr_streaks_card.dart';
import '../widgets/near_miss_card.dart';
import '../widgets/volume_chart_card.dart';
import '../widgets/plateau_warnings_card.dart';
import '../widgets/strength_balance_card.dart';

/// Advanced Analytics Screen showing PR predictions, power score, and insights
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(analyticsProvider),
            tooltip: 'Refresh Analytics',
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(analyticsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Power Score - Top of screen
              PowerScoreCard(powerScore: analytics.powerScore),
              const SizedBox(height: 16),

              // PR Streaks - Gamification element
              if (analytics.prStreaks.isNotEmpty) ...[
                PRStreaksCard(streaks: analytics.prStreaks),
                const SizedBox(height: 16),
              ],

              // Near-Miss PRs - Motivational nudges
              if (analytics.nearMisses.isNotEmpty) ...[
                NearMissCard(nearMisses: analytics.nearMisses),
                const SizedBox(height: 16),
              ],

              // PR Predictions - Main feature
              if (analytics.predictions.isNotEmpty) ...[
                PRPredictionsCard(predictions: analytics.predictions),
                const SizedBox(height: 16),
              ],

              // Volume Trends - Training intensity
              if (analytics.volumeTrends.isNotEmpty) ...[
                VolumeChartCard(volumeTrends: analytics.volumeTrends),
                const SizedBox(height: 16),
              ],

              // Plateau Warnings - Areas needing attention
              if (analytics.plateauAnalysis.plateaus.isNotEmpty) ...[
                PlateauWarningsCard(analysis: analytics.plateauAnalysis),
                const SizedBox(height: 16),
              ],

              // Strength Balance - Muscle group distribution
              StrengthBalanceCard(balance: analytics.strengthBalance),

              const SizedBox(height: 80), // Bottom padding for nav bar
            ],
          ),
        ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing your progress...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading analytics:\n$error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(analyticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
