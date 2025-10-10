import 'package:drift/drift.dart';
import 'package:drift/native.dart';

// Provide a QueryExecutor for native platforms (used in tests and native builds).
QueryExecutor createInMemoryExecutor() => NativeDatabase.memory();
