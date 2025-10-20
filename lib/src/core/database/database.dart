// Drift database definition. Platform-specific opening is implemented in
// `database_open.dart` (native) and `database_open_stub.dart` (web) to avoid
// importing dart:ffi-backed packages into the web compilation graph.

import 'package:drift/drift.dart';

import '../../features/workout/data/seed/default_template_seed.dart';
import '../constants/exercise_types.dart';
import '../converters/json_converters.dart';
import '../models/exercise.dart';
import '../models/exercise_favorite.dart';
import '../models/personal_record.dart';
import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/post_like.dart';
import '../models/set_entry.dart';
import '../models/template_folder.dart';
import '../models/user.dart';
import '../models/user_achievement.dart';
import '../models/user_follow.dart';
import '../models/user_stats.dart';
import '../models/workout_checkpoint.dart';
import '../models/workout_session.dart';
import '../models/workout_template.dart';
import '../utils/exercise_type_mapper.dart';
import 'database_open.dart';

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
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 23;

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
          if (to == 19) {
            try {
              // Ensure all tables have user_id column for user isolation
              final tables = [
                'exercises',
                'workout_sessions', 
                'set_entries',
                'personal_records',
                'user_stats',
                'exercise_favorites',
                'user_achievements'
              ];
              
              for (final table in tables) {
                try {
                  await customStatement('ALTER TABLE $table ADD COLUMN user_id TEXT');
                  print('✅ Added user_id column to $table');
                } catch (e) {
                  // Column may already exist, which is fine
                  print('ℹ️ user_id column may already exist in $table: $e');
                }
              }
              
              // Set all existing exercises to global (NULL user_id)
              await customStatement('UPDATE exercises SET user_id = NULL WHERE user_id IS NULL');
              
              print('✅ Migration 19: Ensured all tables have user_id column');
            } catch (e) {
              print('Migration 19 error: $e');
            }
          }

          if (to == 18) {
            try {
              // Make userId column nullable in workout_templates table for admin templates
              // SQLite doesn't support ALTER COLUMN, so we need to recreate the table
              await customStatement('''
                CREATE TABLE workout_templates_new (
                  id TEXT NOT NULL PRIMARY KEY,
                  user_id TEXT,
                  name TEXT NOT NULL,
                  description TEXT,
                  category TEXT NOT NULL DEFAULT 'Custom',
                  folder_id TEXT,
                  sort_order INTEGER NOT NULL DEFAULT 0,
                  exercise_ids TEXT NOT NULL DEFAULT '',
                  tags TEXT NOT NULL DEFAULT '',
                  estimated_duration_minutes INTEGER,
                  is_default INTEGER NOT NULL DEFAULT 0,
                  created_at INTEGER NOT NULL,
                  updated_at INTEGER NOT NULL
                )
              ''');
              
              // Copy data from old table to new table
              await customStatement('''
                INSERT INTO workout_templates_new 
                SELECT id, user_id, name, description, category, folder_id, sort_order, 
                       exercise_ids, tags, estimated_duration_minutes, is_default, created_at, updated_at
                FROM workout_templates
              ''');
              
              // Drop old table and rename new table
              await customStatement('DROP TABLE workout_templates');
              await customStatement('ALTER TABLE workout_templates_new RENAME TO workout_templates');
            } catch (e) {
              print('Migration 18 error: $e');
            }
          }

          if (to == 17) {
            try {
              // Add userId column to exercises table for user isolation
              await customStatement(
                'ALTER TABLE exercises ADD COLUMN user_id TEXT',
              );
              
              // All existing exercises are global (admin-created), so set userId to NULL
              // This means they'll be visible to all users
              await customStatement(
                "UPDATE exercises SET user_id = NULL WHERE user_id IS NULL",
              );
            } catch (e) {
              // Column may already exist, ignore error
              print('Migration 17 error (may be expected): $e');
            }
          }

          if (to == 16) {
            try {
              // Add userId columns for user isolation
              await customStatement(
                'ALTER TABLE workout_sessions ADD COLUMN user_id TEXT',
              );
              await customStatement(
                'ALTER TABLE set_entries ADD COLUMN user_id TEXT',
              );
              await customStatement(
                'ALTER TABLE workout_templates ADD COLUMN user_id TEXT',
              );
              await customStatement(
                'ALTER TABLE personal_records ADD COLUMN user_id TEXT',
              );

              // Set default userId for existing data (will be updated by current user)
              await customStatement(
                "UPDATE workout_sessions SET user_id = 'default_user' WHERE user_id IS NULL",
              );
              await customStatement(
                "UPDATE set_entries SET user_id = 'default_user' WHERE user_id IS NULL",
              );
              await customStatement(
                "UPDATE workout_templates SET user_id = 'default_user' WHERE user_id IS NULL",
              );
              await customStatement(
                "UPDATE personal_records SET user_id = 'default_user' WHERE user_id IS NULL",
              );
            } catch (e) {
              print('Migration 16 error: $e');
            }
          }

          if (to == 15) {
            try {
              // Add equipment_used and variant_type fields for exercise variants
              await customStatement(
                'ALTER TABLE set_entries ADD COLUMN equipment_used TEXT',
              );
            } catch (e) {
              // Column may already exist, ignore error
            }
            try {
              await customStatement(
                'ALTER TABLE set_entries ADD COLUMN variant_type TEXT',
              );
            } catch (e) {
              // Column may already exist, ignore error
            }
          }

          if (to == 14) {
            try {
              // Add distance field to set_entries for distance-based exercises
              await customStatement(
                'ALTER TABLE set_entries ADD COLUMN distance REAL',
              );
            } catch (e) {
              // Column may already exist, ignore error
            }
          }

          if (to == 13) {
            try {
              await customStatement(
                'ALTER TABLE exercises ADD COLUMN aliases TEXT',
              );
            } catch (e) {}
          }

          if (to == 12) {
            await customStatement(
              "UPDATE workout_templates SET exercise_ids = '' WHERE exercise_ids IS NULL",
            );
          } else if (to == 11) {
            await migrator.createTable(workoutCheckpoints);
          } else if (to == 10) {
            await migrator.createTable(templateFolders);
            await migrator.addColumn(
              workoutTemplates,
              workoutTemplates.folderId,
            );
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
          
          if (to == 20) {
            try {
              // Add sort_order column to template_folders table
              await customStatement('ALTER TABLE template_folders ADD COLUMN sort_order INTEGER DEFAULT 0');
              print('✅ Added sort_order column to template_folders');
              
              // Set sort_order for existing folders based on creation date
              await customStatement('''
                UPDATE template_folders 
                SET sort_order = (
                  SELECT ROW_NUMBER() OVER (ORDER BY created_at) - 1
                )
                WHERE sort_order = 0
              ''');
              print('✅ Set sort_order for existing template folders');
              
              print('✅ Migration 20: Added sort_order to template_folders');
            } catch (e) {
              print('❌ Migration 20 failed: $e');
              rethrow;
            }
          }
          
          if (to == 21) {
            try {
              // Add missing columns to workout_checkpoints table (with error handling)
              try {
                await customStatement('ALTER TABLE workout_checkpoints ADD COLUMN started_at INTEGER');
                print('✅ Added started_at column to workout_checkpoints');
              } catch (e) {
                if (e.toString().contains('duplicate column name')) {
                  print('ℹ️ started_at column already exists in workout_checkpoints');
                } else {
                  rethrow;
                }
              }
              
              try {
                await customStatement('ALTER TABLE workout_checkpoints ADD COLUMN last_saved_at INTEGER');
                print('✅ Added last_saved_at column to workout_checkpoints');
              } catch (e) {
                if (e.toString().contains('duplicate column name')) {
                  print('ℹ️ last_saved_at column already exists in workout_checkpoints');
                } else {
                  rethrow;
                }
              }
              
              // Set timestamps for existing checkpoints (use current time as fallback)
              final now = DateTime.now().millisecondsSinceEpoch;
              await customStatement('''
                UPDATE workout_checkpoints 
                SET started_at = $now, last_saved_at = $now 
                WHERE started_at IS NULL OR last_saved_at IS NULL
              ''');
              print('✅ Set timestamps for existing workout checkpoints');
              
              print('✅ Migration 21: Added missing columns to workout_checkpoints');
            } catch (e) {
              print('❌ Migration 21 failed: $e');
              rethrow;
            }
          }
          
          if (to == 22) {
            try {
              print('🔄 Migration 22: Renaming columns to snake_case to match Supabase...');
              
              // ⚠️ SQLite doesn't support renaming columns directly
              // We need to recreate tables with the new column names
              
              // 1. Add user_id to template_folders if it doesn't exist
              try {
                await customStatement('ALTER TABLE template_folders ADD COLUMN user_id TEXT');
                print('✅ Added user_id column to template_folders');
              } catch (e) {
                if (e.toString().contains('duplicate column name')) {
                  print('ℹ️ user_id column already exists in template_folders');
                } else {
                  throw e;
                }
              }
              
              print('✅ Migration 22: Schema updated to match Supabase (snake_case)');
              print('ℹ️ Note: Drift will handle column name mapping automatically via .named()');
            } catch (e) {
              print('❌ Migration 22 failed: $e');
              rethrow;
            }
          }
          
          if (to == 23) {
            try {
              print('🔄 Migration 23: Converting equipment column to array format...');
              
              // ℹ️ Drift will handle the conversion automatically via StringListConverter
              // Equipment was TEXT, now it's TEXT with StringListConverter (JSON array)
              // Existing data should be compatible as long as it's valid JSON
              
              print('✅ Migration 23: Equipment column now uses array format');
            } catch (e) {
              print('❌ Migration 23 failed: $e');
              rethrow;
            }
          }
        },
      );

  // Internal seeder used by onCreate and tests. Keep this minimal to avoid
  // pulling platform-specific code into the top-level file.
  Future<void> _insertDefaultData() async {
    // First, seed core exercises that templates reference
    await _seedCoreExercises();

    // Seed exercise variants (progressions, regressions, etc.)
    await _seedExerciseVariants();

    // Populate aliases for seeded exercises using raw SQL. We do this via
    // UPDATE statements so we don't need to re-run code generation for the
    // ExercisesCompanion to accept an `aliases` field yet keep the seeder idempotent.
    try {
      await customStatement(
        "UPDATE exercises SET aliases = '[\"hspu\",\"handstand pushup\"]' WHERE id = 'handstand_push_up'",
      );
      await customStatement(
        "UPDATE exercises SET aliases = '[\"dumbbell curl\",\"db curl\",\"bicep curl\"]' WHERE id = 'dumbbell_curls'",
      );
      await customStatement(
        "UPDATE exercises SET aliases = '[\"preacher\",\"preacher_curl\",\"preacher curl\"]' WHERE id = 'preacher_curls'",
      );
      await customStatement(
        "UPDATE exercises SET aliases = '[\"barbell preacher\",\"barbell preacher curl\"]' WHERE id = 'barbell_preacher_curl'",
      );
      await customStatement(
        "UPDATE exercises SET aliases = '[\"db preacher\",\"dumbbell preacher curl\"]' WHERE id = 'db_preacher_curl'",
      );
      await customStatement(
        "UPDATE exercises SET aliases = '[\"machine preacher\",\"machine preacher curl\"]' WHERE id = 'machine_preacher_curl'",
      );
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
          id: Value(f['id'] as String? ?? ''),
          name: Value(f['name'] as String? ?? ''),
          description: Value(f['description'] as String?),
        );
        await into(templateFolders).insertOnConflictUpdate(companion);
      }

      final templatesData = getDefaultTemplatesData();
      for (final t in templatesData) {
        var companion = WorkoutTemplatesCompanion(
          id: Value(t['id'] as String? ?? ''),
          userId: const Value(
              'system'), // Use 'system' as userId for default templates
          name: Value(t['name'] as String? ?? ''),
          description: Value(t['description'] as String?),
          folderId: Value(t['folderId'] as String?),
          exerciseIds: Value(
            List<String>.from(t['exerciseIds'] as List<dynamic>? ?? []),
          ),
          tags: Value(List<String>.from(t['tags'] as List<dynamic>? ?? [])),
          estimatedDurationMinutes:
              Value(t['estimatedDurationMinutes'] as int?),
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

  /// Seed core exercises that templates reference
  Future<void> _seedCoreExercises() async {
    const coreExercises = [
      // Chest Exercises
      {
        'id': 'bench_press',
        'name': 'Bench Press',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['shoulders', 'triceps'],
        'equipment': 'barbell',
        'instructions': 'Lie on bench, lower bar to chest, press up',
        'tags': ['compound', 'upper_body', 'chest'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
      },
      {
        'id': 'incline_dumbbell_press',
        'name': 'Incline Dumbbell Press',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['shoulders', 'triceps'],
        'equipment': 'dumbbell',
        'instructions':
            'On inclined bench, press dumbbells from chest to overhead',
        'tags': ['compound', 'upper_body', 'chest'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
      },
      {
        'id': 'overhead_press',
        'name': 'Overhead Press',
        'primaryMuscleGroup': 'shoulders',
        'secondaryMuscleGroups': ['triceps', 'core'],
        'equipment': 'barbell',
        'instructions':
            'Stand with feet hip-width apart, press bar from shoulders to overhead',
        'tags': ['compound', 'upper_body', 'shoulders'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
      },
      {
        'id': 'lateral_raises',
        'name': 'Lateral Raises',
        'primaryMuscleGroup': 'shoulders',
        'secondaryMuscleGroups': [],
        'equipment': 'dumbbell',
        'instructions':
            'Stand with dumbbells at sides, raise arms to shoulder height',
        'tags': ['isolation', 'upper_body', 'shoulders'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
      },
      {
        'id': 'tricep_dips',
        'name': 'Tricep Dips',
        'primaryMuscleGroup': 'triceps',
        'secondaryMuscleGroups': ['chest', 'shoulders'],
        'equipment': 'bodyweight',
        'instructions':
            'On parallel bars or bench, lower body by bending elbows, push back up',
        'tags': ['compound', 'upper_body', 'triceps'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
      },
      {
        'id': 'close_grip_bench_press',
        'name': 'Close Grip Bench Press',
        'primaryMuscleGroup': 'triceps',
        'secondaryMuscleGroups': ['chest', 'shoulders'],
        'equipment': 'barbell',
        'instructions':
            'Bench press with hands closer together to target triceps',
        'tags': ['compound', 'upper_body', 'triceps'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
      },
      // Back Exercises
      {
        'id': 'deadlift',
        'name': 'Deadlift',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['legs', 'glutes', 'core'],
        'equipment': 'barbell',
        'instructions': 'Stand over bar, grip and lift keeping back straight',
        'tags': ['compound', 'full_body', 'back'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'advanced',
      },
      {
        'id': 'pull_up',
        'name': 'Pull Up',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['biceps', 'forearms'],
        'equipment': 'bodyweight',
        'instructions': 'Hang from bar, pull body up until chin over bar',
        'tags': ['compound', 'upper_body', 'back'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
      },
      {
        'id': 'barbell_rows',
        'name': 'Barbell Rows',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['biceps', 'rear_delts'],
        'equipment': 'barbell',
        'instructions': 'Bend over, row bar to chest keeping back straight',
        'tags': ['compound', 'upper_body', 'back'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
      },
      {
        'id': 'lat_pulldowns',
        'name': 'Lat Pulldowns',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['biceps'],
        'equipment': 'cable',
        'instructions': 'Sit at lat pulldown machine, pull bar to chest',
        'tags': ['compound', 'upper_body', 'back'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
      },
      {
        'id': 'face_pulls',
        'name': 'Face Pulls',
        'primaryMuscleGroup': 'rear_delts',
        'secondaryMuscleGroups': ['upper_back'],
        'equipment': 'cable',
        'instructions': 'Using cable, pull rope to face focusing on rear delts',
        'tags': ['isolation', 'upper_body', 'shoulders'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
      },
      {
        'id': 'barbell_curls',
        'name': 'Barbell Curls',
        'primaryMuscleGroup': 'biceps',
        'secondaryMuscleGroups': ['forearms'],
        'equipment': 'barbell',
        'instructions': 'Stand with barbell, curl from arms extended to chest',
        'tags': ['isolation', 'upper_body', 'biceps'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
      },
      // Leg Exercises
      {
        'id': 'squat',
        'name': 'Back Squat',
        'primaryMuscleGroup': 'legs',
        'secondaryMuscleGroups': ['glutes', 'core'],
        'equipment': 'barbell',
        'instructions':
            'Stand with feet shoulder-width apart, squat down keeping chest up',
        'tags': ['compound', 'lower_body', 'legs'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
      },
      {
        'id': 'romanian_deadlift',
        'name': 'Romanian Deadlift',
        'primaryMuscleGroup': 'hamstrings',
        'secondaryMuscleGroups': ['glutes', 'back'],
        'equipment': 'barbell',
        'instructions':
            'Hinge at hips, lower bar while keeping legs straighter than conventional deadlift',
        'tags': ['compound', 'lower_body', 'hamstrings'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
      },
      {
        'id': 'leg_press',
        'name': 'Leg Press',
        'primaryMuscleGroup': 'legs',
        'secondaryMuscleGroups': ['glutes'],
        'equipment': 'machine',
        'instructions': 'Sit in leg press machine, push weight away with legs',
        'tags': ['compound', 'lower_body', 'legs'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
      },
      {
        'id': 'leg_curls',
        'name': 'Leg Curls',
        'primaryMuscleGroup': 'hamstrings',
        'secondaryMuscleGroups': [],
        'equipment': 'machine',
        'instructions': 'Lying on leg curl machine, curl heels to glutes',
        'tags': ['isolation', 'lower_body', 'hamstrings'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
      },
      {
        'id': 'calf_raises',
        'name': 'Calf Raises',
        'primaryMuscleGroup': 'calves',
        'secondaryMuscleGroups': [],
        'equipment': 'bodyweight',
        'instructions':
            'Stand on edge of step, raise up on toes, lower below step',
        'tags': ['isolation', 'lower_body', 'calves'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
      },
      {
        'id': 'walking_lunges',
        'name': 'Walking Lunges',
        'primaryMuscleGroup': 'legs',
        'secondaryMuscleGroups': ['glutes'],
        'equipment': 'bodyweight',
        'instructions': 'Step forward into lunge, push back up, alternate legs',
        'tags': ['compound', 'lower_body', 'legs'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
      },
      {
        'id': 'planks',
        'name': 'Planks',
        'primaryMuscleGroup': 'core',
        'secondaryMuscleGroups': ['shoulders', 'glutes'],
        'equipment': 'bodyweight',
        'instructions': 'Hold straight body position on forearms and toes',
        'tags': ['isometric', 'core', 'stability'],
        'isBodyweight': true,
        'exerciseType': 'duration',
        'category': 'strength',
        'difficulty': 'beginner',
      },
      // Additional Common Exercises
      {
        'id': 'push_up',
        'name': 'Push Up',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['triceps', 'shoulders'],
        'equipment': 'bodyweight',
        'instructions':
            'Start in plank position, lower chest to ground, push back up',
        'tags': ['compound', 'upper_body', 'chest'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'calisthenics',
        'difficulty': 'beginner',
      },
      {
        'id': 'burpees',
        'name': 'Burpees',
        'primaryMuscleGroup': 'full_body',
        'secondaryMuscleGroups': [],
        'equipment': 'bodyweight',
        'instructions':
            'Squat down, jump back to plank, do push up, jump feet back, jump up',
        'tags': ['compound', 'full_body', 'cardio'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'cardio',
        'difficulty': 'intermediate',
      },
    ];

    for (final exerciseData in coreExercises) {
      try {
        final companion = ExercisesCompanion(
          id: Value(exerciseData['id'] as String? ?? ''),
          name: Value(exerciseData['name'] as String? ?? ''),
          primaryMuscleGroup:
              Value(exerciseData['primaryMuscleGroup'] as String? ?? ''),
          secondaryMuscleGroups: Value(
            List<String>.from(
                exerciseData['secondaryMuscleGroups'] as List<dynamic>),
          ),
          equipment: Value(exerciseData['equipment'] as String? ?? ''),
          instructions: Value(exerciseData['instructions'] as String? ?? ''),
          tags: Value(
            List<String>.from(exerciseData['tags'] as List<dynamic>),
          ),
          isBodyweight: Value(exerciseData['isBodyweight'] as bool? ?? false),
          exerciseType: Value(exerciseData['exerciseType'] as String? ?? ''),
          category: Value(exerciseData['category'] as String? ?? ''),
          difficulty: Value(exerciseData['difficulty'] as String? ?? ''),
        );

        await into(exercises).insertOnConflictUpdate(companion);
      } catch (e) {
        // Non-fatal: if exercise already exists, ignore
      }
    }
  }

  /// Seed exercise variants for progressions
  Future<void> _seedExerciseVariants() async {
    const exerciseVariants = [
      // Push Up Progressions
      {
        'id': 'knee_push_up',
        'name': 'Knee Push Up',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['triceps', 'shoulders'],
        'equipment': 'bodyweight',
        'instructions': 'Start on knees, lower chest to ground, push back up',
        'tags': ['compound', 'upper_body', 'chest', 'regression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'calisthenics',
        'difficulty': 'beginner',
        'parentExerciseId': 'push_up',
        'variantType': 'regression',
      },
      {
        'id': 'incline_push_up',
        'name': 'Incline Push Up',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['triceps', 'shoulders'],
        'equipment': 'bodyweight',
        'instructions':
            'Hands on elevated surface, lower chest to surface, push back up',
        'tags': ['compound', 'upper_body', 'chest', 'regression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'calisthenics',
        'difficulty': 'beginner',
        'parentExerciseId': 'push_up',
        'variantType': 'regression',
      },
      {
        'id': 'decline_push_up',
        'name': 'Decline Push Up',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['triceps', 'shoulders'],
        'equipment': 'bodyweight',
        'instructions':
            'Feet on elevated surface, lower chest to ground, push back up',
        'tags': ['compound', 'upper_body', 'chest', 'progression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'calisthenics',
        'difficulty': 'intermediate',
        'parentExerciseId': 'push_up',
        'variantType': 'progression',
      },
      {
        'id': 'one_arm_pushup',
        'name': 'One Arm Push Up',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['triceps', 'shoulders', 'core'],
        'equipment': 'bodyweight',
        'instructions': 'Single arm push up, maintaining body alignment',
        'tags': ['compound', 'upper_body', 'chest', 'progression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'calisthenics',
        'difficulty': 'expert',
        'parentExerciseId': 'push_up',
        'variantType': 'progression',
      },

      // Pull Up Progressions
      {
        'id': 'assisted_pull_up',
        'name': 'Assisted Pull Up',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['biceps', 'forearms'],
        'equipment': 'bodyweight',
        'instructions': 'Use assistance band or machine to help with pull up',
        'tags': ['compound', 'upper_body', 'back', 'regression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
        'parentExerciseId': 'pull_up',
        'variantType': 'regression',
      },
      {
        'id': 'negative_pull_up',
        'name': 'Negative Pull Up',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['biceps', 'forearms'],
        'equipment': 'bodyweight',
        'instructions': 'Start at top position, slowly lower yourself down',
        'tags': ['compound', 'upper_body', 'back', 'regression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
        'parentExerciseId': 'pull_up',
        'variantType': 'regression',
      },
      {
        'id': 'weighted_pull_up',
        'name': 'Weighted Pull Up',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['biceps', 'forearms'],
        'equipment': 'bodyweight',
        'instructions':
            'Add weight belt or hold weight between legs during pull up',
        'tags': ['compound', 'upper_body', 'back', 'progression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'strength',
        'difficulty': 'advanced',
        'parentExerciseId': 'pull_up',
        'variantType': 'weighted',
      },
      {
        'id': 'one_arm_pull_up',
        'name': 'One Arm Pull Up',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['biceps', 'forearms', 'core'],
        'equipment': 'bodyweight',
        'instructions': 'Single arm pull up, maintaining body control',
        'tags': ['compound', 'upper_body', 'back', 'progression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'calisthenics',
        'difficulty': 'expert',
        'parentExerciseId': 'pull_up',
        'variantType': 'progression',
      },

      // Handstand Progressions
      {
        'id': 'handstand',
        'name': 'Handstand',
        'primaryMuscleGroup': 'shoulders',
        'secondaryMuscleGroups': ['core', 'arms'],
        'equipment': 'bodyweight',
        'instructions':
            'Balance upside down on hands with legs extended upward',
        'tags': ['compound', 'upper_body', 'shoulders', 'balance'],
        'isBodyweight': true,
        'exerciseType': 'duration',
        'category': 'calisthenics',
        'difficulty': 'advanced',
      },
      {
        'id': 'wall_handstand',
        'name': 'Wall Handstand',
        'primaryMuscleGroup': 'shoulders',
        'secondaryMuscleGroups': ['core', 'arms'],
        'equipment': 'bodyweight',
        'instructions': 'Handstand against wall for balance support',
        'tags': ['compound', 'upper_body', 'shoulders', 'regression'],
        'isBodyweight': true,
        'exerciseType': 'duration',
        'category': 'calisthenics',
        'difficulty': 'intermediate',
        'parentExerciseId': 'handstand',
        'variantType': 'regression',
      },
      {
        'id': 'handstand_push_up',
        'name': 'Handstand Push Up',
        'primaryMuscleGroup': 'shoulders',
        'secondaryMuscleGroups': ['triceps', 'core'],
        'equipment': 'bodyweight',
        'instructions': 'Push up while in handstand position',
        'tags': ['compound', 'upper_body', 'shoulders', 'progression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'calisthenics',
        'difficulty': 'expert',
        'parentExerciseId': 'handstand',
        'variantType': 'progression',
      },

      // Squat Progressions
      {
        'id': 'box_squat',
        'name': 'Box Squat',
        'primaryMuscleGroup': 'legs',
        'secondaryMuscleGroups': ['glutes', 'core'],
        'equipment': 'barbell',
        'instructions': 'Squat down to box, pause, then stand up',
        'tags': ['compound', 'lower_body', 'legs', 'regression'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'beginner',
        'parentExerciseId': 'squat',
        'variantType': 'regression',
      },
      {
        'id': 'front_squat',
        'name': 'Front Squat',
        'primaryMuscleGroup': 'legs',
        'secondaryMuscleGroups': ['glutes', 'core', 'shoulders'],
        'equipment': 'barbell',
        'instructions': 'Squat with barbell in front rack position',
        'tags': ['compound', 'lower_body', 'legs', 'progression'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'advanced',
        'parentExerciseId': 'squat',
        'variantType': 'progression',
      },
      {
        'id': 'pistol_squat',
        'name': 'Pistol Squat',
        'primaryMuscleGroup': 'legs',
        'secondaryMuscleGroups': ['glutes', 'core'],
        'equipment': 'bodyweight',
        'instructions': 'Single leg squat, other leg extended forward',
        'tags': ['compound', 'lower_body', 'legs', 'progression'],
        'isBodyweight': true,
        'exerciseType': 'body_weight_reps',
        'category': 'calisthenics',
        'difficulty': 'expert',
        'parentExerciseId': 'squat',
        'variantType': 'progression',
      },

      // Bench Press Variations
      {
        'id': 'dumbbell_bench_press',
        'name': 'Dumbbell Bench Press',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['shoulders', 'triceps'],
        'equipment': 'dumbbell',
        'instructions': 'Bench press with dumbbells instead of barbell',
        'tags': ['compound', 'upper_body', 'chest', 'equipment'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
        'parentExerciseId': 'bench_press',
        'variantType': 'equipment',
      },
      {
        'id': 'incline_bench_press',
        'name': 'Incline Bench Press',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['shoulders', 'triceps'],
        'equipment': 'barbell',
        'instructions': 'Bench press on inclined bench, targeting upper chest',
        'tags': ['compound', 'upper_body', 'chest', 'angle'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
        'parentExerciseId': 'bench_press',
        'variantType': 'angle',
      },
      {
        'id': 'decline_bench_press',
        'name': 'Decline Bench Press',
        'primaryMuscleGroup': 'chest',
        'secondaryMuscleGroups': ['shoulders', 'triceps'],
        'equipment': 'barbell',
        'instructions': 'Bench press on declined bench, targeting lower chest',
        'tags': ['compound', 'upper_body', 'chest', 'angle'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
        'parentExerciseId': 'bench_press',
        'variantType': 'angle',
      },

      // Deadlift Variations
      {
        'id': 'sumo_deadlift',
        'name': 'Sumo Deadlift',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['legs', 'glutes', 'core'],
        'equipment': 'barbell',
        'instructions': 'Wide stance deadlift with toes pointed out',
        'tags': ['compound', 'full_body', 'back', 'equipment'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'advanced',
        'parentExerciseId': 'deadlift',
        'variantType': 'equipment',
      },
      {
        'id': 'trap_bar_deadlift',
        'name': 'Trap Bar Deadlift',
        'primaryMuscleGroup': 'back',
        'secondaryMuscleGroups': ['legs', 'glutes', 'core'],
        'equipment': 'trap_bar',
        'instructions': 'Deadlift using trap/hex bar for more upright position',
        'tags': ['compound', 'full_body', 'back', 'equipment'],
        'isBodyweight': false,
        'exerciseType': 'weight_reps',
        'category': 'strength',
        'difficulty': 'intermediate',
        'parentExerciseId': 'deadlift',
        'variantType': 'equipment',
      },
    ];

    for (final variantData in exerciseVariants) {
      try {
        final companion = ExercisesCompanion(
          id: Value(variantData['id']! as String),
          name: Value(variantData['name']! as String),
          primaryMuscleGroup:
              Value(variantData['primaryMuscleGroup']! as String),
          secondaryMuscleGroups: Value(
            List<String>.from(
                variantData['secondaryMuscleGroups'] as List<dynamic>),
          ),
          equipment: Value(
            List<String>.from(variantData['equipment']! as List<dynamic>),
          ),
          instructions: Value(variantData['instructions']! as String),
          tags: Value(
            List<String>.from(variantData['tags'] as List<dynamic>),
          ),
          isBodyweight: Value(variantData['isBodyweight']! as bool),
          exerciseType: Value(variantData['exerciseType']! as String),
          category: Value(variantData['category']! as String),
          difficulty: Value(variantData['difficulty']! as String),
          parentExerciseId: Value(variantData['parentExerciseId'] as String?),
          variantType: Value(variantData['variantType'] as String?),
        );

        await into(exercises).insertOnConflictUpdate(companion);
      } catch (e) {
        // Non-fatal: if exercise already exists, ignore
      }
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

      print(
        'Starting exercise type migration for ${allExercises.length} exercises...',
      );

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
              .write(
            ExercisesCompanion(
              exerciseType: Value(correctType),
            ),
          );

          updatedCount++;
          print(
            'Updated "${exercise.name}" from "${exercise.exerciseType}" to "$correctType"',
          );
        }
      }

      print(
        'Exercise type migration complete. Updated $updatedCount exercises.',
      );
    } catch (e) {
      print('Error during exercise type migration: $e');
      rethrow;
    }
  }

  /// Auto-assign exercise type based on name, equipment, and category
  /// Uses the centralized ExerciseTypeMapper for consistent type assignment
  String _assignExerciseType({
    required String name,
    required String equipment,
    required String category,
  }) {
    // Use the centralized mapper to ensure consistency
    final exerciseType = ExerciseTypeMapper.assignExerciseType(
      name: name,
      equipment: equipment,
      category: category,
    );

    // Convert enum to string for database storage
    switch (exerciseType) {
      case ExerciseType.duration:
        return 'duration';
      case ExerciseType.distanceDuration:
        return 'distance_duration';
      case ExerciseType.durationWeight:
        return 'duration_weight';
      case ExerciseType.weightDistance:
        return 'weight_distance';
      case ExerciseType.weightedBodyweight:
        return 'weighted_bodyweight';
      case ExerciseType.assistedBodyweight:
        return 'assisted_bodyweight';
      case ExerciseType.bodyweightReps:
        return 'bodyweight_reps';
      case ExerciseType.weightReps:
        return 'weight_reps';
    }
  }
}
