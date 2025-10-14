import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:herq/src/core/database/database.dart';

void main() {
  test('exercise variant mapping audit', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.seedDefaultData();

    final all = await db.select(db.exercises).get();
    final total = all.length;
    final withParent = all
        .where(
            (e) => e.parentExerciseId != null && e.parentExerciseId!.isNotEmpty)
        .toList();

    // Print summary for debugging in CI logs
    print('Total exercises seeded: $total');
    print('Exercises with parentExerciseId: ${withParent.length}');

    // Sanity assertion: we expect at least 10 variant relationships in the seed.
    // This prevents regressions where variants accidentally get removed from the seeder.
    expect(withParent.length >= 10, true,
        reason:
            'Expected at least 10 exercises to have parentExerciseId set; found ${withParent.length}');

    // Spot-check a few known mappings
    final weightedPull = await (db.select(db.exercises)
          ..where((e) => e.id.equals('weighted_pull_up')))
        .getSingleOrNull();
    final oneArm = await (db.select(db.exercises)
          ..where((e) => e.id.equals('one_arm_pushup')))
        .getSingleOrNull();
    final hspu = await (db.select(db.exercises)
          ..where((e) => e.id.equals('handstand_push_up')))
        .getSingleOrNull();

    expect(weightedPull, isNotNull);
    expect(weightedPull!.parentExerciseId, equals('pull_up'));

    expect(oneArm, isNotNull);
    expect(oneArm!.parentExerciseId, equals('push_up'));

    expect(hspu, isNotNull);
    expect(hspu!.parentExerciseId, equals('handstand'));

    await db.close();
  });
}
