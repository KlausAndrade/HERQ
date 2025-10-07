import 'package:drift/drift.dart';

/// Table for storing incomplete workout checkpoints
/// Allows users to resume workouts if the app is closed unexpectedly
class WorkoutCheckpoints extends Table {
  TextColumn get id => text()();
  TextColumn get workoutName => text()();
  TextColumn get workoutData => text()(); // JSON serialized ActiveWorkout
  DateTimeColumn get lastSavedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get elapsedSeconds => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
