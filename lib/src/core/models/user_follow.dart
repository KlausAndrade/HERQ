import 'package:drift/drift.dart';

class UserFollows extends Table {
  TextColumn get id => text()();
  TextColumn get followerId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get followingId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {followerId, followingId}, // Ensure a user can only follow another user once
  ];
}
