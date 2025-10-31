import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/enhanced_global_content_sync_service.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

/// Provider for enhanced global content sync service
final enhancedGlobalContentSyncServiceProvider =
    Provider<EnhancedGlobalContentSyncService?>((ref) {
      final supabase = ref.watch(supabaseClientProvider);
      final db = ref.watch(databaseProvider);

      if (db == null) return null;

      return EnhancedGlobalContentSyncService(supabase, db);
    });

/// Provider to check if global content sync is needed
final needsGlobalContentSyncProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(enhancedGlobalContentSyncServiceProvider);
  if (service == null) return false;

  return await service.needsGlobalContentUpdate();
});

/// Provider for sync status
final globalContentSyncStatusProvider = FutureProvider<SyncStatus>((ref) async {
  final service = ref.watch(enhancedGlobalContentSyncServiceProvider);
  if (service == null) {
    return const SyncStatus(
      lastSync: null,
      version: null,
      needsUpdate: false,
      error: 'Service not available',
    );
  }

  return await service.getSyncStatus();
});

/// Notifier for triggering global content sync
class GlobalContentSyncNotifier
    extends StateNotifier<AsyncValue<FullSyncResult?>> {
  GlobalContentSyncNotifier(this._service) : super(const AsyncValue.data(null));

  final EnhancedGlobalContentSyncService? _service;

  Future<void> syncGlobalContent() async {
    if (_service == null) {
      state = AsyncValue.error('Service not available', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await _service!.syncAllGlobalContent();
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> forceSyncGlobalContent() async {
    if (_service == null) {
      state = AsyncValue.error('Service not available', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await _service!.forceSyncAllContent();
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearState() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for global content sync notifier
final globalContentSyncNotifierProvider =
    StateNotifierProvider<
      GlobalContentSyncNotifier,
      AsyncValue<FullSyncResult?>
    >((ref) {
      final service = ref.watch(enhancedGlobalContentSyncServiceProvider);
      return GlobalContentSyncNotifier(service);
    });

/// Provider for triggering sync
final globalContentSyncTriggerProvider = Provider<GlobalContentSyncNotifier>((
  ref,
) {
  return ref.watch(globalContentSyncNotifierProvider.notifier);
});
