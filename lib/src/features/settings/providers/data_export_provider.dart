import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../services/data_export_service.dart';

/// Provider for data export service
final dataExportServiceProvider = Provider<DataExportService>((ref) {
  final database = ref.watch(databaseProvider);
  if (database == null) throw Exception('Database not initialized');
  return DataExportService(database);
});
