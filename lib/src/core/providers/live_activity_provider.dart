import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/live_activity_service.dart';

/// Provider for the live activity service singleton
final liveActivityServiceProvider = Provider<LiveActivityService>((ref) {
  final service = LiveActivityService();

  // Initialize on first access
  service.initialize();

  // Clean up when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
