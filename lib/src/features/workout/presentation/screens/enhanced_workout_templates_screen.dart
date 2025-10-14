import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import 'package:herq/src/core/services/notification_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../providers/template_providers.dart';

class WorkoutTemplatesScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  ConsumerState<WorkoutTemplatesScreen> createState() =>
      _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState
    extends ConsumerState<WorkoutTemplatesScreen> {
  String? _selectedCategory;
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(workoutTemplatesProvider);
    final categoriesAsync = ref.watch(templateCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Workout Templates'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Done'),
            )
          else
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Templates',
            ),
          IconButton(
            onPressed: () => context.push('/template-builder'),
            icon: const Icon(Icons.add),
            tooltip: 'Create Template',
          ),
        ],
      ),
      body: templatesAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SkeletonWorkoutCard(),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading templates: $error'),
              const SizedBox(height: 16),
              AppButton(
                onPressed: () => ref.refresh(workoutTemplatesProvider),
                variant: AppButtonVariant.primary,
                icon: Icons.refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (templatesByCategory) {
          if (templatesByCategory.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Category Tabs
              categoriesAsync.when(
                data: (categories) => _buildCategoryTabs(categories),
                loading: () => const SizedBox(height: 48),
                error: (_, __) => const SizedBox(height: 48),
              ),

              // Templates List
              Expanded(
                child: _selectedCategory != null
                    ? _buildCategoryTemplates(
                        templatesByCategory[_selectedCategory] ?? [])
                    : _buildAllTemplates(templatesByCategory),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildCategoryTabs(List<String> categories) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "All" tab
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryTab('All', _selectedCategory == null);
          }

          final category = categories[index - 1];
          return _buildCategoryTab(category, _selectedCategory == category);
        },
      ),
    );
  }

  Widget _buildCategoryTab(String category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory =
                selected ? (category == 'All' ? null : category) : null;
          });
        },
      ),
    );
  }

  Widget _buildAllTemplates(
      Map<String, List<WorkoutTemplate>> templatesByCategory) {
    final sortedCategories = templatesByCategory.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final templates = templatesByCategory[category]!;

        return _buildCategorySection(category, templates);
      },
    );
  }

  Widget _buildCategorySection(
      String category, List<WorkoutTemplate> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (_isEditing)
                IconButton(
                  onPressed: () => _showCategoryMenu(context, category),
                  icon: const Icon(Icons.more_vert),
                  iconSize: 20,
                ),
            ],
          ),
        ),
        if (_isEditing)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: templates.length,
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex--;

              // Create mutable copy for reordering
              final reorderedList = List<WorkoutTemplate>.from(templates);
              final item = reorderedList.removeAt(oldIndex);
              reorderedList.insert(newIndex, item);

              // Persist the new order in background (no need to invalidate - ReorderableListView handles UI)
              final actions = ref.read(templateActionsProvider);
              actions.reorderTemplates(reorderedList, category);
            },
            itemBuilder: (context, index) => _buildTemplateCard(
              templates[index],
              key: ValueKey(
                  '${category}-edit-${templates[index].id}'), // Unique key per category
              index: index,
            ),
          )
        else
          ...templates.map((template) => _buildTemplateCard(
                template,
                key: ValueKey(
                    '${category}-view-${template.id}'), // Unique key per category
              )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryTemplates(List<WorkoutTemplate> templates) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No templates in this category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new template to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    // Use ReorderableListView when in edit mode
    if (_isEditing) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        onReorder: (oldIndex, newIndex) async {
          if (newIndex > oldIndex) newIndex--;

          // Create mutable copy for reordering
          final reorderedList = List<WorkoutTemplate>.from(templates);
          final item = reorderedList.removeAt(oldIndex);
          reorderedList.insert(newIndex, item);

          // Persist the new order in background (no need to invalidate - ReorderableListView handles UI)
          final actions = ref.read(templateActionsProvider);
          actions.reorderTemplates(reorderedList, _selectedCategory);
        },
        itemBuilder: (context, index) => _buildTemplateCard(
          templates[index],
          key: ValueKey(
              'edit-${templates[index].id}'), // Unique key for edit mode
          index: index,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) => _buildTemplateCard(
        templates[index],
        key:
            ValueKey('view-${templates[index].id}'), // Unique key for view mode
      ),
    );
  }

  Widget _buildTemplateCard(
    WorkoutTemplate template, {
    Key? key,
    int? index,
  }) {
    return AppCard(
      key: key,
      variant: AppCardVariant.elevated,
      heroTag: 'template-${template.id}',
      onTap: _isEditing ? null : () => _startWorkout(template.id),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _getCategoryColor(template.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(template.category),
                    color: _getCategoryColor(template.category),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (template.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          template.description!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_isEditing) ...[
                  if (index != null)
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.drag_handle,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () => _showTemplateMenu(context, template),
                    icon: const Icon(Icons.more_vert),
                    iconSize: 20,
                  ),
                ] else
                  Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            if (template.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: template.tags.take(3).map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  template.estimatedDurationMinutes != null
                      ? '${template.estimatedDurationMinutes} min'
                      : 'No duration set',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const Spacer(),
                Text(
                  '${template.exerciseIds.length} exercises',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                if (template.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      title: 'No Workout Templates',
      subtitle:
          'Create your first template to get started with structured workouts',
      icon: Icons.fitness_center_outlined,
      actionText: 'Create Template',
      onAction: () => context.push('/template-builder'),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              // Already on templates screen
              break;
            case 2:
              context.go('/exercises');
              break;
            case 3:
              context.go('/progress');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
        ],
      );

  void _startWorkout(String templateId) {
    context.go('/active-workout?templateId=$templateId');
  }

  void _showTemplateMenu(BuildContext context, WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'Template Options',
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
            leading: const Icon(Icons.edit),
            title: const Text('Edit Template'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/template-builder?templateId=${template.id}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Rename'),
            onTap: () {
              Navigator.of(context).pop();
              _showRenameDialog(context, template);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicate'),
            onTap: () {
              Navigator.of(context).pop();
              _showDuplicateDialog(context, template);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Move to Category'),
            onTap: () {
              Navigator.of(context).pop();
              _showMoveCategoryDialog(context, template);
            },
          ),
          if (!template.isDefault)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(context, template);
              },
            ),
        ],
      ),
    );
  }

  void _showCategoryMenu(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'Category Options',
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
            leading: const Icon(Icons.add),
            title: const Text('Add Template to Category'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/template-builder');
            },
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WorkoutTemplate template) {
    final controller = TextEditingController(text: template.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Template'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _renameTemplate(template.id, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDuplicateDialog(BuildContext context, WorkoutTemplate template) {
    final controller = TextEditingController(text: '${template.name} (Copy)');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Template'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _duplicateTemplate(template.id, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
  }

  void _showMoveCategoryDialog(BuildContext context, WorkoutTemplate template) {
    String selectedCategory = template.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Move to Category'),
          content: DropdownButtonFormField<String>(
            value: selectedCategory,
            items: [
              'Custom',
              'Push Pull Legs',
              'Full Body',
              'Upper Lower',
              'PHUL',
              'Strength',
              'Bodybuilding'
            ]
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedCategory = value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _moveTemplate(template.id, selectedCategory);
                Navigator.of(context).pop();
              },
              child: const Text('Move'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
            'Are you sure you want to delete "${template.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _deleteTemplate(template.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _renameTemplate(String templateId, String newName) async {
    final actions = ref.read(templateActionsProvider);
    final success = await actions.renameTemplate(templateId, newName);

    if (success) {
      ref.invalidate(workoutTemplatesProvider);
      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Renamed',
              body: 'Template renamed successfully',
            )
            .catchError((_) {});
      }
    }
  }

  void _duplicateTemplate(String templateId, String newName) async {
    final actions = ref.read(templateActionsProvider);
    final success = await actions.duplicateTemplate(templateId, newName);

    if (success) {
      ref.invalidate(workoutTemplatesProvider);
      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Duplicated',
              body: 'Template duplicated successfully',
            )
            .catchError((_) {});
      }
    }
  }

  void _moveTemplate(String templateId, String newCategory) async {
    final actions = ref.read(templateActionsProvider);
    final success = await actions.moveTemplate(templateId, newCategory, 0);

    if (success) {
      ref.invalidate(workoutTemplatesProvider);
      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Moved',
              body: 'Template moved successfully',
            )
            .catchError((_) {});
      }
    }
  }

  void _deleteTemplate(String templateId) async {
    final actions = ref.read(templateActionsProvider);
    final success = await actions.deleteTemplate(templateId);

    if (success) {
      ref.invalidate(workoutTemplatesProvider);
      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Deleted',
              body: 'Template deleted successfully',
            )
            .catchError((_) {});
      }
    }
  }

  // ignore: unused_element
  void _initializeDefaultTemplates() async {
    final actions = ref.read(templateActionsProvider);
    final success = await actions.initializeDefaultTemplates();

    if (success) {
      ref.invalidate(workoutTemplatesProvider);
      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Defaults loaded',
              body: 'Default templates loaded successfully',
            )
            .catchError((_) {});
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Push Pull Legs':
        return Colors.blue;
      case 'Full Body':
        return Colors.green;
      case 'Upper Lower':
        return Colors.orange;
      case 'PHUL':
        return Colors.purple;
      case 'Strength':
        return Colors.red;
      case 'Bodybuilding':
        return Colors.indigo;
      case 'Custom':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Push Pull Legs':
        return Icons.trending_up;
      case 'Full Body':
        return Icons.fitness_center;
      case 'Upper Lower':
        return Icons.unfold_more;
      case 'PHUL':
        return Icons.flash_on;
      case 'Strength':
        return Icons.sports_gymnastics;
      case 'Bodybuilding':
        return Icons.emoji_people;
      case 'Custom':
        return Icons.build;
      default:
        return Icons.fitness_center;
    }
  }
}
