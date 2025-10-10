import 'package:drift/drift.dart';
import '../../../core/database/database.dart';

/// Lightweight analytics service that computes weekly total volume (weight * reps)
/// for a given time range. Designed to be small and testable.
class AnalyticsService {
  final AppDatabase database;

  AnalyticsService(this.database);

  /// Returns a map of ISO week (YYYY-WW) -> total volume
  Future<Map<String, double>> weeklyVolume({
    required DateTime from,
    required DateTime to,
  }) async {
    // Query set_entries joined with workout_sessions to get completed_at
    final query = database.select(database.setEntries).join([
      leftOuterJoin(database.workoutSessions, database.workoutSessions.id.equalsExp(database.setEntries.workoutSessionId)),
    ])
      ..where(database.setEntries.completedAt.isBiggerOrEqualValue(from))
      ..where(database.setEntries.completedAt.isSmallerOrEqualValue(to));

    final rows = await query.get();

    final Map<String, double> totals = {};

    for (final row in rows) {
      final setEntry = row.readTable(database.setEntries);
  final completedAt = setEntry.completedAt;
      final weekKey = _isoWeekKey(completedAt);
  final weight = setEntry.weight;
  final reps = setEntry.reps;
  final weightVal = weight ?? 0.0;
  final repsVal = reps; // reps is non-nullable in generated model
  final current = totals[weekKey] ?? 0.0;
  totals[weekKey] = current + (weightVal * repsVal);
    }

    return totals;
  }

  String _isoWeekKey(DateTime dt) {
    // ISO week date calculation: week starts on Monday, week 1 is the week with Jan 4th
    // Calculate the Thursday of the current week
    final thursday = dt.add(Duration(days: 4 - dt.weekday));
    final weekYear = thursday.year;
    final firstWeekThursday = DateTime(weekYear, 1, 4);
    final weekNumber = ((thursday.difference(firstWeekThursday).inDays) ~/ 7) + 1;
    return '${weekYear.toString()}-${weekNumber.toString().padLeft(2, '0')}';
  }
}
