import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database.dart';
import '../core/providers/database_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/user_context_service.dart';
import '../features/workout/presentation/providers/template_web_provider.dart';

// Provider for all template folders
final templateFoldersProvider = StreamProvider<List<dynamic>>((ref) async* {
  // On web, fetch from Supabase
  if (kIsWeb) {
    final folders = await ref.watch(foldersWebProvider.future);
    yield folders;
    return;
  }

  final database = ref.watch(databaseProvider);

  // On mobile, if database is null, return empty list
  if (database == null) {
    yield [];
    return;
  }

  try {
    await for (final folders in (database.select(database.templateFolders)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch()) {
      yield folders;
    }
  } catch (e) {
    print('Error accessing template folders: $e');
    yield [];
  }
});

// Provider for managing template folder operations
final templateFolderNotifierProvider =
    StateNotifierProvider<TemplateFolderNotifier, AsyncValue<void>>((ref) {
  final database = ref.watch(databaseProvider);
  final supabase = ref.watch(supabaseClientProvider);

  // On web, database is null - return a stub notifier
  if (kIsWeb || database == null) {
    return TemplateFolderNotifier(null, supabase);
  }

  return TemplateFolderNotifier(database, supabase);
});

class TemplateFolderNotifier extends StateNotifier<AsyncValue<void>> {
  TemplateFolderNotifier(this._database, this._supabase)
      : super(const AsyncValue.data(null));
  final AppDatabase? _database;
  final SupabaseClient _supabase;

  // Create a new folder
  Future<TemplateFolder> createFolder({
    required String name,
    String? description,
    String? color,
  }) async {
    final db = _database;
    if (db == null) {
      throw UnimplementedError('Template folders not available on web yet');
    }

    state = const AsyncValue.loading();
    try {
      final folderId = const Uuid().v4();
      final now = DateTime.now();

      final folder = TemplateFoldersCompanion.insert(
        id: folderId,
        userId: Value(
            UserContextService.instance.getCurrentUserId()), // ✅ USER ISOLATION
        name: name,
        description: Value(description),
        color: Value(color),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      // Save to local database
      await db.into(db.templateFolders).insert(folder);

      // 🌩️ Sync to Supabase
      try {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          await _supabase.from('template_folders').insert({
            'id': folderId,
            'user_id': user.id,
            'name': name,
            'description': description,
            'color': color,
            'sort_order': 0,
            'is_expanded': true,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
          print('✅ Folder synced to Supabase');
        }
      } catch (syncError) {
        print('⚠️ Folder cloud sync failed: $syncError');
      }

      final createdFolder = await (db.select(db.templateFolders)
            ..where((t) => t.id.equals(folderId)))
          .getSingle();

      state = const AsyncValue.data(null);
      return createdFolder;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Update folder
  Future<void> updateFolder({
    required String folderId,
    String? name,
    String? description,
    String? color,
    bool? isExpanded,
  }) async {
    final db = _database;
    if (db == null) {
      throw UnimplementedError('Template folders not available on web yet');
    }

    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();

      await (db.update(db.templateFolders)..where((t) => t.id.equals(folderId)))
          .write(
        TemplateFoldersCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          description:
              description != null ? Value(description) : const Value.absent(),
          color: color != null ? Value(color) : const Value.absent(),
          isExpanded:
              isExpanded != null ? Value(isExpanded) : const Value.absent(),
          updatedAt: Value(now),
        ),
      );

      // 🌩️ Sync to Supabase
      try {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          final updateData = <String, dynamic>{
            'updated_at': now.toIso8601String(),
          };

          if (name != null) updateData['name'] = name;
          if (description != null) updateData['description'] = description;
          if (color != null) updateData['color'] = color;
          if (isExpanded != null) updateData['is_expanded'] = isExpanded;

          await _supabase
              .from('template_folders')
              .update(updateData)
              .eq('id', folderId);
          print('✅ Folder update synced to Supabase');
        }
      } catch (syncError) {
        print('⚠️ Folder update sync failed: $syncError');
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Delete folder
  Future<void> deleteFolder(String folderId) async {
    final db = _database;
    if (db == null) {
      throw UnimplementedError('Template folders not available on web yet');
    }

    state = const AsyncValue.loading();
    try {
      // First, remove folderId from all templates in this folder
      await (db.update(db.workoutTemplates)
            ..where((t) => t.folderId.equals(folderId)))
          .write(
        const WorkoutTemplatesCompanion(
          folderId: Value(null),
        ),
      );

      // Then delete the folder
      await (db.delete(db.templateFolders)..where((t) => t.id.equals(folderId)))
          .go();

      // 🌩️ Sync to Supabase
      try {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          // Remove folderId from templates in Supabase
          await _supabase.from('workout_templates').update({
            'folder_id': null,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('folder_id', folderId);

          // Delete the folder from Supabase
          await _supabase.from('template_folders').delete().eq('id', folderId);
          print('✅ Folder deletion synced to Supabase');
        }
      } catch (syncError) {
        print('⚠️ Folder deletion sync failed: $syncError');
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Move template to folder
  Future<void> moveTemplateToFolder({
    required String templateId,
    String? folderId, // null means remove from folder
  }) async {
    final db = _database;
    if (db == null) {
      throw UnimplementedError('Template folders not available on web yet');
    }

    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();

      await (db.update(db.workoutTemplates)
            ..where((t) => t.id.equals(templateId)))
          .write(
        WorkoutTemplatesCompanion(
          folderId: Value(folderId),
          updatedAt: Value(now),
        ),
      );

      // 🌩️ Sync to Supabase
      try {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          await _supabase.from('workout_templates').update({
            'folder_id': folderId,
            'updated_at': now.toIso8601String(),
          }).eq('id', templateId);
          print('✅ Template folder assignment synced to Supabase');
        }
      } catch (syncError) {
        print('⚠️ Template folder assignment sync failed: $syncError');
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Reorder folders
  Future<void> reorderFolders(List<TemplateFolder> folders) async {
    final db = _database;
    if (db == null) {
      throw UnimplementedError('Template folders not available on web yet');
    }

    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();

      for (var i = 0; i < folders.length; i++) {
        final sortValue = i * 2;
        await (db.update(db.templateFolders)
              ..where((t) => t.id.equals(folders[i].id)))
            .write(
          TemplateFoldersCompanion(
            sortOrder: Value(sortValue),
            updatedAt: Value(now),
          ),
        );
      }

      // 🌩️ Sync to Supabase
      try {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          for (var i = 0; i < folders.length; i++) {
            final sortValue = i * 2;
            await _supabase.from('template_folders').update({
              'sort_order': sortValue,
              'updated_at': now.toIso8601String(),
            }).eq('id', folders[i].id);
          }
          print('✅ Folder reordering synced to Supabase');
        }
      } catch (syncError) {
        print('⚠️ Folder reordering sync failed: $syncError');
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateFolderSortOrders(Map<String, int> orders) async {
    if (orders.isEmpty) return;

    final db = _database;
    if (db == null) {
      throw UnimplementedError('Template folders not available on web yet');
    }

    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      for (final entry in orders.entries) {
        await (db.update(db.templateFolders)
              ..where((t) => t.id.equals(entry.key)))
            .write(
          TemplateFoldersCompanion(
            sortOrder: Value(entry.value),
            updatedAt: Value(now),
          ),
        );
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// Provider for templates in a specific folder
final templatesInFolderProvider =
    StreamProvider.family<List<dynamic>, String?>((ref, folderId) async* {
  // On web, fetch from Supabase
  if (kIsWeb) {
    final templates =
        await ref.watch(templatesInFolderWebProvider(folderId).future);
    yield templates;
    return;
  }

  final database = ref.watch(databaseProvider);

  // On mobile, if database is null, return empty list
  if (database == null) {
    yield [];
    return;
  }

  try {
    if (folderId == null) {
      // Return templates not in any folder
      await for (final templates in (database.select(database.workoutTemplates)
            ..where((t) => t.folderId.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch()) {
        yield templates;
      }
    } else {
      // Return templates in the specified folder
      await for (final templates in (database.select(database.workoutTemplates)
            ..where((t) => t.folderId.equals(folderId))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch()) {
        yield templates;
      }
    }
  } catch (e) {
    print('Error accessing templates in folder: $e');
    yield [];
  }
});
