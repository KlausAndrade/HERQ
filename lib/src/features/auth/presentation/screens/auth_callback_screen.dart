import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/enhanced_web_auth_helper.dart';

/// Handles authentication callbacks from Supabase (email confirmation, magic links, etc.)
class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      print('🔍 Handling auth callback...');
      
      // Use enhanced auth callback handler
      final response = await EnhancedWebAuthHelper.handleAuthCallback();
      
      if (response != null && response.user != null) {
        print('✅ Auth callback successful: ${response.user?.email}');
        
        if (mounted) {
          // Navigate to home page
          context.go('/');
        }
      } else {
        print('❌ No valid session found in callback');
        _setError('Authentication failed. Please try again.');
      }
    } catch (e) {
      print('❌ Auth callback error: $e');
      _setError('Authentication failed: ${e.toString()}');
    }
  }

  void _setError(String error) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141516), // HERQ Charcoal
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // HERQ Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BFA6), Color(0xFFD4FF4D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'HERQ',
                  style: TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B1D21),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              if (_isLoading) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BFA6)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Completing authentication...',
                  style: TextStyle(
                    color: Color(0xFFF8F8FA),
                    fontSize: 16,
                  ),
                ),
              ] else if (_error != null) ...[
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFD4FF4D),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Authentication Error',
                  style: TextStyle(
                    color: Color(0xFFF8F8FA),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF8F8FA),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA6),
                    foregroundColor: const Color(0xFF1B1D21),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
