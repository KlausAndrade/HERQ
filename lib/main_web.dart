import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/features/auth/presentation/screens/auth_callback_screen.dart';
import 'src/features/workout/presentation/screens/web_auth_screen.dart';
import 'src/features/workout/presentation/screens/web_history_screen.dart';
import 'src/features/workout/presentation/screens/web_home_screen.dart';
import 'src/features/workout/presentation/screens/web_templates_screen.dart';
import 'src/features/workout/presentation/screens/web_workout_screen.dart';

/// Web-specific entry point for HERQ
/// Uses Supabase for data persistence instead of SQLite
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables (fallback for local dev)
    await dotenv.load().catchError((_) {
      print('ℹ️ No .env file found, using compile-time config');
    });

    // Get Supabase credentials from compile-time constants (--dart-define)
    // or fall back to .env file
    const supabaseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    const supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );

    final url = supabaseUrl.isNotEmpty
        ? supabaseUrl
        : (dotenv.env['SUPABASE_URL'] ?? '');
    final anonKey = supabaseAnonKey.isNotEmpty
        ? supabaseAnonKey
        : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

    // Initialize Supabase for web
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    print('✅ Web platform initialized with Supabase');
    print('   URL: ${url.isNotEmpty ? "configured" : "NOT SET"}');
    print('   Anon Key: ${anonKey.isNotEmpty ? "configured" : "NOT SET"}');
    
    // Test Supabase connection
    try {
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      print('   Current session: ${session != null ? "Active" : "None"}');
    } catch (e) {
      print('   ⚠️ Supabase connection test failed: $e');
    }
  } catch (e) {
    print('⚠️ Web initialization error: $e');
    // Continue anyway - app should handle missing env gracefully
  }

  runApp(
    const ProviderScope(
      child: HerqWebApp(),
    ),
  );
}

class HerqWebApp extends ConsumerWidget {
  const HerqWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'HERQ - Smart Strength Training',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00BFA6), // HERQ Teal
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF141516), // HERQ Charcoal
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      );
}

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isAuthRoute = state.matchedLocation == '/auth';

    if (user == null && !isAuthRoute) {
      return '/auth';
    }

    if (user != null && isAuthRoute) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const WebAuthScreen(),
    ),
    GoRoute(
      path: '/auth/callback',
      builder: (context, state) => const AuthCallbackScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const WebHomeScreen(),
    ),
    GoRoute(
      path: '/templates',
      builder: (context, state) => const WebTemplatesScreen(),
    ),
    GoRoute(
      path: '/workout/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return WebWorkoutScreen(templateId: id);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const WebHistoryScreen(),
    ),
  ],
);
