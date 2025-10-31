import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Web-specific authentication helper that handles JSON decoding issues
class WebAuthHelper {
  /// Safely sign in with email and password, handling web-specific issues
  static Future<AuthResponse> signInWithPasswordSafe({
    required String email,
    required String password,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // Add debug logging for web
      if (kIsWeb) {
        debugPrint('🔍 Web: Attempting sign in for $email');
      }

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Validate response on web
      if (kIsWeb) {
        if (response.user == null) {
          throw Exception('Sign in failed - no user in response');
        }

        if (response.session == null) {
          throw Exception('Sign in failed - no session in response');
        }

        debugPrint('✅ Web: Sign in successful for ${response.user?.email}');
      }

      return response;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Sign in error: $e');

        // Handle specific web JSON decoding errors
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('format exception') ||
            errorString.contains('unexpected character') ||
            errorString.contains('json')) {
          throw Exception(
            'Response format error. Please refresh the page and try again.',
          );
        }
      }

      rethrow;
    }
  }

  /// Safely sign up with email and password, handling web-specific issues
  static Future<AuthResponse> signUpSafe({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // Add debug logging for web
      if (kIsWeb) {
        debugPrint('🔍 Web: Attempting sign up for $email');
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {if (displayName != null) 'display_name': displayName},
      );

      // Validate response on web
      if (kIsWeb) {
        if (response.user == null) {
          throw Exception('Sign up failed - no user in response');
        }

        debugPrint('✅ Web: Sign up successful for ${response.user?.email}');
      }

      return response;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Sign up error: $e');

        // Handle specific web JSON decoding errors
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('format exception') ||
            errorString.contains('unexpected character') ||
            errorString.contains('json')) {
          throw Exception(
            'Response format error. Please refresh the page and try again.',
          );
        }
      }

      rethrow;
    }
  }

  /// Safely handle OAuth sign in for web
  static Future<bool> signInWithOAuthSafe(OAuthProvider provider) async {
    try {
      final supabase = Supabase.instance.client;

      if (kIsWeb) {
        debugPrint('🔍 Web: Attempting OAuth sign in with ${provider.name}');
      }

      final response = await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/auth/callback'
            : 'herq://login-callback/',
      );

      if (kIsWeb) {
        debugPrint('✅ Web: OAuth redirect initiated for ${provider.name}');
      }

      return response;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: OAuth error: $e');

        // Handle specific web JSON decoding errors
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('format exception') ||
            errorString.contains('unexpected character') ||
            errorString.contains('json')) {
          throw Exception('OAuth response format error. Please try again.');
        }
      }

      rethrow;
    }
  }

  /// Check if current session is valid on web
  static bool isSessionValid() {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (kIsWeb) {
        debugPrint('🔍 Web: Current session valid: ${session != null}');
      }

      return session != null;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Session validation error: $e');
      }
      return false;
    }
  }

  /// Get current user safely on web
  static User? getCurrentUser() {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (kIsWeb) {
        debugPrint('🔍 Web: Current user: ${user?.email ?? "None"}');
      }

      return user;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Get user error: $e');
      }
      return null;
    }
  }

  /// Safely sign out on web
  static Future<void> signOutSafe() async {
    try {
      final supabase = Supabase.instance.client;

      if (kIsWeb) {
        debugPrint('🔍 Web: Signing out user');
      }

      await supabase.auth.signOut();

      if (kIsWeb) {
        debugPrint('✅ Web: Sign out successful');
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Sign out error: $e');
      }
      rethrow;
    }
  }
}
