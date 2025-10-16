import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../providers/template_folder_provider.dart';

/// Dialog for selecting a folder to optimize
class FolderSelectionDialog extends HookConsumerWidget {
  const FolderSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(templateFoldersProvider);

    return AlertDialog(
      title: const Text('Select Folder to Optimize'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: foldersAsync.when(
          data: (folders) {
            if (folders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No folders found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create some workout templates and organize them into folders first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return _buildFolderItem(context, ref, folder);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load folders',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(templateFoldersProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildFolderItem(BuildContext context, WidgetRef ref, TemplateFolder folder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: folder.color != null 
                ? Color(int.parse(folder.color!.replaceFirst('#', '0xff')))
                : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.folder,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          folder.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: folder.description != null && folder.description!.isNotEmpty
            ? Text(folder.description!)
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).pop(folder.id);
        },
      ),
    );
  }
}
