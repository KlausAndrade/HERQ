import 'package:drift/drift.dart';
import '../converters/json_converters.dart';

// ✅ SCHEMA UPDATE: Now using snake_case to match Supabase exactly
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable().named('user_id')(); // ✅ USER ISOLATION: Link to user (null = global/admin)
  TextColumn get name => text()();
  TextColumn get primaryMuscleGroup => text().named('primary_muscle_group')();
  TextColumn get secondaryMuscleGroups =>
      text().map(const StringListConverter()).named('secondary_muscle_groups')();
  TextColumn get equipment => text()(); // Keep as string for compatibility, convert to array in sync
  TextColumn get instructions => text()();
  TextColumn get tags => text().map(const StringListConverter())();
  // Optional list of search aliases / synonyms for this exercise (e.g. "hspu" -> "handstand push up").
  // Stored as a JSON text column via StringListConverter. Nullable for backward-compatible migrations.
  TextColumn get aliases =>
      text().map(const StringListConverter()).nullable()();
  BoolColumn get isBodyweight => boolean().withDefault(const Constant(false)).named('is_bodyweight')();

  // New fields for exercise types and variants
  TextColumn get exerciseType => text().withDefault(
        const Constant('reps'),
      ).named('exercise_type')(); // 'reps', 'timer', 'body_weighted', 'assisted'
  TextColumn get category => text().withDefault(
        const Constant(
          'strength',
        ),
      )(); // 'strength', 'calisthenics', 'yoga', 'cardio', 'flexibility'
  TextColumn get parentExerciseId =>
      text().nullable().named('parent_exercise_id')(); // For variants, references the main exercise
  TextColumn get variantType => text()
      .nullable().named('variant_type')(); // 'progression', 'regression', 'equipment', 'angle', etc.
  TextColumn get difficulty => text().withDefault(
        const Constant(
          'intermediate',
        ),
      )(); // 'beginner', 'intermediate', 'advanced', 'expert'

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime).named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
