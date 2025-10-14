import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/exercise_types.dart';
import '../../domain/models/active_workout.dart';
import '../providers/active_workout_web_provider.dart';

class WebWorkoutScreen extends ConsumerWidget {
  const WebWorkoutScreen({required this.templateId, super.key});
  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(activeWorkoutWebProvider);

    // Start workout if not already active
    if (workout == null) {
      Future.microtask(() async {
        await ref
            .read(activeWorkoutWebProvider.notifier)
            .startWorkoutFromTemplate(templateId);
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
                await ref
                    .read(activeWorkoutWebProvider.notifier)
                    .finishWorkout();
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
                          exerciseType: exercise.exerciseType,
                          onUpdate: (updatedSet) {
                            ref
                                .read(activeWorkoutWebProvider.notifier)
                                .updateSet(
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
                            ref
                                .read(activeWorkoutWebProvider.notifier)
                                .addSet(exerciseIndex);
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('templateId', templateId));
  }
}

class _SetRow extends StatefulWidget {
  const _SetRow({
    required this.set,
    required this.exerciseType,
    required this.onUpdate,
  });
  final ActiveSet set;
  final String exerciseType;
  final Function(ActiveSet) onUpdate;

  @override
  State<_SetRow> createState() => _SetRowState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ActiveSet>('set', set));
    properties.add(StringProperty('exerciseType', exerciseType));
    properties.add(
        ObjectFlagProperty<Function(ActiveSet p1)>.has('onUpdate', onUpdate));
  }
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController weightController;
  late TextEditingController repsController;
  late TextEditingController durationController;
  late TextEditingController distanceController;
  late TextEditingController assistanceWeightController;
  late TextEditingController addedWeightController;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    repsController = TextEditingController(
      text: widget.set.reps > 0 ? widget.set.reps.toString() : '',
    );
    durationController = TextEditingController(
      text: widget.set.durationSeconds?.toString() ?? '',
    );
    distanceController = TextEditingController(
      text: widget.set.distance?.toString() ?? '',
    );
    assistanceWeightController = TextEditingController(
      text: widget.set.assistanceWeight?.toString() ?? '',
    );
    addedWeightController = TextEditingController(
      text: widget.set.addedWeight?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    durationController.dispose();
    distanceController.dispose();
    assistanceWeightController.dispose();
    addedWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ExerciseTypeConfig.fromString(widget.exerciseType);
    final fields = config.requiredFields;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: widget.set.isCompleted ? Colors.green : Colors.grey,
        child: Text('${widget.set.number}'),
      ),
      title: Row(
        children: [
          // Dynamic input fields based on exercise type
          ...fields.map(
            (field) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildInputField(field),
              ),
            ),
          ),

          // Complete button
          IconButton(
            icon: Icon(
              widget.set.isCompleted
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: widget.set.isCompleted ? Colors.green : null,
            ),
            onPressed: () {
              final updatedSet = ActiveSet(
                number: widget.set.number,
                weight: _parseDouble(weightController.text),
                reps: _parseInt(repsController.text) ?? 0,
                durationSeconds: _parseInt(durationController.text),
                distance: _parseDouble(distanceController.text),
                assistanceWeight: _parseDouble(assistanceWeightController.text),
                addedWeight: _parseDouble(addedWeightController.text),
                rpe: widget.set.rpe,
                isCompleted: true,
              );
              widget.onUpdate(updatedSet);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(ExerciseField field) {
    switch (field) {
      case ExerciseField.weight:
        return TextField(
          controller: weightController,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        );
      case ExerciseField.reps:
        return TextField(
          controller: repsController,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      case ExerciseField.duration:
        return TextField(
          controller: durationController,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      case ExerciseField.distance:
        return TextField(
          controller: distanceController,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        );
      case ExerciseField.assistanceWeight:
        return TextField(
          controller: assistanceWeightController,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        );
      case ExerciseField.addedWeight:
        return TextField(
          controller: addedWeightController,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        );
    }
  }

  double? _parseDouble(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  int? _parseInt(String text) {
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>(
        'weightController', weightController));
    properties.add(DiagnosticsProperty<TextEditingController>(
        'repsController', repsController));
    properties.add(DiagnosticsProperty<TextEditingController>(
        'durationController', durationController));
    properties.add(DiagnosticsProperty<TextEditingController>(
        'distanceController', distanceController));
    properties.add(DiagnosticsProperty<TextEditingController>(
        'assistanceWeightController', assistanceWeightController));
    properties.add(DiagnosticsProperty<TextEditingController>(
        'addedWeightController', addedWeightController));
  }
}
