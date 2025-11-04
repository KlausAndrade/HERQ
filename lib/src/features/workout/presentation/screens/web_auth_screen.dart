import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/auth_error_handler.dart';
import '../../../../core/utils/enhanced_web_auth_helper.dart';
import '../../../../core/utils/web_auth_test_helper.dart';

class WebAuthScreen extends ConsumerStatefulWidget {
  const WebAuthScreen({super.key});

  @override
  ConsumerState<WebAuthScreen> createState() => _WebAuthScreenState();
}

class _WebAuthScreenState extends ConsumerState<WebAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isSignUp) {
        final response = await EnhancedWebAuthHelper.signUpSafe(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Handle signup response
        if (response.user != null) {
          if (mounted) {
            context.go('/');
          }
        } else {
          throw Exception('Signup failed - no user returned');
        }
      } else {
        final response = await EnhancedWebAuthHelper.signInWithPasswordSafe(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Handle signin response
        if (response.user != null) {
          if (mounted) {
            context.go('/');
          }
        } else {
          throw Exception('Signin failed - no user returned');
        }
      }
    } on Exception catch (e) {
      setState(() {
        _error = _getWebFriendlyErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getWebFriendlyErrorMessage(dynamic error) {
    // Handle specific web-related JSON decoding errors
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('format exception') ||
        errorString.contains('unexpected character') ||
        errorString.contains('json')) {
      return 'Login failed due to response format error. Please try again.';
    }

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    }

    if (errorString.contains('cors')) {
      return 'Cross-origin request blocked. Please refresh the page and try again.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    // Fall back to the standard error handler
    return AuthErrorHandler.getErrorMessage(error);
  }

  Future<void> _downloadApk() async {
    try {
      final uri = Uri.parse('/herq-release.apk');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to trigger download directly
        final downloadUrl = Uri.parse('${Uri.base.origin}/herq-release.apk');
        await launchUrl(downloadUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download APK: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _runDebugTests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await WebAuthTestHelper.runAllTests();

      if (mounted) {
        final allPassed = results.values.every((result) => result);
        final message = allPassed
            ? 'All tests passed! ✅'
            : 'Some tests failed: ${results.entries.where((e) => !e.value).map((e) => e.key).join(', ')}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: allPassed ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Debug test failed: $e';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HERQ Logo
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/images/herq_logo.png',
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to HERQ text if logo not found
                            return Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00BFA6),
                                        Color(0xFFD4FF4D)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'HERQ',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Smart Strength. Simplified.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF00BFA6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSignUp ? 'Create Account' : 'Welcome Back',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00BFA6),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              const Color(0xFF00BFA6), // HERQ Electric Teal
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                            _error = null;
                          });
                        },
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Sign In'
                              : 'Don\'t have an account? Sign Up',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Debug test button (only show in debug mode)
                      if (kDebugMode) ...[
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _runDebugTests,
                          icon: const Icon(Icons.bug_report, size: 16),
                          label: const Text('Debug Tests'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            foregroundColor: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Prefer the mobile app?',
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                      // Debug: Add a visible indicator that this is the web auth screen
                      if (kDebugMode)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEBUG: This is WebAuthScreen with APK download',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _downloadApk,
                        icon: const Icon(Icons.download),
                        label: const Text('Download Android APK'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor:
                              const Color(0xFF00BFA6).withValues(alpha: 0.1),
                          foregroundColor: const Color(0xFF00BFA6),
                          side: const BorderSide(color: Color(0xFF00BFA6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Additional mobile app info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00BFA6).withValues(alpha: 0.1),
                              const Color(0xFFD4FF4D).withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF00BFA6)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00BFA6),
                                    Color(0xFFD4FF4D)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.phone_android,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Get the full HERQ experience',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF00BFA6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Smart Strength. Simplified. On mobile.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1B1D21),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
