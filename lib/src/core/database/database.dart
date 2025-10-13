// Drift database definition. Platform-specific opening is implemented in
// `database_open.dart` (native) and `database_open_stub.dart` (web) to avoid
// importing dart:ffi-backed packages into the web compilation graph.

import 'package:drift/drift.dart';
import 'database_open.dart';
import '../converters/json_converters.dart';
import 'package:gym_ai/src/features/workout/data/seed/default_template_seed.dart';

import '../models/user.dart';
import '../models/exercise.dart';
import '../models/exercise_favorite.dart';
import '../models/workout_template.dart';
import '../models/template_folder.dart';
import '../models/workout_session.dart';
import '../models/workout_checkpoint.dart';
import '../models/set_entry.dart';
import '../models/personal_record.dart';
import '../models/user_achievement.dart';
import '../models/user_stats.dart';
import '../models/post.dart';
import '../models/post_like.dart';
import '../models/post_comment.dart';
import '../models/user_follow.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Exercises,
    ExerciseFavorites,
    WorkoutTemplates,
    TemplateFolders,
    WorkoutSessions,
    WorkoutCheckpoints,
    SetEntries,
    PersonalRecords,
    UserAchievements,
    UserStats,
    Posts,
    PostLikes,
    PostComments,
    UserFollows,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Default constructor uses platform-specific opener provided by
  // `database_open.dart` (native) or `database_open_stub.dart` (web).
  AppDatabase() : super(openConnection());

  // For tests that supply an in-memory executor
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // Enable foreign keys for integrity
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (migrator) async {
          await migrator.createAll();
          await _insertDefaultData();
        },
        onUpgrade: (migrator, from, to) async {
          // Apply lightweight per-version migrations. Keep in sync with
          // native implementation in `database_native.dart`.
          if (to == 14) {
            try {
              // Add distance field to set_entries for distance-based exercises
              await customStatement('ALTER TABLE set_entries ADD COLUMN distance REAL');
            } catch (e) {
              // Column may already exist, ignore error
            }
          }
          
          if (to == 13) {
            try {
              await customStatement('ALTER TABLE exercises ADD COLUMN aliases TEXT');
            } catch (e) {}
          }

          if (to == 12) {
            await customStatement("UPDATE workout_templates SET exercise_ids = '' WHERE exercise_ids IS NULL");
          } else if (to == 11) {
            await migrator.createTable(workoutCheckpoints);
          } else if (to == 10) {
            await migrator.createTable(templateFolders);
            await migrator.addColumn(workoutTemplates, workoutTemplates.folderId);
          } else if (to == 9) {
            await migrator.createTable(posts);
            await migrator.createTable(postLikes);
            await migrator.createTable(postComments);
            await migrator.createTable(userFollows);
          } else if (to == 8) {
            await migrator.createTable(userAchievements);
            await migrator.createTable(userStats);
          } else if (to == 7) {
            await migrator.createTable(exerciseFavorites);
          } else if (to == 6) {
            await migrator.deleteTable('exercises');
            await migrator.deleteTable('set_entries');
            await migrator.deleteTable('workout_templates');
            await migrator.deleteTable('workout_sessions');
            await migrator.deleteTable('personal_records');

            await migrator.createTable(exercises);
            await migrator.createTable(setEntries);
            await migrator.createTable(workoutTemplates);
            await migrator.createTable(workoutSessions);
            await migrator.createTable(personalRecords);

            await _insertDefaultData();
          } else if (to == 5) {
            await migrator.deleteTable('exercises');
            await migrator.deleteTable('set_entries');
            await migrator.deleteTable('workout_templates');

            await migrator.createTable(exercises);
            await migrator.createTable(setEntries);
            await migrator.createTable(workoutTemplates);

            await _insertDefaultData();
          }
        },
      );

  // Internal seeder used by onCreate and tests. Keep this minimal to avoid
  // pulling platform-specific code into the top-level file.
  Future<void> _insertDefaultData() async {
    // Populate aliases for seeded exercises using raw SQL. We do this via
    // UPDATE statements so we don't need to re-run code generation for the
    // ExercisesCompanion to accept an `aliases` field yet keep the seeder idempotent.
    try {
      await customStatement("UPDATE exercises SET aliases = '[\"hspu\",\"handstand pushup\"]' WHERE id = 'handstand_push_up'");
      await customStatement("UPDATE exercises SET aliases = '[\"dumbbell curl\",\"db curl\",\"bicep curl\"]' WHERE id = 'dumbbell_curls'");
      await customStatement("UPDATE exercises SET aliases = '[\"preacher\",\"preacher_curl\",\"preacher curl\"]' WHERE id = 'preacher_curls'");
      await customStatement("UPDATE exercises SET aliases = '[\"barbell preacher\",\"barbell preacher curl\"]' WHERE id = 'barbell_preacher_curl'");
      await customStatement("UPDATE exercises SET aliases = '[\"db preacher\",\"dumbbell preacher curl\"]' WHERE id = 'db_preacher_curl'");
      await customStatement("UPDATE exercises SET aliases = '[\"machine preacher\",\"machine preacher curl\"]' WHERE id = 'machine_preacher_curl'");
    } catch (e) {
      // Non-fatal: if the UPDATE fails (e.g., running on older DB without aliases column), ignore.
    }

    // Insert default workout templates / folders. The helper functions
    // `getDefaultFoldersData` / `getDefaultTemplatesData` are defined in the
    // seed utilities and return plain maps; convert them to Companion
    // objects to avoid circular types.
    try {
      final foldersData = getDefaultFoldersData();
      for (final f in foldersData) {
        final companion = TemplateFoldersCompanion(
          id: Value(f['id'] as String),
          name: Value(f['name'] as String),
          description: Value(f['description'] as String?),
        );
        await into(templateFolders).insertOnConflictUpdate(companion);
      }

      final templatesData = getDefaultTemplatesData();
      for (final t in templatesData) {
        var companion = WorkoutTemplatesCompanion(
          id: Value(t['id'] as String),
          name: Value(t['name'] as String),
          description: Value(t['description'] as String?),
          folderId: Value(t['folderId'] as String?),
          exerciseIds: Value(List<String>.from(t['exerciseIds'] as List<dynamic>? ?? [])),
          tags: Value(List<String>.from(t['tags'] as List<dynamic>? ?? [])),
          estimatedDurationMinutes: Value(t['estimatedDurationMinutes'] as int?),
          isDefault: Value(t['isDefault'] as bool? ?? false),
        );

        final cat = t['category'] as String?;
        if (cat != null) {
          companion = companion.copyWith(category: Value(cat));
        }

        await into(workoutTemplates).insertOnConflictUpdate(companion);
      }
    } catch (e) {
      // Non-fatal seeding errors should not crash app startup.
    }
  }

  // Public wrapper for seeding default data in tests/CI
  Future<void> seedDefaultData() async => _insertDefaultData();

  /// Migrate existing exercises to use correct exercise types
  /// This updates all exercises in the database with the auto-assigned type
  Future<void> migrateExerciseTypes() async {
    try {
      // Import the mapper in the method to avoid circular dependencies
      final allExercises = await select(exercises).get();
      
      print('Starting exercise type migration for ${allExercises.length} exercises...');
      
      int updatedCount = 0;
      for (final exercise in allExercises) {
        // Use the auto-assignment logic to determine the correct type
        final correctType = _assignExerciseType(
          name: exercise.name,
          equipment: exercise.equipment,
          category: exercise.category,
        );
        
        // Only update if the type is different
        if (exercise.exerciseType != correctType) {
          await (update(exercises)..where((e) => e.id.equals(exercise.id)))
              .write(ExercisesCompanion(
            exerciseType: Value(correctType),
          ));
          
          updatedCount++;
          print('Updated "${exercise.name}" from "${exercise.exerciseType}" to "$correctType"');
        }
      }
      
      print('Exercise type migration complete. Updated $updatedCount exercises.');
    } catch (e) {
      print('Error during exercise type migration: $e');
      rethrow;
    }
  }

  /// Auto-assign exercise type based on name, equipment, and category
  /// This is a simplified version of ExerciseTypeMapper to avoid circular dependencies
  String _assignExerciseType({
    required String name,
    required String equipment,
    required String category,
  }) {
    final lowerName = name.toLowerCase();
    final lowerEquipment = equipment.toLowerCase();

    // Duration-based exercises (planks, holds, isometric)
    if (_isDurationExercise(lowerName)) {
      return 'duration';
    }

    // Distance & duration (cardio)
    if (_isDistanceDurationExercise(lowerName, category)) {
      return 'distance_duration';
    }

    // Duration & weight (loaded carries for time)
    if (_isDurationWeightExercise(lowerName)) {
      return 'duration_weight';
    }

    // Weight & distance (loaded carries for distance)
    if (_isWeightDistanceExercise(lowerName)) {
      return 'weight_distance';
    }

    // Weighted bodyweight exercises
    if (lowerName.contains('weighted') && _isBodyweightBase(lowerName)) {
      return 'weighted_bodyweight';
    }

    // Assisted bodyweight exercises
    if ((lowerName.contains('assisted') || lowerEquipment.contains('assisted') || 
         lowerEquipment.contains('machine')) && _isBodyweightBase(lowerName)) {
      return 'assisted_bodyweight';
    }

    // Bodyweight reps (push-ups, pull-ups, etc.)
    if (lowerEquipment == 'bodyweight' || _isBodyweightBase(lowerName)) {
      return 'bodyweight_reps';
    }

    // Default: weight & reps
    return 'weight_reps';
  }

  bool _isDurationExercise(String name) {
    final durationKeywords = [
      'plank',
      'hold',
      'wall sit',
      'dead hang',
      'hollow hold',
      'l-sit',
      'l sit',
      'handstand',
      'hollow body',
      'arch hold',
      'support hold',
      'static hold',
      'isometric',
      'bridge hold',
      'horse stance',
    ];
    return durationKeywords.any((keyword) => name.contains(keyword));
  }

  bool _isDistanceDurationExercise(String name, String category) {
    if (category.toLowerCase() == 'cardio') return true;
    
    final keywords = [
      'run',
      'jog',
      'sprint',
      'row',
      'swim',
      'cycle',
      'bike',
      'elliptical',
      'ski erg',
      'assault bike',
      'air bike',
    ];
    return keywords.any((keyword) => name.contains(keyword));
  }

  bool _isDurationWeightExercise(String name) {
    final keywords = [
      'farmer walk',
      'farmers walk',
      'sled push',
      'sled pull',
      'prowler push',
      'yoke walk',
      'sandbag carry',
    ];
    return keywords.any((keyword) => name.contains(keyword));
  }

  bool _isWeightDistanceExercise(String name) {
    final keywords = [
      'farmer carry',
      'farmers carry',
      'waiter carry',
      'overhead carry',
      'suitcase carry',
      'zercher carry',
    ];
    return keywords.any((keyword) => name.contains(keyword));
  }

  bool _isBodyweightBase(String name) {
    final bodyweightExercises = [
      'pull up',
      'pull-up',
      'pullup',
      'chin up',
      'chin-up',
      'chinup',
      'push up',
      'push-up',
      'pushup',
      'dip',
      'muscle up',
      'muscle-up',
      'pistol squat',
      'lunge',
      'squat',
      'burpee',
      'jumping jack',
      'mountain climber',
    ];
    return bodyweightExercises.any((keyword) => name.contains(keyword));
  }
}
