import 'package:drift/drift.dart';

// ✅ SCHEMA UPDATE: Now using snake_case to match Supabase exactly
class TemplateFolders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable().named('user_id')(); // ✅ USER ISOLATION: Added to match Supabase
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0)).named('sort_order')();
  TextColumn get color => text().nullable()(); // Hex color for folder
  BoolColumn get isExpanded => boolean().withDefault(const Constant(true)).named('is_expanded')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime).named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}
