import 'package:drift/drift.dart';

class UserStats extends Table {
  TextColumn get userId => text()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get experiencePoints => integer().withDefault(const Constant(0))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWorkoutDate => dateTime().nullable()();
  IntColumn get totalWorkouts => integer().withDefault(const Constant(0))();
  IntColumn get totalSetsCompleted => integer().withDefault(const Constant(0))();
  RealColumn get totalVolumeLifted => real().withDefault(const Constant(0.0))();
  IntColumn get totalWorkoutMinutes => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}
