import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) {
    throw UnimplementedError('Database is required for analytics');
  }
  return AnalyticsService(db);
});
