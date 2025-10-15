import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/ai/presentation/screens/ai_coaching_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart' as user_analytics;
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/exercises/presentation/screens/create_exercise_screen.dart';
import '../../features/exercises/presentation/screens/exercise_detail_screen.dart';
import '../../features/exercises/presentation/screens/exercise_library_screen.dart';
import '../../features/gamification/presentation/screens/gamification_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/settings/presentation/screens/about_herq_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/social/presentation/screens/edit_profile_screen.dart';
import '../../features/social/presentation/screens/followers_screen.dart';
import '../../features/social/presentation/screens/following_screen.dart';
import '../../features/social/presentation/screens/leaderboards_screen.dart';
import '../../features/social/presentation/screens/post_comments_screen.dart';
import '../../features/social/presentation/screens/post_detail_screen.dart';
import '../../features/social/presentation/screens/social_feed_screen.dart';
import '../../features/social/presentation/screens/user_profile_screen.dart';
import '../../features/workout/domain/models/workout_summary.dart';
import '../../features/workout/presentation/screens/active_workout_screen.dart';
import '../../features/workout/presentation/screens/template_builder_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/workout/presentation/screens/workout_history_screen.dart';
import '../../features/workout/presentation/screens/workout_summary_screen.dart';
import '../../features/workout/presentation/screens/workout_templates_with_folders_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/user_management_screen.dart';
import '../../features/admin/presentation/screens/content_moderation_screen.dart';
import '../../features/admin/presentation/screens/analytics_screen.dart';
import '../../features/admin/presentation/screens/system_admin_screen.dart';
import '../../features/admin/presentation/screens/data_operations_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../widgets/page_transitions.dart';

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
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
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => AppPageTransitions.fadeTransition(
          const HomeScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        pageBuilder: (context, state) => AppPageTransitions.slideUpTransition(
          const AuthScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/workout-templates',
        name: 'workout-templates',
        pageBuilder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          final isEditing = mode != 'start';

          return AppPageTransitions.slideRightTransition(
            WorkoutTemplatesWithFoldersScreen(isEditing: isEditing),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/template-builder',
        name: 'template-builder',
        pageBuilder: (context, state) {
          final templateId = state.uri.queryParameters['templateId'];
          final folderId = state.uri.queryParameters['folderId'];
          return AppPageTransitions.slideRightTransition(
            TemplateBuilderScreen(templateId: templateId, folderId: folderId),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/workout/:id',
        name: 'workout-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.sharedAxisTransition(
            WorkoutDetailScreen(workoutId: id),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/active-workout',
        name: 'active-workout',
        pageBuilder: (context, state) {
          final templateId = state.uri.queryParameters['templateId'];
          return AppPageTransitions.slideUpTransition(
            ActiveWorkoutScreen(templateId: templateId),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/workout-summary',
        name: 'workout-summary',
        pageBuilder: (context, state) {
          final summary = state.extra as WorkoutSummary?;
          if (summary == null) {
            // Redirect to home if no summary provided
            return AppPageTransitions.fadeTransition(
              const HomeScreen(),
              key: state.pageKey,
            );
          }
          return AppPageTransitions.slideUpTransition(
            WorkoutSummaryScreen(summary: summary),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/workout-history',
        name: 'workout-history',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const WorkoutHistoryScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercise-library',
        pageBuilder: (context, state) => AppPageTransitions.fadeTransition(
          const ExerciseLibraryScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/exercises/create',
        name: 'create-exercise',
        pageBuilder: (context, state) {
          final exerciseId = state.uri.queryParameters['id'];
          return AppPageTransitions.slideUpTransition(
            CreateExerciseScreen(exerciseId: exerciseId),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/exercise/:id',
        name: 'exercise-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.sharedAxisTransition(
            ExerciseDetailScreen(exerciseId: id),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        pageBuilder: (context, state) => AppPageTransitions.fadeTransition(
          const ProgressScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        pageBuilder: (context, state) => AppPageTransitions.fadeTransition(
          const user_analytics.AnalyticsScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/social',
        name: 'social',
        pageBuilder: (context, state) => AppPageTransitions.fadeTransition(
          const SocialFeedScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/user/:id',
        name: 'user-profile',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.slideRightTransition(
            UserProfileScreen(userId: id),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        pageBuilder: (context, state) => AppPageTransitions.slideUpTransition(
          const EditProfileScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/user/:id/followers',
        name: 'user-followers',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.slideRightTransition(
            FollowersScreen(userId: id),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/user/:id/following',
        name: 'user-following',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.slideRightTransition(
            FollowingScreen(userId: id),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/post/:id',
        name: 'post-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.sharedAxisTransition(
            PostDetailScreen(postId: id),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/post/:id/comments',
        name: 'post-comments',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.slideUpTransition(
            PostCommentsScreen(postId: id),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/leaderboards',
        name: 'leaderboards',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const LeaderboardsScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/ai-coach',
        name: 'ai-coach',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const AICoachingScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const SettingsScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/about-herq',
        name: 'about-herq',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const AboutHerqScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/gamification',
        name: 'gamification',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const GamificationScreen(),
          key: state.pageKey,
        ),
      ),
      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'admin-dashboard',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const AdminDashboardScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const UserManagementScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/admin/content',
        name: 'admin-content',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const ContentModerationScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/admin/analytics',
        name: 'admin-analytics',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const AnalyticsScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/admin/system',
        name: 'admin-system',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const SystemAdminScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/admin/data',
        name: 'admin-data',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const DataOperationsScreen(),
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'admin-settings',
        pageBuilder: (context, state) =>
            AppPageTransitions.slideRightTransition(
          const AdminSettingsScreen(),
          key: state.pageKey,
        ),
      ),
    ],
  ),
);
