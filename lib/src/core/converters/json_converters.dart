import 'package:drift/drift.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String? fromDb) {
    if (fromDb == null || fromDb.isEmpty) return [];
    return fromDb
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}
