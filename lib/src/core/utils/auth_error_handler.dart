import 'package:supabase_flutter/supabase_flutter.dart';

/// Utility class for handling authentication errors and providing user-friendly messages
class AuthErrorHandler {
  /// Converts AuthApi exceptions to user-friendly error messages
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return _getAuthExceptionMessage(error);
    }

    if (error is Exception) {
      return _getGenericExceptionMessage(error);
    }

    // Handle string errors
    if (error is String) {
      return _parseStringError(error);
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Get user-friendly message for AuthException
  static String _getAuthExceptionMessage(AuthException error) {
    switch (error.message) {
      // Sign in errors
      case 'Invalid login credentials':
        return 'Invalid email or password. Please check your credentials and try again.';

      case 'Email not confirmed':
        return 'Please check your email and click the confirmation link before signing in.';

      case 'Too many requests':
        return 'Too many login attempts. Please wait a few minutes before trying again.';

      // Sign up errors
      case 'User already registered':
        return 'An account with this email already exists. Please sign in instead.';

      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters long.';

      case 'Signup requires a valid password':
        return 'Please enter a valid password.';

      case 'Unable to validate email address: invalid format':
        return 'Please enter a valid email address.';

      // Password reset errors
      case 'For security purposes, you can only request this once every 60 seconds':
        return 'Please wait 60 seconds before requesting another password reset email.';

      // OAuth errors
      case 'OAuth provider not found':
        return 'OAuth provider is not configured. Please try again later.';

      case 'OAuth account not found':
        return 'No account found with this OAuth provider. Please sign up first.';

      // Network errors
      case 'Network request failed':
        return 'Network connection failed. Please check your internet connection.';

      case 'Connection timeout':
        return 'Connection timed out. Please check your internet connection and try again.';

      // Generic fallback
      default:
        return _parseAuthMessage(error.message);
    }
  }

  /// Parse AuthException message for common patterns
  static String _parseAuthMessage(String message) {
    // Handle common error patterns
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (message.contains('Email not confirmed')) {
      return 'Please check your email and click the confirmation link before signing in.';
    }

    if (message.contains('User already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    }

    if (message.contains('Password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }

    if (message.contains('Too many requests')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }

    if (message.contains('Network') || message.contains('connection')) {
      return 'Network connection failed. Please check your internet connection.';
    }

    if (message.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }

    // Return original message if no pattern matches
    return message;
  }

  /// Handle generic exceptions
  static String _getGenericExceptionMessage(Exception error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') || message.contains('connection')) {
      return 'Network connection failed. Please check your internet connection.';
    }

    if (message.contains('socketexception') ||
        message.contains('failed host lookup')) {
      return 'Cannot connect to server. Please check your internet connection and try again.';
    }

    if (message.contains('clientexception')) {
      return 'Connection error. Please check your internet connection and try again.';
    }

    if (message.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }

    if (message.contains('unauthorized')) {
      return 'Authentication failed. Please sign in again.';
    }

    if (message.contains('forbidden')) {
      return 'Access denied. Please contact support if this continues.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Parse string errors for common patterns
  static String _parseStringError(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (lowerError.contains('user already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    }

    if (lowerError.contains('email not confirmed')) {
      return 'Please check your email and click the confirmation link before signing in.';
    }

    if (lowerError.contains('too many requests')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Network connection failed. Please check your internet connection.';
    }

    return error;
  }

  /// Get error title based on error type
  static String getErrorTitle(dynamic error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      if (message.contains('invalid login credentials')) {
        return 'Sign In Failed';
      }

      if (message.contains('user already registered')) {
        return 'Account Exists';
      }

      if (message.contains('email not confirmed')) {
        return 'Email Not Verified';
      }

      if (message.contains('too many requests')) {
        return 'Too Many Attempts';
      }

      if (message.contains('network') || message.contains('connection')) {
        return 'Connection Error';
      }
    }

    return 'Authentication Error';
  }

  /// Check if error is retryable
  static bool isRetryable(dynamic error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      // Network errors are retryable
      if (message.contains('network') ||
          message.contains('connection') ||
          message.contains('timeout')) {
        return true;
      }

      // Rate limiting is retryable after waiting
      if (message.contains('too many requests')) {
        return true;
      }
    }

    // Generic network errors
    if (error is Exception) {
      final message = error.toString().toLowerCase();
      if (message.contains('network') ||
          message.contains('connection') ||
          message.contains('timeout')) {
        return true;
      }
    }

    return false;
  }

  /// Get retry delay in seconds for rate limited requests
  static int getRetryDelaySeconds(dynamic error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      if (message.contains('too many requests')) {
        return 60; // Wait 1 minute
      }
    }

    return 5; // Default 5 seconds for network errors
  }
}
