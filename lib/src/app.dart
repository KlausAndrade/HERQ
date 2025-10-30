import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/services/app_lifecycle_observer.dart';
import 'core/services/deep_link_handler.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/notification_redesign/notification_overlay.dart';
import 'core/providers/telemetry_provider.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'features/settings/providers/locale_provider.dart';
import 'features/settings/providers/theme_provider.dart';

class HerqApp extends ConsumerStatefulWidget {
  const HerqApp({super.key});

  @override
  ConsumerState<HerqApp> createState() => _HerqAppState();
}

class _HerqAppState extends ConsumerState<HerqApp> {
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
    final themeVariant = ref.watch(themeVariantProvider);
    final locale = ref.watch(localeProvider);

    // Initialize deep link handler when router is available
    if (!_showSplash) {
      DeepLinkHandler().initialize(context, router);
    }

    // Select theme based on variant (HERQ or Default)
    final lightTheme =
        themeVariant == 'herq' ? AppTheme.herqLightTheme : AppTheme.lightTheme;
    final darkTheme =
        themeVariant == 'herq' ? AppTheme.herqDarkTheme : AppTheme.darkTheme;

    if (_showSplash) {
      return MaterialApp(
        title: 'HERQ - Smart Strength Training',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.supportedLocales,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          onFinished: () async {
            // Hide the splash and rebuild to show the app.
            if (!mounted) return;
            setState(() {
              _showSplash = false;
            });

            // Track app open (best-effort, non-blocking)
            try {
              final telemetry = ref.read(telemetryProvider);
              telemetry.trackEvent('app_open', {
                'platform': Theme.of(context).platform.name,
                'timestamp': DateTime.now().toIso8601String(),
              });
            } catch (_) {}
          },
        ),
      );
    }

    return MaterialApp.router(
      title: 'HERQ - Smart Strength Training',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      routerConfig: router,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
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
