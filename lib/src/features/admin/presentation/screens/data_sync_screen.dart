import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/exercise_sync_service.dart';

class DataSyncScreen extends ConsumerStatefulWidget {
  const DataSyncScreen({super.key});

  @override
  ConsumerState<DataSyncScreen> createState() => _DataSyncScreenState();
}

class _DataSyncScreenState extends ConsumerState<DataSyncScreen> {
  bool _isSyncing = false;
  String _syncStatus = 'Ready to sync';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Sync'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync Local Data to Supabase',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will upload your local SQLite data to Supabase so it\'s available on web and other devices.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Status: $_syncStatus',
                      style: TextStyle(
                        color: _isSyncing ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sync Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : () => _syncExercises(),
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('Sync Exercises'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : () => _syncTemplates(),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Sync Templates'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : () => _syncFolders(),
                    icon: const Icon(Icons.folder),
                    label: const Text('Sync Folders'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : () => _syncAll(),
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync All'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Make sure you\'re logged in to Supabase\n'
              '2. Click "Sync All" to upload everything\n'
              '3. Check the console for sync progress\n'
              '4. Your data will be available on web after sync',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncExercises() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing exercises...';
    });

    try {
      await ExerciseSyncService.syncLocalExercisesToSupabase(ref);
      setState(() {
        _syncStatus = 'Exercises synced successfully!';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Exercise sync failed: $e';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _syncTemplates() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing templates...';
    });

    try {
      // Need to sync folders first to get ID mapping
      final folderIdMap =
          await ExerciseSyncService.syncLocalFoldersToSupabase(ref);
      await ExerciseSyncService.syncLocalTemplatesToSupabase(ref,
          folderIdMap: folderIdMap);
      setState(() {
        _syncStatus = 'Templates synced successfully!';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Template sync failed: $e';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _syncFolders() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing folders...';
    });

    try {
      await ExerciseSyncService.syncLocalFoldersToSupabase(ref);
      setState(() {
        _syncStatus = 'Folders synced successfully!';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Folder sync failed: $e';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _syncAll() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing all data...';
    });

    try {
      // 1. Sync exercises
      await ExerciseSyncService.syncLocalExercisesToSupabase(ref);
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Sync folders (returns ID mapping)
      final folderIdMap =
          await ExerciseSyncService.syncLocalFoldersToSupabase(ref);
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. Sync templates (using folder ID mapping)
      await ExerciseSyncService.syncLocalTemplatesToSupabase(ref,
          folderIdMap: folderIdMap);

      setState(() {
        _syncStatus = 'All data synced successfully!';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Sync failed: $e';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }
}
