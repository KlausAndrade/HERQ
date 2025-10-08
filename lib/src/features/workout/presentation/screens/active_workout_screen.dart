import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/active_workout.dart';
import '../providers/active_workout_provider.dart';
import '../widgets/exercise_picker_dialog.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/set_entry_widget.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({
    super.key,
    this.templateId,
  });
  final String? templateId;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final Set<int> _expandedExercises = {};
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _exerciseKeys = {};

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      // Initialize workout from template
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final existingWorkout = ref.read(activeWorkoutProvider);
        
        // If there's already an active workout, show confirmation dialog
        if (existingWorkout != null && mounted) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Workout in Progress'),
              content: Text(
                'You have an active workout "${existingWorkout.name}" in progress. '
                'Starting a new workout will end the current one.\n\n'
                'Do you want to continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Force Start New Workout'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    // Force cleanup to ensure clean state
                    await ref.read(activeWorkoutProvider.notifier).forceCleanup();
                  },
                  child: const Text('Clear & Start New'),
                ),
              ],
            ),
          );

          if (confirmed != true) {
            // User cancelled, go back to previous screen
            if (mounted) {
              Navigator.of(context).pop();
            }
            return;
          }
        }
        
        // Start the new workout
        await ref
            .read(activeWorkoutProvider.notifier)
            .startWorkoutFromTemplate(widget.templateId!);
        // Auto-expand first exercise
        setState(() {
          _expandedExercises.add(0);
        });
      });
    } else {
      // Auto-expand first exercise if any
      if (mounted) {
        _expandedExercises.add(0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBackButtonPressed(BuildContext context) async {
    final activeWorkout = ref.read(activeWorkoutProvider);
    
    if (activeWorkout == null) {
      // No active workout, safe to navigate back
      context.go('/');
      return;
    }

    // Show dialog asking what to do with the active workout
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Workout?'),
        content: Text(
          'You have an active workout "${activeWorkout.name}" in progress.\n\n'
          'What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('Save & Exit'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard Workout'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    switch (action) {
      case 'save':
        // Save as checkpoint and exit
        context.go('/');
        break;
      case 'discard':
        // Force cleanup and exit - navigate first to avoid "no active workout" flash
        context.go('/');
        await ref.read(activeWorkoutProvider.notifier).forceCleanup();
        break;
      case 'cancel':
      default:
        // Do nothing, stay in workout
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final restTimer = ref.watch(restTimerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBackButtonPressed(context),
        ),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                _formatDuration(activeWorkout.elapsedTime),
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
                          const Spacer(),
                          _buildWorkoutStats(context, activeWorkout),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rest Timer (if active)
                if (restTimer.isActive) const RestTimerWidget(),

                // Exercise List
                Expanded(
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false, // We'll add custom drag handles
                    onReorder: (oldIndex, newIndex) {
                      ref.read(activeWorkoutProvider.notifier).reorderExercises(oldIndex, newIndex);
                    },
                    scrollController: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: activeWorkout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = activeWorkout.exercises[index];
                      // Create a key for each exercise if it doesn't exist
                      _exerciseKeys.putIfAbsent(index, () => GlobalKey());
                      return ReorderableDragStartListener(
                        key: ValueKey('exercise-${exercise.id}-$index'),
                        index: index,
                        child: _ExerciseCard(
                          key: _exerciseKeys[index],
                          exercise: exercise,
                          exerciseIndex: index,
                          isExpanded: _expandedExercises.contains(index),
                          showDragHandle: true, // Show drag handle during workout
                          onTap: () {
                            setState(() {
                              if (_expandedExercises.contains(index)) {
                                _expandedExercises.remove(index);
                              } else {
                                _expandedExercises.add(index);
                              }
                            });
                          },
                          onSetChanged: (setIndex, updatedSet) async {
                          final oldSet = exercise.sets[setIndex];
                          
                          await ref
                              .read(activeWorkoutProvider.notifier)
                              .updateSet(index, setIndex, updatedSet);
                          
                          // Check if we just completed a set and got a PR
                          if (updatedSet.isCompleted && !oldSet.isCompleted) {
                            // Wait for state to update
                            await Future.delayed(const Duration(milliseconds: 300));
                            final updatedWorkout = ref.read(activeWorkoutProvider);
                            if (updatedWorkout != null) {
                              final updatedExercise = updatedWorkout.exercises[index];
                              final newSet = updatedExercise.sets[setIndex];
                              
                              if (newSet.isPRWeight || newSet.isPRReps) {
                                if (context.mounted) {
                                  String message = '';
                                  if (newSet.isPRWeight && newSet.isPRReps) {
                                    message = '🏆 Double PR! New max weight AND reps!';
                                  } else if (newSet.isPRWeight) {
                                    message = '💪 New PR! Max weight achieved!';
                                  } else if (newSet.isPRReps) {
                                    message = '🔥 New PR! Max reps achieved!';
                                  }
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: Colors.amber.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 3),
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      action: SnackBarAction(
                                        label: '🎉',
                                        textColor: Colors.white,
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        onAddSet: () {
                          ref
                              .read(activeWorkoutProvider.notifier)
                              .addSet(index);
                        },
                      ),
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

  Widget _buildWorkoutStats(BuildContext context, ActiveWorkout workout) =>
      Column(
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

  void _showAddExerciseDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ExercisePickerDialog(),
    );

    if (result != null && context.mounted) {
      final exercise = result['exercise'];
      final initialWeight = result['initialWeight'] as double?;
      final restTimerSeconds = result['restTimerSeconds'] as int? ?? 90;
      final isAssisted = result['isAssisted'] as bool? ?? false;

      await ref.read(activeWorkoutProvider.notifier).addExercise(
            exercise.id,
            initialWeight: initialWeight,
            restTimerSeconds: restTimerSeconds,
            isAssisted: isAssisted,
          );
    }
  }

  void _showFinishWorkoutDialog(BuildContext context) {
    final activeWorkout = ref.read(activeWorkoutProvider);
    if (activeWorkout == null) return;

    // Check if all exercises have at least one completed set
    final incompleteExercises = <int>[];
    for (var i = 0; i < activeWorkout.exercises.length; i++) {
      final exercise = activeWorkout.exercises[i];
      final hasCompletedSet = exercise.sets.any((set) => set.isCompleted);
      if (!hasCompletedSet) {
        incompleteExercises.add(i);
      }
    }

    // If there are incomplete exercises, show warning
    if (incompleteExercises.isNotEmpty) {
      _showIncompleteExercisesWarning(context, incompleteExercises);
      return;
    }

    // All exercises complete, show normal finish dialog
    _showConfirmFinishDialog(context);
  }

  void _showIncompleteExercisesWarning(
      BuildContext context, List<int> incompleteExercises) {
    final activeWorkout = ref.read(activeWorkoutProvider);
    if (activeWorkout == null) return;

    final incompleteNames = incompleteExercises
        .map((i) => activeWorkout.exercises[i].name)
        .join(', ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Incomplete Exercises',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The following exercises have no completed sets:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                incompleteNames,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Do you want to continue these exercises or finish anyway?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Auto-scroll to first incomplete exercise
              _scrollToExercise(incompleteExercises.first);
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showConfirmFinishDialog(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Finish Anyway'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _showDiscardWorkoutDialog(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDiscardWorkoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Discard Workout?'),
          ],
        ),
        content: const Text(
          'This will permanently discard your current workout. '
          'All progress will be lost and cannot be recovered.\n\n'
          'Are you sure you want to discard this workout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard Workout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Navigate to home first
      context.go('/');
      // Then force cleanup in the background
      await ref.read(activeWorkoutProvider.notifier).forceCleanup();
    }
  }

  void _showConfirmFinishDialog(BuildContext context) {
    final hasModifications = ref.read(workoutModificationsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Workout'),
        content: hasModifications
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You made changes during this workout:'),
                  SizedBox(height: 8),
                  Text('• Reordered exercises', style: TextStyle(fontSize: 13)),
                  Text('• Added or removed exercises', style: TextStyle(fontSize: 13)),
                  Text('• Added or removed sets', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 12),
                  Text('These changes will be saved in your workout history.'),
                ],
              )
            : const Text('Are you sure you want to finish this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _showDiscardWorkoutDialog(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () async {
              print('🏁 Finish button pressed');
              Navigator.of(context).pop();
              
              // Finish workout and get summary
              final summary = await ref.read(activeWorkoutProvider.notifier).finishWorkout();
              
              print('🏁 Finish result - Summary: ${summary != null ? 'available' : 'null'}');
              
              if (context.mounted) {
                if (summary != null) {
                  print('🏁 Navigating to workout summary');
                  // Navigate to summary screen
                  context.go('/workout-summary', extra: summary);
                } else {
                  print('🏁 No summary, falling back to home');
                  // Fallback to home if no summary
                  context.go('/');
                }
              }
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _scrollToExercise(int exerciseIndex) {
    // Expand the exercise
    setState(() {
      _expandedExercises.add(exerciseIndex);
    });

    // Wait for the widget to expand, then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _exerciseKeys[exerciseIndex]?.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1, // Position at top of visible area
        );
      }
    });
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

class _ExerciseCard extends ConsumerWidget {
  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.isExpanded,
    required this.onTap,
    required this.onSetChanged,
    required this.onAddSet,
    this.showDragHandle = false,
  });
  final ActiveExercise exercise;
  final int exerciseIndex;
  final bool isExpanded;
  final VoidCallback onTap;
  final Future<void> Function(int setIndex, ActiveSet updatedSet) onSetChanged;
  final VoidCallback onAddSet;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          Text(
                            '${exercise.sets.length} sets',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showDragHandle) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 4),
                        child: Icon(
                          Icons.drag_handle,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    // Rest Timer Controls
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Rest',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            iconSize: 20,
                            onPressed: exercise.restTimerSeconds > 15
                                ? () {
                                    ref
                                        .read(activeWorkoutProvider.notifier)
                                        .updateExerciseRestTimer(
                                          exerciseIndex,
                                          exercise.restTimerSeconds - 15,
                                        );
                                  }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${exercise.restTimerSeconds}s',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            iconSize: 20,
                            onPressed: () {
                              ref
                                  .read(activeWorkoutProvider.notifier)
                                  .updateExerciseRestTimer(
                                    exerciseIndex,
                                    exercise.restTimerSeconds + 15,
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sets List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exercise.sets.length,
                      itemBuilder: (context, index) {
                        final set = exercise.sets[index];
                        return Dismissible(
                          key: Key('set_${exerciseIndex}_$index'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Theme.of(context).colorScheme.error,
                            child: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.onError,
                              size: 28,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            // Show confirmation dialog
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Remove Set?'),
                                content: Text(
                                  'Are you sure you want to remove set ${index + 1}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ),
                            ) ?? false;
                          },
                          onDismissed: (direction) {
                            // Remove the set
                            ref
                                .read(activeWorkoutProvider.notifier)
                                .removeSet(exerciseIndex, index);
                            
                            // Show snackbar with undo option
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Set ${index + 1} removed'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: SetEntryWidget(
                            set: set,
                            setNumber: index + 1,
                            restTimerSeconds: exercise.restTimerSeconds,
                            exerciseName: exercise.name,
                            totalSets: exercise.sets.length,
                            isFirstSet: index == 0,
                            onChanged: (updatedSet) {
                              onSetChanged(index, updatedSet);
                            },
                          ),
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
