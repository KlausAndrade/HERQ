// Stub file for web platform - notifications not available on web

class NotificationService {
  // Stub implementation for web
  NotificationService();
  
  Future<void> initialize() async {
    // No-op on web
  }
  
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // No-op on web
  }
  
  Future<void> cancelAll() async {
    // No-op on web
  }
}
