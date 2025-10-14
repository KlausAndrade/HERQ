import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'src/features/workout/presentation/screens/web_home_screen.dart';
import 'src/features/workout/presentation/screens/web_templates_screen.dart';
import 'src/features/workout/presentation/screens/web_workout_screen.dart';
import 'src/features/workout/presentation/screens/web_history_screen.dart';
import 'src/features/workout/presentation/screens/web_auth_screen.dart';

/// Web-specific entry point for GymAI
/// Uses Supabase for data persistence instead of SQLite
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    
    // Initialize Supabase for web
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    
    print('✅ Web platform initialized with Supabase');
  } catch (e) {
    print('⚠️ Web initialization error: $e');
    // Continue anyway - app should handle missing env gracefully
  }
  
  runApp(
    const ProviderScope(
      child: GymAIWebApp(),
    ),
  );
}

class GymAIWebApp extends ConsumerWidget {
  const GymAIWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
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
