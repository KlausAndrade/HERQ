import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/routing/app_router.dart';
import 'src/core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: HerqNavApp(),
    ),
  );
}

class HerqNavApp extends ConsumerWidget {
  const HerqNavApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HERQ - Smart Strength Training',
      theme: AppTheme.herqLightTheme,
      darkTheme: AppTheme.herqDarkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
