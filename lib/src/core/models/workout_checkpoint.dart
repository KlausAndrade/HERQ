import 'package:drift/drift.dart';

/// Table for storing incomplete workout checkpoints
/// Allows users to resume workouts if the app is closed unexpectedly
class WorkoutCheckpoints extends Table {
  TextColumn get id => text()();
  TextColumn get workoutName => text().named('workout_name')();
  TextColumn get workoutData =>
      text().named('workout_data')(); // JSON serialized ActiveWorkout
  DateTimeColumn get lastSavedAt => dateTime().named('last_saved_at')();
  DateTimeColumn get startedAt => dateTime().named('started_at')();
  IntColumn get elapsedSeconds => integer().named('elapsed_seconds')();

  @override
  Set<Column> get primaryKey => {id};
}
