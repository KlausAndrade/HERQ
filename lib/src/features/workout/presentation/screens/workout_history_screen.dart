import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/database/database.dart';
import '../providers/workout_providers.dart';
import '../providers/filter_providers.dart';
import '../widgets/workout_calendar.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

enum HistoryViewMode { list, monthly, calendar }

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  HistoryViewMode _viewMode = HistoryViewMode.monthly;

  @override
  Widget build(BuildContext context) {
    final workoutStatsAsync = ref.watch(workoutStatsProvider);
    final workoutSessionsAsync = _viewMode == HistoryViewMode.monthly
        ? ref.watch(workoutSessionsByMonthProvider)
        : ref.watch(filteredWorkoutSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(S.of(context)!.workoutHistory),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _viewMode = switch (_viewMode) {
                  HistoryViewMode.list => HistoryViewMode.monthly,
                  HistoryViewMode.monthly => HistoryViewMode.calendar,
                  HistoryViewMode.calendar => HistoryViewMode.list,
                };
              });
            },
            icon: Icon(_getViewIcon()),
            tooltip: _getViewTooltip(),
          ),
          IconButton(
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Filter Indicator
          Consumer(
            builder: (context, ref, _) {
              final filterState = ref.watch(workoutFilterProvider);
              if (filterState.filter == WorkoutFilter.all) {
                return const SizedBox.shrink();
              }

              String filterText;
              switch (filterState.filter) {
                case WorkoutFilter.thisWeek:
                  filterText = 'This Week';
                  break;
                case WorkoutFilter.thisMonth:
                  filterText = 'This Month';
                  break;
                case WorkoutFilter.all:
                  filterText = 'All';
                  break;
              }

              return Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filter: $filterText',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        ref
                            .read(workoutFilterProvider.notifier)
                            .setFilter(WorkoutFilter.all);
                      },
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Workout Stats Header
          workoutStatsAsync.when(
            data: (stats) => _WorkoutStatsHeader(stats: stats),
            loading: () => const SizedBox(height: 140),
            error: (error, stack) => const SizedBox(height: 140),
          ),

          // Workout History List
          Expanded(
            child: switch (_viewMode) {
              HistoryViewMode.list => _buildListView(workoutSessionsAsync),
              HistoryViewMode.monthly =>
                _buildGroupedView(workoutSessionsAsync),
              HistoryViewMode.calendar =>
                _buildCalendarView(workoutSessionsAsync),
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  IconData _getViewIcon() {
    return switch (_viewMode) {
      HistoryViewMode.list => Icons.calendar_month,
      HistoryViewMode.monthly => Icons.calendar_view_month,
      HistoryViewMode.calendar => Icons.list,
    };
  }

  String _getViewTooltip() {
    return switch (_viewMode) {
      HistoryViewMode.list => 'Monthly View',
      HistoryViewMode.monthly => 'Calendar View',
      HistoryViewMode.calendar => 'List View',
    };
  }

  Widget _buildCalendarView(AsyncValue workoutSessionsAsync) {
    return workoutSessionsAsync.when(
      data: (data) {
        // For calendar view, we need the flat list of sessions
        List<WorkoutSession> sessions;
        if (data is Map<String, List<WorkoutSession>>) {
          // If data comes from monthly provider, flatten it
          sessions = data.values.expand((list) => list).toList();
        } else {
          sessions = data as List<WorkoutSession>;
        }

        if (sessions.isEmpty) {
          return _buildEmptyState();
        }

        return WorkoutCalendar(
          workouts: sessions,
          onWorkoutTap: (workout) {
            context.push('/workout/${workout.id}');
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading workouts: $error'),
      ),
    );
  }

  Widget _buildGroupedView(AsyncValue workoutSessionsAsync) {
    return workoutSessionsAsync.when(
      data: (data) {
        final groupedSessions = data as Map<String, List<WorkoutSession>>;
        if (groupedSessions.isEmpty) {
          return _buildEmptyState();
        }

        final sortedMonths = groupedSessions.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedMonths.length,
          itemBuilder: (context, index) {
            final monthKey = sortedMonths[index];
            final sessions = groupedSessions[monthKey]!;
            final monthDate = DateTime.parse('$monthKey-01');
            final monthName = DateFormat('MMMM y').format(monthDate);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0) const SizedBox(height: 24),

                // Month Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        monthName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${sessions.length} workouts',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Month's workouts
                ...sessions
                    .map((session) => _WorkoutCard(
                          workoutSession: session,
                          showDate: true,
                        ))
                    .toList(),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Error loading workout history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(AsyncValue workoutSessionsAsync) {
    return workoutSessionsAsync.when(
      data: (data) {
        final sessions = data as List<WorkoutSession>;
        if (sessions.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return _WorkoutCard(
              workoutSession: session,
              showDate: true,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Error loading workout history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context)!.noWorkoutHistoryTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context)!.completeFirstWorkout,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/workout-templates?mode=start');
              },
              icon: const Icon(Icons.fitness_center),
              label: Text(S.of(context)!.startFirstWorkout),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'Filter Workouts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(S.of(context)!.allCompleted),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(workoutFilterProvider.notifier)
                    .setFilter(WorkoutFilter.all);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(S.of(context)!.thisWeek),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(workoutFilterProvider.notifier)
                    .setFilter(WorkoutFilter.thisWeek);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(S.of(context)!.thisMonth),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(workoutFilterProvider.notifier)
                    .setFilter(WorkoutFilter.thisMonth);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Progress/History tab
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

class _WorkoutStatsHeader extends StatelessWidget {
  const _WorkoutStatsHeader({required this.stats});

  final WorkoutStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatCard(
                    label: 'Total Workouts',
                    value: '${stats.totalWorkouts}',
                    icon: Icons.fitness_center,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Avg Duration',
                    value: '${stats.averageDurationMinutes}m',
                    icon: Icons.schedule,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    label: 'Total Volume',
                    value: '${stats.totalVolumeKg.toStringAsFixed(0)}kg',
                    icon: Icons.monitor_weight,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Current Streak',
                    value: '${stats.currentStreak} days',
                    icon: Icons.local_fire_department,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.workoutSession,
    required this.showDate,
  });

  final WorkoutSession workoutSession;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final dateFormat = showDate ? DateFormat('MMM d, y') : DateFormat('h:mm a');
    final isCompleted = workoutSession.completedAt != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          context.go('/workout/${workoutSession.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1)
                          : Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.schedule,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.tertiary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workoutSession.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(workoutSession.startedAt),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isCompleted
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.tertiary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _QuickStat(
                    icon: Icons.schedule,
                    value: _formatDuration(workoutSession.totalDurationSeconds),
                  ),
                  _QuickStat(
                    icon: Icons.fitness_center,
                    value: '${workoutSession.totalSets} sets',
                  ),
                  _QuickStat(
                    icon: Icons.monitor_weight,
                    value: '${workoutSession.totalVolume.toStringAsFixed(0)}kg',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '--';

    final duration = Duration(seconds: seconds);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
