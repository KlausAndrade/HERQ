import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/core/database/database.dart';

void main() {
  test('seeder inserts workout templates and folders', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    // Call the method that inserts default data
    await db.seedDefaultData();

    // Verify that folders were seeded
    final folders = await db.select(db.templateFolders).get();
    expect(
      folders.isNotEmpty,
      true,
      reason: 'Default folders should be seeded',
    );

    // Verify specific folders exist
    final pplFolder = await (db.select(db.templateFolders)
          ..where((f) => f.id.equals('fold_ppl')))
        .getSingleOrNull();
    expect(
      pplFolder,
      isNot(null),
      reason: 'Push/Pull/Legs folder should be inserted',
    );
    expect(pplFolder!.name, equals('Push/Pull/Legs'));

    // Verify that templates were seeded
    final templates = await db.select(db.workoutTemplates).get();
    expect(
      templates.isNotEmpty,
      true,
      reason: 'Default templates should be seeded',
    );

    // Verify specific template exists
    final pushTemplate = await (db.select(db.workoutTemplates)
          ..where((t) => t.id.equals('ppl_push')))
        .getSingleOrNull();
    expect(
      pushTemplate,
      isNot(null),
      reason: 'Push Day template should be inserted',
    );
    expect(pushTemplate!.name, equals('Push Day - Classic'));
    expect(pushTemplate.folderId, equals('fold_ppl'));
    expect(pushTemplate.isDefault, isTrue);

    await db.close();
  });
}
