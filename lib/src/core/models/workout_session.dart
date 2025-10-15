import 'package:drift/drift.dart';

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // ✅ USER ISOLATION: Link to current user
  TextColumn get templateId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get totalDurationSeconds => integer().nullable()();
  RealColumn get totalVolume => real().withDefault(const Constant(0))();
  RealColumn get totalTonnage => real().withDefault(const Constant(0))();
  IntColumn get totalSets => integer().withDefault(const Constant(0))();
  IntColumn get totalReps => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

enum WorkoutStatus {
  notStarted,
  inProgress,
  completed,
  cancelled,
}
