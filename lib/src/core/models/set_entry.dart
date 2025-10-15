import 'package:drift/drift.dart';

class SetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // ✅ USER ISOLATION: Link to current user
  TextColumn get workoutSessionId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real().nullable()();
  IntColumn get reps => integer()();
  IntColumn get rpe =>
      integer().nullable()(); // Rate of Perceived Exertion (1-10)
  IntColumn get restDurationSeconds => integer().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();
  BoolColumn get isDropSet => boolean().withDefault(const Constant(false))();
  BoolColumn get isFailure => boolean().withDefault(const Constant(false))();

  // New fields for different exercise types and supersets
  TextColumn get setType => text().withDefault(
        const Constant('working'),
      )(); // 'warmup', 'working', 'drop', 'failure'
  TextColumn get supersetId =>
      text().nullable()(); // Groups exercises in a superset
  IntColumn get supersetOrder =>
      integer().nullable()(); // Order within superset
  IntColumn get durationSeconds =>
      integer().nullable()(); // For timer-based exercises
  RealColumn get assistanceWeight =>
      real().nullable()(); // For assisted exercises (negative weight)
  RealColumn get addedWeight =>
      real().nullable()(); // For body weighted exercises (additional weight)
  RealColumn get distance =>
      real().nullable()(); // For distance-based exercises (stored in meters)
  TextColumn get equipmentUsed =>
      text().nullable()(); // Equipment variant (barbell, dumbbell, cable, etc)
  TextColumn get variantType =>
      text().nullable()(); // Variant type (standard, assisted, weighted, etc)

  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
