import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/user_context_service.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';
import '../providers/template_providers.dart';
import '../widgets/multi_exercise_picker_dialog.dart';

class TemplateBuilderScreen extends ConsumerStatefulWidget {
  // Optional: preselect folder when creating

  const TemplateBuilderScreen({super.key, this.templateId, this.folderId});
  final String? templateId; // For editing existing templates
  final String? folderId;

  @override
  ConsumerState<TemplateBuilderScreen> createState() =>
      _TemplateBuilderScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('templateId', templateId));
    properties.add(StringProperty('folderId', folderId));
  }
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
    // If a folderId is provided and we're creating a new template, prefill
    // internal state to hint the template should be created inside that folder.
    if (widget.templateId == null && widget.folderId != null) {
      // Store folder id temporarily in tags to avoid changing DB models here;
      // the actual assignment occurs on save via TemplateActions.createTemplate.
      // We'll keep a private variable to hold the folderId.
      _initialFolderId = widget.folderId;
    }
  }

  String? _initialFolderId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplate() async {
    setState(() => _isLoading = true);

    try {
      final templatesAsync = ref.read(workoutTemplatesProvider);
      await templatesAsync.when(
        data: (templatesByCategory) async {
          for (final templates in templatesByCategory.values) {
            final template =
                templates.where((t) => t.id == widget.templateId).firstOrNull;
            if (template != null) {
              print('🔍 TemplateBuilder - Loading template: ${template.name}');
              print('🔍 TemplateBuilder - Template exerciseIds: ${template.exerciseIds}');
              print('🔍 TemplateBuilder - Template exerciseIds count: ${template.exerciseIds.length}');
              
              _nameController.text = template.name;
              _descriptionController.text = template.description ?? '';
              // Normalize category from stored template to avoid issues with
              // differing capitalization/whitespace (e.g., 'YOGA' vs 'Yoga').
              _selectedCategory = template.category.trim();
              _selectedExerciseIds.addAll(template.exerciseIds);
              _tags.addAll(template.tags);
              _estimatedDuration = template.estimatedDurationMinutes;
              
              print('🔍 TemplateBuilder - Loaded exerciseIds: $_selectedExerciseIds');
              print('🔍 TemplateBuilder - Loaded exerciseIds count: ${_selectedExerciseIds.length}');
              
              if (mounted) setState(() {});
              break;
            }
          }
        },
        loading: () async {
          // Wait a bit and try again
          await Future.delayed(const Duration(milliseconds: 500));
          await _loadTemplate();
          return;
        },
        error: (error, stack) async {
          print('Error loading template: $error');
        },
      );
    } catch (e) {
      print('Error in _loadTemplate: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showExercisePickerDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const MultiExercisePickerDialog(),
    );
    if (result != null && result['exercises'] != null) {
      setState(() {
        final exercises = result['exercises'] as List;
        for (final exercise in exercises) {
          if (!_selectedExerciseIds.contains(exercise.id)) {
            _selectedExerciseIds.add(exercise.id);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider);
    
    // Debug: Print exercises state
    exercisesAsync.when(
      data: (exercises) {
        print('🔍 TemplateBuilder - Available exercises count: ${exercises.length}');
        print('🔍 TemplateBuilder - Selected exerciseIds: $_selectedExerciseIds');
        print('🔍 TemplateBuilder - Selected exerciseIds count: ${_selectedExerciseIds.length}');
      },
      loading: () => print('🔍 TemplateBuilder - Loading exercises...'),
      error: (error, stack) => print('🔍 TemplateBuilder - Error loading exercises: $error'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              widget.templateId == null ? 'Create Template' : 'Edit Template',
            ),
            if (ref.watch(currentAdminModeProvider)) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (widget.templateId != null && _canDeleteTemplate()) ...[
            IconButton(
              onPressed: _isLoading ? null : _showDeleteConfirmation,
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Template',
            ),
          ],
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
                  Builder(
                    builder: (context) {
                      // Default category options; include currently selected
                      // category if it's not already present to avoid the
                      // DropdownButton assertion when editing templates with
                      // a custom or seeded category (e.g., 'YOGA').
                      final defaultCategories = [
                        'Custom',
                        'Push Pull Legs',
                        'Full Body',
                        'Upper Lower',
                        'PHUL',
                        'Strength',
                        'Bodybuilding',
                      ];

                      // Build categories list and normalize entries by trimming
                      // whitespace. Use a LinkedHashSet-like approach to preserve
                      // insertion order while removing duplicates that differ
                      // only by surrounding whitespace.
                      final categories = List<String>.from(defaultCategories);
                      final selectedTrimmed = _selectedCategory.trim();
                      if (selectedTrimmed.isNotEmpty &&
                          !categories.any((c) => c.trim() == selectedTrimmed)) {
                        categories.insert(0, _selectedCategory);
                      }

                      final uniqueCategories = <String>[];
                      for (final c in categories) {
                        final trimmed = c.trim();
                        if (!uniqueCategories.any((u) => u.trim() == trimmed)) {
                          uniqueCategories.add(c);
                        }
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: uniqueCategories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      );
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
                        onPressed: _showExercisePickerDialog,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          Text(
                                            exercise.primaryMuscleGroup,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
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
                      ..._tags.map(
                        (tag) => Chip(
                          label: Text(tag),
                          onDeleted: () {
                            setState(() => _tags.remove(tag));
                          },
                        ),
                      ),
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

  // ...existing code... (exercise picker is implemented by
  // _showExercisePickerDialog / MultiExercisePickerDialog)

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
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Please add at least one exercise',
            body: '',
          )
          .catchError((_) {});
      return;
    }

    setState(() => _isLoading = true);

    final template = WorkoutTemplate(
      id: widget.templateId ?? const Uuid().v4(),
      userId: ref.read(currentAdminModeProvider)
          ? null // Admin templates are system-wide
          : UserContextService.instance.getCurrentUserId() ?? 'default_user', // ✅ USER ISOLATION
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      sortOrder: 0,
      folderId: _initialFolderId,
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
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: widget.templateId == null
                  ? 'Template created successfully'
                  : 'Template updated successfully',
              body: '',
            )
            .catchError((_) {});
        Navigator.of(context).pop();
      } else {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Failed to save template',
              body: '',
            )
            .catchError((_) {});
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
          'Are you sure you want to delete "${_nameController.text}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTemplate();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTemplate() async {
    if (widget.templateId == null) return;

    setState(() => _isLoading = true);

    try {
      final actions = ref.read(templateActionsProvider);
      final success = await actions.deleteTemplate(widget.templateId!);

      if (success) {
        if (mounted) {
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Template deleted',
                body: 'Template deleted successfully',
              )
              .catchError((_) {});
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Failed to delete template',
                body: '',
              )
              .catchError((_) {});
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error deleting template',
              body: e.toString(),
            )
            .catchError((_) {});
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _canDeleteTemplate() {
    if (widget.templateId == null) return false;
    
    // System template IDs that should not be deletable
    const systemTemplateIds = {
      'ppl_push', 'ppl_pull', 'ppl_legs',
      'phul_upper_power', 'phul_lower_power', 'phul_upper_hyp', 'phul_lower_hyp',
      'full_body_beginner', 'full_body_intermediate', 'full_body_advanced',
      'upper_lower_upper', 'upper_lower_lower',
      'strength_beginner', 'strength_intermediate', 'strength_advanced',
      'bodybuilding_chest', 'bodybuilding_back', 'bodybuilding_legs', 'bodybuilding_arms',
    };
    
    // Don't allow deletion of system templates
    if (systemTemplateIds.contains(widget.templateId)) {
      return false;
    }
    
    // Allow deletion of AI-generated templates (start with 'ai_gen_')
    if (widget.templateId!.startsWith('ai_gen_')) {
      return true;
    }
    
    // Allow deletion of user-created templates (not system templates)
    // This is a fallback for any other user-created templates
    return true;
  }
}
