import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:gym_ai/src/core/database/database.dart';

void main() {
  test('seed contains expected progressions and parent links', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.seedDefaultData();

    final idsToCheck = {
      'band_assisted_muscle_up': 'muscle_up',
      'muscle_up_negative': 'muscle_up',
      'false_grip_pull_up': 'muscle_up',
      'chest_to_bar_pull_up': 'muscle_up',
      'planche_leans': 'planche',
      'pseudo_planche_push_up': 'planche',
      'planche_on_parallettes': 'planche',
      'front_lever_tuck': 'front_lever',
      'front_lever_rows': 'front_lever',
      'back_lever_tuck': 'back_lever',
      'skin_the_cat': 'back_lever',
      'dumbbell_curls': 'barbell_curls',
      'hammer_curls': 'barbell_curls',
      'preacher_curls': 'barbell_curls',
      'cable_curls': 'barbell_curls',
      'tricep_pushdown': 'tricep_dips',
      'skull_crushers': 'tricep_dips',
      'arnold_press': 'overhead_press',
      'rear_delt_fly': 'dumbbell_shoulder_press',
      'hollow_body_hold': 'planks',
      'hanging_leg_raises': null,
      'goblet_squat': 'squat',
      'bulgarian_split_squat': null,
      'wrist_curls': null,
      'reverse_wrist_curls': null,
    };

    final exercises = await db.select(db.exercises).get();
    final map = {for (var e in exercises) e.id: e};

    for (final entry in idsToCheck.entries) {
      final id = entry.key;
      final expectedParent = entry.value;
      expect(map.containsKey(id), isTrue, reason: 'Expected $id to be present in seed');
      if (expectedParent != null) {
        expect(map[id]!.parentExerciseId, expectedParent, reason: 'Expected $id to have parent $expectedParent');
      }
    }

    await db.close();
  }, timeout: Timeout.none);
}
