import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../../workout/presentation/providers/active_workout_provider.dart';
import '../../../workout/presentation/providers/workout_checkpoint_provider.dart';
import '../../../workout/presentation/widgets/resume_workout_dialog.dart';
import '../../../gamification/presentation/widgets/gamification_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Check for incomplete workouts on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForIncompleteWorkout();
    });
  }

  Future<void> _checkForIncompleteWorkout() async {
    final checkpointService = ref.read(workoutCheckpointServiceProvider);
    if (checkpointService == null) return;

    // Check if there's already an active workout
    final activeWorkout = ref.read(activeWorkoutProvider);
    if (activeWorkout != null) return; // Don't show dialog if workout is already running

    // Check for saved checkpoint
    final checkpoint = await checkpointService.getLatestCheckpoint();
    if (checkpoint == null) return;

    if (!mounted) return;

    // Show resume dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResumeWorkoutDialog(
        workout: checkpoint,
        onResume: () {
          Navigator.of(context).pop();
          ref.read(activeWorkoutProvider.notifier).resumeWorkout(checkpoint);
          context.go('/active-workout');
        },
        onDiscard: () async {
          Navigator.of(context).pop();
          await checkpointService.deleteCheckpoint(checkpoint.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                AnimatedListItem(
                  index: 0,
                  delay: const Duration(milliseconds: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ready for your next workout?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Gamification badges
                      const StreakBadge(size: 36, showText: true),
                      const SizedBox(width: 8),
                      const LevelIndicator(size: 48, showProgress: false),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          await HapticService.lightImpact();
                          if (context.mounted) context.go('/settings');
                        },
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLG),

                // Quick Actions
                AnimatedListItem(
                  index: 1,
                  child: _buildQuickActions(context),
                ),
                const SizedBox(height: AppTheme.spacingLG),

                // Current Stats
                AnimatedListItem(
                  index: 2,
                  child: _buildCurrentStats(context, ref),
                ),
                const SizedBox(height: AppTheme.spacingLG),

                // Recent Workouts
                AnimatedListItem(
                  index: 3,
                  child: _buildRecentWorkouts(context, ref),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(context),
      );

  Widget _buildQuickActions(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final activeWorkout = ref.watch(activeWorkoutProvider);
          final hasActiveWorkout = activeWorkout != null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title:
                          hasActiveWorkout ? 'Resume Workout' : 'Start Workout',
                      subtitle: hasActiveWorkout
                          ? 'Continue ${activeWorkout.name}'
                          : 'Begin a new session',
                      icon: hasActiveWorkout
                          ? Icons.play_circle_filled
                          : Icons.play_arrow,
                      color: hasActiveWorkout
                          ? Colors.orange
                          : AppTheme.primaryColor,
                      onTap: () async {
                        if (hasActiveWorkout) {
                          // Resume active workout
                          context.go('/active-workout');
                        } else {
                          // Start new workout
                          context.go('/workout-templates');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Achievements',
                      subtitle: 'Track your progress',
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                      onTap: () => context.go('/gamification'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'View Progress',
                      subtitle: 'Check your stats',
                      icon: Icons.trending_up,
                      color: AppTheme.secondaryColor,
                      onTap: () => context.go('/progress'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Exercise Library',
                      subtitle: 'Browse exercises',
                      icon: Icons.fitness_center,
                      color: AppTheme.accentColor,
                      onTap: () => context.go('/exercises'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'History',
                      subtitle: 'Past workouts',
                      icon: Icons.history,
                      color: Colors.purple,
                      onTap: () => context.go('/workout-history'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Social Feed',
                      subtitle: 'Friends & activity',
                      icon: Icons.people,
                      color: Colors.blue,
                      onTap: () => context.go('/social'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Leaderboards',
                      subtitle: 'Compare & compete',
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                      onTap: () => context.go('/leaderboards'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'AI Coach',
                      subtitle: 'Smart training help',
                      icon: Icons.psychology,
                      color: Colors.teal,
                      onTap: () => context.go('/ai-coach'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Settings',
                      subtitle: 'App preferences',
                      icon: Icons.settings,
                      color: Colors.grey,
                      onTap: () => context.go('/settings'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );

  Widget _buildCurrentStats(BuildContext context, WidgetRef ref) {
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            weeklyStatsAsync.when(
              data: (stats) => Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Workouts',
                      value: stats.workoutsCount.toString(),
                      icon: Icons.fitness_center,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Total Volume',
                      value: stats.formattedVolume,
                      icon: Icons.scale,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'PRs Set',
                      value: stats.prsSet.toString(),
                      icon: Icons.emoji_events,
                    ),
                  ),
                ],
              ),
              loading: () => Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Workouts',
                      value: '-',
                      icon: Icons.fitness_center,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Total Volume',
                      value: '-',
                      icon: Icons.scale,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'PRs Set',
                      value: '-',
                      icon: Icons.emoji_events,
                    ),
                  ),
                ],
              ),
              error: (error, stack) => Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Workouts',
                      value: '0',
                      icon: Icons.fitness_center,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Total Volume',
                      value: '0 kg',
                      icon: Icons.scale,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'PRs Set',
                      value: '0',
                      icon: Icons.emoji_events,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(BuildContext context, WidgetRef ref) {
    final recentWorkoutsAsync = ref.watch(recentWorkoutSessionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Workouts',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/workout-history'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        recentWorkoutsAsync.when(
          data: (workouts) {
            if (workouts.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No workouts yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Start your first workout to see your progress here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final displayWorkouts =
                workouts.take(AppConfig.homeRecentWorkoutsLimit).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayWorkouts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final workout = displayWorkouts[index];
                final duration = workout.completedAt != null
                    ? workout.completedAt!.difference(workout.startedAt)
                    : Duration.zero;

                return AnimatedListItem(
                  index: index,
                  delay: const Duration(milliseconds: 80),
                  child: _RecentWorkoutCard(
                    workoutId: workout.id,
                    name: workout.name,
                    date: DateFormat('MMM d').format(workout.startedAt),
                    duration: duration.inMinutes > 0
                        ? '${duration.inMinutes}m'
                        : 'In progress',
                    onTap: () async {
                      await HapticService.lightImpact();
                      if (context.mounted) context.go('/workout/${workout.id}');
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Error loading workouts: $error'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) async {
          await HapticService.selectionClick();
          if (!context.mounted) return;

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
        ],
      );
}

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.snappy),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withOpacity(0.15),
                  widget.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: widget.color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () async {
                await HapticService.lightImpact();
                widget.onTap();
              },
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSM),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSM),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      );
}

class _RecentWorkoutCard extends ConsumerWidget {
  const _RecentWorkoutCard({
    required this.workoutId,
    required this.name,
    required this.date,
    required this.duration,
    this.onTap,
  });

  final String workoutId;
  final String name;
  final String date;
  final String duration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseCountAsync =
        ref.watch(exerciseCountBySessionProvider(workoutId));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingSM,
          ),
          leading: Container(
            padding: const EdgeInsets.all(AppTheme.spacingSM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.fitness_center,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: exerciseCountAsync.when(
            data: (exerciseCount) => Text(
              '$exerciseCount exercises • $duration',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            loading: () => Text(
              'Loading... • $duration',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            error: (_, __) => Text(
              '0 exercises • $duration',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          trailing: Text(
            date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
