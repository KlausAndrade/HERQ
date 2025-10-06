import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/workout/presentation/screens/active_workout_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/workout/presentation/screens/workout_history_screen.dart';
import '../../features/workout/presentation/screens/enhanced_workout_templates_screen.dart';
import '../../features/workout/presentation/screens/template_builder_screen.dart';
import '../../features/exercises/presentation/screens/exercise_library_screen.dart';
import '../../features/exercises/presentation/screens/exercise_detail_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/social/presentation/screens/social_feed_screen.dart';
import '../../features/social/presentation/screens/leaderboards_screen.dart';
import '../../features/ai/presentation/screens/ai_coaching_screen.dart';

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/workout-templates',
        name: 'workout-templates',
        builder: (context, state) => const WorkoutTemplatesScreen(),
      ),
      GoRoute(
        path: '/template-builder',
        name: 'template-builder',
        builder: (context, state) {
          final templateId = state.uri.queryParameters['templateId'];
          return TemplateBuilderScreen(templateId: templateId);
        },
      ),
      GoRoute(
        path: '/workout/:id',
        name: 'workout-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkoutDetailScreen(workoutId: id);
        },
      ),
      GoRoute(
        path: '/active-workout',
        name: 'active-workout',
        builder: (context, state) {
          final templateId = state.uri.queryParameters['templateId'];
          return ActiveWorkoutScreen(templateId: templateId);
        },
      ),
      GoRoute(
        path: '/workout-history',
        name: 'workout-history',
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercise-library',
        builder: (context, state) => const ExerciseLibraryScreen(),
      ),
      GoRoute(
        path: '/exercise/:id',
        name: 'exercise-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExerciseDetailScreen(exerciseId: id);
        },
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/social',
        name: 'social',
        builder: (context, state) => const SocialFeedScreen(),
      ),
      GoRoute(
        path: '/leaderboards',
        name: 'leaderboards',
        builder: (context, state) => const LeaderboardsScreen(),
      ),
      GoRoute(
        path: '/ai-coach',
        name: 'ai-coach',
        builder: (context, state) => const AICoachingScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  ));