import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/telemetry_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/apk_selector.dart';
import '../../../../core/utils/auth_error_handler.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to handle deep link authentication
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState.session != null && mounted) {
          print('✅ User authenticated via deep link, navigating to home');
          context.go('/');
        }
      });
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo and title
                Image.asset(
                  'assets/images/herq_logo.png',
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),

                Text(
                  S.of(context)!.appTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  S.of(context)!.yourIntelligentWorkoutCompanion,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Auth form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'Create Account' : 'Welcome Back',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Name field (signup only)
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Display Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (_isSignUp &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 6),
                        ],

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 6),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_isSignUp && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 2,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                        ),
                        const SizedBox(height: 12),

                        // Toggle sign up/sign in
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign In'
                                : 'Don\'t have an account? Sign Up',
                          ),
                        ),

                        // Forgot password (sign in only)
                        if (!_isSignUp) ...[
                          TextButton(
                            onPressed: _handleForgotPassword,
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Social sign in
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      children: [
                        Text(
                          'Or continue with',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isLoading ? null : _handleGoogleSignIn,
                                icon: const Icon(Icons.g_mobiledata, size: 24),
                                label: const Text('Google'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isLoading ? null : _handleAppleSignIn,
                                icon: const Icon(Icons.apple, size: 24),
                                label: const Text('Apple'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                _isLoading ? null : _handleFacebookSignIn,
                            icon: const Icon(Icons.facebook, size: 24),
                            label: const Text('Continue with Facebook'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: const Color(0xFF1877F2),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Skip for now button
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Skip for now'),
                ),

                // Download APK button (web only)
                if (kIsWeb) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _downloadApk,
                          icon: const Icon(Icons.download),
                          label: const Text('Download APK (Auto)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFF00BFA6).withValues(alpha: 0.1),
                            foregroundColor: const Color(0xFF00BFA6),
                            side: const BorderSide(color: Color(0xFF00BFA6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _showApkOptions,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          backgroundColor: const Color(0xFF00BFA6).withValues(alpha: 0.1),
                          foregroundColor: const Color(0xFF00BFA6),
                          side: const BorderSide(color: Color(0xFF00BFA6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadApk() async {
    try {
      // Get the recommended APK based on device architecture
      final apkInfo = ApkSelector.getRecommendedApkInfo();
      final downloadUrl = ApkSelector.getRecommendedApkUrl();
      
      if (kDebugMode) {
        print('Downloading APK: ${apkInfo.fileName}');
        print('Architecture: ${apkInfo.displayName}');
        print('URL: $downloadUrl');
      }
      
      // Show info message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Downloading ${apkInfo.displayName} APK (${apkInfo.estimatedSize})',
            ),
            backgroundColor: const Color(0xFF00BFA6),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Trigger download
      if (await canLaunchUrl(downloadUrl)) {
        await launchUrl(downloadUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Cannot launch download URL');
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

  void _showApkOptions() {
    final variants = ApkSelector.getAllApkVariants();
    final recommended = ApkSelector.getRecommendedApkInfo();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose APK Version'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select the version that matches your device:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ...variants.map((variant) {
                final isRecommended = variant.fileName == recommended.fileName;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isRecommended
                        ? const Color(0xFF00BFA6).withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        Navigator.pop(context);
                        final url = ApkSelector.getApkDownloadUrl(variant.fileName);
                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to download: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              isRecommended ? Icons.star : Icons.phone_android,
                              color: isRecommended
                                  ? const Color(0xFF00BFA6)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        variant.displayName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isRecommended
                                              ? const Color(0xFF00BFA6)
                                              : null,
                                        ),
                                      ),
                                      if (isRecommended) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00BFA6),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'RECOMMENDED',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    variant.description,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    variant.estimatedSize,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.download, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);

      if (_isSignUp) {
        await authService.signUpWithEmailSafe(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
        );
        // Telemetry: signup_completed
        try {
          final telemetry = ref.read(telemetryProvider);
          telemetry.trackEvent('signup_completed', {
            'method': 'email',
          });
        } catch (_) {}

        if (mounted) {
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Account created',
                body: 'Please check your email to verify.',
              )
              .catchError((_) {});
        }
      } else {
        await authService.signInWithEmailSafe(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Telemetry: login_completed
        try {
          final telemetry = ref.read(telemetryProvider);
          telemetry.trackEvent('login_completed', {
            'method': 'email',
          });
        } catch (_) {}

        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error',
              body: e.toString(),
            )
            .catchError((_) {});
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.signInWithGoogleSafe();

      if (success && mounted) {
        try {
          ref.read(telemetryProvider).trackEvent('login_completed', {
            'method': 'google',
          });
        } catch (_) {}
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = AuthErrorHandler.getErrorMessage(e);
        final errorTitle = AuthErrorHandler.getErrorTitle(e);

        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: errorTitle,
              body: errorMessage,
            )
            .catchError((_) {});
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.signInWithAppleSafe();

      if (success && mounted) {
        try {
          ref.read(telemetryProvider).trackEvent('login_completed', {
            'method': 'apple',
          });
        } catch (_) {}
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = AuthErrorHandler.getErrorMessage(e);
        final errorTitle = AuthErrorHandler.getErrorTitle(e);

        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: errorTitle,
              body: errorMessage,
            )
            .catchError((_) {});
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.signInWithFacebookSafe();

      if (success && mounted) {
        try {
          ref.read(telemetryProvider).trackEvent('login_completed', {
            'method': 'facebook',
          });
        } catch (_) {}
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = AuthErrorHandler.getErrorMessage(e);
        final errorTitle = AuthErrorHandler.getErrorTitle(e);

        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: errorTitle,
              body: errorMessage,
            )
            .catchError((_) {});
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Missing email',
            body: 'Please enter your email first',
          )
          .catchError((_) {});
      return;
    }

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPasswordSafe(_emailController.text.trim());

      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Password reset',
              body: 'Password reset email sent!',
            )
            .catchError((_) {});
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = AuthErrorHandler.getErrorMessage(e);
        final errorTitle = AuthErrorHandler.getErrorTitle(e);

        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: errorTitle,
              body: errorMessage,
            )
            .catchError((_) {});
      }
    }
  }
}
