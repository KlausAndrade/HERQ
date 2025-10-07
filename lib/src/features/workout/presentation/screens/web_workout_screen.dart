import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/active_workout.dart';
import '../providers/active_workout_web_provider.dart';

class WebWorkoutScreen extends ConsumerWidget {
  final String templateId;

  const WebWorkoutScreen({super.key, required this.templateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(activeWorkoutWebProvider);

    // Start workout if not already active
    if (workout == null) {
      Future.microtask(() async {
        await ref.read(activeWorkoutWebProvider.notifier).startWorkoutFromTemplate(templateId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(workout?.name ?? 'Loading...'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showDiscardDialog(context, ref),
        ),
        actions: [
          if (workout != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                await ref.read(activeWorkoutWebProvider.notifier).finishWorkout();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
        ],
      ),
      body: workout == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workout.exercises.length,
              itemBuilder: (context, exerciseIndex) {
                final exercise = workout.exercises[exerciseIndex];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ...List.generate(
                        exercise.sets.length,
                        (setIndex) => _SetRow(
                          set: exercise.sets[setIndex],
                          onUpdate: (weight, reps) {
                            final updatedSet = ActiveSet(
                              number: exercise.sets[setIndex].number,
                              weight: weight,
                              reps: reps,
                              rpe: exercise.sets[setIndex].rpe,
                              isCompleted: true,
                            );
                            ref.read(activeWorkoutWebProvider.notifier).updateSet(
                              exerciseIndex,
                              setIndex,
                              updatedSet,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextButton.icon(
                          onPressed: () {
                            ref.read(activeWorkoutWebProvider.notifier).addSet(exerciseIndex);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Set'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showDiscardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Workout'),
        content: const Text('Are you sure you want to discard this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(activeWorkoutWebProvider.notifier).forceCleanup();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/');
              }
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final dynamic set;
  final Function(double, int) onUpdate;

  const _SetRow({required this.set, required this.onUpdate});

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController weightController;
  late TextEditingController repsController;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    repsController = TextEditingController(
      text: widget.set.reps.toString(),
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: widget.set.isCompleted ? Colors.green : Colors.grey,
        child: Text('${widget.set.number}'),
      ),
      title: Row(
        children: [
          Expanded(
            child: TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: repsController,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              widget.set.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: widget.set.isCompleted ? Colors.green : null,
            ),
            onPressed: () {
              final weight = double.tryParse(weightController.text) ?? 0;
              final reps = int.tryParse(repsController.text) ?? 0;
              widget.onUpdate(weight, reps);
            },
          ),
        ],
      ),
    );
  }
}
