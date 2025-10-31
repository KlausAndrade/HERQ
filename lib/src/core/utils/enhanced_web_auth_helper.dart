import 'dart:html' as html;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Enhanced web authentication helper that handles JSON decoding issues
class EnhancedWebAuthHelper {
  /// Safely sign in with email and password, handling web-specific JSON issues
  static Future<AuthResponse> signInWithPasswordSafe({
    required String email,
    required String password,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      if (kIsWeb) {
        debugPrint('🔍 Web: Attempting sign in for $email');

        // Clear any existing session data that might cause conflicts
        await _clearWebStorage();
      }

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Enhanced validation for web
      if (kIsWeb) {
        if (response.user == null) {
          throw Exception('Sign in failed - no user in response');
        }

        if (response.session == null) {
          throw Exception('Sign in failed - no session in response');
        }

        // Validate session data integrity
        if (!_validateSessionData(response.session!)) {
          throw Exception('Invalid session data received');
        }

        debugPrint('✅ Web: Sign in successful for ${response.user?.email}');
      }

      return response;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Sign in error: $e');

        // Handle specific web JSON decoding errors
        if (_isJsonDecodingError(e)) {
          await _clearWebStorage();
          throw Exception(
            'Authentication response format error. Please refresh the page and try again.',
          );
        }

        // Handle network errors
        if (_isNetworkError(e)) {
          throw Exception(
            'Network error. Please check your connection and try again.',
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

      if (kIsWeb) {
        debugPrint('🔍 Web: Attempting sign up for $email');

        // Clear any existing session data
        await _clearWebStorage();
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {if (displayName != null) 'display_name': displayName},
      );

      // Enhanced validation for web
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
        if (_isJsonDecodingError(e)) {
          await _clearWebStorage();
          throw Exception(
            'Registration response format error. Please refresh the page and try again.',
          );
        }

        // Handle network errors
        if (_isNetworkError(e)) {
          throw Exception(
            'Network error. Please check your connection and try again.',
          );
        }
      }

      rethrow;
    }
  }

  /// Enhanced OAuth sign in for web with better error handling
  static Future<bool> signInWithOAuthSafe(OAuthProvider provider) async {
    try {
      final supabase = Supabase.instance.client;

      if (kIsWeb) {
        debugPrint('🔍 Web: Attempting OAuth sign in with ${provider.name}');

        // Clear any existing session data
        await _clearWebStorage();
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
        if (_isJsonDecodingError(e)) {
          await _clearWebStorage();
          throw Exception('OAuth response format error. Please try again.');
        }
      }

      rethrow;
    }
  }

  /// Enhanced auth callback handling for web
  static Future<AuthResponse?> handleAuthCallback() async {
    try {
      if (!kIsWeb) return null;

      debugPrint('🔍 Web: Handling auth callback...');

      final uri = Uri.base;
      debugPrint('🔍 Current URI: $uri');

      // Check if this is a Supabase auth callback
      if (uri.fragment.contains('access_token') ||
          uri.fragment.contains('error') ||
          uri.queryParameters.containsKey('access_token') ||
          uri.queryParameters.containsKey('error')) {
        debugPrint('🔍 Supabase auth callback detected');

        // Clear any corrupted session data first
        await _clearWebStorage();

        // Let Supabase handle the session from the URL
        final response = await Supabase.instance.client.auth.getSessionFromUrl(
          uri,
        );

        if (response.session != null) {
          debugPrint(
            '✅ Auth callback successful: ${response.session?.user.email}',
          );

          // Validate session data
          if (!_validateSessionData(response.session!)) {
            throw Exception('Invalid session data in callback');
          }

          return AuthResponse(
            user: response.session!.user,
            session: response.session!,
          );
        } else {
          debugPrint('❌ No session found in callback');
          return null;
        }
      } else {
        debugPrint('❌ Not a valid auth callback URL');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Auth callback error: $e');

      if (_isJsonDecodingError(e)) {
        await _clearWebStorage();
        throw Exception(
          'Authentication callback format error. Please try again.',
        );
      }

      rethrow;
    }
  }

  /// Clear web storage to resolve session conflicts
  static Future<void> _clearWebStorage() async {
    try {
      if (!kIsWeb) return;

      // Clear localStorage
      html.window.localStorage.clear();

      // Clear sessionStorage
      html.window.sessionStorage.clear();

      debugPrint('🧹 Web: Cleared storage data');
    } catch (e) {
      debugPrint('⚠️ Web: Error clearing storage: $e');
    }
  }

  /// Validate session data integrity
  static bool _validateSessionData(Session session) {
    try {
      // Check if session has required fields
      if (session.accessToken.isEmpty) return false;
      if (session.user.id.isEmpty) return false;

      // Validate token format (basic check)
      if (!session.accessToken.contains('.')) return false;

      return true;
    } catch (e) {
      debugPrint('❌ Session validation error: $e');
      return false;
    }
  }

  /// Check if error is JSON decoding related
  static bool _isJsonDecodingError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('format exception') ||
        errorString.contains('unexpected character') ||
        errorString.contains('json') ||
        errorString.contains('decode') ||
        errorString.contains('parse');
  }

  /// Check if error is network related
  static bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('fetch');
  }

  /// Get current session with validation
  static Session? getCurrentSession() {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (kIsWeb && session != null) {
        if (!_validateSessionData(session)) {
          debugPrint('❌ Web: Invalid session data, clearing...');
          _clearWebStorage();
          return null;
        }

        debugPrint('🔍 Web: Current session valid: ${session.user.email}');
      }

      return session;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Session validation error: $e');
        _clearWebStorage();
      }
      return null;
    }
  }

  /// Get current user with validation
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

  /// Safely sign out with cleanup
  static Future<void> signOutSafe() async {
    try {
      final supabase = Supabase.instance.client;

      if (kIsWeb) {
        debugPrint('🔍 Web: Signing out user');
      }

      await supabase.auth.signOut();

      // Clear web storage after sign out
      if (kIsWeb) {
        await _clearWebStorage();
      }

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

  /// Test Supabase connection
  static Future<bool> testConnection() async {
    try {
      final supabase = Supabase.instance.client;

      // Try to get current session (this tests the connection)
      final session = supabase.auth.currentSession;

      if (kIsWeb) {
        debugPrint('🔍 Web: Connection test - session: ${session != null}');
      }

      return true;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web: Connection test failed: $e');
      }
      return false;
    }
  }
}
