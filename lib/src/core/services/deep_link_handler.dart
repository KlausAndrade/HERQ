import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'snackbar_service.dart';
import '../../../l10n/app_localizations.dart';

/// Handles deep link authentication for mobile apps
class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  
  DeepLinkHandler._internal();
  
  factory DeepLinkHandler() => _instance;

  BuildContext? _context;
  GoRouter? _router;

  /// Initialize the deep link handler
  void initialize(BuildContext context, GoRouter router) {
    _context = context;
    _router = router;
    
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen(_handleAuthStateChange);
    
    debugPrint('🔗 Deep link handler initialized');
  }

  /// Handle authentication state changes
  void _handleAuthStateChange(AuthState state) {
    debugPrint('🔍 Auth state changed: ${state.event}');
    debugPrint('🔍 User: ${state.session?.user?.email}');
    
    if (state.event == AuthChangeEvent.signedIn && state.session != null) {
      debugPrint('✅ User signed in via deep link: ${state.session?.user?.email}');
      
      // Show success notification
      if (_context != null) {
        final localizations = S.of(_context!);
        if (localizations != null) {
          SnackbarService.showSuccess(
            _context!,
            localizations.loggedInSuccessfully,
            duration: const Duration(seconds: 3),
          );
        }
      }
      
      // Navigate to home screen
      if (_context != null && _router != null) {
        _router!.go('/');
      }
    } else if (state.event == AuthChangeEvent.signedOut) {
      debugPrint('❌ User signed out');
      
      // Navigate to auth screen
      if (_context != null && _router != null) {
        _router!.go('/auth');
      }
    }
  }

  /// Handle incoming deep links
  Future<void> handleDeepLink(String link) async {
    debugPrint('🔗 Handling deep link: $link');
    
    try {
      // Parse the deep link URL
      final uri = Uri.parse(link);
      debugPrint('🔍 Parsed URI: $uri');
      
      // Check if this is a Supabase auth callback
      if (uri.scheme == 'herq' && uri.host == 'login-callback') {
        debugPrint('🔍 Supabase auth callback detected');
        
        // Use the URL to get session from Supabase
        final session = await Supabase.instance.client.auth.getSessionFromUrl(uri);
        
        if (session != null) {
          debugPrint('✅ Session created successfully');
        } else {
          debugPrint('❌ Failed to create session from URL');
        }
      }
    } on Exception catch (e) {
      debugPrint('❌ Error handling deep link: $e');
    }
  }
}

