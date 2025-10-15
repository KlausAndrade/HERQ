// Database seeding helper
// Call this to reload templates and exercises

import '../../features/workout/data/seed/acroyoga_exercises_seed.dart';
import '../../features/workout/data/seed/additional_exercises_seed.dart';
import '../../features/workout/data/seed/core_exercises_seed.dart';
import 'database.dart';

Future<void> seedDatabase(AppDatabase database) async {
  print('🌱 Starting database seeding...');

  // IMPORTANT: Seed exercises BEFORE templates
  // Templates reference exercise IDs, so exercises must exist first

  // Seed core strength exercises first (bench press, squat, deadlift, etc.)
  print('💪 Seeding core strength exercises...');
  await seedCoreExercises(database);

  // Seed additional exercises (Tricep Extension, etc.)
  print('💪 Seeding additional exercises...');
  await seedAdditionalExercises(database);

  // Seed AcroYoga exercises
  print('🧘 Seeding AcroYoga exercises...');
  await seedAcroYogaExercises(database);

  // Then seed templates and folders (includes exercise variants)
  print('📝 Seeding templates and folders...');
  await database.seedDefaultData();

  print('✅ Database seeding complete!');
  print(
    '📊 Core strength exercises, AcroYoga folder with 4 templates and 16 exercises are now available',
  );
}
