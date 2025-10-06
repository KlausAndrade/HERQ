import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get preferences =>
      text().map(const JsonConverter()).withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class JsonConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) => {};

  @override
  String toSql(Map<String, dynamic> value) => '';
}
