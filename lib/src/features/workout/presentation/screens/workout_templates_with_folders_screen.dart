import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/database/database.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../providers/template_folder_provider.dart';
import '../../../workouts/widgets/create_folder_dialog.dart';
import '../providers/template_providers.dart';

/// Drag item type used to indicate what kind of object is being dragged.
enum _DragItemType { exercise }

/// Data class describing a dragged item. For now only exercises are draggable.
class _DragItemData {
  const _DragItemData.exercise(this.templateId, this.sourceFolderId)
      : type = _DragItemType.exercise;

  final _DragItemType type;
  final String templateId;
  final String? sourceFolderId;
}

/// Screen showing workout templates organized by folders with basic drag and drop support.
///
/// Users can drag exercises onto folders to move them. Dragging a template onto another
/// folder will remove it from its current folder (if any) and add it to the new one.
/// Folder reordering and root-level reordering still use ReorderableListView in edit mode.
class WorkoutTemplatesWithFoldersScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesWithFoldersScreen({
    super.key,
    this.isEditing = true,
  });

  final bool isEditing;

  @override
  ConsumerState<WorkoutTemplatesWithFoldersScreen> createState() =>
      _WorkoutTemplatesWithFoldersScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isEditing', isEditing));
  }
}

class _WorkoutTemplatesWithFoldersScreenState
    extends ConsumerState<WorkoutTemplatesWithFoldersScreen> {
  late bool _isEditing;
  final Set<String> _expandedFolders = {};
  bool _isAdminMode = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing;
    // Check if we're in admin mode from URL parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      _isAdminMode = uri.queryParameters['admin'] == 'true';
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant WorkoutTemplatesWithFoldersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEditing != widget.isEditing) {
      setState(() {
        _isEditing = widget.isEditing;
      });
    }
  }

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
        title: Row(
          children: [
            Text(
              _isEditing
                  ? S.of(context)?.workoutTemplates ?? 'Workout Templates'
                  : S.of(context)?.selectWorkout ?? 'Select Workout',
            ),
            if (_isAdminMode) ...[
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
              // Folders - with reordering support in edit mode
              if (_isEditing && foldersList.isNotEmpty)
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: foldersList.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex--;
                    final reorderedList =
                        List<TemplateFolder>.from(foldersList);
                    final item = reorderedList.removeAt(oldIndex);
                    reorderedList.insert(newIndex, item);
                    final actions = ref.read(templateActionsProvider);
                    actions.reorderFolders(reorderedList);
                  },
                  itemBuilder: (context, index) => _buildFolderSection(
                    foldersList[index],
                    key: ValueKey('folder-edit-${foldersList[index].id}'),
                    index: index,
                  ),
                )
              else
                ...foldersList.map(
                  (folder) => _buildFolderSection(
                    folder,
                    key: ValueKey('folder-view-${folder.id}'),
                  ),
                ),
              // Unfoldered Templates - wrapped in DragTarget to allow dropping
              unfoldered.when(
                data: (templates) => _buildUncategorizedSection(
                    templates as List<WorkoutTemplate>),
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
        label: Text(S.of(context)?.newFolder ?? 'New Folder'),
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
    Color folderColor;
    if (folder.color != null && folder.color!.isNotEmpty) {
      try {
        folderColor = Color(int.parse(folder.color!));
      } catch (e) {
        folderColor = Theme.of(context).colorScheme.primary;
      }
    } else {
      folderColor = Theme.of(context).colorScheme.primary;
    }

    // Only the folder header is a DragTarget for move-to-folder
    return DragTarget<_DragItemData>(
      key: key,
      onWillAcceptWithDetails: (details) =>
          details.data.type == _DragItemType.exercise &&
          details.data.sourceFolderId != folder.id,
      onAcceptWithDetails: (details) {
        _moveTemplate(details.data.templateId, folder);
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDraggingOver ? folderColor.withOpacity(0.2) : null,
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: DecoratedBox(
                  decoration: isDraggingOver
                      ? BoxDecoration(
                          border: Border.all(
                            color: folderColor,
                            width: 2,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        )
                      : const BoxDecoration(),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (folder.description != null &&
                                  folder.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    folder.description!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
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
                          error: (_, __) =>
                              const Icon(Icons.error_outline, size: 20),
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'No templates in this folder',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to template builder with folder preselected
                                  final folderId =
                                      Uri.encodeComponent(folder.id);
                                  context.push(
                                    '/template-builder?folderId=$folderId',
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create Template'),
                              ),
                            ],
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
                          final reorderedList =
                              List<WorkoutTemplate>.from(templates);
                          final item = reorderedList.removeAt(oldIndex);
                          reorderedList.insert(newIndex, item);
                          final actions = ref.read(templateActionsProvider);
                          actions.reorderTemplates(reorderedList, folder.id);
                        },
                        itemBuilder: (context, index) => _buildTemplateCard(
                          templates[index],
                          folder.id,
                          key: ValueKey(
                            '${folder.id}-edit-${templates[index].id}',
                          ),
                          index: index,
                        ),
                      );
                    }
                    return Column(
                      children: templates
                          .map(
                            (template) => _buildTemplateCard(
                              template,
                              folder.id,
                            ),
                          )
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

  /// Builds the Uncategorized section as a DragTarget. This allows dropping
  /// templates from folders into the uncategorized list.
  Widget _buildUncategorizedSection(List<WorkoutTemplate> templates) {
    // Always show when dragging, even if empty
    return DragTarget<_DragItemData>(
      onWillAcceptWithDetails: (details) =>
          details.data.type == _DragItemType.exercise &&
          details.data.sourceFolderId != null,
      onAcceptWithDetails: (details) {
        _moveTemplate(details.data.templateId, null);
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;

        // If empty and not dragging, hide the section
        if (templates.isEmpty && !isDraggingOver) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDraggingOver
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
          elevation: isDraggingOver ? 4 : 1,
          child: DecoratedBox(
            decoration: isDraggingOver
                ? BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  )
                : const BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        color: isDraggingOver
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isDraggingOver
                              ? 'Drop to move to Uncategorized'
                              : 'Uncategorized',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isDraggingOver
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                    fontWeight: isDraggingOver
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                        ),
                      ),
                      if (templates.isNotEmpty)
                        Chip(
                          label: Text('${templates.length}'),
                          labelStyle: const TextStyle(fontSize: 12),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
                if (templates.isEmpty && isDraggingOver)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Text(
                        'Drop here to remove from folder',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  )
                else if (templates.isNotEmpty) ...[
                  if (_isEditing)
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: templates.length,
                      onReorder: (oldIndex, newIndex) async {
                        if (newIndex > oldIndex) newIndex--;
                        final reorderedList =
                            List<WorkoutTemplate>.from(templates);
                        final item = reorderedList.removeAt(oldIndex);
                        reorderedList.insert(newIndex, item);
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
                    ...templates
                        .map((template) => _buildTemplateCard(template, null)),
                ],
              ],
            ),
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
    // In edit mode with index, use drag handle for reordering within same container
    if (_isEditing && index != null) {
      return Container(
        key: key,
        child: _buildTemplateCardWithDragHandle(template, folderId, index),
      );
    }

    // In view mode or edit mode without index, allow drag to move between containers
    return LongPressDraggable<_DragItemData>(
      key: key,
      data: _DragItemData.exercise(template.id, folderId),
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
    // In edit mode: show drag handle for reordering, but also allow long press to move between folders
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Use LongPressDraggable on the whole card (except drag handle) to move between folders
          Expanded(
            child: LongPressDraggable<_DragItemData>(
              data: _DragItemData.exercise(template.id, folderId),
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                child: _buildEditModeCardContent(template, folderId),
              ),
              child: _buildEditModeCardContent(template, folderId),
            ),
          ),
          // Drag handle for reordering within the same list
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
        ],
      ),
    );
  }

  Widget _buildEditModeCardContent(
    WorkoutTemplate template,
    String? folderId,
  ) =>
      InkWell(
        onTap: () {
          context.push('/template-builder?templateId=${template.id}');
        },
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (template.description?.isNotEmpty ?? false)
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
            ],
          ),
        ),
      );

  Widget _buildTemplateCardContent(
    WorkoutTemplate template,
    String? folderId,
  ) =>
      Card(
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      if (template.description != null &&
                          template.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            template.description!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
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
                    onPressed: () => _showTemplateMenu(context, template),
                    icon: const Icon(Icons.more_vert),
                    iconSize: 20,
                  ),
              ],
            ),
          ),
        ),
      );

  Future<void> _createNewFolder() async {
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
          try {
            await NotificationService().showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Folder "${result['name']}" created',
              body: '',
            );
          } catch (_) {}
        }
      } catch (e) {
        if (mounted) {
          try {
            await NotificationService().showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error creating folder: $e',
              body: '',
            );
          } catch (_) {}
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
              title: const Text(
                'Delete Folder',
                style: TextStyle(color: Colors.red),
              ),
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

  Future<void> _renameFolder(TemplateFolder folder) async {
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
          try {
            await NotificationService().showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Folder updated',
              body: '',
            );
          } catch (_) {}
        }
      } catch (e) {
        if (mounted) {
          try {
            await NotificationService().showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error updating folder: $e',
              body: '',
            );
          } catch (_) {}
        }
      }
    }
  }

  Future<void> _deleteFolder(TemplateFolder folder) async {
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
        await ref
            .read(templateFolderNotifierProvider.notifier)
            .deleteFolder(folder.id);
        if (mounted) {
          try {
            await NotificationService().showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Folder deleted',
              body: '',
            );
          } catch (_) {}
        }
      } catch (e) {
        if (mounted) {
          try {
            await NotificationService().showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error deleting folder: $e',
              body: '',
            );
          } catch (_) {}
        }
      }
    }
  }

  Future<void> _moveTemplate(String templateId, TemplateFolder? folder) async {
    // Move a template to a new folder (null folder indicates root).
    try {
      await ref
          .read(templateFolderNotifierProvider.notifier)
          .moveTemplateToFolder(
            templateId: templateId,
            folderId: folder?.id,
          );
      if (mounted) {
        // Publish a curated in-app notification for template moves. We intentionally
        // avoid the SnackBar fallback here to make the in-app overlay the primary
        // feedback channel for this interaction.
        try {
          await NotificationService().showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: folder == null
                ? 'Template moved to Uncategorized'
                : 'Template moved to ${folder.name}',
            body: '',
          );
        } catch (_) {
          // Best-effort: ignore failures in test/headless environments.
        }
      }
    } catch (e) {
      if (mounted) {
        try {
          await NotificationService().showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Error moving template',
            body: 'Error moving template: $e',
            backgroundColor: Colors.red,
          );
        } catch (_) {}
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

  void _showTemplateMenu(BuildContext context, WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
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
            title: const Text('Move to Folder'),
            onTap: () {
              Navigator.of(context).pop();
              _showMoveToFolderDialog(context, template);
            },
          ),
          if (_canDeleteTemplate(template))
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

  void _showRenameDialog(BuildContext context, WorkoutTemplate template) {
    final controller = TextEditingController(text: template.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Template'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Template Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _renameTemplate(template.id, controller.text.trim());
                Navigator.pop(context);
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
            labelText: 'New Template Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _duplicateTemplate(template.id, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
  }

  void _showMoveToFolderDialog(BuildContext context, WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Uncategorized'),
              onTap: () {
                Navigator.pop(context);
                _moveTemplate(template.id, null);
              },
            ),
            ...ref.read(templateFoldersProvider).when(
                  data: (folders) => folders.map((folder) => ListTile(
                        title: Text(folder.name),
                        onTap: () {
                          Navigator.pop(context);
                          _moveTemplate(template.id, folder);
                        },
                      )),
                  loading: () => [const ListTile(title: Text('Loading...'))],
                  error: (_, __) =>
                      [const ListTile(title: Text('Error loading folders'))],
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
          'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
        ),
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

  Future<void> _renameTemplate(String templateId, String newName) async {
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

  Future<void> _duplicateTemplate(String templateId, String newName) async {
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

  Future<void> _deleteTemplate(String templateId) async {
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

  bool _canDeleteTemplate(WorkoutTemplate template) {
    // System template IDs that should not be deletable
    const systemTemplateIds = {
      'ppl_push',
      'ppl_pull',
      'ppl_legs',
      'phul_upper_power',
      'phul_lower_power',
      'phul_upper_hyp',
      'phul_lower_hyp',
      'full_body_beginner',
      'full_body_intermediate',
      'full_body_advanced',
      'upper_lower_upper',
      'upper_lower_lower',
      'strength_beginner',
      'strength_intermediate',
      'strength_advanced',
      'bodybuilding_chest',
      'bodybuilding_back',
      'bodybuilding_legs',
      'bodybuilding_arms',
    };

    // Don't allow deletion of system templates
    if (systemTemplateIds.contains(template.id)) {
      return false;
    }

    // Allow deletion of AI-generated templates (start with 'ai_gen_')
    if (template.id.startsWith('ai_gen_')) {
      return true;
    }

    // Allow deletion of user-created templates (not system templates)
    // This is a fallback for any other user-created templates
    return true;
  }
}
