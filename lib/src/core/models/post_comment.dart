import 'package:drift/drift.dart';
import 'post.dart';
import 'user.dart';

class PostComments extends Table {
  TextColumn get id => text()();
  TextColumn get postId =>
      text().references(Posts, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get comment => text().withLength(min: 1, max: 500)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
