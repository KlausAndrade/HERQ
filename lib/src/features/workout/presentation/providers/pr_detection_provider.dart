import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/services/pr_detection_service.dart';

final prDetectionServiceProvider = Provider<PRDetectionService?>((ref) {
  final database = ref.watch(databaseProvider);
  if (database == null) return null;
  return PRDetectionService(database);
});
