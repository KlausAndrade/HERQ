import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:herq/src/core/database/database.dart';

void main() {
  test('templates are seeded with exercises and references exist', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.seedDefaultData();

    final templates = await db.select(db.workoutTemplates).get();
    expect(templates.isNotEmpty, true, reason: 'No templates were seeded');

    // Build a set of existing exercise ids
    final existingExercises = await db.select(db.exercises).get();
    final existingIds = existingExercises.map((e) => e.id).toSet();

    final missingRefs = <String, List<String>>{}; // templateId -> missing ids

    for (final t in templates) {
      // exerciseIds is stored as List<String>
      final ids = t.exerciseIds;
      if (ids.isEmpty) {
        missingRefs[t.id] = [];
        continue;
      }

      final notFound = <String>[];
      for (final id in ids) {
        if (!existingIds.contains(id)) notFound.add(id);
      }
      if (notFound.isNotEmpty) missingRefs[t.id] = notFound;
    }

    if (missingRefs.isNotEmpty) {
      final sb = StringBuffer();
      sb.writeln('Found templates with missing exercise references:');
      missingRefs.forEach((tid, ids) {
        sb.writeln(
            ' - $tid -> ${ids.isEmpty ? '<no exercises>' : ids.join(', ')}');
      });
      fail(sb.toString());
    }

    await db.close();
  });
}
