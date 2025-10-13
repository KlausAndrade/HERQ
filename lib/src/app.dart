import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/services/app_lifecycle_observer.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/theme_provider.dart';
import 'generated/l10n.dart';
import 'core/ui/notification_redesign/notification_overlay.dart';

class GymAIApp extends ConsumerStatefulWidget {
  const GymAIApp({super.key});

  @override
  ConsumerState<GymAIApp> createState() => _GymAIAppState();
}

class _GymAIAppState extends ConsumerState<GymAIApp> {
  late final AppLifecycleObserver _lifecycleObserver;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = AppLifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    // Show the splash screen on every cold start as an initial loader.
    // Auto-hide after a short delay so users aren't blocked.
    Future.delayed(const Duration(milliseconds: 100), () {
      // small micro-delay to allow the widget tree to settle before starting
      // the splash lifecycle (helps in tests/hot-reload scenarios).
      if (!mounted) return;
      // Auto-dismiss splash after 1 seconds to avoid blocking startup.
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _showSplash = false;
        });
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _lifecycleObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (_showSplash) {
      return MaterialApp(
        title: 'GymAI - Workout Tracker',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          onFinished: () async {
            // Hide the splash and rebuild to show the app.
            if (!mounted) return;
            setState(() {
              _showSplash = false;
            });
          },
        ),
      );
    }

    return MaterialApp.router(
      title: 'GymAI - Workout Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Place the notification overlay above the app shell so in-app
        // notifications can float on top of all routes. We keep the
        // MaterialApp.router as the root but inject an additional Stack
        // via the builder which receives the navigator's child.
        return Stack(
          children: [
            if (child != null) child,
            const NotificationOverlay(),
          ],
        );
      },
    );
  }
}
