import 'package:drift/drift.dart';

class ExerciseFavorites extends Table {
  TextColumn get userId => text()();
  TextColumn get exerciseId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId, exerciseId};
}
