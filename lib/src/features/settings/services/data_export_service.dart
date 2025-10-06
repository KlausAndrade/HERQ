import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../core/database/database.dart';

/// Service for exporting user data
class DataExportService {
  final AppDatabase _database;

  DataExportService(this._database);

  /// Export all user data as JSON
  Future<String> exportAllData() async {
    try {
      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'workouts': await _exportWorkouts(),
        'templates': await _exportTemplates(),
        'exercises': await _exportExercises(),
        'personalRecords': await _exportPersonalRecords(),
      };

      return jsonEncode(data);
    } catch (e) {
      debugPrint('Error exporting data: $e');
      rethrow;
    }
  }

  /// Export workouts
  Future<List<Map<String, dynamic>>> _exportWorkouts() async {
    final workouts = await _database.select(_database.workoutSessions).get();
    return workouts
        .map((w) => {
              'id': w.id,
              'name': w.name,
              'templateId': w.templateId,
              'startedAt': w.startedAt.toIso8601String(),
              'completedAt': w.completedAt?.toIso8601String(),
              'totalDurationSeconds': w.totalDurationSeconds,
              'totalVolume': w.totalVolume,
              'totalTonnage': w.totalTonnage,
              'totalSets': w.totalSets,
              'totalReps': w.totalReps,
              'notes': w.notes,
            })
        .toList();
  }

  /// Export templates
  Future<List<Map<String, dynamic>>> _exportTemplates() async {
    final templates = await _database.select(_database.workoutTemplates).get();
    return templates
        .map((t) => {
              'id': t.id,
              'name': t.name,
              'description': t.description,
              'category': t.category,
              'exerciseIds': t.exerciseIds,
              'tags': t.tags,
              'estimatedDurationMinutes': t.estimatedDurationMinutes,
              'isDefault': t.isDefault,
              'sortOrder': t.sortOrder,
              'createdAt': t.createdAt.toIso8601String(),
              'updatedAt': t.updatedAt.toIso8601String(),
            })
        .toList();
  }

  /// Export exercises
  Future<List<Map<String, dynamic>>> _exportExercises() async {
    final exercises = await _database.select(_database.exercises).get();
    return exercises
        .map((e) => {
              'id': e.id,
              'name': e.name,
              'primaryMuscleGroup': e.primaryMuscleGroup,
              'secondaryMuscleGroups': e.secondaryMuscleGroups,
              'equipment': e.equipment,
              'difficulty': e.difficulty,
              'instructions': e.instructions,
              'exerciseType': e.exerciseType,
              'category': e.category,
              'isBodyweight': e.isBodyweight,
              'tags': e.tags,
            })
        .toList();
  }

  /// Export personal records
  Future<List<Map<String, dynamic>>> _exportPersonalRecords() async {
    final records = await _database.select(_database.personalRecords).get();
    return records
        .map((r) => {
              'id': r.id,
              'exerciseId': r.exerciseId,
              'recordType': r.recordType,
              'value': r.value,
              'unit': r.unit,
              'weight': r.weight,
              'reps': r.reps,
              'workoutSessionId': r.workoutSessionId,
              'achievedAt': r.achievedAt.toIso8601String(),
            })
        .toList();
  }

  /// Export data as CSV (for specific entity)
  Future<String> exportWorkoutsAsCsv() async {
    final workouts = await _database.select(_database.workoutSessions).get();

    final csvBuffer = StringBuffer();
    csvBuffer.writeln(
        'ID,Name,Started At,Completed At,Duration (sec),Total Volume,Total Sets,Total Reps,Notes');

    for (final workout in workouts) {
      csvBuffer.writeln([
        workout.id,
        _escapeCsv(workout.name),
        workout.startedAt.toIso8601String(),
        workout.completedAt?.toIso8601String() ?? '',
        workout.totalDurationSeconds ?? '',
        workout.totalVolume,
        workout.totalSets,
        workout.totalReps,
        _escapeCsv(workout.notes ?? ''),
      ].join(','));
    }

    return csvBuffer.toString();
  }

  /// Export templates as CSV
  Future<String> exportTemplatesAsCsv() async {
    final templates = await _database.select(_database.workoutTemplates).get();

    final csvBuffer = StringBuffer();
    csvBuffer.writeln(
        'ID,Name,Description,Category,Exercise Count,Tags,Duration (min),Is Default,Sort Order');

    for (final template in templates) {
      csvBuffer.writeln([
        template.id,
        _escapeCsv(template.name),
        _escapeCsv(template.description ?? ''),
        template.category,
        template.exerciseIds.length,
        _escapeCsv(template.tags.join('; ')),
        template.estimatedDurationMinutes ?? '',
        template.isDefault,
        template.sortOrder,
      ].join(','));
    }

    return csvBuffer.toString();
  }

  /// Helper to escape CSV values
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Get export summary
  Future<Map<String, int>> getExportSummary() async {
    final workouts = await _database.select(_database.workoutSessions).get();
    final templates = await _database.select(_database.workoutTemplates).get();
    final exercises = await _database.select(_database.exercises).get();
    final records = await _database.select(_database.personalRecords).get();

    return {
      'workouts': workouts.length,
      'templates': templates.length,
      'exercises': exercises.length,
      'personalRecords': records.length,
    };
  }
}
