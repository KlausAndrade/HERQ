import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper for testing deep link authentication
class DeepLinkTestHelper {
  /// Test if the app can handle Supabase auth callbacks
  static Future<void> testAuthCallback() async {
    if (kDebugMode) {
      print('🧪 Testing auth callback handling...');

      // Check if we have a current session
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        print('✅ Current session exists: ${session.user.email}');
      } else {
        print('❌ No current session');
      }

      // Listen for auth state changes
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        print('🔍 Auth state change: ${data.event}');
        print('🔍 User: ${data.session?.user?.email}');
      });
    }
  }

  /// Simulate a deep link callback (for testing)
  static Future<void> simulateDeepLinkCallback() async {
    if (kDebugMode) {
      print('🧪 Simulating deep link callback...');

      // This would normally come from the deep link
      final testUrl =
          'herq://login-callback/?access_token=test_token&refresh_token=test_refresh';
      print('🔗 Test URL: $testUrl');

      // In a real scenario, this would be handled by the deep link handler
      print('📱 Deep link would be processed by DeepLinkHandler');
    }
  }
}
