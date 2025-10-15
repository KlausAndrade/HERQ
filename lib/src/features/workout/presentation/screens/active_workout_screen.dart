import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/models/active_workout.dart';
import '../../domain/models/workout_summary.dart';
import '../providers/active_workout_provider.dart';
import '../widgets/exercise_picker_dialog.dart';
import '../widgets/exercise_variant_picker.dart';
import '../widgets/rest_timer_widget.dart';
import '../widgets/set_entry_widget.dart';
import 'workout_save_screen.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({
    super.key,
    this.templateId,
  });
  final String? templateId;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('templateId', templateId));
  }
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final Set<int> _expandedExercises = {};
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _exerciseKeys = {};
  bool _isEditingTimer = false;
  final TextEditingController _timerController = TextEditingController();
  final FocusNode _timerFocusNode = FocusNode();

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
              title: Text(S.of(context)!.workoutInProgress),
              content: Text(
                '${S.of(context)!.haveActiveWorkout(existingWorkout.name)} '
                '${S.of(context)!.startingNewWillEnd}\n\n'
                '${S.of(context)!.doYouWantToContinue}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(S.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(S.of(context)!.forceStartNewWorkout),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    // Force cleanup to ensure clean state
                    await ref
                        .read(activeWorkoutProvider.notifier)
                        .forceCleanup();
                  },
                  child: Text(S.of(context)!.clearAndStartNew),
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
    _timerController.dispose();
    _timerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleBackButtonPressed(BuildContext context) async {
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
        title: Text(S.of(context)!.leaveWorkout),
        content: Text(
          '${S.of(context)!.haveActiveWorkout(activeWorkout.name)}\n\n'
          '${S.of(context)!.whatWouldYouLikeToDo}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text(S.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: Text(S.of(context)!.saveAndExit),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(S.of(context)!.discardWorkout),
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
        title: Text(activeWorkout?.name ?? S.of(context)!.activeWorkout),
        actions: [
          TextButton(
            onPressed: () => _showFinishWorkoutDialog(context),
            child: Text(S.of(context)!.finish),
          ),
        ],
      ),
      body: activeWorkout == null
          ? Center(child: Text(S.of(context)!.noActiveWorkout))
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
                              _buildEditableTimer(context, activeWorkout),
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
                    buildDefaultDragHandles:
                        false, // We'll add custom drag handles
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(activeWorkoutProvider.notifier)
                          .reorderExercises(oldIndex, newIndex);
                    },
                    scrollController: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: activeWorkout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = activeWorkout.exercises[index];
                      // Create a key for each exercise if it doesn't exist
                      _exerciseKeys.putIfAbsent(index, GlobalKey.new);
                      return ReorderableDelayedDragStartListener(
                        key: ValueKey('exercise-${exercise.id}-$index'),
                        index: index,
                        child: _ExerciseCard(
                          key: _exerciseKeys[index],
                          exercise: exercise,
                          exerciseIndex: index,
                          isExpanded: _expandedExercises.contains(index),
                          showDragHandle:
                              true, // Show drag handle during workout
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
                              await Future.delayed(
                                const Duration(milliseconds: 300),
                              );
                              final updatedWorkout =
                                  ref.read(activeWorkoutProvider);
                              if (updatedWorkout != null) {
                                final updatedExercise =
                                    updatedWorkout.exercises[index];
                                final newSet = updatedExercise.sets[setIndex];

                                if (newSet.isPRWeight || newSet.isPRReps) {
                                  if (context.mounted) {
                                    String message = '';
                                    if (newSet.isPRWeight && newSet.isPRReps) {
                                      message =
                                          '🏆 Double PR! New max weight AND reps!';
                                    } else if (newSet.isPRWeight) {
                                      message =
                                          '💪 New PR! Max weight achieved!';
                                    } else if (newSet.isPRReps) {
                                      message = '🔥 New PR! Max reps achieved!';
                                    }

                                    NotificationService()
                                        .showInAppNotification(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          title: message,
                                          body: '',
                                          primaryActionLabel: '🎉',
                                          onPrimaryAction: () {},
                                        )
                                        .catchError((_) {});
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
                        child: OutlinedButton(
                          onPressed: () => _showAddExerciseDialog(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, size: 20),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  S.of(context)!.add,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showFinishWorkoutDialog(context),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            S.of(context)!.finishWorkout,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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

  Future<void> _showAddExerciseDialog(BuildContext context) async {
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
    BuildContext context,
    List<int> incompleteExercises,
  ) {
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
            Flexible(
              child: Text(
                S.of(context)!.incompleteExercises,
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
              S.of(context)!.followingExercisesNoSets,
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
              S.of(context)!.continueExercisesOrFinish,
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
            onPressed: () async {
              Navigator.of(context).pop();
              // Skip confirmation - they already confirmed by clicking "Finish Anyway"
              await _finishWorkout(context);
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

    if (confirmed ?? false && mounted) {
      // Navigate to home first
      context.go('/');
      // Then force cleanup in the background
      await ref.read(activeWorkoutProvider.notifier).forceCleanup();
    }
  }

  Future<void> _finishWorkout(BuildContext context) async {
    print('🏁 Finish workout called');

    // Get workout state before clearing
    final workout = ref.read(activeWorkoutProvider);
    if (workout == null) {
      if (context.mounted) {
        context.go('/');
      }
      return;
    }

    print('🏁 Creating quick summary...');

    // Create a quick summary to show immediately
    final quickSummary = WorkoutSummary(
      workoutName: workout.name,
      duration: workout.elapsedTime,
      totalSets: workout.exercises
          .fold(0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length),
      totalReps: workout.exercises
          .expand((e) => e.sets)
          .where((s) => s.isCompleted)
          .fold(0, (sum, s) => sum + s.reps),
      totalVolume: workout.exercises
          .expand((e) => e.sets)
          .where((s) => s.isCompleted && s.weight != null)
          .fold(0.0, (sum, s) => sum + (s.weight! * s.reps)),
      totalTonnage: workout.exercises
          .expand((e) => e.sets)
          .where((s) => s.isCompleted && s.weight != null)
          .fold(0.0, (sum, s) => sum + (s.weight! * s.reps)),
      exercises: workout.exercises.map((e) {
        final completedSets = e.sets.where((s) => s.isCompleted).toList();
        final exerciseVolume = completedSets
            .where((s) => s.weight != null)
            .fold<double>(0, (sum, s) => sum + (s.weight! * s.reps));
        final maxWeight = completedSets
            .map((s) => s.weight)
            .whereType<double>()
            .fold<double?>(null, (max, w) => max == null || w > max ? w : max);

        return ExerciseSummary(
          exerciseId: e.id,
          exerciseName: e.name,
          sets: completedSets.length,
          totalReps: completedSets.fold<int>(0, (sum, s) => sum + s.reps),
          maxWeight: maxWeight,
          totalVolume: exerciseVolume,
        );
      }).toList(),
      prs: const [],
      achievements: WorkoutAchievements(
        perfectCompletion: workout.isFullyCompleted(),
      ),
    );

    print('🏁 Navigating to save screen...');

    // Navigate to save screen with quick summary
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WorkoutSaveScreen(
            summary: quickSummary,
            onDiscard: () {
              // User chose to discard workout - just navigate home
              // The workout wasn't saved so it will be lost
              Navigator.of(context).pop(); // Close save screen
              context.go('/'); // Go home
            },
            onSave: (name, notes, photoPath, postToSocial) async {
              print('💾 Saving workout with name: $name');

              // Save the workout
              try {
                await ref.read(activeWorkoutProvider.notifier).finishWorkout();

                // TODO: Save notes to database
                // TODO: Save photo to storage
                // TODO: Create social post if requested

                print('✅ Workout saved successfully!');

                // Navigate to summary screen with confetti
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close save screen
                  context.go('/workout-summary', extra: quickSummary);
                }
              } catch (e) {
                print('❌ Error saving workout: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving workout: $e')),
                  );
                }
              }
            },
          ),
        ),
      );
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
                  Text(
                    '• Added or removed exercises',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    '• Added or removed sets',
                    style: TextStyle(fontSize: 13),
                  ),
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
              Navigator.of(context).pop();
              await _finishWorkout(context);
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

  Widget _buildEditableTimer(BuildContext context, ActiveWorkout workout) {
    if (_isEditingTimer) {
      return SizedBox(
        width: 100,
        height: 32,
        child: TextField(
          controller: _timerController,
          focusNode: _timerFocusNode,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          decoration: InputDecoration(
            hintText: '0m 0s',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 14,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            isDense: true,
          ),
          onSubmitted: _saveTimerEdit,
          onTapOutside: (event) {
            _saveTimerEdit(_timerController.text);
          },
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditingTimer = true;
          _timerController.text = _formatDurationForEdit(workout.elapsedTime);
          _timerFocusNode.requestFocus();
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(workout.elapsedTime),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.edit,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  String _formatDurationForEdit(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  void _saveTimerEdit(String value) {
    setState(() {
      _isEditingTimer = false;
    });

    if (value.trim().isEmpty) return;

    // Parse the input (supports formats like: "5m 30s", "1h 15m", "90s", "45")
    final parsed = _parseDuration(value.trim());
    if (parsed != null) {
      ref.read(activeWorkoutProvider.notifier).adjustElapsedTime(parsed);
    }

    _timerController.clear();
  }

  Duration? _parseDuration(String input) {
    try {
      int hours = 0;
      int minutes = 0;
      int seconds = 0;

      // Remove all spaces
      input = input.replaceAll(' ', '');

      // Try to match hours
      final hoursMatch = RegExp(r'(\d+)h').firstMatch(input);
      if (hoursMatch != null) {
        hours = int.parse(hoursMatch.group(1)!);
      }

      // Try to match minutes
      final minutesMatch = RegExp(r'(\d+)m').firstMatch(input);
      if (minutesMatch != null) {
        minutes = int.parse(minutesMatch.group(1)!);
      }

      // Try to match seconds
      final secondsMatch = RegExp(r'(\d+)s').firstMatch(input);
      if (secondsMatch != null) {
        seconds = int.parse(secondsMatch.group(1)!);
      }

      // If no units specified, assume minutes
      if (hours == 0 && minutes == 0 && seconds == 0) {
        final number = int.tryParse(input);
        if (number != null) {
          minutes = number;
        }
      }

      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } catch (e) {
      print('⚠️ Error parsing duration: $e');
      return null;
    }
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
    required this.exercise,
    required this.exerciseIndex,
    required this.isExpanded,
    required this.onTap,
    required this.onSetChanged,
    required this.onAddSet,
    super.key,
    this.showDragHandle = false,
  });
  final ActiveExercise exercise;
  final int exerciseIndex;
  final bool isExpanded;
  final VoidCallback onTap;
  final Future<void> Function(int setIndex, ActiveSet updatedSet) onSetChanged;
  final VoidCallback onAddSet;
  final bool showDragHandle;

  String _getEquipmentShortName(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'barbell':
        return 'BB';
      case 'dumbbell':
        return 'DB';
      case 'cable':
        return 'Cable';
      case 'machine':
        return 'Mach';
      case 'bodyweight':
        return 'BW';
      case 'resistance_band':
        return 'Band';
      case 'kettlebell':
        return 'KB';
      default:
        return equipment.substring(0, 3).toUpperCase();
    }
  }

  String _getVariantShortName(String variant) {
    switch (variant.toLowerCase()) {
      case 'assisted':
        return 'Assist';
      case 'weighted':
        return 'Weight';
      case 'tempo':
        return 'Tempo';
      case 'pause':
        return 'Pause';
      default:
        return variant.substring(0, 4).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        margin: const EdgeInsets.only(bottom: 4),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${exercise.sets.length} sets',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              if (exercise.equipmentUsed != null ||
                                  exercise.variantType != null) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      [
                                        if (exercise.equipmentUsed != null)
                                          _getEquipmentShortName(
                                            exercise.equipmentUsed!,
                                          ),
                                        if (exercise.variantType != null &&
                                            exercise.variantType != 'standard')
                                          _getVariantShortName(
                                            exercise.variantType!,
                                          ),
                                      ].join(' • '),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Variant Picker Button
                    ExerciseVariantPicker(
                      currentEquipment: exercise.equipmentUsed,
                      currentVariant: exercise.variantType,
                      onChanged: (equipment, variant) {
                        ref
                            .read(activeWorkoutProvider.notifier)
                            .updateExerciseVariant(
                              exerciseIndex,
                              equipmentUsed: equipment,
                              variantType: variant,
                            );
                      },
                    ),
                    if (showDragHandle) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 4),
                        child: Icon(
                          Icons.drag_handle,
                          size: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
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
                padding: const EdgeInsets.fromLTRB(2, 18, 2, 2),
                child: Column(
                  children: [
                    // Rest Timer Controls
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Rest',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                          ),
                          const SizedBox(width: 8),
                          // Compact minus button
                          InkWell(
                            onTap: exercise.restTimerSeconds > 15
                                ? () {
                                    ref
                                        .read(activeWorkoutProvider.notifier)
                                        .updateExerciseRestTimer(
                                          exerciseIndex,
                                          exercise.restTimerSeconds - 15,
                                        );
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: exercise.restTimerSeconds > 15
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.3),
                              ),
                            ),
                          ),
                          // Compact value display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${exercise.restTimerSeconds}s',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                height: 1,
                              ),
                            ),
                          ),
                          // Compact plus button
                          InkWell(
                            onTap: () {
                              ref
                                  .read(activeWorkoutProvider.notifier)
                                  .updateExerciseRestTimer(
                                    exerciseIndex,
                                    exercise.restTimerSeconds + 15,
                                  );
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
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
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          },
                          onDismissed: (direction) {
                            // Remove the set
                            ref
                                .read(activeWorkoutProvider.notifier)
                                .removeSet(exerciseIndex, index);

                            // Show in-app notification with undo option
                            NotificationService()
                                .showInAppNotification(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  title: 'Set removed',
                                  body: 'Set ${index + 1} removed',
                                  primaryActionLabel: 'Undo',
                                  onPrimaryAction: () {
                                    // Simple undo: re-add a set at this exercise
                                    ref
                                        .read(activeWorkoutProvider.notifier)
                                        .addSet(exerciseIndex);
                                  },
                                )
                                .catchError((_) {});
                          },
                          child: SetEntryWidget(
                            set: set,
                            setNumber: index + 1,
                            restTimerSeconds: exercise.restTimerSeconds,
                            exerciseName: exercise.name,
                            exerciseType: exercise.exerciseType,
                            variantType: exercise.variantType,
                            totalSets: exercise.sets.length,
                            isFirstSet: index == 0,
                            onChanged: (updatedSet) {
                              onSetChanged(index, updatedSet);
                            },
                          ),
                        );
                      },
                    ),
                    // Add Set Button
                    SizedBox(
                      width: double.infinity,
                      height: 48, // Increased height for better touch target
                      child: OutlinedButton(
                        onPressed: onAddSet,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Add Set',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12), // Space after Add Set button
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ActiveExercise>('exercise', exercise));
    properties.add(IntProperty('exerciseIndex', exerciseIndex));
    properties.add(DiagnosticsProperty<bool>('isExpanded', isExpanded));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<
            Future<void> Function(int setIndex, ActiveSet updatedSet)>.has(
        'onSetChanged', onSetChanged));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onAddSet', onAddSet));
    properties.add(DiagnosticsProperty<bool>('showDragHandle', showDragHandle));
  }
}
