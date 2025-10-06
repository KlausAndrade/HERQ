import 'package:drift/drift.dart';

class UserAchievements extends Table {
  TextColumn get userId => text()();
  TextColumn get achievementId => text()();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {userId, achievementId};
}
