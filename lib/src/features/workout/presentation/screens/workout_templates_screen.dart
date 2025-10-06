import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/active_workout_provider.dart';

class WorkoutTemplatesScreen extends ConsumerWidget {
  const WorkoutTemplatesScreen({super.key});

  Future<void> _handleStartWorkout({
    required BuildContext context,
    required WidgetRef ref,
    required String templateId,
  }) async {
    final activeWorkout = ref.read(activeWorkoutProvider);

    if (activeWorkout != null) {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Workout in Progress'),
          content: Text(
            'You have an active workout "${activeWorkout.name}" in progress. '
            'Starting a new workout will end the current one.\n\n'
            'Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Start New Workout'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }
    }

    // Navigate to active workout with template
    if (context.mounted) {
      context.go('/active-workout?templateId=$templateId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text('Workout Templates'),
          actions: [
            IconButton(
              onPressed: () {
                context.push('/template-builder');
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Default Templates Section
            Text(
              'Default Templates',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _WorkoutTemplateCard(
              name: 'Push Day',
              description: 'Chest, shoulders, and triceps workout',
              exercises: const ['Bench Press', 'Overhead Press', 'Push-up'],
              duration: '60 min',
              onTap: () => _handleStartWorkout(
                context: context,
                ref: ref,
                templateId: 'push_day',
              ),
            ),
            const SizedBox(height: 8),
            _WorkoutTemplateCard(
              name: 'Pull Day',
              description: 'Back and biceps workout',
              exercises: const ['Deadlift', 'Pull-up'],
              duration: '60 min',
              onTap: () => _handleStartWorkout(
                context: context,
                ref: ref,
                templateId: 'pull_day',
              ),
            ),
            const SizedBox(height: 8),
            _WorkoutTemplateCard(
              name: 'Leg Day',
              description: 'Lower body workout',
              exercises: const ['Squat', 'Deadlift'],
              duration: '60 min',
              onTap: () => _handleStartWorkout(
                context: context,
                ref: ref,
                templateId: 'leg_day',
              ),
            ),
            const SizedBox(height: 24),

            // Custom Templates Section
            Row(
              children: [
                Text(
                  'Custom Templates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    context.push('/template-builder');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No custom templates yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your own workout templates to get started faster',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(context),
      );

  Widget _buildBottomNavigation(BuildContext context) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
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

class _WorkoutTemplateCard extends StatelessWidget {
  const _WorkoutTemplateCard({
    required this.name,
    required this.description,
    required this.exercises,
    required this.duration,
    required this.onTap,
  });
  final String name;
  final String description;
  final List<String> exercises;
  final String duration;
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.play_arrow,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: exercises.map((exercise) {
                    return Chip(
                      label: Text(
                        exercise,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${exercises.length} exercises',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
