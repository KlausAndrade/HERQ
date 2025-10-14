import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';

/// Provider for user's favorite exercises
final favoritesProvider = StreamProvider<List<ExerciseFavorite>>((ref) {
  final database = ref.watch(databaseProvider);
  final user = ref.watch(currentUserProvider);

  if (database == null || user == null) {
    return Stream.value([]);
  }

  return (database.select(database.exerciseFavorites)
        ..where((tbl) => tbl.userId.equals(user.id)))
      .watch();
});

/// Provider to check if an exercise is favorited
final isExerciseFavorited =
    Provider.family<AsyncValue<bool>, String>((ref, exerciseId) {
  final favoritesAsync = ref.watch(favoritesProvider);

  return favoritesAsync.when(
    data: (favorites) => AsyncValue.data(
      favorites.any((fav) => fav.exerciseId == exerciseId),
    ),
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

/// Provider for favorite exercise IDs (for quick lookups)
final favoriteExerciseIdsProvider = Provider<Set<String>>((ref) {
  final favoritesAsync = ref.watch(favoritesProvider);

  return favoritesAsync.maybeWhen(
    data: (favorites) => favorites.map((f) => f.exerciseId).toSet(),
    orElse: () => {},
  );
});

/// Provider for favorite exercises with full details
final favoriteExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final database = ref.watch(databaseProvider);
  final favoriteIds = ref.watch(favoriteExerciseIdsProvider);

  if (database == null || favoriteIds.isEmpty) {
    return [];
  }

  return (database.select(database.exercises)
        ..where((tbl) => tbl.id.isIn(favoriteIds)))
      .get();
});

/// Notifier for managing favorite exercises
final favoritesNotifierProvider = Provider<FavoritesNotifier>((ref) {
  final database = ref.watch(databaseProvider);
  final user = ref.watch(currentUserProvider);

  return FavoritesNotifier(database, user?.id);
});

class FavoritesNotifier {
  FavoritesNotifier(this._database, this._userId);
  final AppDatabase? _database;
  final String? _userId;

  /// Toggle favorite status for an exercise
  Future<void> toggleFavorite(String exerciseId) async {
    final db = _database;
    final userId = _userId;

    if (db == null || userId == null) {
      throw Exception('Database or user not available');
    }

    // Check if already favorited
    final existing = await (db.select(db.exerciseFavorites)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.exerciseId.equals(exerciseId),
          ))
        .getSingleOrNull();

    if (existing != null) {
      // Remove from favorites
      await (db.delete(db.exerciseFavorites)
            ..where(
              (tbl) =>
                  tbl.userId.equals(userId) & tbl.exerciseId.equals(exerciseId),
            ))
          .go();
    } else {
      // Add to favorites
      await db.into(db.exerciseFavorites).insert(
            ExerciseFavoritesCompanion(
              userId: Value(userId),
              exerciseId: Value(exerciseId),
            ),
          );
    }
  }

  /// Add exercise to favorites
  Future<void> addFavorite(String exerciseId) async {
    final db = _database;
    final userId = _userId;

    if (db == null || userId == null) {
      throw Exception('Database or user not available');
    }

    await db.into(db.exerciseFavorites).insert(
          ExerciseFavoritesCompanion(
            userId: Value(userId),
            exerciseId: Value(exerciseId),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Remove exercise from favorites
  Future<void> removeFavorite(String exerciseId) async {
    final db = _database;
    final userId = _userId;

    if (db == null || userId == null) {
      throw Exception('Database or user not available');
    }

    await (db.delete(db.exerciseFavorites)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.exerciseId.equals(exerciseId),
          ))
        .go();
  }

  /// Check if exercise is favorited
  Future<bool> isFavorited(String exerciseId) async {
    final db = _database;
    final userId = _userId;

    if (db == null || userId == null) {
      return false;
    }

    final result = await (db.select(db.exerciseFavorites)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.exerciseId.equals(exerciseId),
          ))
        .getSingleOrNull();

    return result != null;
  }
}
