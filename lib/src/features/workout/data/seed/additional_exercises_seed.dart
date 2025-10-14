// Additional exercises seed data
// Missing exercises that should be in the database

import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';

const additionalExercises = [
  {
    'id': 'tricep_extension',
    'name': 'Tricep Extension',
    'primaryMuscleGroup': 'triceps',
    'secondaryMuscleGroups': ['shoulders'],
    'equipment': 'dumbbell',
    'instructions': 'Hold weight overhead with both hands. Lower behind head by bending elbows. Extend back to start.',
    'tags': ['triceps', 'arms', 'isolation'],
    'isBodyweight': false,
    'exerciseType': 'weight_reps',
    'category': 'strength',
    'difficulty': 'beginner',
  },
  {
    'id': 'overhead_tricep_extension',
    'name': 'Overhead Tricep Extension',
    'primaryMuscleGroup': 'triceps',
    'secondaryMuscleGroups': ['shoulders'],
    'equipment': 'cable',
    'instructions': 'Using rope attachment on high cable, extend arms overhead. Control the weight down and squeeze at the top.',
    'tags': ['triceps', 'cable', 'isolation'],
    'isBodyweight': false,
    'exerciseType': 'weight_reps',
    'category': 'strength',
    'difficulty': 'intermediate',
  },
  {
    'id': 'skull_crushers',
    'name': 'Skull Crushers',
    'primaryMuscleGroup': 'triceps',
    'secondaryMuscleGroups': [],
    'equipment': 'barbell',
    'instructions': 'Lying on bench, lower bar to forehead by bending elbows. Keep upper arms stationary. Extend back to start.',
    'tags': ['triceps', 'barbell', 'isolation'],
    'isBodyweight': false,
    'exerciseType': 'weight_reps',
    'category': 'strength',
    'difficulty': 'intermediate',
  },
];

Future<void> seedAdditionalExercises(AppDatabase database) async {
  for (final exercise in additionalExercises) {
    await database.into(database.exercises).insertOnConflictUpdate(
      ExercisesCompanion.insert(
        id: exercise['id'] as String,
        name: exercise['name'] as String,
        primaryMuscleGroup: exercise['primaryMuscleGroup'] as String,
        secondaryMuscleGroups: List<String>.from(exercise['secondaryMuscleGroups'] as List),
        equipment: exercise['equipment'] as String,
        instructions: exercise['instructions'] as String,
        tags: List<String>.from(exercise['tags'] as List),
        isBodyweight: Value(exercise['isBodyweight'] as bool),
        exerciseType: Value(exercise['exerciseType'] as String),
        category: Value(exercise['category'] as String),
        difficulty: Value(exercise['difficulty'] as String),
      ),
    );
  }
  print('✓ Seeded ${additionalExercises.length} additional exercises (including Tricep Extension)');
}

