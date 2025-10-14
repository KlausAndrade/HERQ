import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/core/database/database.dart';

void main() {
  test('seeder inserts exercises and variant relationships', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    // Call the method that inserts default data
    await db.seedDefaultData();

    // Query for the newly added exercises
    final tricep = await (db.select(db.exercises)
          ..where((e) => e.id.equals('tricep_dips')))
        .getSingleOrNull();
    final dbsp = await (db.select(db.exercises)
          ..where((e) => e.id.equals('dumbbell_shoulder_press')))
        .getSingleOrNull();
    final scr = await (db.select(db.exercises)
          ..where((e) => e.id.equals('seated_cable_rows')))
        .getSingleOrNull();

    expect(tricep, isNot(null), reason: 'tricep_dips should be inserted');
    expect(
      dbsp,
      isNot(null),
      reason: 'dumbbell_shoulder_press should be inserted',
    );
    expect(scr, isNot(null), reason: 'seated_cable_rows should be inserted');

    // Check variant/parent relationships
    // parentExerciseId is a nullable String column in the generated model
    expect(tricep!.parentExerciseId, equals('chest_dips'));
    expect(dbsp!.parentExerciseId, equals('overhead_press'));
    expect(scr!.parentExerciseId, equals('barbell_rows'));

    await db.close();
  });
}
