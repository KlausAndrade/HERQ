import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/active_workout.dart';
import '../providers/active_workout_provider.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/set_entry_widget.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {

  const ActiveWorkoutScreen({
    super.key,
    this.templateId,
  });
  final String? templateId;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final Set<int> _expandedExercises = {};
  
  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      // Initialize workout from template
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(activeWorkoutProvider.notifier).startWorkoutFromTemplate(widget.templateId!);
        // Auto-expand first exercise
        _expandedExercises.add(0);
      });
    } else {
      // Auto-expand first exercise if any
      _expandedExercises.add(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final restTimer = ref.watch(restTimerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(activeWorkout?.name ?? 'Active Workout'),
        actions: [
          TextButton(
            onPressed: () => _showFinishWorkoutDialog(context),
            child: const Text('Finish'),
          ),
        ],
      ),
      body: activeWorkout == null
          ? const Center(child: Text('No active workout'))
          : Column(
              children: [
                // Workout Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeWorkout.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatDuration(activeWorkout.elapsedTime),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildWorkoutStats(context, activeWorkout),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rest Timer (if active)
                if (restTimer.isActive)
                  const RestTimerWidget(),

                // Exercise List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeWorkout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = activeWorkout.exercises[index];
                      return _ExerciseCard(
                        exercise: exercise,
                        exerciseIndex: index,
                        isExpanded: _expandedExercises.contains(index),
                        onTap: () {
                          setState(() {
                            if (_expandedExercises.contains(index)) {
                              _expandedExercises.remove(index);
                            } else {
                              _expandedExercises.add(index);
                            }
                          });
                        },
                        onSetChanged: (setIndex, updatedSet) {
                          ref.read(activeWorkoutProvider.notifier).updateSet(index, setIndex, updatedSet);
                        },
                        onAddSet: () {
                          ref.read(activeWorkoutProvider.notifier).addSet(index);
                        },
                      );
                    },
                  ),
                ),

                // Bottom Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddExerciseDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _showFinishWorkoutDialog(context),
                        child: const Text('Finish Workout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWorkoutStats(BuildContext context, ActiveWorkout workout) => Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${workout.totalSets} sets',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          '${workout.totalVolume.toStringAsFixed(1)}kg',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );

  void _showAddExerciseDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Exercise Name',
            hintText: 'e.g., Squats',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(activeWorkoutProvider.notifier).addExercise(controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showFinishWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Workout'),
        content: const Text('Are you sure you want to finish this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(activeWorkoutProvider.notifier).finishWorkout();
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }
}

class _ExerciseCard extends StatelessWidget {

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.isExpanded,
    required this.onTap,
    required this.onSetChanged,
    required this.onAddSet,
  });
  final ActiveExercise exercise;
  final int exerciseIndex;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(int setIndex, ActiveSet updatedSet) onSetChanged;
  final VoidCallback onAddSet;

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
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
              exercise.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${exercise.sets.length} sets'),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: onTap,
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Sets List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercise.sets.length,
                    itemBuilder: (context, index) {
                      final set = exercise.sets[index];
                      return SetEntryWidget(
                        set: set,
                        setNumber: index + 1,
                        onChanged: (updatedSet) {
                          onSetChanged(index, updatedSet);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Add Set Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAddSet,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Set'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
