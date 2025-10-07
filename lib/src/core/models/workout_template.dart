import 'package:drift/drift.dart';
import '../converters/json_converters.dart';

class WorkoutTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('Custom'))();
  TextColumn get folderId => text().nullable()(); // Reference to TemplateFolders
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get exerciseIds => text().map(const StringListConverter()).withDefault(const Constant(''))();
  TextColumn get tags => text().map(const StringListConverter())();
  IntColumn get estimatedDurationMinutes => integer().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
