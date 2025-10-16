import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/services/notification_service.dart';
import '../../../workout/presentation/providers/template_providers.dart';

/// Widget to display optimized folder results with save/replace options
class OptimizedFolderView extends HookConsumerWidget {
  const OptimizedFolderView({
    super.key,
    required this.optimizedData,
    required this.originalFolderId,
    this.onSave,
    this.onReplace,
  });

  final Map<String, dynamic> optimizedData;
  final String originalFolderId;
  final VoidCallback? onSave;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = optimizedData['folder'] as Map<String, dynamic>? ?? {};
    final folderName = folder['name'] as String? ?? 'Optimized Folder';
    final templates = folder['templates'] as List<dynamic>? ?? [];
    final summary = optimizedData['summary'] as String? ?? '';
    final improvements = optimizedData['improvements'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Optimized: $folderName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      summary,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (improvements.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Key Improvements:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...improvements.map((improvement) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              improvement.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Templates list
          Text(
            'Optimized Templates (${templates.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ...templates.map((template) => _buildTemplateCard(context, ref, template)),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _saveAllAsNew(context, ref),
                  child: const Text('Save All as New'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _replaceAll(context, ref),
                  child: const Text('Replace All'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WidgetRef ref, Map<String, dynamic> template) {
    final name = template['name'] as String? ?? 'Unknown Template';
    final description = template['description'] as String? ?? '';
    final exercises = template['exercises'] as List<dynamic>? ?? [];
    final estimatedDuration = template['estimatedDurationMinutes'] as int? ?? 60;
    final changes = template['changes'] as String? ?? '';
    final improvements = template['improvements'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'OPTIMIZED',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${estimatedDuration} min',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${exercises.length} exercises',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (changes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withAlpha((0.3 * 255).round()),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Changes Made:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      changes,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            if (improvements.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Improvements:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              ...improvements.map((improvement) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        improvement.toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _saveTemplateAsNew(context, ref, template),
                    child: const Text('Save as New'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _replaceTemplate(context, ref, template),
                    child: const Text('Replace'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAllAsNew(BuildContext context, WidgetRef ref) async {
    try {
      final templates = optimizedData['folder']?['templates'] as List<dynamic>? ?? [];
      final templateActions = ref.read(templateActionsProvider);
      
      int savedCount = 0;
      for (final template in templates) {
        final success = await _createTemplateFromOptimized(templateActions, template);
        if (success) savedCount++;
      }

      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Saved $savedCount templates',
              body: 'All optimized templates have been saved as new templates.',
            )
            .catchError((_) {});
        
        onSave?.call();
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error saving templates: $e',
              body: '',
            )
            .catchError((_) {});
      }
    }
  }

  Future<void> _replaceAll(BuildContext context, WidgetRef ref) async {
    try {
      final templates = optimizedData['folder']?['templates'] as List<dynamic>? ?? [];
      final templateActions = ref.read(templateActionsProvider);
      
      int replacedCount = 0;
      for (final template in templates) {
        final success = await _updateTemplateFromOptimized(templateActions, template);
        if (success) replacedCount++;
      }

      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Replaced $replacedCount templates',
              body: 'All optimized templates have replaced the originals.',
            )
            .catchError((_) {});
        
        onReplace?.call();
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error replacing templates: $e',
              body: '',
            )
            .catchError((_) {});
      }
    }
  }

  Future<void> _saveTemplateAsNew(BuildContext context, WidgetRef ref, Map<String, dynamic> template) async {
    try {
      final templateActions = ref.read(templateActionsProvider);
      final success = await _createTemplateFromOptimized(templateActions, template);

      if (context.mounted) {
        if (success) {
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Template saved successfully!',
                body: 'Your optimized template has been saved as a new template.',
              )
              .catchError((_) {});
        } else {
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Failed to save template',
                body: 'Please try again.',
              )
              .catchError((_) {});
        }
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error saving template: $e',
              body: '',
            )
            .catchError((_) {});
      }
    }
  }

  Future<void> _replaceTemplate(BuildContext context, WidgetRef ref, Map<String, dynamic> template) async {
    try {
      final templateActions = ref.read(templateActionsProvider);
      final success = await _updateTemplateFromOptimized(templateActions, template);

      if (context.mounted) {
        if (success) {
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Template replaced successfully!',
                body: 'Your optimized template has replaced the original.',
              )
              .catchError((_) {});
        } else {
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Failed to replace template',
                body: 'Please try again.',
              )
              .catchError((_) {});
        }
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error replacing template: $e',
              body: '',
            )
            .catchError((_) {});
      }
    }
  }

  Future<bool> _createTemplateFromOptimized(dynamic templateActions, Map<String, dynamic> template) async {
    try {
      final templateId = 'ai_opt_${DateTime.now().millisecondsSinceEpoch}_${template['id']}';
      final workoutTemplate = WorkoutTemplate(
        id: templateId,
        userId: 'default_user', // TODO: Replace with actual user ID
        name: '${template['name']} (Optimized)',
        description: template['description'] as String? ?? '',
        category: 'AI Optimized',
        sortOrder: 0,
        exerciseIds: (template['exercises'] as List<dynamic>?)
                ?.map((e) => e['id'] as String? ?? '')
                .where((id) => id.isNotEmpty)
                .toList() ??
            [],
        tags: ['ai_optimized', ...(template['tags'] as List<dynamic>? ?? [])],
        estimatedDurationMinutes: template['estimatedDurationMinutes'] as int? ?? 60,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await templateActions.createTemplate(workoutTemplate);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateTemplateFromOptimized(dynamic templateActions, Map<String, dynamic> template) async {
    try {
      // This would require implementing an update method in templateActions
      // For now, we'll create a new template with the original ID
      final templateId = template['id'] as String? ?? 'unknown';
      final workoutTemplate = WorkoutTemplate(
        id: templateId,
        userId: 'default_user', // TODO: Replace with actual user ID
        name: template['name'] as String? ?? 'Optimized Template',
        description: template['description'] as String? ?? '',
        category: 'AI Optimized',
        sortOrder: 0,
        exerciseIds: (template['exercises'] as List<dynamic>?)
                ?.map((e) => e['id'] as String? ?? '')
                .where((id) => id.isNotEmpty)
                .toList() ??
            [],
        tags: ['ai_optimized', ...(template['tags'] as List<dynamic>? ?? [])],
        estimatedDurationMinutes: template['estimatedDurationMinutes'] as int? ?? 60,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await templateActions.createTemplate(workoutTemplate);
    } catch (e) {
      return false;
    }
  }
}
