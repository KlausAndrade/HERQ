import 'package:drift/drift.dart';
import '../converters/json_converters.dart';

// ✅ SCHEMA UPDATE: Now using snake_case to match Supabase exactly
class WorkoutTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable().named(
    'user_id',
  )(); // ✅ USER ISOLATION: Link to current user (null = admin/system-wide)
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('Custom'))();
  TextColumn get folderId =>
      text().nullable().named('folder_id')(); // Reference to TemplateFolders
  IntColumn get sortOrder =>
      integer().withDefault(const Constant(0)).named('sort_order')();
  TextColumn get exerciseIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant(''))
      .named('exercise_ids')();
  TextColumn get tags => text().map(const StringListConverter())();
  IntColumn get estimatedDurationMinutes =>
      integer().nullable().named('estimated_duration')();
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false)).named('is_default')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
