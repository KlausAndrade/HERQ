import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

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
import 'package:gym_ai/src/features/workout/data/seed/default_template_seed.dart';

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
  AppDatabase() : super(_openConnection());

  // Test constructor for in-memory database
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (migrator) async {
          await migrator.createAll();
          await _insertDefaultData();
        },
        onUpgrade: (migrator, from, to) async {
          if (to == 12) {
            // Fix workout templates with null exerciseIds
            await customStatement('UPDATE workout_templates SET exercise_ids = \'\' WHERE exercise_ids IS NULL');
          } else if (to == 11) {
            // Add workout checkpoints table for auto-save functionality
            await migrator.createTable(workoutCheckpoints);
          } else if (to == 10) {
            // Add template folders table and folderId to workout templates
            await migrator.createTable(templateFolders);
            await migrator.addColumn(workoutTemplates, workoutTemplates.folderId);
          } else if (to == 9) {
            // Add social media tables
            await migrator.createTable(posts);
            await migrator.createTable(postLikes);
            await migrator.createTable(postComments);
            await migrator.createTable(userFollows);
          } else if (to == 8) {
            // Add gamification tables
            await migrator.createTable(userAchievements);
            await migrator.createTable(userStats);
          } else if (to == 7) {
            // Add exercise favorites table
            await migrator.createTable(exerciseFavorites);
          } else if (to == 6) {
            // Force recreate all tables with new schema for version 6
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
            // Legacy migration for version 5
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

  // Method to force repopulate exercises (for debugging)
  Future<void> forceRepopulateExercises() async {
    await delete(exercises).go();
    await _insertDefaultData();
  }

  Future<void> _insertDefaultData() async {
    // Insert comprehensive exercise library with all categories
    final defaultExercises = [
      // ===== STRENGTH TRAINING =====

      // CHEST EXERCISES
      const ExercisesCompanion(
        id: Value('bench_press'),
        name: Value('Bench Press'),
        primaryMuscleGroup: Value('chest'),
        secondaryMuscleGroups: Value(['shoulders', 'triceps']),
        equipment: Value('barbell'),
        instructions: Value('Lie on bench, lower bar to chest, press up'),
        tags: Value(['compound', 'upper_body']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('push_up'),
        name: Value('Push-up'),
        primaryMuscleGroup: Value('chest'),
        secondaryMuscleGroups: Value(['shoulders', 'triceps', 'core']),
        equipment: Value('bodyweight'),
        instructions:
            Value('Start in plank, lower chest to ground, push back up'),
        tags: Value(['compound', 'upper_body', 'bodyweight']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('chest_dips'),
        name: Value('Chest Dips'),
        primaryMuscleGroup: Value('chest'),
        secondaryMuscleGroups: Value(['triceps', 'shoulders']),
        equipment: Value('dip_bars'),
        instructions: Value('Lower body between bars, push back up'),
        tags: Value(['compound', 'upper_body', 'bodyweight']),
        isBodyweight: Value(true),
        exerciseType: Value('body_weighted'),
        category: Value('calisthenics'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('weighted_dips'),
        name: Value('Weighted Dips'),
        primaryMuscleGroup: Value('chest'),
        secondaryMuscleGroups: Value(['triceps', 'shoulders']),
        equipment: Value('dip_bars'),
        instructions: Value('Perform dips with additional weight attached'),
        tags: Value(['compound', 'upper_body', 'weighted']),
        isBodyweight: Value(false),
        exerciseType: Value('body_weighted'),
        category: Value('calisthenics'),
        parentExerciseId: Value('chest_dips'),
        variantType: Value('weighted'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('assisted_dips'),
        name: Value('Assisted Dips'),
        primaryMuscleGroup: Value('chest'),
        secondaryMuscleGroups: Value(['triceps', 'shoulders']),
        equipment: Value('assistance_machine'),
        instructions:
            Value('Perform dips with assistance to reduce body weight'),
        tags: Value(['compound', 'upper_body', 'assisted']),
        isBodyweight: Value(true),
        exerciseType: Value('assisted'),
        category: Value('calisthenics'),
        parentExerciseId: Value('chest_dips'),
        variantType: Value('assisted'),
        difficulty: Value('beginner'),
      ),

      // ===== CALISTHENICS =====

      // Advanced Calisthenics
      const ExercisesCompanion(
        id: Value('muscle_up'),
        name: Value('Muscle Up'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['chest', 'shoulders', 'triceps', 'core']),
        equipment: Value('pull_up_bar'),
        instructions:
            Value('Pull up and transition over the bar in one fluid motion'),
        tags: Value(['advanced', 'compound', 'explosive']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('strict_muscle_up'),
        name: Value('Strict Muscle Up'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['chest', 'shoulders', 'triceps', 'core']),
        equipment: Value('pull_up_bar'),
        instructions: Value('Muscle up without momentum or kipping motion'),
        tags: Value(['expert', 'compound', 'strict']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        parentExerciseId: Value('muscle_up'),
        variantType: Value('strict'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('ring_muscle_up'),
        name: Value('Ring Muscle Up'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['chest', 'shoulders', 'triceps', 'core']),
        equipment: Value('gymnastic_rings'),
        instructions: Value('Muscle up performed on gymnastic rings'),
        tags: Value(['expert', 'compound', 'rings']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        parentExerciseId: Value('muscle_up'),
        variantType: Value('equipment'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('planche'),
        name: Value('Planche'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['chest', 'triceps', 'core', 'back']),
        equipment: Value('bodyweight'),
        instructions:
            Value('Hold body horizontal with hands on ground, legs extended'),
        tags: Value(['expert', 'isometric', 'balance']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('full_planche'),
        name: Value('Full Planche'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['chest', 'triceps', 'core', 'back']),
        equipment: Value('bodyweight'),
        instructions: Value(
            'Perfect horizontal body position with straight arms and legs'),
        tags: Value(['expert', 'isometric', 'balance']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        parentExerciseId: Value('planche'),
        variantType: Value('progression'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('tucked_planche'),
        name: Value('Tucked Planche'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['chest', 'triceps', 'core']),
        equipment: Value('bodyweight'),
        instructions: Value('Planche with knees tucked to chest'),
        tags: Value(['advanced', 'isometric', 'balance']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        parentExerciseId: Value('planche'),
        variantType: Value('regression'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('advanced_tucked_planche'),
        name: Value('Advanced Tucked Planche'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['chest', 'triceps', 'core']),
        equipment: Value('bodyweight'),
        instructions: Value('Tucked planche with knees closer to chest'),
        tags: Value(['advanced', 'isometric', 'balance']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        parentExerciseId: Value('planche'),
        variantType: Value('progression'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('straddle_planche'),
        name: Value('Straddle Planche'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['chest', 'triceps', 'core', 'back']),
        equipment: Value('bodyweight'),
        instructions: Value('Planche with legs spread wide apart'),
        tags: Value(['expert', 'isometric', 'balance']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        parentExerciseId: Value('planche'),
        variantType: Value('progression'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('human_flag'),
        name: Value('Human Flag'),
        primaryMuscleGroup: Value('core'),
        secondaryMuscleGroups: Value(['shoulders', 'back', 'arms']),
        equipment: Value('vertical_pole'),
        instructions: Value('Hold body horizontal against a vertical pole'),
        tags: Value(['expert', 'isometric', 'lateral']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('human_flag_progression'),
        name: Value('Human Flag Negatives'),
        primaryMuscleGroup: Value('core'),
        secondaryMuscleGroups: Value(['shoulders', 'back', 'arms']),
        equipment: Value('vertical_pole'),
        instructions: Value('Lower slowly from horizontal position'),
        tags: Value(['advanced', 'negative', 'lateral']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        parentExerciseId: Value('human_flag'),
        variantType: Value('progression'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('front_lever'),
        name: Value('Front Lever'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['core', 'shoulders', 'arms']),
        equipment: Value('pull_up_bar'),
        instructions: Value('Hold body horizontal under the bar, face up'),
        tags: Value(['expert', 'isometric', 'back']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('back_lever'),
        name: Value('Back Lever'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['core', 'shoulders', 'biceps']),
        equipment: Value('pull_up_bar'),
        instructions: Value('Hold body horizontal under the bar, face down'),
        tags: Value(['expert', 'isometric', 'back']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('one_arm_pushup'),
        name: Value('One Arm Push-up'),
        primaryMuscleGroup: Value('chest'),
        secondaryMuscleGroups: Value(['shoulders', 'triceps', 'core']),
        equipment: Value('bodyweight'),
        instructions: Value('Push-up performed with one arm'),
        tags: Value(['expert', 'unilateral', 'upper_body']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        difficulty: Value('expert'),
        parentExerciseId: Value('push_up'),
        variantType: Value('progression'),
      ),
      const ExercisesCompanion(
        id: Value('handstand'),
        name: Value('Handstand'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['triceps', 'core', 'forearms']),
        equipment: Value('bodyweight'),
        instructions: Value('Balance inverted on hands'),
        tags: Value(['balance', 'isometric', 'inversion']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('freestanding_handstand'),
        name: Value('Freestanding Handstand'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['triceps', 'core', 'forearms']),
        equipment: Value('bodyweight'),
        instructions: Value('Handstand without wall support'),
        tags: Value(['balance', 'isometric', 'inversion']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        parentExerciseId: Value('handstand'),
        variantType: Value('progression'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('wall_handstand'),
        name: Value('Wall Handstand'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['triceps', 'core', 'forearms']),
        equipment: Value('wall'),
        instructions: Value('Handstand with feet against wall for support'),
        tags: Value(['balance', 'isometric', 'inversion']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('calisthenics'),
        parentExerciseId: Value('handstand'),
        variantType: Value('assisted'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('handstand_push_up'),
        name: Value('Handstand Push-up'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['triceps', 'core']),
        equipment: Value('wall'),
        instructions: Value('Push-up while in handstand position'),
        tags: Value(['compound', 'upper_body', 'inversion']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        difficulty: Value('expert'),
        parentExerciseId: Value('handstand'),
        variantType: Value('progression'),
      ),

      // ===== ACCESSORY & COMMON EXERCISES MISSING FROM SEED =====
      const ExercisesCompanion(
        id: Value('incline_dumbbell_press'),
        name: Value('Incline Dumbbell Press'),
        primaryMuscleGroup: Value('chest'),
        secondaryMuscleGroups: Value(['shoulders', 'triceps']),
        equipment: Value('dumbbells'),
        instructions: Value('Press dumbbells from an inclined bench'),
        tags: Value(['upper_body', 'compound']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
        parentExerciseId: Value('bench_press'),
        variantType: Value('equipment'),
      ),
      const ExercisesCompanion(
        id: Value('lateral_raises'),
        name: Value('Lateral Raises'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['traps']),
        equipment: Value('dumbbells'),
        instructions: Value('Raise dumbbells to side to shoulder height'),
        tags: Value(['isolation', 'shoulders']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
      // Additional accessory / variants
      const ExercisesCompanion(
        id: Value('dumbbell_shoulder_press'),
        name: Value('Dumbbell Shoulder Press'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['triceps']),
        equipment: Value('dumbbells'),
        instructions: Value('Press dumbbells overhead from shoulder height'),
        tags: Value(['shoulders', 'equipment', 'upper_body']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
        parentExerciseId: Value('overhead_press'),
        variantType: Value('equipment'),
      ),
      const ExercisesCompanion(
        id: Value('seated_cable_rows'),
        name: Value('Seated Cable Rows'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['biceps']),
        equipment: Value('cable_machine'),
        instructions: Value('Sit and pull cable handle to torso focusing on scapular retraction'),
        tags: Value(['back', 'equipment']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('beginner'),
        parentExerciseId: Value('barbell_rows'),
        variantType: Value('equipment'),
      ),
      const ExercisesCompanion(
        id: Value('tricep_dips'),
        name: Value('Tricep Dips'),
        primaryMuscleGroup: Value('triceps'),
        secondaryMuscleGroups: Value(['chest', 'shoulders']),
        equipment: Value('dip_bars'),
        instructions: Value('Lower body between bars keeping torso more upright to emphasize triceps, push back up'),
        tags: Value(['triceps', 'compound', 'bodyweight']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        difficulty: Value('intermediate'),
        parentExerciseId: Value('chest_dips'),
        variantType: Value('focus'),
      ),
      const ExercisesCompanion(
        id: Value('close_grip_bench_press'),
        name: Value('Close-grip Bench Press'),
        primaryMuscleGroup: Value('triceps'),
        secondaryMuscleGroups: Value(['chest', 'shoulders']),
        equipment: Value('barbell'),
        instructions: Value('Bench press with narrow grip to emphasize triceps'),
        tags: Value(['compound', 'triceps']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('barbell_rows'),
        name: Value('Barbell Rows'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['biceps']),
        equipment: Value('barbell'),
        instructions: Value('Row barbell to the torso with a hinged back'),
        tags: Value(['compound', 'back']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('lat_pulldowns'),
        name: Value('Lat Pulldowns'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['biceps']),
        equipment: Value('cable_machine'),
        instructions: Value('Pull bar down to chest to target latissimus dorsi'),
        tags: Value(['back', 'isolation']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('face_pulls'),
        name: Value('Face Pulls'),
        primaryMuscleGroup: Value('rear_delts'),
        secondaryMuscleGroups: Value(['traps', 'upper_back']),
        equipment: Value('cable'),
        instructions: Value('Pull rope towards face focusing on rear delts'),
        tags: Value(['shoulders', 'rehab']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('barbell_curls'),
        name: Value('Barbell Curls'),
        primaryMuscleGroup: Value('biceps'),
        secondaryMuscleGroups: Value(['forearms']),
        equipment: Value('barbell'),
        instructions: Value('Curl barbell up keeping elbows fixed'),
        tags: Value(['arms', 'isolation']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('romanian_deadlift'),
        name: Value('Romanian Deadlift'),
        primaryMuscleGroup: Value('hamstrings'),
        secondaryMuscleGroups: Value(['glutes', 'back']),
        equipment: Value('barbell'),
        instructions: Value('Hinge at hips and lower bar while keeping back straight'),
        tags: Value(['hinge', 'posterior_chain']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('leg_press'),
        name: Value('Leg Press'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['quads', 'glutes']),
        equipment: Value('leg_press_machine'),
        instructions: Value('Press platform using legs while seated'),
        tags: Value(['legs', 'machine']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('leg_curls'),
        name: Value('Leg Curls'),
        primaryMuscleGroup: Value('hamstrings'),
        secondaryMuscleGroups: Value(['glutes']),
        equipment: Value('machine'),
        instructions: Value('Curl heels toward glutes while lying or seated'),
        tags: Value(['isolation', 'hamstrings']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('calf_raises'),
        name: Value('Calf Raises'),
        primaryMuscleGroup: Value('calves'),
        secondaryMuscleGroups: Value([]),
        equipment: Value('bodyweight'),
        instructions: Value('Raise heels to stand on toes'),
        tags: Value(['calves', 'isolation']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('walking_lunges'),
        name: Value('Walking Lunges'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['glutes', 'core']),
        equipment: Value('bodyweight'),
        instructions: Value('Step forward into lunges alternating legs'),
        tags: Value(['legs', 'unilateral']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('planks'),
        name: Value('Plank'),
        primaryMuscleGroup: Value('core'),
        secondaryMuscleGroups: Value(['shoulders', 'back']),
        equipment: Value('bodyweight'),
        instructions: Value('Hold a straight-body plank on forearms or hands'),
        tags: Value(['core', 'isometric']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('strength'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('weighted_pull_up'),
        name: Value('Weighted Pull-up'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['biceps']),
        equipment: Value('pull_up_bar'),
        instructions: Value('Perform pull-ups with added external weight'),
        tags: Value(['pull', 'weighted']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        difficulty: Value('advanced'),
        parentExerciseId: Value('pull_up'),
        variantType: Value('weighted'),
      ),
      const ExercisesCompanion(
        id: Value('barbell_bench_press'),
        name: Value('Barbell Bench Press'),
        primaryMuscleGroup: Value('chest'),
        secondaryMuscleGroups: Value(['shoulders', 'triceps']),
        equipment: Value('barbell'),
        instructions: Value('Perform bench press with barbell'),
        tags: Value(['bench', 'strength']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('front_squats'),
        name: Value('Front Squat'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['core', 'quads']),
        equipment: Value('barbell'),
        instructions: Value('Barbell rests on front of shoulders, squat down'),
        tags: Value(['squat', 'strength']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('kettlebell_swings'),
        name: Value('Kettlebell Swings'),
        primaryMuscleGroup: Value('glutes'),
        secondaryMuscleGroups: Value(['hamstrings', 'back', 'core']),
        equipment: Value('kettlebell'),
        instructions: Value('Swing kettlebell using hip hinge, powerful extension'),
        tags: Value(['cardio', 'conditioning']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('cardio'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('sprint'),
        name: Value('Sprint'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['cardiovascular']),
        equipment: Value('track'),
        instructions: Value('Short maximal effort run'),
        tags: Value(['cardio', 'sprint']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('cardio'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('jump_rope'),
        name: Value('Jump Rope'),
        primaryMuscleGroup: Value('full_body'),
        secondaryMuscleGroups: Value(['cardiovascular']),
        equipment: Value('jump_rope'),
        instructions: Value('Continuous rope jumps for conditioning'),
        tags: Value(['cardio', 'conditioning']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('cardio'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('box_jumps'),
        name: Value('Box Jumps'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['glutes', 'core']),
        equipment: Value('plyo_box'),
        instructions: Value('Jump onto a box from standing position'),
        tags: Value(['plyometrics', 'power']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('cardio'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('row'),
        name: Value('Row (Erg)'),
        primaryMuscleGroup: Value('full_body'),
        secondaryMuscleGroups: Value(['cardiovascular']),
        equipment: Value('ergometer'),
        instructions: Value('Row on the erg for distance or time'),
        tags: Value(['cardio', 'conditioning']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('cardio'),
        difficulty: Value('beginner'),
      ),

      // ===== YOGA EXERCISES =====

      // Sun Salutation Series
      const ExercisesCompanion(
        id: Value('mountain_pose'),
        name: Value('Mountain Pose (Tadasana)'),
        primaryMuscleGroup: Value('core'),
        secondaryMuscleGroups: Value(['legs', 'back']),
        equipment: Value('yoga_mat'),
        instructions: Value(
            'Stand tall with feet together, arms at sides, spine straight'),
        tags: Value(['standing', 'foundation', 'balance']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('downward_dog'),
        name: Value('Downward Facing Dog (Adho Mukha Svanasana)'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['hamstrings', 'calves', 'arms']),
        equipment: Value('yoga_mat'),
        instructions: Value('Inverted V-shape, hands and feet on ground'),
        tags: Value(['inversion', 'stretch', 'strength']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('upward_dog'),
        name: Value('Upward Facing Dog (Urdhva Mukha Svanasana)'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['chest', 'shoulders', 'arms']),
        equipment: Value('yoga_mat'),
        instructions:
            Value('Open chest, straight arms, tops of feet on ground'),
        tags: Value(['backbend', 'chest_opener', 'strength']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('cobra_pose'),
        name: Value('Cobra Pose (Bhujangasana)'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['chest', 'shoulders']),
        equipment: Value('yoga_mat'),
        instructions: Value('Lift chest off ground, forearms supporting'),
        tags: Value(['backbend', 'chest_opener', 'prone']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('child_pose'),
        name: Value('Child\'s Pose (Balasana)'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['hips', 'shoulders']),
        equipment: Value('yoga_mat'),
        instructions:
            Value('Kneel and fold forward, arms extended or at sides'),
        tags: Value(['restorative', 'hip_opener', 'relaxation']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('warrior_1'),
        name: Value('Warrior I (Virabhadrasana I)'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['core', 'shoulders']),
        equipment: Value('yoga_mat'),
        instructions: Value('Lunge position with arms raised overhead'),
        tags: Value(['standing', 'hip_opener', 'strength']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('warrior_2'),
        name: Value('Warrior II (Virabhadrasana II)'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['core', 'shoulders']),
        equipment: Value('yoga_mat'),
        instructions: Value('Wide leg lunge with arms parallel to ground'),
        tags: Value(['standing', 'hip_opener', 'strength']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('warrior_3'),
        name: Value('Warrior III (Virabhadrasana III)'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['core', 'glutes', 'back']),
        equipment: Value('yoga_mat'),
        instructions: Value('Balance on one leg, body parallel to ground'),
        tags: Value(['balance', 'standing', 'strength']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('tree_pose'),
        name: Value('Tree Pose (Vrikshasana)'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['core', 'glutes']),
        equipment: Value('yoga_mat'),
        instructions: Value('Stand on one leg, other foot on inner thigh'),
        tags: Value(['balance', 'standing', 'hip_opener']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('triangle_pose'),
        name: Value('Triangle Pose (Trikonasana)'),
        primaryMuscleGroup: Value('core'),
        secondaryMuscleGroups: Value(['legs', 'shoulders']),
        equipment: Value('yoga_mat'),
        instructions: Value('Wide leg forward fold with hand to floor/block'),
        tags: Value(['standing', 'side_bend', 'stretch']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('pigeon_pose'),
        name: Value('Pigeon Pose (Eka Pada Rajakapotasana)'),
        primaryMuscleGroup: Value('hips'),
        secondaryMuscleGroups: Value(['glutes', 'hip_flexors']),
        equipment: Value('yoga_mat'),
        instructions: Value('One leg forward bent, other leg extended back'),
        tags: Value(['hip_opener', 'seated', 'stretch']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('lotus_pose'),
        name: Value('Lotus Pose (Padmasana)'),
        primaryMuscleGroup: Value('hips'),
        secondaryMuscleGroups: Value(['core', 'spine']),
        equipment: Value('yoga_mat'),
        instructions: Value('Cross-legged with feet on opposite thighs'),
        tags: Value(['seated', 'hip_opener', 'meditation']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('seated_forward_fold'),
        name: Value('Seated Forward Fold (Paschimottanasana)'),
        primaryMuscleGroup: Value('hamstrings'),
        secondaryMuscleGroups: Value(['back', 'calves']),
        equipment: Value('yoga_mat'),
        instructions: Value('Sit with legs extended, fold forward over legs'),
        tags: Value(['seated', 'forward_fold', 'stretch']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('beginner'),
      ),
        const ExercisesCompanion(
          id: Value('forward_fold'),
          name: Value('Forward Fold'),
          primaryMuscleGroup: Value('hamstrings'),
          secondaryMuscleGroups: Value(['back', 'core']),
          equipment: Value('yoga_mat'),
          instructions: Value('Stand with feet together and fold forward at the hips'),
          tags: Value(['yoga','stretch']),
          isBodyweight: Value(true),
          exerciseType: Value('timer'),
          category: Value('yoga'),
          difficulty: Value('beginner'),
        ),
      const ExercisesCompanion(
        id: Value('camel_pose'),
        name: Value('Camel Pose (Ustrasana)'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['chest', 'hip_flexors', 'shoulders']),
        equipment: Value('yoga_mat'),
        instructions: Value('Kneeling backbend, hands to heels'),
        tags: Value(['backbend', 'kneeling', 'chest_opener']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('bridge_pose'),
        name: Value('Bridge Pose (Setu Bandhasana)'),
        primaryMuscleGroup: Value('glutes'),
        secondaryMuscleGroups: Value(['hamstrings', 'back', 'core']),
        equipment: Value('yoga_mat'),
        instructions: Value('Lie on back, lift hips up, shoulders on ground'),
        tags: Value(['backbend', 'supine', 'glute_activation']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('wheel_pose'),
        name: Value('Wheel Pose (Urdhva Dhanurasana)'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['shoulders', 'arms', 'legs']),
        equipment: Value('yoga_mat'),
        instructions: Value('Full backbend with hands and feet on ground'),
        tags: Value(['backbend', 'inversion', 'advanced']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('crow_pose'),
        name: Value('Crow Pose (Bakasana)'),
        primaryMuscleGroup: Value('arms'),
        secondaryMuscleGroups: Value(['core', 'shoulders']),
        equipment: Value('yoga_mat'),
        instructions: Value('Balance on hands with knees on upper arms'),
        tags: Value(['arm_balance', 'core', 'balance']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('headstand'),
        name: Value('Headstand (Sirsasana)'),
        primaryMuscleGroup: Value('core'),
        secondaryMuscleGroups: Value(['shoulders', 'arms', 'neck']),
        equipment: Value('yoga_mat'),
        instructions: Value('Balance inverted on head and forearms'),
        tags: Value(['inversion', 'balance', 'core']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('advanced'),
      ),
      const ExercisesCompanion(
        id: Value('forearm_stand'),
        name: Value('Forearm Stand (Pincha Mayurasana)'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['core', 'back', 'arms']),
        equipment: Value('yoga_mat'),
        instructions: Value('Balance inverted on forearms'),
        tags: Value(['inversion', 'balance', 'advanced']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('expert'),
      ),
      const ExercisesCompanion(
        id: Value('side_plank'),
        name: Value('Side Plank (Vasisthasana)'),
        primaryMuscleGroup: Value('core'),
        secondaryMuscleGroups: Value(['shoulders', 'arms', 'obliques']),
        equipment: Value('yoga_mat'),
        instructions: Value('Hold plank position on one side'),
        tags: Value(['core', 'balance', 'isometric']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('yoga'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('sun_salutation_a'),
        name: Value('Sun Salutation A (Surya Namaskara A)'),
        primaryMuscleGroup: Value('full_body'),
        secondaryMuscleGroups: Value(['all']),
        equipment: Value('yoga_mat'),
        instructions: Value(
            'Complete sequence: Mountain -> Forward Fold -> Low Push-up -> Upward Dog -> Downward Dog'),
        tags: Value(['flow', 'sequence', 'vinyasa']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('yoga'),
        difficulty: Value('intermediate'),
      ),

      // ===== CARDIO/CONDITIONING =====

      const ExercisesCompanion(
        id: Value('treadmill_walk'),
        name: Value('Treadmill Walk'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['cardiovascular']),
        equipment: Value('treadmill'),
        instructions: Value('Walk at steady pace on treadmill'),
        tags: Value(['cardio', 'low_impact', 'endurance']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('cardio'),
        difficulty: Value('beginner'),
      ),
      const ExercisesCompanion(
        id: Value('treadmill_run'),
        name: Value('Treadmill Run'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['cardiovascular']),
        equipment: Value('treadmill'),
        instructions: Value('Run at moderate to high pace on treadmill'),
        tags: Value(['cardio', 'running', 'endurance']),
        isBodyweight: Value(true),
        exerciseType: Value('timer'),
        category: Value('cardio'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('burpees'),
        name: Value('Burpees'),
        primaryMuscleGroup: Value('full_body'),
        secondaryMuscleGroups: Value(['cardiovascular']),
        equipment: Value('bodyweight'),
        instructions:
            Value('Squat, jump back to plank, push-up, jump forward, jump up'),
        tags: Value(['cardio', 'full_body', 'explosive']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('cardio'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('mountain_climbers'),
        name: Value('Mountain Climbers'),
        primaryMuscleGroup: Value('core'),
        secondaryMuscleGroups: Value(['legs', 'shoulders', 'cardiovascular']),
        equipment: Value('bodyweight'),
        instructions:
            Value('Plank position, alternate bringing knees to chest'),
        tags: Value(['cardio', 'core', 'dynamic']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('cardio'),
        difficulty: Value('intermediate'),
      ),

      // ===== BASIC STRENGTH EXERCISES =====

      const ExercisesCompanion(
        id: Value('pull_up'),
        name: Value('Pull-up'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['biceps']),
        equipment: Value('pull_up_bar'),
        instructions: Value('Hang from bar, pull body up until chin over bar'),
        tags: Value(['compound', 'upper_body', 'bodyweight']),
        isBodyweight: Value(true),
        exerciseType: Value('reps'),
        category: Value('calisthenics'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('squat'),
        name: Value('Back Squat'),
        primaryMuscleGroup: Value('legs'),
        secondaryMuscleGroups: Value(['glutes', 'core']),
        equipment: Value('barbell'),
        instructions: Value(
            'Stand with feet shoulder-width apart, squat down keeping chest up'),
        tags: Value(['compound', 'lower_body']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('deadlift'),
        name: Value('Deadlift'),
        primaryMuscleGroup: Value('back'),
        secondaryMuscleGroups: Value(['legs', 'glutes', 'core']),
        equipment: Value('barbell'),
        instructions:
            Value('Stand over bar, grip and lift keeping back straight'),
        tags: Value(['compound', 'full_body']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
      const ExercisesCompanion(
        id: Value('overhead_press'),
        name: Value('Overhead Press'),
        primaryMuscleGroup: Value('shoulders'),
        secondaryMuscleGroups: Value(['triceps', 'core']),
        equipment: Value('barbell'),
        instructions: Value('Press bar overhead from shoulder level'),
        tags: Value(['compound', 'upper_body']),
        isBodyweight: Value(false),
        exerciseType: Value('reps'),
        category: Value('strength'),
        difficulty: Value('intermediate'),
      ),
    ];

    for (final exercise in defaultExercises) {
      // Use insertOnConflictUpdate to make the seeder idempotent. This
      // allows calling the seeder multiple times (e.g., onCreate and in tests)
      // without violating unique constraints.
      await into(exercises).insertOnConflictUpdate(exercise);
    }

    // Insert default workout templates
    // Insert folders and templates from the centralized seed
    // Convert seed data maps to Companion objects to avoid circular types
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

      // category is a non-nullable String inside Value<String> in the companion
      // only set it when the seed provides a non-null value to avoid
      // passing a String? into Value<String> which causes a type error.
      final cat = t['category'] as String?;
      if (cat != null) {
        companion = companion.copyWith(category: Value(cat));
      }

      await into(workoutTemplates).insertOnConflictUpdate(companion);
    }
  }

  // Public wrapper for seeding default data in tests/CI
  Future<void> seedDefaultData() async => _insertDefaultData();
}

LazyDatabase _openConnection() => LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'gym_ai.db'));

      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
