import 'package:drift/drift.dart';
import '../converters/json_converters.dart';

class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get primaryMuscleGroup => text()();
  TextColumn get secondaryMuscleGroups => text().map(const StringListConverter())();
  TextColumn get equipment => text()();
  TextColumn get instructions => text()();
  TextColumn get tags => text().map(const StringListConverter())();
  BoolColumn get isBodyweight => boolean().withDefault(const Constant(false))();
  
  // New fields for exercise types and variants
  TextColumn get exerciseType => text().withDefault(const Constant('reps'))(); // 'reps', 'timer', 'body_weighted', 'assisted'
  TextColumn get category => text().withDefault(const Constant('strength'))(); // 'strength', 'calisthenics', 'yoga', 'cardio', 'flexibility'
  TextColumn get parentExerciseId => text().nullable()(); // For variants, references the main exercise
  TextColumn get variantType => text().nullable()(); // 'progression', 'regression', 'equipment', 'angle', etc.
  TextColumn get difficulty => text().withDefault(const Constant('intermediate'))(); // 'beginner', 'intermediate', 'advanced', 'expert'
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}