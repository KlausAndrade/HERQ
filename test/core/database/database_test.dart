import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/core/database/database.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Database Tests', () {
    late AppDatabase database;

    setUp(() {
      // Use in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('should initialize database correctly', () {
      expect(database, isA<AppDatabase>());
      // schemaVersion check - just verify it's a valid version
      expect(database.schemaVersion, greaterThan(0));
    });

    group('Exercise Tests', () {
      test('should insert and retrieve exercises', () async {
        // Create test exercise
        final exercise = ExercisesCompanion.insert(
          id: const Uuid().v4(),
          name: 'Test Bench Press',
          primaryMuscleGroup: 'Chest',
          secondaryMuscleGroups: const ['Shoulders', 'Triceps'],
          equipment: 'Barbell',
          instructions: 'Lie on bench and press weight up',
          tags: const ['compound', 'push'],
          isBodyweight: const Value(false),
          exerciseType: const Value('reps'),
          category: const Value('strength'),
          difficulty: const Value('intermediate'),
        );

        // Insert exercise
        await database.into(database.exercises).insert(exercise);

        // Retrieve and verify
        final exercises = await database.select(database.exercises).get();
        expect(exercises.length, greaterThan(0));

        final insertedExercise = exercises.firstWhere(
          (e) => e.name == 'Test Bench Press',
        );
        expect(insertedExercise.primaryMuscleGroup, equals('Chest'));
        expect(insertedExercise.equipment, equals('Barbell'));
        expect(insertedExercise.category, equals('strength'));
      });

      test('should update exercise', () async {
        // Insert exercise
        final exerciseId = const Uuid().v4();
        await database.into(database.exercises).insert(
              ExercisesCompanion.insert(
                id: exerciseId,
                name: 'Test Squat',
                primaryMuscleGroup: 'Legs',
                secondaryMuscleGroups: const ['Glutes'],
                equipment: 'Barbell',
                instructions: 'Squat down',
                tags: const ['compound'],
              ),
            );

        // Update exercise
        await (database.update(database.exercises)
              ..where((e) => e.id.equals(exerciseId)))
            .write(
          const ExercisesCompanion(
            name: Value('Updated Squat'),
            difficulty: Value('advanced'),
          ),
        );

        // Verify update
        final updated = await (database.select(database.exercises)
              ..where((e) => e.id.equals(exerciseId)))
            .getSingle();
        expect(updated.name, equals('Updated Squat'));
        expect(updated.difficulty, equals('advanced'));
      });

      test('should delete exercise', () async {
        // Insert exercise
        final exerciseId = const Uuid().v4();
        await database.into(database.exercises).insert(
              ExercisesCompanion.insert(
                id: exerciseId,
                name: 'Test Deadlift',
                primaryMuscleGroup: 'Back',
                secondaryMuscleGroups: const ['Legs'],
                equipment: 'Barbell',
                instructions: 'Lift from ground',
                tags: const ['compound'],
              ),
            );

        // Delete exercise
        await (database.delete(database.exercises)
              ..where((e) => e.id.equals(exerciseId)))
            .go();

        // Verify deletion
        final exercises = await (database.select(database.exercises)
              ..where((e) => e.id.equals(exerciseId)))
            .get();
        expect(exercises, isEmpty);
      });
    });

    group('Workout Session Tests', () {
      test('should create and retrieve workout session', () async {
        // Create session
        final sessionId = const Uuid().v4();
        final session = WorkoutSessionsCompanion.insert(
          id: sessionId,
          userId: 'test_user', // ✅ USER ISOLATION
          name: 'Test Workout',
          startedAt: DateTime.now(),
          completedAt: Value(DateTime.now().add(const Duration(hours: 1))),
          totalVolume: const Value(5000),
          totalTonnage: const Value(2500),
          totalSets: const Value(15),
          totalReps: const Value(75),
        );

        await database.into(database.workoutSessions).insert(session);

        // Retrieve session
        final sessions = await (database.select(database.workoutSessions)
              ..where((s) => s.id.equals(sessionId)))
            .get();

        expect(sessions.length, equals(1));
        expect(sessions.first.name, equals('Test Workout'));
        expect(sessions.first.totalVolume, equals(5000.0));
        expect(sessions.first.totalSets, equals(15));
      });

      test('should update workout session stats', () async {
        // Create session
        final sessionId = const Uuid().v4();
        await database.into(database.workoutSessions).insert(
              WorkoutSessionsCompanion.insert(
                id: sessionId,
                userId: 'test_user', // ✅ USER ISOLATION
                name: 'Progressive Workout',
                startedAt: DateTime.now(),
              ),
            );

        // Update stats
        await (database.update(database.workoutSessions)
              ..where((s) => s.id.equals(sessionId)))
            .write(
          const WorkoutSessionsCompanion(
            totalVolume: Value(7500),
            totalSets: Value(20),
            totalReps: Value(100),
          ),
        );

        // Verify update
        final updated = await (database.select(database.workoutSessions)
              ..where((s) => s.id.equals(sessionId)))
            .getSingle();
        expect(updated.totalVolume, equals(7500.0));
        expect(updated.totalSets, equals(20));
        expect(updated.totalReps, equals(100));
      });

      test('should handle workout session with sets', () async {
        // Create exercise first
        final exerciseId = const Uuid().v4();
        await database.into(database.exercises).insert(
              ExercisesCompanion.insert(
                id: exerciseId,
                name: 'Test Press',
                primaryMuscleGroup: 'Chest',
                secondaryMuscleGroups: const [],
                equipment: 'Barbell',
                instructions: 'Press weight',
                tags: const [],
              ),
            );

        // Create session
        final sessionId = const Uuid().v4();
        await database.into(database.workoutSessions).insert(
              WorkoutSessionsCompanion.insert(
                id: sessionId,
                userId: 'test_user', // ✅ USER ISOLATION
                name: 'Chest Day',
                startedAt: DateTime.now(),
              ),
            );

        // Add sets to session
        for (int i = 1; i <= 3; i++) {
          await database.into(database.setEntries).insert(
                SetEntriesCompanion.insert(
                  id: const Uuid().v4(),
                  userId: 'test_user',
                  workoutSessionId: sessionId,
                  exerciseId: exerciseId,
                  setNumber: i,
                  reps: 10,
                  completedAt: DateTime.now(),
                  weight: Value(100.0 + (i * 5)),
                ),
              );
        }

        // Verify sets were created
        final sets = await (database.select(database.setEntries)
              ..where((s) => s.workoutSessionId.equals(sessionId)))
            .get();

        expect(sets.length, equals(3));
        expect(sets.first.exerciseId, equals(exerciseId));
        expect(sets.every((s) => s.weight != null), isTrue);
      });
    });

    group('Personal Records Tests', () {
      test('should create and retrieve personal record', () async {
        // Create exercise
        final exerciseId = const Uuid().v4();
        await database.into(database.exercises).insert(
              ExercisesCompanion.insert(
                id: exerciseId,
                name: 'Test Squat',
                primaryMuscleGroup: 'Legs',
                secondaryMuscleGroups: const [],
                equipment: 'Barbell',
                instructions: 'Squat',
                tags: const [],
              ),
            );

        // Create PR
        final prId = const Uuid().v4();
        await database.into(database.personalRecords).insert(
              PersonalRecordsCompanion.insert(
                id: prId,
                userId: 'test_user', // ✅ USER ISOLATION
                exerciseId: exerciseId,
                recordType: '1rm',
                value: 225,
                unit: 'kg',
                achievedAt: DateTime.now(),
                weight: const Value(200),
                reps: const Value(5),
              ),
            );

        // Retrieve PR
        final prs = await (database.select(database.personalRecords)
              ..where((pr) => pr.exerciseId.equals(exerciseId)))
            .get();

        expect(prs.length, equals(1));
        expect(prs.first.weight, equals(200.0));
        expect(prs.first.value, equals(225.0));
      });
    });

    group('Exercise Favorites Tests', () {
      test('should favorite and unfavorite exercise', () async {
        // Create exercise
        final exerciseId = const Uuid().v4();
        await database.into(database.exercises).insert(
              ExercisesCompanion.insert(
                id: exerciseId,
                name: 'Favorite Exercise',
                primaryMuscleGroup: 'Back',
                secondaryMuscleGroups: const [],
                equipment: 'Barbell',
                instructions: 'Instructions',
                tags: const [],
              ),
            );

        // Add to favorites
        const userId = 'test-user-id';
        await database.into(database.exerciseFavorites).insert(
              ExerciseFavoritesCompanion.insert(
                userId: userId,
                exerciseId: exerciseId,
              ),
            );

        // Verify favorite exists
        final favorites =
            await database.select(database.exerciseFavorites).get();
        expect(favorites.any((f) => f.exerciseId == exerciseId), isTrue);

        // Remove from favorites
        await (database.delete(database.exerciseFavorites)
              ..where((f) => f.exerciseId.equals(exerciseId)))
            .go();

        // Verify removed
        final afterRemoval =
            await database.select(database.exerciseFavorites).get();
        expect(afterRemoval.any((f) => f.exerciseId == exerciseId), isFalse);
      });
    });

    group('Gamification Tests', () {
      test('should create and update user stats', () async {
        // Create user stats
        final userId = const Uuid().v4();
        await database.into(database.userStats).insert(
              UserStatsCompanion.insert(
                userId: userId,
                totalWorkouts: const Value(10),
                totalVolumeLifted: const Value(50000),
                currentStreak: const Value(5),
                longestStreak: const Value(10),
                experiencePoints: const Value(500),
                level: const Value(5),
              ),
            );

        // Retrieve and verify
        final stats = await (database.select(database.userStats)
              ..where((s) => s.userId.equals(userId)))
            .getSingle();

        expect(stats.totalWorkouts, equals(10));
        expect(stats.currentStreak, equals(5));
        expect(stats.level, equals(5));

        // Update stats
        await (database.update(database.userStats)
              ..where((s) => s.userId.equals(userId)))
            .write(
          const UserStatsCompanion(
            totalWorkouts: Value(15),
            currentStreak: Value(6),
            experiencePoints: Value(750),
          ),
        );

        // Verify update
        final updated = await (database.select(database.userStats)
              ..where((s) => s.userId.equals(userId)))
            .getSingle();
        expect(updated.totalWorkouts, equals(15));
        expect(updated.currentStreak, equals(6));
        expect(updated.experiencePoints, equals(750));
      });

      test('should unlock achievement', () async {
        // Create achievement
        final userId = const Uuid().v4();
        const achievementId = 'first_workout';

        await database.into(database.userAchievements).insert(
              UserAchievementsCompanion.insert(
                userId: userId,
                achievementId: achievementId,
                unlockedAt: Value(DateTime.now()),
              ),
            );

        // Verify achievement
        final achievements = await (database.select(database.userAchievements)
              ..where((a) => a.userId.equals(userId)))
            .get();

        expect(achievements.length, equals(1));
        expect(achievements.first.achievementId, equals(achievementId));
      });
    });

    group('Workout Template Tests', () {
      test('should create workout template', () async {
        // Create template
        final templateId = const Uuid().v4();
        await database.into(database.workoutTemplates).insert(
              WorkoutTemplatesCompanion.insert(
                id: templateId,
                userId: const Value('test_user'), // ✅ USER ISOLATION
                name: 'Push Day Template',
                exerciseIds: const Value([]),
                tags: const ['push', 'strength'],
                description: const Value('Chest, Shoulders, Triceps'),
              ),
            );

        // Retrieve template
        final templates = await (database.select(database.workoutTemplates)
              ..where((t) => t.id.equals(templateId)))
            .get();

        expect(templates.length, equals(1));
        expect(templates.first.name, equals('Push Day Template'));
      });

      test('should update template', () async {
        // Create template
        final templateId = const Uuid().v4();
        await database.into(database.workoutTemplates).insert(
              WorkoutTemplatesCompanion.insert(
                id: templateId,
                userId: const Value('test_user'), // ✅ USER ISOLATION
                name: 'Original Template',
                exerciseIds: const Value([]),
                tags: const [],
              ),
            );

        // Update template
        await (database.update(database.workoutTemplates)
              ..where((t) => t.id.equals(templateId)))
            .write(
          const WorkoutTemplatesCompanion(
            name: Value('Updated Template'),
            description: Value('Updated description'),
          ),
        );

        // Verify update
        final updated = await (database.select(database.workoutTemplates)
              ..where((t) => t.id.equals(templateId)))
            .getSingle();
        expect(updated.name, equals('Updated Template'));
        expect(updated.description, equals('Updated description'));
      });
    });
  });
}
