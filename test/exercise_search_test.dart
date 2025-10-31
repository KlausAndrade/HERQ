import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/core/database/database.dart';

void main() {
  test('exercise search matches aliases and muscle group', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    // Seed default data
    await db.seedDefaultData();

    // Search for preacher alias
    const q = '%preacher%';
    final rows = await db
        .customSelect(
          'SELECT * FROM exercises WHERE LOWER(name) LIKE ? OR LOWER(primary_muscle_group) LIKE ? OR LOWER(aliases) LIKE ? OR LOWER(tags) LIKE ? COLLATE NOCASE',
          variables: [
            const Variable<String>(q),
            const Variable<String>(q),
            const Variable<String>(q),
            const Variable<String>(q),
          ],
        )
        .get();

    final results = rows.map((r) => db.exercises.map(r.data)).toList();
    // Expect at least preacher_curls and variants to be present
    final ids = results.map((e) => e.id).toSet();
    expect(ids.contains('preacher_curls'), isTrue);
    expect(
      ids.contains('db_preacher_curl') || ids.contains('barbell_preacher_curl'),
      isTrue,
    );

    // Search by muscle group: biceps
    const qb = '%biceps%';
    final rows2 = await db
        .customSelect(
          'SELECT * FROM exercises WHERE LOWER(name) LIKE ? OR LOWER(primary_muscle_group) LIKE ? OR LOWER(aliases) LIKE ? OR LOWER(tags) LIKE ? COLLATE NOCASE',
          variables: [
            const Variable<String>(qb),
            const Variable<String>(qb),
            const Variable<String>(qb),
            const Variable<String>(qb),
          ],
        )
        .get();

    final results2 = rows2.map((r) => db.exercises.map(r.data)).toList();
    final ids2 = results2.map((e) => e.id).toSet();
    expect(ids2.contains('preacher_curls'), isTrue);
    expect(ids2.contains('dumbbell_curls'), isTrue);

    await db.close();
  });
}
