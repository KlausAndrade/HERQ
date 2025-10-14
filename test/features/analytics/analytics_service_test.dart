import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/core/database/database.dart';
import 'package:herq/src/features/analytics/data/analytics_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('weeklyVolume aggregates set entries by ISO week', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      final sessionId = const Uuid().v4();
      final now = DateTime.now();

      // Insert workout session
      await db.into(db.workoutSessions).insert(
            WorkoutSessionsCompanion.insert(
              id: sessionId,
              name: 'Test Session',
              startedAt: now,
              completedAt: Value(now),
            ),
          );

      // Insert two set entries in same week
      await db.into(db.setEntries).insert(
            SetEntriesCompanion.insert(
              id: const Uuid().v4(),
              workoutSessionId: sessionId,
              exerciseId: 'bench_press',
              setNumber: 1,
              reps: 5,
              completedAt: now,
              weight: const Value(100),
            ),
          );

      await db.into(db.setEntries).insert(
            SetEntriesCompanion.insert(
              id: const Uuid().v4(),
              workoutSessionId: sessionId,
              exerciseId: 'bench_press',
              setNumber: 2,
              reps: 3,
              completedAt: now,
              weight: const Value(120),
            ),
          );

      final service = AnalyticsService(db);
      final totals = await service.weeklyVolume(
        from: now.subtract(const Duration(days: 7)),
        to: now.add(const Duration(days: 1)),
      );

      final totalVolume = totals.values.fold<double>(0, (a, b) => a + b);
      expect(totalVolume, closeTo(100.0 * 5 + 120.0 * 3, 0.001));
    } finally {
      await db.close();
    }
  });
}
