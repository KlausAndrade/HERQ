import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/telemetry_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';
import '../providers/active_workout_provider.dart';
import '../providers/workout_providers.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({
    required this.workoutId,
    super.key,
  });

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutSessionAsync =
        ref.watch(workoutSessionByIdProvider(workoutId));
    final setEntriesAsync = ref.watch(setEntriesBySessionProvider(workoutId));

    return workoutSessionAsync.when(
      data: (workoutSession) {
        if (workoutSession == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Workout Not Found'),
            ),
            body: const Center(
              child: Text('Workout session not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
            title: Text(workoutSession.name),
            actions: [
              IconButton(
                onPressed: () {
                  _showWorkoutMenu(context, ref, workoutSession);
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout Header
                _WorkoutHeader(workoutSession: workoutSession),

                const SizedBox(height: 16),

                // Exercise Sets
                setEntriesAsync.when(
                  data: (setEntries) => _ExerciseSetsSection(
                    setEntries: setEntries,
                    workoutSession: workoutSession,
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Error loading sets: $error'),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Workout Notes
                if (workoutSession.notes != null &&
                    workoutSession.notes!.isNotEmpty)
                  _WorkoutNotes(notes: workoutSession.notes!),

                const SizedBox(height: 32),
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
                'Error loading workout',
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

  void _showWorkoutMenu(
    BuildContext context,
    WidgetRef ref,
    WorkoutSession workoutSession,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    S.of(context)!.workoutOptions,
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
            ListTile(
              leading: const Icon(Icons.repeat),
              title: Text(S.of(context)!.repeatWorkout),
              onTap: () {
                Navigator.pop(context);
                _startNewWorkoutWithTemplate(context, ref, workoutSession);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Workout'),
              onTap: () {
                Navigator.pop(context);
                _shareWorkout(context, workoutSession);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(S.of(context)!.editNotes),
              onTap: () {
                Navigator.pop(context);
                _showEditNotesDialog(context, ref, workoutSession);
              },
            ),
            if (workoutSession.completedAt == null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  S.of(context)!.deleteWorkout,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, ref, workoutSession);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditNotesDialog(
    BuildContext context,
    WidgetRef ref,
    WorkoutSession workoutSession,
  ) {
    final controller = TextEditingController(text: workoutSession.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context)!.editNotes),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: S.of(context)!.addWorkoutNotes,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final database = ref.read(databaseProvider);
              if (database == null) return;

              try {
                await database.update(database.workoutSessions).replace(
                      workoutSession.copyWith(notes: Value(controller.text)),
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  NotificationService()
                      .showInAppNotification(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Notes updated',
                        body: '',
                      )
                      .catchError((_) {});
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  NotificationService()
                      .showInAppNotification(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Error updating notes',
                        body: '$e',
                      )
                      .catchError((_) {});
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _startNewWorkoutWithTemplate(
    BuildContext context,
    WidgetRef ref,
    WorkoutSession workoutSession,
  ) {
    // Navigate to active workout with the same template or exercises
    if (workoutSession.templateId != null &&
        workoutSession.templateId!.isNotEmpty) {
      // Use the existing template
      context.go('/active-workout?templateId=${workoutSession.templateId}');
    } else {
      // Create a temporary template from this workout's exercises
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Repeat Workout'),
          content: Text(
            'Start a new workout with the same exercises as "${workoutSession.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                final database = ref.read(databaseProvider);
                if (database == null) return;

                try {
                  // Gather distinct exercise IDs used in this workout session
                  final entries = await (database.select(database.setEntries)
                        ..where(
                          (tbl) =>
                              tbl.workoutSessionId.equals(workoutSession.id),
                        ))
                      .get();

                  final exerciseIds =
                      entries.map((e) => e.exerciseId).toSet().toList();

                  // Start workout directly from exercise IDs (no DB template)
                  await ref
                      .read(activeWorkoutProvider.notifier)
                      .startWorkoutFromExerciseIds(
                        'Repeat: ${workoutSession.name}',
                        exerciseIds,
                      );

                  // Telemetry: track repeat action (best-effort)
                  try {
                    final telemetry = ref.read(telemetryProvider);
                    telemetry.trackEvent('repeat_workout', {
                      'source': 'workout_detail',
                      'workoutId': workoutSession.id,
                      'exerciseCount': exerciseIds.length,
                      'name': workoutSession.name,
                    });
                  } catch (_) {
                    // ignore - telemetry must not crash
                  }

                  if (context.mounted) {
                    // Provide user feedback
                    NotificationService()
                        .showInAppNotification(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: 'Repeat workout started',
                          body: '',
                        )
                        .catchError((_) {});

                    context.go('/active-workout');
                  }
                } catch (e) {
                  if (context.mounted) {
                    NotificationService()
                        .showInAppNotification(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: 'Error',
                          body: '$e',
                        )
                        .catchError((_) {});
                  }
                }
              },
              child: Text(S.of(context)!.startWorkout),
            ),
          ],
        ),
      );
    }
  }

  void _shareWorkout(BuildContext context, WorkoutSession workoutSession) {
    // Simple share functionality using dialog for now
    // In a real app, you'd use share_plus package
    final shareText = '''
${workoutSession.name}
Completed: ${workoutSession.completedAt != null ? DateFormat('MMM d, y').format(workoutSession.completedAt!) : 'In Progress'}

Stats:
• Duration: ${_formatDuration(workoutSession.totalDurationSeconds)}
• Total Sets: ${workoutSession.totalSets}
• Volume: ${workoutSession.totalVolume.toStringAsFixed(1)}kg

${workoutSession.notes != null && workoutSession.notes!.isNotEmpty ? '\nNotes:\n${workoutSession.notes}' : ''}
    '''
        .trim();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context)!.shareWorkout),
        content: SingleChildScrollView(
          child: SelectableText(shareText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context)!.close),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '--';

    final duration = Duration(seconds: seconds);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    WorkoutSession workoutSession,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text(
          'Are you sure you want to delete this workout? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final database = ref.read(databaseProvider);
              if (database == null) return;

              try {
                // Delete associated set entries first
                await (database.delete(database.setEntries)
                      ..where(
                        (tbl) => tbl.workoutSessionId.equals(workoutSession.id),
                      ))
                    .go();

                // Delete the workout session
                await database
                    .delete(database.workoutSessions)
                    .delete(workoutSession);

                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  NotificationService()
                      .showInAppNotification(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Workout deleted',
                        body: '',
                      )
                      .catchError((_) {});
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  NotificationService()
                      .showInAppNotification(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Error deleting workout: $e',
                        body: '',
                      )
                      .catchError((_) {});
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('workoutId', workoutId));
  }
}

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({required this.workoutSession});

  final WorkoutSession workoutSession;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(workoutSession.completedAt != null),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      workoutSession.completedAt != null
                          ? Icons.check_circle
                          : Icons.fitness_center,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workoutSession.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(workoutSession.completedAt != null)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      workoutSession.completedAt != null
                          ? 'COMPLETED'
                          : 'IN PROGRESS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            _getStatusColor(workoutSession.completedAt != null),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Workout Stats
              Row(
                children: [
                  _StatItem(
                    icon: Icons.schedule,
                    label: 'Duration',
                    value: _formatDuration(workoutSession.totalDurationSeconds),
                  ),
                  const SizedBox(width: 24),
                  _StatItem(
                    icon: Icons.fitness_center,
                    label: 'Sets',
                    value: '${workoutSession.totalSets}',
                  ),
                  const SizedBox(width: 24),
                  _StatItem(
                    icon: Icons.repeat,
                    label: 'Reps',
                    value: '${workoutSession.totalReps}',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _StatItem(
                    icon: Icons.monitor_weight,
                    label: 'Volume',
                    value:
                        '${workoutSession.totalVolume.toStringAsFixed(1)} kg',
                  ),
                  const SizedBox(width: 24),
                  _StatItem(
                    icon: Icons.trending_up,
                    label: 'Tonnage',
                    value:
                        '${workoutSession.totalTonnage.toStringAsFixed(1)} kg',
                  ),
                ],
              ),

              if (workoutSession.completedAt != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Started: ${timeFormat.format(workoutSession.startedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Finished: ${timeFormat.format(workoutSession.completedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(bool isCompleted) =>
      isCompleted ? Colors.green : Colors.orange;

  String _formatDuration(int? seconds) {
    if (seconds == null) return '--';

    final duration = Duration(seconds: seconds);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<WorkoutSession>('workoutSession', workoutSession));
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('value', value));
  }
}

class _ExerciseSetsSection extends ConsumerWidget {
  const _ExerciseSetsSection({
    required this.setEntries,
    required this.workoutSession,
  });

  final List<SetEntry> setEntries;
  final WorkoutSession workoutSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (setEntries.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No exercises recorded',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This workout doesn\'t have any recorded sets yet',
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
      );
    }

    // Group sets by exercise
    final groupedSets = <String, List<SetEntry>>{};
    for (final set in setEntries) {
      groupedSets.putIfAbsent(set.exerciseId, () => []).add(set);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercises',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...groupedSets.entries.map((entry) {
            final exerciseId = entry.key;
            final exerciseSets = entry.value;

            return _ExerciseCard(
              exerciseId: exerciseId,
              sets: exerciseSets,
            );
          }),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<SetEntry>('setEntries', setEntries));
    properties.add(
        DiagnosticsProperty<WorkoutSession>('workoutSession', workoutSession));
  }
}

class _ExerciseCard extends ConsumerWidget {
  const _ExerciseCard({
    required this.exerciseId,
    required this.sets,
  });

  final String exerciseId;
  final List<SetEntry> sets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseByIdProvider(exerciseId));

    return exerciseAsync.when(
      data: (exercise) {
        final exerciseName = exercise?.name ?? S.of(context)!.unknownExercise;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      exercise?.isBodyweight ?? false
                          ? Icons.accessibility
                          : Icons.fitness_center,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exerciseName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    Text(
                      '${sets.length} ${S.of(context)!.sets}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Sets table header
                Row(
                  children: [
                    const SizedBox(width: 30),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Weight',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Reps',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'RPE',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 8),

                // Sets
                ...sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getSetTypeColor(set.setType),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: Text(
                            set.weight != null
                                ? '${set.weight!.toStringAsFixed(1)} kg'
                                : '--',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${set.reps}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            set.rpe != null ? '${set.rpe}' : '--',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading exercise: $error'),
        ),
      ),
    );
  }

  Color _getSetTypeColor(String setType) {
    switch (setType.toLowerCase()) {
      case 'warmup':
        return Colors.orange;
      case 'working':
        return Colors.blue;
      case 'drop':
        return Colors.purple;
      case 'failure':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('exerciseId', exerciseId));
    properties.add(IterableProperty<SetEntry>('sets', sets));
  }
}

class _WorkoutNotes extends StatelessWidget {
  const _WorkoutNotes({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notes,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('notes', notes));
  }
}
