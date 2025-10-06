import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../../gamification/presentation/widgets/gamification_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

    @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready for your next workout?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Gamification badges
                  const StreakBadge(size: 36, showText: true),
                  const SizedBox(width: 12),
                  const LevelIndicator(size: 48, showProgress: false),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => context.go('/settings'),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Current Stats
              _buildCurrentStats(context, ref),
              const SizedBox(height: 24),

              // Recent Workouts
              _buildRecentWorkouts(context, ref),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );

  Widget _buildQuickActions(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Start Workout',
                subtitle: 'Begin a new session',
                icon: Icons.play_arrow,
                color: AppTheme.primaryColor,
                onTap: () => context.go('/workout-templates'),
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
                subtitle: 'Smart recommendations',
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
            
            final displayWorkouts = workouts.take(AppConfig.homeRecentWorkoutsLimit).toList();
            
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
                
                return _RecentWorkoutCard(
                  workoutId: workout.id,
                  name: workout.name,
                  date: DateFormat('MMM d').format(workout.startedAt),
                  duration: duration.inMinutes > 0 ? '${duration.inMinutes}m' : 'In progress',
                  onTap: () => context.go('/workout-detail/${workout.id}'),
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

class _QuickActionCard extends StatelessWidget {

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
  Widget build(BuildContext context) => Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
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
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
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
    final exerciseCountAsync = ref.watch(exerciseCountBySessionProvider(workoutId));

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fitness_center,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: exerciseCountAsync.when(
          data: (exerciseCount) => Text('$exerciseCount exercises • $duration'),
          loading: () => Text('Loading... • $duration'),
          error: (_, __) => Text('0 exercises • $duration'),
        ),
        trailing: Text(
          date,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}