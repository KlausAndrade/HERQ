import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../utils/auth_error_handler.dart';
// telemetry is handled in UI layers where ref is accessible

// Supabase client provider
final supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

// Authentication state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.read(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((state) => state.session?.user).value;
});

// Authentication service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.read(supabaseClientProvider);
  return AuthService(client);
});

class AuthService {
  const AuthService(this._client);

  final SupabaseClient _client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async =>
      _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null) 'display_name': displayName,
        },
      );

  // Sign in with Google
  Future<bool> signInWithGoogle() async => _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'herq://login-callback/',
      );

  // Sign in with Apple
  Future<bool> signInWithApple() async => _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'herq://login-callback/',
      );

  // Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      print('🔍 Starting Facebook login...');
      
      // Use native Facebook SDK with login behavior preference
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.nativeWithFallback, // Prefer native SSO
      );
      
      print('🔍 Facebook login result: ${result.status}');
      print('🔍 Facebook login message: ${result.message}');
      print('🔍 Facebook login method: ${result.accessToken?.graphDomain}');

      if (result.status == LoginStatus.success) {
        print('✅ Facebook login successful');
        
        // Get Facebook access token
        final AccessToken accessToken = result.accessToken!;
        print('🔍 Facebook access token received');

        // Sign in to Supabase with Facebook token
        print('🔍 Signing in to Supabase with Facebook token...');
        final AuthResponse response = await _client.auth.signInWithIdToken(
          provider: OAuthProvider.facebook,
          idToken: accessToken.token,
        );

        print('🔍 Supabase response: ${response.session != null ? "Success" : "Failed"}');
        return response.session != null;
      } else {
        print('❌ Facebook login failed: ${result.message}');
      }

      return false;
    } catch (e) {
      print('❌ Facebook login error: $e');
      throw AuthErrorHandler.getErrorMessage(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    final user = _client.auth.currentUser;
    if (user?.email != null) {
      await _client.auth.resend(
        type: OtpType.signup,
        email: user!.email,
      );
    }
  }

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Enhanced error handling methods
  Future<AuthResponse> signInWithEmailSafe({
    required String email,
    required String password,
  }) async {
    try {
      return await signInWithEmail(email: email, password: password);
    } catch (e) {
      throw AuthErrorHandler.getErrorMessage(e);
    }
  }

  Future<AuthResponse> signUpWithEmailSafe({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      return await signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
    } catch (e) {
      throw AuthErrorHandler.getErrorMessage(e);
    }
  }

  Future<bool> signInWithGoogleSafe() async {
    try {
      return await signInWithGoogle();
    } catch (e) {
      throw AuthErrorHandler.getErrorMessage(e);
    }
  }

  Future<bool> signInWithAppleSafe() async {
    try {
      return await signInWithApple();
    } catch (e) {
      throw AuthErrorHandler.getErrorMessage(e);
    }
  }

  Future<bool> signInWithFacebookSafe() async {
    try {
      return await signInWithFacebook();
    } catch (e) {
      throw AuthErrorHandler.getErrorMessage(e);
    }
  }

  Future<void> resetPasswordSafe(String email) async {
    try {
      await resetPassword(email);
    } catch (e) {
      throw AuthErrorHandler.getErrorMessage(e);
    }
  }

  Future<void> resendEmailVerificationSafe() async {
    try {
      await resendEmailVerification();
    } catch (e) {
      throw AuthErrorHandler.getErrorMessage(e);
    }
  }

  Future<void> signOutSafe() async {
    try {
      await signOut();
    } catch (e) {
      throw AuthErrorHandler.getErrorMessage(e);
    }
  }
}
