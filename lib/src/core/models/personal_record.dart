import 'package:drift/drift.dart';

class PersonalRecords extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // ✅ USER ISOLATION: Link to current user
  TextColumn get exerciseId => text()();
  TextColumn get recordType => text()(); // '1rm', 'volume', 'reps', 'time'
  RealColumn get value => real()();
  TextColumn get unit => text()(); // 'kg', 'lbs', 'reps', 'seconds'
  RealColumn get weight => real().nullable()();
  IntColumn get reps => integer().nullable()();
  TextColumn get workoutSessionId => text().nullable()();
  DateTimeColumn get achievedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
