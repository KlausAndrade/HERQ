import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database.dart';
import '../providers/database_provider.dart';
import '../services/global_content_sync_service.dart';

/// Provider for global content sync service
final globalContentSyncServiceProvider = Provider<GlobalContentSyncService?>((ref) {
  final database = ref.watch(databaseProvider);
  if (database == null) return null;
  
  return GlobalContentSyncService(
    Supabase.instance.client,
    database,
  );
});

/// Provider to check if global content sync is needed
final needsGlobalContentSyncProvider = FutureProvider<bool>((ref) async {
  final syncService = ref.watch(globalContentSyncServiceProvider);
  if (syncService == null) return false;
  
  return await syncService.needsGlobalContentUpdate();
});

/// Provider to trigger global content sync
final globalContentSyncTriggerProvider = StateNotifierProvider<GlobalContentSyncNotifier, bool>((ref) {
  return GlobalContentSyncNotifier(ref);
});

class GlobalContentSyncNotifier extends StateNotifier<bool> {
  GlobalContentSyncNotifier(this._ref) : super(false);
  final Ref _ref;

  /// Trigger global content sync
  Future<void> syncGlobalContent() async {
    if (state) return; // Already syncing
    
    state = true;
    
    try {
      final syncService = _ref.read(globalContentSyncServiceProvider);
      if (syncService != null) {
        await syncService.syncAllGlobalContent();
      }
    } catch (e) {
      print('❌ Error syncing global content: $e');
    } finally {
      state = false;
    }
  }

  /// Sync only global exercises
  Future<void> syncGlobalExercises() async {
    if (state) return;
    
    state = true;
    
    try {
      final syncService = _ref.read(globalContentSyncServiceProvider);
      if (syncService != null) {
        await syncService.syncGlobalExercises();
      }
    } catch (e) {
      print('❌ Error syncing global exercises: $e');
    } finally {
      state = false;
    }
  }

  /// Sync only global templates
  Future<void> syncGlobalTemplates() async {
    if (state) return;
    
    state = true;
    
    try {
      final syncService = _ref.read(globalContentSyncServiceProvider);
      if (syncService != null) {
        await syncService.syncGlobalTemplates();
      }
    } catch (e) {
      print('❌ Error syncing global templates: $e');
    } finally {
      state = false;
    }
  }
}
