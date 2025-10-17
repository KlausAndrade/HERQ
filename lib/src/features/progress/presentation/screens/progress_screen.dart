import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/widgets/swipe_back_wrapper.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../providers/chart_providers.dart';
import '../widgets/chart_widgets.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutStats = ref.watch(workoutStatsProvider);
    final weeklyVolume = ref.watch(weeklyVolumeProvider);
    final workoutFrequency = ref.watch(workoutFrequencyProvider);

    return SwipeBackWrapperWithFeedback(
      onSwipeBack: () => context.go('/'),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: Text(S.of(context)!.progress),
          actions: [
            IconButton(
              icon: const Icon(Icons.psychology),
              onPressed: () => context.go('/analytics'),
              tooltip: 'Advanced Analytics',
            ),
          ],
        ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Stats Cards
          workoutStats.when(
            data: (stats) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: S.of(context)!.totalWorkouts,
                        value: stats.totalWorkouts.toString(),
                        subtitle: 'Completed',
                        icon: Icons.fitness_center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: S.of(context)!.totalVolume,
                        value:
                            '${(stats.totalVolumeKg / 1000).toStringAsFixed(1)}k',
                        subtitle: S.of(context)!.kgLifted,
                        icon: Icons.scale,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: S.of(context)!.avgDuration,
                        value: stats.averageDurationMinutes.toString(),
                        subtitle: S.of(context)!.minutes,
                        icon: Icons.schedule,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: S.of(context)!.streak,
                        value: stats.currentStreak.toString(),
                        subtitle: S.of(context)!.days,
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: S.of(context)!.loading,
                        value: '-',
                        subtitle: '',
                        icon: Icons.fitness_center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: S.of(context)!.loading,
                        value: '-',
                        subtitle: '',
                        icon: Icons.scale,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: S.of(context)!.loading,
                        value: '-',
                        subtitle: '',
                        icon: Icons.schedule,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: S.of(context)!.loading,
                        value: '-',
                        subtitle: '',
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            error: (error, stack) => Center(
              child: Text(S.of(context)!.error),
            ),
          ),
          const SizedBox(height: 24),

          // Charts Section
          Text(
            S.of(context)!.progressCharts,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          // Volume Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Volume Over Time (Weekly)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  weeklyVolume.when(
                    data: (data) => VolumeChart(data: data),
                    loading: () => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Error loading chart'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Frequency Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout Frequency (Weekly)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  workoutFrequency.when(
                    data: (data) => FrequencyChart(data: data),
                    loading: () => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Error loading chart'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Personal Records Section
          Text(
            'Recent Personal Records',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          ref.watch(personalRecordsProvider).when(
                data: (records) {
                  if (records.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No personal records yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Complete some workouts to see your progress!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: records
                        .take(5)
                        .map(
                          (record) => FutureBuilder(
                            future: _getExerciseName(ref, record.exerciseId),
                            builder: (context, snapshot) {
                              final exerciseName =
                                  snapshot.data ?? record.exerciseId;
                              return _PersonalRecordCard(
                                exercise: exerciseName,
                                type: '1RM Est.',
                                value:
                                    '${record.oneRepMax.toStringAsFixed(1)} kg',
                                date: _formatDate(record.date),
                                improvement:
                                    '${record.weight.toStringAsFixed(1)}kg × ${record.reps}',
                              );
                            },
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text('Error loading personal records: $error'),
                    ),
                  ),
                ),
              ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
      ),
    );
  }

  Future<String> _getExerciseName(WidgetRef ref, String exerciseId) async {
    try {
      final database = ref.read(databaseProvider);
      if (database == null) return exerciseId;

      final exercises = await (database.select(database.exercises)
            ..where((tbl) => tbl.id.equals(exerciseId)))
          .get();

      return exercises.isNotEmpty ? exercises.first.name : exerciseId;
    } catch (e) {
      return exerciseId;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else {
      final months = (difference / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }
  }

  Widget _buildBottomNavigation(BuildContext context) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/workout-templates');
              break;
            case 2:
              context.go('/exercises');
              break;
            case 3:
              context.go('/progress');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: S.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center_outlined),
            activeIcon: const Icon(Icons.fitness_center),
            label: S.of(context)!.workouts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search),
            label: S.of(context)!.exercises,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up_outlined),
            activeIcon: const Icon(Icons.trending_up),
            label: S.of(context)!.progress,
          ),
        ],
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('value', value));
    properties.add(StringProperty('subtitle', subtitle));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
  }
}

class _PersonalRecordCard extends StatelessWidget {
  const _PersonalRecordCard({
    required this.exercise,
    required this.type,
    required this.value,
    required this.date,
    required this.improvement,
  });
  final String exercise;
  final String type;
  final String value;
  final String date;
  final String improvement;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.emoji_events,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
          title: Text(
            '$exercise ($type)',
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(date),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                improvement,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('exercise', exercise));
    properties.add(StringProperty('type', type));
    properties.add(StringProperty('value', value));
    properties.add(StringProperty('date', date));
    properties.add(StringProperty('improvement', improvement));
  }
}
