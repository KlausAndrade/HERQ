// Database seeding helper
// Call this to reload templates and exercises

import '../../features/workout/data/seed/acroyoga_exercises_seed.dart';
import '../../features/workout/data/seed/additional_exercises_seed.dart';
import 'database.dart';

Future<void> seedDatabase(AppDatabase database) async {
  print('🌱 Starting database seeding...');

  // IMPORTANT: Seed exercises BEFORE templates
  // Templates reference exercise IDs, so exercises must exist first

  // Seed additional exercises (Tricep Extension, etc.)
  print('💪 Seeding additional exercises...');
  await seedAdditionalExercises(database);

  // Seed AcroYoga exercises
  print('🧘 Seeding AcroYoga exercises...');
  await seedAcroYogaExercises(database);

  // Then seed templates and folders
  print('📝 Seeding templates and folders...');
  await database.seedDefaultData();

  print('✅ Database seeding complete!');
  print(
    '📊 AcroYoga folder with 4 templates and 16 exercises is now available',
  );
}
