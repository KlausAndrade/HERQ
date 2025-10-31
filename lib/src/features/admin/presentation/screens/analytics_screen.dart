import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/admin_data_provider.dart';
import '../../../../core/providers/admin_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gate access
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    final analyticsData = ref.watch(analyticsProvider);
    final recentEvents = ref.watch(recentEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reporting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(analyticsProvider),
          ),
        ],
      ),
      body: analyticsData.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'User Metrics', Colors.blue),
              const SizedBox(height: 12),
              _buildUserMetrics(context, data),
              const SizedBox(height: 24),
              _buildSectionHeader(
                context,
                'Recent Events (Last 100)',
                Colors.teal,
              ),
              const SizedBox(height: 12),
              recentEvents.when(
                data: (events) => _buildEventsList(context, events),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Failed to load events: $e'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Workout Activity', Colors.green),
              const SizedBox(height: 12),
              _buildWorkoutMetrics(context, data),
              const SizedBox(height: 24),
              _buildSectionHeader(
                context,
                'User Growth Over Time',
                Colors.purple,
              ),
              const SizedBox(height: 12),
              _buildUserGrowthChart(context, data),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Workout Trends', Colors.orange),
              const SizedBox(height: 12),
              _buildWorkoutTrendChart(context, data),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Top Exercises', Colors.red),
              const SizedBox(height: 12),
              _buildTopExercises(context, data),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading analytics: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(analyticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 24,
          color: color,
          margin: const EdgeInsets.only(right: 8),
        ),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildUserMetrics(BuildContext context, Map<String, dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile: 2x2 grid
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Total Users',
                      value: '${data['totalUsers'] ?? 0}',
                      change: 'Overall',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      title: 'Active Users',
                      value: '${data['activeUsers'] ?? 0}',
                      change: 'Currently active',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Total Workouts',
                      value: '${data['totalWorkouts'] ?? 0}',
                      change: 'All time',
                      icon: Icons.fitness_center,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      title: 'Avg/User',
                      value: '${data['averageWorkoutsPerUser'] ?? '0'}',
                      change: 'Workouts per user',
                      icon: Icons.bar_chart,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Desktop: 4 columns
          return Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Users',
                  value: '${data['totalUsers'] ?? 0}',
                  change: 'Overall',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Active Users',
                  value: '${data['activeUsers'] ?? 0}',
                  change: 'Currently active',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Total Workouts',
                  value: '${data['totalWorkouts'] ?? 0}',
                  change: 'All time',
                  icon: Icons.fitness_center,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Avg/User',
                  value: '${data['averageWorkoutsPerUser'] ?? '0'}',
                  change: 'Workouts per user',
                  icon: Icons.bar_chart,
                  color: Colors.purple,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildWorkoutMetrics(BuildContext context, Map<String, dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Recent Workouts',
                      value: '${data['recentWorkouts'] ?? 0}',
                      change: 'Last 30 days',
                      icon: Icons.trending_up,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      title: 'Daily Avg',
                      value:
                          '${((data['recentWorkouts'] ?? 0) / 30).toStringAsFixed(1)}',
                      change: 'Workouts per day',
                      icon: Icons.calendar_today,
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Recent Workouts',
                  value: '${data['recentWorkouts'] ?? 0}',
                  change: 'Last 30 days',
                  icon: Icons.trending_up,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Daily Avg',
                  value:
                      '${((data['recentWorkouts'] ?? 0) / 30).toStringAsFixed(1)}',
                  change: 'Workouts per day',
                  icon: Icons.calendar_today,
                  color: Colors.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Growth Rate',
                  value: '+12%',
                  change: 'vs last month',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Peak Day',
                  value: 'Monday',
                  change: 'Most active day',
                  icon: Icons.schedule,
                  color: Colors.indigo,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildUserGrowthChart(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final dailyWorkouts = data['dailyWorkouts'] as Map<String, int>? ?? {};
    final List<FlSpot> spots = [];
    final List<String> dates = dailyWorkouts.keys.toList()..sort();

    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyWorkouts[dates[i]]!.toDouble()));
    }

    if (spots.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No user growth data available.')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Activity (Last 30 Days)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (dates.length / 5).ceil().toDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < dates.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                dates[value.toInt()].substring(5),
                              ), // Show MM-DD
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval:
                            (spots
                                        .map((e) => e.y)
                                        .reduce((a, b) => a > b ? a : b) /
                                    4)
                                .ceil()
                                .toDouble(),
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.withOpacity(0.3),
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

  Widget _buildWorkoutTrendChart(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final dailyWorkouts = data['dailyWorkouts'] as Map<String, int>? ?? {};
    final List<FlSpot> spots = [];
    final List<String> dates = dailyWorkouts.keys.toList()..sort();

    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyWorkouts[dates[i]]!.toDouble()));
    }

    if (spots.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No workout trend data available.')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workouts Completed (Last 30 Days)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (dates.length / 5).ceil().toDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < dates.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                dates[value.toInt()].substring(5),
                              ), // Show MM-DD
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval:
                            (spots
                                        .map((e) => e.y)
                                        .reduce((a, b) => a > b ? a : b) /
                                    4)
                                .ceil()
                                .toDouble(),
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withOpacity(0.3),
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

  Widget _buildTopExercises(BuildContext context, Map<String, dynamic> data) {
    final topExercises = data['topExercises'] as List<dynamic>? ?? [];

    if (topExercises.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No top exercises data available.')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Popular Exercises',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topExercises.length,
              itemBuilder: (context, index) {
                final exercise = topExercises[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  title: Text(exercise['name']),
                  trailing: Text('${exercise['count']} uses'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              change,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildEventsList(
  BuildContext context,
  List<Map<String, dynamic>> events,
) {
  if (events.isEmpty) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No events found.')),
      ),
    );
  }

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: events.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final e = events[index];
          final name = e['name'] as String? ?? 'event';
          final createdAt = e['created_at'] as String?;
          final props = e['properties'];

          return ListTile(
            dense: true,
            leading: const Icon(Icons.bolt, color: Colors.teal),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              props is Map<String, dynamic>
                  ? props.entries
                        .take(3)
                        .map((kv) => '${kv.key}: ${kv.value}')
                        .join(' • ')
                  : props?.toString() ?? '-',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              createdAt != null
                  ? createdAt.substring(0, 19).replaceFirst('T', ' ')
                  : '',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          );
        },
      ),
    ),
  );
}
