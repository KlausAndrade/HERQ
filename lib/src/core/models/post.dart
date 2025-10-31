import 'package:drift/drift.dart';
import 'user.dart';
import 'workout_session.dart';

class Posts extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get caption => text().withLength(min: 0, max: 500)();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get workoutSessionId => text().nullable().references(
    WorkoutSessions,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get likesCount => integer().withDefault(const Constant(0))();
  IntColumn get commentsCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
