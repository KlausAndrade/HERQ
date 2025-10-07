import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';
import '../providers/template_providers.dart';

class TemplateBuilderScreen extends ConsumerStatefulWidget {
  final String? templateId; // For editing existing templates

  const TemplateBuilderScreen({super.key, this.templateId});

  @override
  ConsumerState<TemplateBuilderScreen> createState() =>
      _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends ConsumerState<TemplateBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Custom';
  final List<String> _selectedExerciseIds = [];
  final List<String> _tags = [];
  int? _estimatedDuration;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      _loadTemplate();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplate() async {
    setState(() => _isLoading = true);

    final templatesAsync = ref.read(workoutTemplatesProvider);
    templatesAsync.whenData((templatesByCategory) {
      for (final templates in templatesByCategory.values) {
        final template =
            templates.where((t) => t.id == widget.templateId).firstOrNull;
        if (template != null) {
          _nameController.text = template.name;
          _descriptionController.text = template.description ?? '';
          _selectedCategory = template.category;
          _selectedExerciseIds.addAll(template.exerciseIds);
          _tags.addAll(template.tags);
          _estimatedDuration = template.estimatedDurationMinutes;
          setState(() {});
          break;
        }
      }
    });

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.templateId == null ? 'Create Template' : 'Edit Template'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTemplate,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Template Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Template Name *',
                      hintText: 'e.g., Push Day, Full Body Workout',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a template name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief description of this workout',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Category Selection
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Custom',
                      'Push Pull Legs',
                      'Full Body',
                      'Upper Lower',
                      'PHUL',
                      'Strength',
                      'Bodybuilding',
                    ]
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Estimated Duration
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Estimated Duration (minutes)',
                      hintText: 'e.g., 60',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _estimatedDuration?.toString(),
                    onChanged: (value) {
                      _estimatedDuration = int.tryParse(value);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Exercise Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exercises (${_selectedExerciseIds.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showExerciseSelector(exercisesAsync),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Exercise'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Selected Exercises List
                  if (_selectedExerciseIds.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No exercises added yet',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "Add Exercise" to get started',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    exercisesAsync.when(
                      data: (exercises) => ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedExerciseIds.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item =
                                _selectedExerciseIds.removeAt(oldIndex);
                            _selectedExerciseIds.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final exerciseId = _selectedExerciseIds[index];
                          final exercise = exercises.firstWhere(
                            (e) => e.id == exerciseId,
                            orElse: () => exercises.first,
                          );

                          return Container(
                            key: ValueKey(exerciseId),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      child: Text('${index + 1}'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.name,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          Text(
                                            exercise.primaryMuscleGroup,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.drag_handle,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          _selectedExerciseIds.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Text('Error loading exercises'),
                    ),
                  const SizedBox(height: 24),

                  // Tags
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: () {
                              setState(() => _tags.remove(tag));
                            },
                          )),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 16),
                        label: const Text('Add Tag'),
                        onPressed: _showAddTagDialog,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _showExerciseSelector(AsyncValue<List<Exercise>> exercisesAsync) {
    exercisesAsync.whenData((exercises) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Exercises',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedExerciseIds.isNotEmpty)
                            Chip(
                              label: Text('${_selectedExerciseIds.length} selected'),
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {}); // Update parent widget after closing
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      final isSelected =
                          _selectedExerciseIds.contains(exercise.id);

                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(exercise.name),
                        subtitle: Text(
                          '${exercise.primaryMuscleGroup} • ${exercise.equipment}',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (selected) {
                          setModalState(() {
                            if (selected == true) {
                              _selectedExerciseIds.add(exercise.id);
                            } else {
                              _selectedExerciseIds.remove(exercise.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tag name',
            hintText: 'e.g., beginner, strength',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _tags.add(controller.text.trim().toLowerCase()));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final template = WorkoutTemplate(
      id: widget.templateId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      sortOrder: 0,
      exerciseIds: _selectedExerciseIds,
      tags: _tags,
      estimatedDurationMinutes: _estimatedDuration,
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final actions = ref.read(templateActionsProvider);
    final success = widget.templateId == null
        ? await actions.createTemplate(template)
        : await actions.updateTemplate(template);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ref.invalidate(workoutTemplatesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.templateId == null
                  ? 'Template created successfully'
                  : 'Template updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save template'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
