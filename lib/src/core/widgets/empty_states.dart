import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../theme/app_theme.dart';

/// Generic empty state widget
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLG),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppTheme.spacingLG),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLG,
                  vertical: AppTheme.spacingMD,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('message', message));
    properties.add(StringProperty('actionLabel', actionLabel));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onAction', onAction));
  }
}

/// Empty state for no workouts
class NoWorkoutsEmptyState extends StatelessWidget {
  const NoWorkoutsEmptyState({super.key, this.onStartWorkout});

  final VoidCallback? onStartWorkout;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.fitness_center_outlined,
    title: 'No workouts yet',
    message:
        'Start your first workout to track your progress and achieve your fitness goals',
    actionLabel: 'Start Workout',
    onAction: onStartWorkout,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback?>.has('onStartWorkout', onStartWorkout),
    );
  }
}

/// Empty state for no exercises
class NoExercisesEmptyState extends StatelessWidget {
  const NoExercisesEmptyState({super.key, this.onAddExercise});

  final VoidCallback? onAddExercise;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.search_off,
    title: 'No exercises found',
    message:
        'Try adjusting your search or filters to find what you\'re looking for',
    actionLabel: onAddExercise != null ? 'Add Exercise' : null,
    onAction: onAddExercise,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback?>.has('onAddExercise', onAddExercise),
    );
  }
}

/// Empty state for no templates
class NoTemplatesEmptyState extends StatelessWidget {
  const NoTemplatesEmptyState({super.key, this.onCreateTemplate});

  final VoidCallback? onCreateTemplate;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.content_paste_off,
    title: 'No workout templates',
    message:
        'Create your first workout template to save time and stay consistent with your training',
    actionLabel: 'Create Template',
    onAction: onCreateTemplate,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback?>.has(
        'onCreateTemplate',
        onCreateTemplate,
      ),
    );
  }
}

/// Empty state for no history
class NoHistoryEmptyState extends StatelessWidget {
  const NoHistoryEmptyState({super.key, this.onStartWorkout});

  final VoidCallback? onStartWorkout;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.history_outlined,
    title: 'No workout history',
    message:
        'Complete your first workout to start tracking your progress over time',
    actionLabel: 'Start Workout',
    onAction: onStartWorkout,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback?>.has('onStartWorkout', onStartWorkout),
    );
  }
}

/// Empty state for no progress data
class NoProgressEmptyState extends StatelessWidget {
  const NoProgressEmptyState({super.key, this.onStartWorkout});

  final VoidCallback? onStartWorkout;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.trending_up_outlined,
    title: 'No progress data',
    message:
        'Start logging workouts to see your progress charts and statistics',
    actionLabel: 'Start Tracking',
    onAction: onStartWorkout,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback?>.has('onStartWorkout', onStartWorkout),
    );
  }
}

/// Empty state for search results
class NoSearchResultsEmptyState extends StatelessWidget {
  const NoSearchResultsEmptyState({super.key, this.searchQuery});

  final String? searchQuery;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.search_off,
    title: 'No results found',
    message: searchQuery != null
        ? 'No results for "$searchQuery". Try a different search term.'
        : 'Try adjusting your search to find what you\'re looking for',
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('searchQuery', searchQuery));
  }
}

/// Empty state for network error
class ErrorEmptyState extends StatelessWidget {
  const ErrorEmptyState({required this.message, super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLG),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppTheme.spacingLG),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLG,
                  vertical: AppTheme.spacingMD,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRetry', onRetry));
  }
}
