import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/workout/domain/models/active_workout.dart';
import '../database/database.dart';

/// Wrapper class for checkpoint data with metadata
class CheckpointData {
  CheckpointData({
    required this.id,
    required this.workout,
    required this.lastSavedAt,
  });
  final String id;
  final ActiveWorkout workout;
  final DateTime lastSavedAt;
}

/// Service for automatically saving workout progress to prevent data loss
/// Implements periodic checkpointing and resume functionality
class WorkoutCheckpointService {
  WorkoutCheckpointService(this.database);
  final AppDatabase database;
  Timer? _autoSaveTimer;
  String? _currentCheckpointId;

  /// Start auto-save timer for active workout
  /// Saves every 2 minutes to balance between safety and performance
  void startAutoSave(ActiveWorkout workout) {
    _currentCheckpointId = workout.id;

    // Cancel existing timer if any
    _autoSaveTimer?.cancel();

    // Save immediately on start
    _saveCheckpoint(workout);

    // Then save every 2 minutes
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _saveCheckpoint(workout);
    });

    print('✅ Auto-save started for workout: ${workout.name}');
  }

  /// Save workout checkpoint immediately (called on app minimize/pause)
  Future<void> saveCheckpoint(ActiveWorkout workout) async {
    await _saveCheckpoint(workout);
    print('💾 Manual checkpoint saved');
  }

  /// Stop auto-save and clean up
  Future<void> stopAutoSave({bool deleteCheckpoint = true}) async {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;

    if (deleteCheckpoint && _currentCheckpointId != null) {
      await _deleteCheckpoint(_currentCheckpointId!);
      print('🗑️ Checkpoint deleted - workout completed normally');
    }

    _currentCheckpointId = null;
  }

  /// Internal save method
  Future<void> _saveCheckpoint(ActiveWorkout workout) async {
    try {
      final workoutJson = jsonEncode(workout.toJson());

      await database.into(database.workoutCheckpoints).insertOnConflictUpdate(
            WorkoutCheckpointsCompanion.insert(
              id: workout.id,
              workoutName: workout.name,
              workoutData: workoutJson,
              lastSavedAt: DateTime.now(),
              startedAt: DateTime.now().subtract(workout.elapsedTime),
              elapsedSeconds: workout.elapsedTime.inSeconds,
            ),
          );

      print(
        '💾 Checkpoint saved: ${workout.name} (${workout.elapsedTime.inMinutes}min)',
      );
    } catch (e) {
      print('❌ Failed to save checkpoint: $e');
    }
  }

  /// Get the most recent incomplete workout checkpoint
  /// Get the latest saved checkpoint with metadata
  Future<CheckpointData?> getLatestCheckpoint() async {
    try {
      final checkpoint = await (database.select(database.workoutCheckpoints)
            ..orderBy([(t) => OrderingTerm.desc(t.lastSavedAt)])
            ..limit(1))
          .getSingleOrNull();

      if (checkpoint == null) return null;

      // Parse JSON back to ActiveWorkout
      final workoutJson =
          jsonDecode(checkpoint.workoutData) as Map<String, dynamic>;
      final workout = ActiveWorkout.fromJson(workoutJson);

      print(
        '📦 Found checkpoint: ${workout.name} from ${checkpoint.lastSavedAt}',
      );

      return CheckpointData(
        id: checkpoint.id,
        workout: workout,
        lastSavedAt: checkpoint.lastSavedAt,
      );
    } catch (e) {
      print('❌ Failed to load checkpoint: $e');
      return null;
    }
  }

  /// Delete a specific checkpoint
  Future<void> deleteCheckpoint(String checkpointId) async {
    await _deleteCheckpoint(checkpointId);
  }

  /// Internal delete method
  Future<void> _deleteCheckpoint(String checkpointId) async {
    try {
      await (database.delete(database.workoutCheckpoints)
            ..where((t) => t.id.equals(checkpointId)))
          .go();
    } catch (e) {
      print('❌ Failed to delete checkpoint: $e');
    }
  }

  /// Delete all old checkpoints (older than 7 days)
  Future<void> cleanupOldCheckpoints() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      await (database.delete(database.workoutCheckpoints)
            ..where((t) => t.lastSavedAt.isSmallerThanValue(cutoffDate)))
          .go();
      print('🧹 Old checkpoints cleaned up');
    } catch (e) {
      print('❌ Failed to cleanup checkpoints: $e');
    }
  }

  void dispose() {
    _autoSaveTimer?.cancel();
  }
}
