import 'package:drift/drift.dart';
import 'post.dart';
import 'user.dart';

class PostLikes extends Table {
  TextColumn get id => text()();
  TextColumn get postId =>
      text().references(Posts, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {postId, userId}, // Ensure a user can only like a post once
      ];
}
