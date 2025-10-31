import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/template_web_provider.dart';
import '../widgets/multi_exercise_picker_dialog.dart';
import 'template_builder_screen.dart';

class WebTemplatesScreen extends ConsumerWidget {
  const WebTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(workoutTemplatesWebProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Templates'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: templates.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 24),
                  const Text('No templates yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Template'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final template = data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.fitness_center),
                  ),
                  title: Text(template['name'] ?? 'Unnamed'),
                  subtitle: Text(
                    '${(template['exercise_ids'] as List?)?.length ?? 0} exercises',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Edit Template',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TemplateBuilderScreen(
                                templateId: template['id'],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Color(0xFF6366F1),
                        ),
                        onPressed: () =>
                            context.go('/workout/${template['id']}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(context, ref, template['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => _CreateTemplateDialog(
        nameController: nameController,
        onSubmit: (name, exerciseIds) async {
          final create = ref.read(createTemplateWebProvider);
          await create(name: name, exerciseIds: exerciseIds);
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String templateId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: const Text('Are you sure you want to delete this template?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final delete = ref.read(deleteTemplateWebProvider);
              await delete(templateId);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CreateTemplateDialog extends ConsumerStatefulWidget {
  const _CreateTemplateDialog({
    required this.nameController,
    required this.onSubmit,
  });
  final TextEditingController nameController;
  final Function(String name, List<String> exerciseIds) onSubmit;

  @override
  ConsumerState<_CreateTemplateDialog> createState() =>
      _CreateTemplateDialogState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<TextEditingController>(
        'nameController',
        nameController,
      ),
    );
    properties.add(
      ObjectFlagProperty<Function(String name, List<String> exerciseIds)>.has(
        'onSubmit',
        onSubmit,
      ),
    );
  }
}

class _CreateTemplateDialogState extends ConsumerState<_CreateTemplateDialog> {
  final List<String> selectedExercises = [];

  @override
  Widget build(BuildContext context) => Dialog(
    child: Container(
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Template',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: widget.nameController,
            decoration: const InputDecoration(
              labelText: 'Template Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Exercises',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (selectedExercises.isNotEmpty)
                Chip(
                  label: Text('${selectedExercises.length} selected'),
                  backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedExercises.isNotEmpty)
            Chip(
              label: Text('${selectedExercises.length} selected'),
              backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Exercises'),
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => const MultiExercisePickerDialog(),
              );
              if (result != null && result['exercises'] != null) {
                setState(() {
                  final exercises = result['exercises'] as List;
                  for (final exercise in exercises) {
                    if (!selectedExercises.contains(exercise.id)) {
                      selectedExercises.add(exercise.id);
                    }
                  }
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: selectedExercises.isEmpty
                    ? null
                    : () {
                        widget.onSubmit(
                          widget.nameController.text,
                          selectedExercises,
                        );
                      },
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      IterableProperty<String>('selectedExercises', selectedExercises),
    );
  }
}
