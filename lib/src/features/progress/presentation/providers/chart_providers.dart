import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';

// Configurable chart parameters
class ChartConfig {
  static const int defaultWeeksToShow = 12;
  static const int defaultMonthsToShow = 12;
  static const double oneRepMaxConstant = 30.0;
}

// Provider for weekly volume data
final weeklyVolumeProvider = FutureProvider<List<VolumeData>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }
  
  final sessions = await database.select(database.workoutSessions).get();
  final completedSessions = sessions.where((s) => s.completedAt != null).toList();
  
  // Group by week
  final weeklyData = <String, double>{};
  
  for (final session in completedSessions) {
    final weekStart = _getWeekStart(session.startedAt);
    final weekKey = weekStart.toIso8601String().split('T')[0];
    weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + session.totalVolume;
  }
  
  // Convert to list and sort by date
  final volumeList = weeklyData.entries
      .map((e) => VolumeData(
            date: DateTime.parse(e.key),
            volume: e.value,
          ))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  
  // Keep only last N weeks (configurable)
  if (volumeList.length > ChartConfig.defaultWeeksToShow) {
    return volumeList.sublist(volumeList.length - ChartConfig.defaultWeeksToShow);
  }
  
  return volumeList;
});

// Provider for monthly volume data
final monthlyVolumeProvider = FutureProvider<List<VolumeData>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }
  
  final sessions = await database.select(database.workoutSessions).get();
  final completedSessions = sessions.where((s) => s.completedAt != null).toList();
  
  // Group by month
  final monthlyData = <String, double>{};
  
  for (final session in completedSessions) {
    final monthKey = '${session.startedAt.year}-${session.startedAt.month.toString().padLeft(2, '0')}';
    monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + session.totalVolume;
  }
  
  // Convert to list and sort by date
  final volumeList = monthlyData.entries
      .map((e) => VolumeData(
            date: DateTime.parse('${e.key}-01'),
            volume: e.value,
          ))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  
  // Keep only last N months (configurable)
  if (volumeList.length > ChartConfig.defaultMonthsToShow) {
    return volumeList.sublist(volumeList.length - ChartConfig.defaultMonthsToShow);
  }
  
  return volumeList;
});

// Provider for workout frequency data (workouts per week)
final workoutFrequencyProvider = FutureProvider<List<FrequencyData>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }
  
  final sessions = await database.select(database.workoutSessions).get();
  final completedSessions = sessions.where((s) => s.completedAt != null).toList();
  
  // Group by week
  final weeklyData = <String, int>{};
  
  for (final session in completedSessions) {
    final weekStart = _getWeekStart(session.startedAt);
    final weekKey = weekStart.toIso8601String().split('T')[0];
    weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + 1;
  }
  
  // Convert to list and sort by date
  final frequencyList = weeklyData.entries
      .map((e) => FrequencyData(
            date: DateTime.parse(e.key),
            count: e.value,
          ))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  
  // Keep only last N weeks (configurable)
  if (frequencyList.length > ChartConfig.defaultWeeksToShow) {
    return frequencyList.sublist(frequencyList.length - ChartConfig.defaultWeeksToShow);
  }
  
  return frequencyList;
});

// Provider for exercise progress (specific exercise over time)
final exerciseProgressProvider = FutureProvider.family<List<ExerciseProgressData>, String>((ref, exerciseId) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }
  
  final sets = await (database.select(database.setEntries)
    ..where((tbl) => tbl.exerciseId.equals(exerciseId))
    ..orderBy([(tbl) => OrderingTerm.asc(tbl.completedAt)])).get();
  
  final completedSets = sets.where((s) => s.weight != null).toList();
  
  // Calculate max weight for each session
  final sessionMaxes = <String, ExerciseProgressData>{};
  
  for (final set in completedSets) {
    final sessionId = set.workoutSessionId;
    final weight = set.weight!;
    final reps = set.reps;
    
    if (!sessionMaxes.containsKey(sessionId) || 
        weight > sessionMaxes[sessionId]!.weight ||
        (weight == sessionMaxes[sessionId]!.weight && reps > sessionMaxes[sessionId]!.reps)) {
      sessionMaxes[sessionId] = ExerciseProgressData(
        date: set.completedAt,
        weight: weight,
        reps: reps,
        oneRepMax: _calculateOneRepMax(weight, reps),
      );
    }
  }
  
  return sessionMaxes.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

// Provider for personal records
final personalRecordsProvider = FutureProvider<List<PersonalRecord>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }
  
  final sets = await database.select(database.setEntries).get();
  final completedSets = sets.where((s) => s.weight != null).toList();
  
  // Group by exercise and find max weights
  final exerciseMaxes = <String, PersonalRecord>{};
  
  for (final set in completedSets) {
    final exerciseId = set.exerciseId;
    final weight = set.weight!;
    final reps = set.reps;
    final oneRepMax = _calculateOneRepMax(weight, reps);
    
    if (!exerciseMaxes.containsKey(exerciseId) || 
        oneRepMax > exerciseMaxes[exerciseId]!.oneRepMax) {
      exerciseMaxes[exerciseId] = PersonalRecord(
        exerciseId: exerciseId,
        weight: weight,
        reps: reps,
        oneRepMax: oneRepMax,
        date: set.completedAt,
      );
    }
  }
  
  return exerciseMaxes.values.toList()
    ..sort((a, b) => b.oneRepMax.compareTo(a.oneRepMax));
});

// Helper function to get the start of the week (Monday)
DateTime _getWeekStart(DateTime date) {
  final dayOfWeek = date.weekday;
  return DateTime(date.year, date.month, date.day - (dayOfWeek - 1));
}

// Helper function to calculate estimated 1RM using Epley formula
double _calculateOneRepMax(double weight, int reps) {
  if (reps == 1) return weight;
  return weight * (1 + reps / ChartConfig.oneRepMaxConstant);
}

// Data classes
class VolumeData {
  const VolumeData({
    required this.date,
    required this.volume,
  });

  final DateTime date;
  final double volume;
}

class FrequencyData {
  const FrequencyData({
    required this.date,
    required this.count,
  });

  final DateTime date;
  final int count;
}

class ExerciseProgressData {
  const ExerciseProgressData({
    required this.date,
    required this.weight,
    required this.reps,
    required this.oneRepMax,
  });

  final DateTime date;
  final double weight;
  final int reps;
  final double oneRepMax;
}

class PersonalRecord {
  const PersonalRecord({
    required this.exerciseId,
    required this.weight,
    required this.reps,
    required this.oneRepMax,
    required this.date,
  });

  final String exerciseId;
  final double weight;
  final int reps;
  final double oneRepMax;
  final DateTime date;
}