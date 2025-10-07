import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../../../../providers/template_folder_provider.dart';
import '../providers/template_providers.dart';
import '../../../workouts/widgets/create_folder_dialog.dart';

class WorkoutTemplatesWithFoldersScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesWithFoldersScreen({super.key});

  @override
  ConsumerState<WorkoutTemplatesWithFoldersScreen> createState() =>
      _WorkoutTemplatesWithFoldersScreenState();
}

class _WorkoutTemplatesWithFoldersScreenState
    extends ConsumerState<WorkoutTemplatesWithFoldersScreen> {
  bool _isEditing = false;
  final Set<String> _expandedFolders = {};

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(templateFoldersProvider);
    final unfoldered = ref.watch(templatesInFolderProvider(null));

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
      body: foldersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading folders: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(templateFoldersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (folders) {
          final foldersList = folders.toList();
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Create Folder Button
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: OutlinedButton.icon(
                    onPressed: _createNewFolder,
                    icon: const Icon(Icons.create_new_folder),
                    label: const Text('Create Folder'),
                  ),
                ),

              // Folders - with reordering support in edit mode
              if (_isEditing && foldersList.isNotEmpty)
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: foldersList.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex--;
                    
                    // Create mutable copy for reordering
                    final reorderedList = List<TemplateFolder>.from(foldersList);
                    final item = reorderedList.removeAt(oldIndex);
                    reorderedList.insert(newIndex, item);

                    // Persist the new order in background (no need to invalidate - ReorderableListView handles UI)
                    final actions = ref.read(templateActionsProvider);
                    actions.reorderFolders(reorderedList);
                  },
                  itemBuilder: (context, index) => _buildFolderSection(
                    foldersList[index],
                    key: ValueKey('folder-edit-${foldersList[index].id}'), // Unique key for edit mode
                    index: index,
                  ),
                )
              else
                ...foldersList.map((folder) => _buildFolderSection(
                      folder,
                      key: ValueKey('folder-view-${folder.id}'), // Unique key for view mode
                    )),

              // Unfolderd Templates
              unfoldered.when(
                data: (templates) {
                  if (templates.isEmpty) return const SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Uncategorized',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                        ),
                      ),
                      if (_isEditing)
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: templates.length,
                          onReorder: (oldIndex, newIndex) async {
                            if (newIndex > oldIndex) newIndex--;
                            
                            final reorderedList = List<WorkoutTemplate>.from(templates);
                            final item = reorderedList.removeAt(oldIndex);
                            reorderedList.insert(newIndex, item);

                            // Persist in background (no need to invalidate - ReorderableListView handles UI)
                            final actions = ref.read(templateActionsProvider);
                            actions.reorderTemplates(reorderedList, null);
                          },
                          itemBuilder: (context, index) => _buildTemplateCard(
                            templates[index],
                            null,
                            key: ValueKey('uncat-edit-${templates[index].id}'),
                            index: index,
                          ),
                        )
                      else
                        ...templates.map((template) => _buildTemplateCard(template, null)),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewFolder,
        icon: const Icon(Icons.folder_open),
        label: const Text('New Folder'),
      ),
    );
  }

  Widget _buildFolderSection(
    TemplateFolder folder, {
    Key? key,
    int? index,
  }) {
    final isExpanded = _expandedFolders.contains(folder.id);
    final templatesAsync = ref.watch(templatesInFolderProvider(folder.id));
    final folderColor = folder.color != null
        ? Color(int.parse(folder.color!))
        : Theme.of(context).colorScheme.primary;

    return DragTarget<String>(
      key: key,
      onAcceptWithDetails: (details) {
        _moveTemplate(details.data, folder.id);
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDraggingOver
              ? folderColor.withOpacity(0.2)
              : null,
          elevation: isDraggingOver ? 8 : 1,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedFolders.remove(folder.id);
                    } else {
                      _expandedFolders.add(folder.id);
                    }
                  });
                },
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  decoration: isDraggingOver
                      ? BoxDecoration(
                          border: Border.all(
                            color: folderColor,
                            width: 2,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          isExpanded ? Icons.folder_open : Icons.folder,
                          color: folderColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                folder.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (folder.description != null && folder.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    folder.description!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        templatesAsync.when(
                          data: (templates) => Chip(
                            label: Text('${templates.length}'),
                            labelStyle: const TextStyle(fontSize: 12),
                            visualDensity: VisualDensity.compact,
                          ),
                          loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (_, __) => const Icon(Icons.error_outline, size: 20),
                        ),
                        const SizedBox(width: 8),
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
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showFolderMenu(context, folder),
                            iconSize: 20,
                          ),
                        ] else
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isExpanded)
                templatesAsync.when(
                  data: (templates) {
                    if (templates.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No templates in this folder',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                          ),
                        ),
                      );
                    }

                    if (_isEditing) {
                      return ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: templates.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) newIndex--;
                          
                          final reorderedList = List<WorkoutTemplate>.from(templates);
                          final item = reorderedList.removeAt(oldIndex);
                          reorderedList.insert(newIndex, item);

                          // Persist in background (no need to invalidate - ReorderableListView handles UI)
                          final actions = ref.read(templateActionsProvider);
                          actions.reorderTemplates(reorderedList, folder.id);
                        },
                        itemBuilder: (context, index) => _buildTemplateCard(
                          templates[index],
                          folder.id,
                          key: ValueKey('${folder.id}-edit-${templates[index].id}'),
                          index: index,
                        ),
                      );
                    }

                    return Column(
                      children: templates
                          .map((template) => _buildTemplateCard(template, folder.id))
                          .toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: Text('Error: $error')),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateCard(
    WorkoutTemplate template,
    String? folderId, {
    Key? key,
    int? index,
  }) {
    // In edit mode with reordering, show drag handle instead of long-press draggable
    if (_isEditing && index != null) {
      return Container(
        key: key,
        child: _buildTemplateCardWithDragHandle(template, folderId, index),
      );
    }
    
    return LongPressDraggable<String>(
      key: key,
      data: template.id,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(template.category),
                color: _getCategoryColor(template.category),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  template.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTemplateCardContent(template, folderId),
      ),
      child: _buildTemplateCardContent(template, folderId),
    );
  }

  Widget _buildTemplateCardWithDragHandle(
    WorkoutTemplate template,
    String? folderId,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _startWorkout(template.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(template.category).withOpacity(0.1),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (template.description?.isNotEmpty == true)
                      Text(
                        template.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showTemplateMenu(context, template, folderId),
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCardContent(WorkoutTemplate template, String? folderId) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _isEditing ? null : () => _startWorkout(template.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(template.category).withOpacity(0.1),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (template.description != null && template.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          template.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (template.estimatedDurationMinutes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${template.estimatedDurationMinutes} min',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showTemplateMenu(context, template, folderId),
                  iconSize: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewFolder() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreateFolderDialog(),
    );

    if (result != null && mounted) {
      try {
        await ref.read(templateFolderNotifierProvider.notifier).createFolder(
              name: result['name'],
              description: result['description'],
              color: result['color'],
            );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Folder "${result['name']}" created')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating folder: $e')),
          );
        }
      }
    }
  }

  void _showFolderMenu(BuildContext context, TemplateFolder folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename Folder'),
              onTap: () {
                Navigator.pop(context);
                _renameFolder(folder);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Folder', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteFolder(folder);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _renameFolder(TemplateFolder folder) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateFolderDialog(
        folderId: folder.id,
        initialName: folder.name,
        initialDescription: folder.description,
      ),
    );

    if (result != null && mounted) {
      try {
        await ref.read(templateFolderNotifierProvider.notifier).updateFolder(
              folderId: folder.id,
              name: result['name'],
              description: result['description'],
              color: result['color'],
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating folder: $e')),
          );
        }
      }
    }
  }

  void _deleteFolder(TemplateFolder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"?\n\n'
          'Templates in this folder will be moved to Uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(templateFolderNotifierProvider.notifier).deleteFolder(folder.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting folder: $e')),
          );
        }
      }
    }
  }

  void _showTemplateMenu(BuildContext context, WorkoutTemplate template, String? currentFolderId) async {
    final foldersAsync = ref.read(templateFoldersProvider);
    
    await foldersAsync.when(
      data: (folders) async {
        await showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Move to Folder',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(height: 1),
                if (currentFolderId != null)
                  ListTile(
                    leading: const Icon(Icons.folder_off),
                    title: const Text('Remove from Folder'),
                    onTap: () {
                      Navigator.pop(context);
                      _moveTemplate(template.id, null);
                    },
                  ),
                ...folders
                    .where((f) => f.id != currentFolderId)
                    .map((folder) => ListTile(
                          leading: Icon(
                            Icons.folder,
                            color: folder.color != null
                                ? Color(int.parse(folder.color!))
                                : null,
                          ),
                          title: Text(folder.name),
                          onTap: () {
                            Navigator.pop(context);
                            _moveTemplate(template.id, folder.id);
                          },
                        )),
                if (folders.where((f) => f.id != currentFolderId).isEmpty && currentFolderId != null)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No other folders available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  void _moveTemplate(String templateId, String? folderId) async {
    try {
      await ref.read(templateFolderNotifierProvider.notifier).moveTemplateToFolder(
            templateId: templateId,
            folderId: folderId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              folderId == null
                  ? 'Template moved to Uncategorized'
                  : 'Template moved to folder',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error moving template: $e')),
        );
      }
    }
  }

  void _startWorkout(String templateId) {
    context.push('/active-workout?templateId=$templateId');
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Colors.red;
      case 'cardio':
        return Colors.blue;
      case 'flexibility':
        return Colors.green;
      case 'sports':
        return Colors.orange;
      case 'custom':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      case 'sports':
        return Icons.sports_basketball;
      case 'custom':
        return Icons.edit_note;
      default:
        return Icons.folder_outlined;
    }
  }
}
