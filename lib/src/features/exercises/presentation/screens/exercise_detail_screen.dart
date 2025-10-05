import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/exercise_providers.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseByIdProvider(exerciseId));

    return exerciseAsync.when(
      data: (exercise) {
        if (exercise == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Exercise Not Found'),
            ),
            body: const Center(
              child: Text('Exercise not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(exercise.name),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Add to favorites
                },
                icon: const Icon(Icons.favorite_border),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(context, exercise.category),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getCategoryIcon(exercise.category),
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Primary: ${exercise.primaryMuscleGroup[0].toUpperCase() + exercise.primaryMuscleGroup.substring(1)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.fitness_center,
                              label: exercise.equipment[0].toUpperCase() + 
                                     exercise.equipment.substring(1).replaceAll('_', ' '),
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: exercise.isBodyweight ? Icons.accessibility : Icons.monitor_weight,
                              label: exercise.isBodyweight ? 'Bodyweight' : 'Weighted',
                            ),
                            const SizedBox(width: 8),
                            _DifficultyChip(difficulty: exercise.difficulty),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _InfoChip(
                              icon: _getCategoryIcon(exercise.category),
                              label: exercise.category[0].toUpperCase() + exercise.category.substring(1),
                            ),
                            const SizedBox(width: 8),
                            _ExerciseTypeChip(type: exercise.exerciseType),
                            if (exercise.parentExerciseId != null && exercise.variantType != null) ...[
                              const SizedBox(width: 8),
                              _VariantChip(variantType: exercise.variantType!),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Exercise Progression/Variants
                Consumer(
                  builder: (context, ref, child) {
                    final progressionChainAsync = ref.watch(exerciseProgressionChainProvider(exerciseId));
                    
                    return progressionChainAsync.when(
                      data: (progressionChain) {
                        if (progressionChain.length > 1) {
                          return Column(
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.trending_up,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Exercise Progression',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...progressionChain.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final exerciseInChain = entry.value;
                                        final isCurrentExercise = exerciseInChain.id == exercise.id;
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: isCurrentExercise 
                                                      ? Theme.of(context).colorScheme.primary
                                                      : Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: isCurrentExercise ? Colors.white : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: isCurrentExercise ? null : () {
                                                    context.go('/exercise/${exerciseInChain.id}');
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: isCurrentExercise 
                                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                                          : Theme.of(context).colorScheme.surface,
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color: isCurrentExercise 
                                                            ? Theme.of(context).colorScheme.primary
                                                            : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                exerciseInChain.name,
                                                                style: TextStyle(
                                                                  fontWeight: isCurrentExercise ? FontWeight.bold : FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Row(
                                                                children: [
                                                                  _DifficultyChip(difficulty: exerciseInChain.difficulty),
                                                                  if (exerciseInChain.variantType != null) ...[
                                                                    const SizedBox(width: 8),
                                                                    _VariantChip(variantType: exerciseInChain.variantType!),
                                                                  ],
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (!isCurrentExercise)
                                                          const Icon(Icons.chevron_right),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (error, stack) => const SizedBox.shrink(),
                    );
                  },
                ),

                // Muscle Groups
                if (exercise.secondaryMuscleGroups.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secondary Muscles',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: exercise.secondaryMuscleGroups.map((muscle) => Chip(
                              label: Text(muscle[0].toUpperCase() + muscle.substring(1)),
                              backgroundColor: Theme.of(context).colorScheme.surface,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Instructions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.instructions,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tags
                if (exercise.tags.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tags',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: exercise.tags.map((tag) => Chip(
                              label: Text(tag.replaceAll('_', ' ').toUpperCase()),
                              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Start quick workout with this exercise
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Quick Workout'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Add to workout template
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add to Workout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Error loading exercise',
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
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});

  final String difficulty;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      case 'expert':
        color = Colors.deepPurple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ExerciseTypeChip extends StatelessWidget {
  const _ExerciseTypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'reps':
        icon = Icons.repeat;
        color = Colors.blue;
        break;
      case 'timer':
        icon = Icons.timer;
        color = Colors.green;
        break;
      case 'body_weighted':
        icon = Icons.accessibility;
        color = Colors.orange;
        break;
      case 'assisted':
        icon = Icons.support;
        color = Colors.purple;
        break;
      default:
        icon = Icons.fitness_center;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            type.toUpperCase().replaceAll('_', ' '),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantChip extends StatelessWidget {
  const _VariantChip({required this.variantType});

  final String variantType;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (variantType.toLowerCase()) {
      case 'progression':
        color = Colors.green;
        icon = Icons.trending_up;
        break;
      case 'regression':
        color = Colors.amber;
        icon = Icons.trending_down;
        break;
      case 'assisted':
        color = Colors.blue;
        icon = Icons.support;
        break;
      case 'weighted':
        color = Colors.deepPurple;
        icon = Icons.fitness_center;
        break;
      case 'equipment':
        color = Colors.teal;
        icon = Icons.build;
        break;
      case 'strict':
        color = Colors.indigo;
        icon = Icons.rule;
        break;
      default:
        color = Colors.grey;
        icon = Icons.extension;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            variantType.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension methods for the ExerciseDetailScreen
extension ExerciseDetailScreenExtensions on ExerciseDetailScreen {
  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'calisthenics':
        return Icons.accessibility;
      case 'yoga':
        return Icons.self_improvement;
      case 'cardio':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getCategoryColor(BuildContext context, String? category) {
    switch (category?.toLowerCase()) {
      case 'strength':
        return Colors.blue;
      case 'calisthenics':
        return Colors.orange;
      case 'yoga':
        return Colors.purple;
      case 'cardio':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}