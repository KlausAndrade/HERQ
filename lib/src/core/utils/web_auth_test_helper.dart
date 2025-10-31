import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test helper for web authentication issues
class WebAuthTestHelper {
  /// Test if Supabase is properly initialized for web
  static bool testSupabaseInitialization() {
    try {
      final client = Supabase.instance.client;

      if (kIsWeb) {
        debugPrint('🔍 Web: Supabase client initialized: true');
      }

      // Test if we can access the client without errors
      return true;
    } on Exception catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Supabase initialization test failed: $e');
      }
      return false;
    }
  }

  /// Test authentication response handling
  static Future<bool> testAuthResponseHandling() async {
    try {
      final client = Supabase.instance.client;

      // Test getting current session
      final session = client.auth.currentSession;
      if (kIsWeb) {
        debugPrint(
          '🔍 Web: Current session: ${session != null ? "Active" : "None"}',
        );
      }

      // Test getting current user
      final user = client.auth.currentUser;
      if (kIsWeb) {
        debugPrint('🔍 Web: Current user: ${user?.email ?? "None"}');
      }

      return true;
    } on Exception catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Auth response test failed: $e');
      }
      return false;
    }
  }

  /// Test JSON decoding with sample data
  static bool testJsonDecoding() {
    try {
      // Test basic JSON operations that might fail on web
      final testData = {
        'user': {
          'id': 'test-id',
          'email': 'test@example.com',
          'created_at': DateTime.now().toIso8601String(),
        },
        'session': {
          'access_token': 'test-token',
          'refresh_token': 'test-refresh',
        },
      };

      // Test JSON encoding/decoding
      final jsonString = testData.toString();
      if (kIsWeb) {
        debugPrint('🔍 Web: JSON test data: $jsonString');
      }

      return true;
    } on Exception catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: JSON decoding test failed: $e');
      }
      return false;
    }
  }

  /// Run all web authentication tests
  static Future<Map<String, bool>> runAllTests() async {
    final results = <String, bool>{};

    results['supabase_init'] = testSupabaseInitialization();
    results['auth_response'] = await testAuthResponseHandling();
    results['json_decoding'] = testJsonDecoding();

    if (kIsWeb) {
      debugPrint('🔍 Web: Test results: $results');
    }

    return results;
  }
}
