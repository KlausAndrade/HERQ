import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database.dart';
import '../core/providers/database_provider.dart';

// Provider for all template folders
final templateFoldersProvider = StreamProvider<List<TemplateFolder>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return (database.select(database.templateFolders)
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .watch();
});

// Provider for managing template folder operations
final templateFolderNotifierProvider =
    StateNotifierProvider<TemplateFolderNotifier, AsyncValue<void>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return TemplateFolderNotifier(database);
});

class TemplateFolderNotifier extends StateNotifier<AsyncValue<void>> {
  TemplateFolderNotifier(this._database) : super(const AsyncValue.data(null));
  final AppDatabase _database;

  // Create a new folder
  Future<TemplateFolder> createFolder({
    required String name,
    String? description,
    String? color,
  }) async {
    state = const AsyncValue.loading();
    try {
      final folderId = const Uuid().v4();
      final folder = TemplateFoldersCompanion.insert(
        id: folderId,
        name: name,
        description: Value(description),
        color: Value(color),
      );

      await _database.into(_database.templateFolders).insert(folder);

      final createdFolder = await (_database.select(_database.templateFolders)
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
    state = const AsyncValue.loading();
    try {
      await (_database.update(_database.templateFolders)
            ..where((t) => t.id.equals(folderId)))
          .write(
        TemplateFoldersCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          description:
              description != null ? Value(description) : const Value.absent(),
          color: color != null ? Value(color) : const Value.absent(),
          isExpanded:
              isExpanded != null ? Value(isExpanded) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Delete folder
  Future<void> deleteFolder(String folderId) async {
    state = const AsyncValue.loading();
    try {
      // First, remove folderId from all templates in this folder
      await (_database.update(_database.workoutTemplates)
            ..where((t) => t.folderId.equals(folderId)))
          .write(
        const WorkoutTemplatesCompanion(
          folderId: Value(null),
        ),
      );

      // Then delete the folder
      await (_database.delete(_database.templateFolders)
            ..where((t) => t.id.equals(folderId)))
          .go();

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
    state = const AsyncValue.loading();
    try {
      await (_database.update(_database.workoutTemplates)
            ..where((t) => t.id.equals(templateId)))
          .write(
        WorkoutTemplatesCompanion(
          folderId: Value(folderId),
          updatedAt: Value(DateTime.now()),
        ),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Reorder folders
  Future<void> reorderFolders(List<TemplateFolder> folders) async {
    state = const AsyncValue.loading();
    try {
      for (var i = 0; i < folders.length; i++) {
        final sortValue = i * 2;
        await (_database.update(_database.templateFolders)
              ..where((t) => t.id.equals(folders[i].id)))
            .write(
          TemplateFoldersCompanion(
            sortOrder: Value(sortValue),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateFolderSortOrders(Map<String, int> orders) async {
    if (orders.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      for (final entry in orders.entries) {
        await (_database.update(_database.templateFolders)
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
    StreamProvider.family<List<WorkoutTemplate>, String?>((ref, folderId) {
  final database = ref.watch(databaseProvider)!;

  if (folderId == null) {
    // Return templates not in any folder
    return (database.select(database.workoutTemplates)
          ..where((t) => t.folderId.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  } else {
    // Return templates in the specified folder
    return (database.select(database.workoutTemplates)
          ..where((t) => t.folderId.equals(folderId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }
});
