import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../workout/presentation/providers/template_providers.dart';
import '../../domain/models/ai_models.dart';
import '../providers/ai_providers.dart';

// Default user ID for AI coaching - TODO: Replace with actual user ID when auth implemented
const String _kDefaultUserId = 'default_user';

class AICoachingScreen extends HookConsumerWidget {
  const AICoachingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
            title: Text(S.of(context)!.aiCoach),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  text: S.of(context)!.recommendations,
                  icon: const Icon(Icons.lightbulb_outline),
                ),
                Tab(text: S.of(context)!.recovery, icon: const Icon(Icons.spa)),
                Tab(
                  text: S.of(context)!.progressAnalysis,
                  icon: const Icon(Icons.trending_up),
                ),
                Tab(
                  text: S.of(context)!.suggestions,
                  icon: const Icon(Icons.tips_and_updates),
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              WorkoutRecommendationsTab(),
              RecoveryAnalysisTab(),
              ProgressAnalysisTab(),
              GeneralSuggestionsTab(),
            ],
          ),
        ),
      );
}

class WorkoutRecommendationsTab extends HookConsumerWidget {
  const WorkoutRecommendationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const params = WorkoutRecommendationParams(
      userId: _kDefaultUserId,
      preferredMuscleGroups: ['chest', 'back', 'shoulders'],
      availableEquipment: ['barbell', 'dumbbell', 'bench'],
      maxDuration: 60,
    );

    final recommendationsAsync =
        ref.watch(workoutRecommendationsProvider(params));

    return recommendationsAsync.when(
      data: (recommendations) =>
          _buildRecommendationsList(context, ref, recommendations),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(workoutRecommendationsProvider),
              child: Text(S.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList(
    BuildContext context,
    WidgetRef ref,
    List<WorkoutRecommendation> recommendations,
  ) {
    if (recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No recommendations available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return _buildRecommendationCard(context, ref, recommendation);
      },
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    WidgetRef ref,
    WorkoutRecommendation recommendation,
  ) =>
      Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recommendation.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(recommendation.difficulty)
                          .withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recommendation.difficulty.name.toUpperCase(),
                      style: TextStyle(
                        color: _getDifficultyColor(recommendation.difficulty),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${recommendation.estimatedDuration} min',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${recommendation.exercises.length} exercises',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(recommendation.confidence * 100).round()}% match',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Target: ${recommendation.targetMuscleGroups.join(', ')}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recommendation.reasoning,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Exercises:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendation.exercises.map(_buildExerciseItem),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // View details
                      },
                      child: Text(S.of(context)!.viewDetails),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _startWorkoutFromRecommendation(
                        context,
                        ref,
                        recommendation,
                      ),
                      child: Text(S.of(context)!.startWorkout),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildExerciseItem(RecommendedExercise exercise) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${exercise.name} - ${exercise.sets} sets × ${exercise.reps} reps',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (exercise.weight != null)
              Text(
                '${exercise.weight}kg',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      );

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.advanced:
        return Colors.red;
    }
  }

  Future<void> _startWorkoutFromRecommendation(
    BuildContext context,
    WidgetRef ref,
    WorkoutRecommendation recommendation,
  ) async {
    try {
      // Import required providers and services
      final database = ref.read(databaseProvider);
      final templateActions = ref.read(templateActionsProvider);

      if (database == null) {
        if (context.mounted) {
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Database not available. Please try again.',
                body: '',
              )
              .catchError((_) {});
        }
        return;
      }

      // Create a workout template from the AI recommendation
      final templateId = 'ai_rec_${DateTime.now().millisecondsSinceEpoch}';
      final template = WorkoutTemplate(
        id: templateId,
        name: recommendation.name,
        description: recommendation.description,
        category: 'AI Recommended',
        sortOrder: 0,
        exerciseIds: recommendation.exercises.map((e) => e.exerciseId).toList(),
        tags: ['ai_generated', ...recommendation.targetMuscleGroups],
        estimatedDurationMinutes: recommendation.estimatedDuration,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the template to database
      final success = await templateActions.createTemplate(template);

      if (!success) {
        if (context.mounted) {
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Failed to create workout template',
                body: '',
              )
              .catchError((_) {});
        }
        return;
      }

      if (context.mounted) {
        // Show success message via in-app overlay
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Starting "${recommendation.name}"...',
              body: '',
            )
            .catchError((_) {});

        // Navigate to active workout with the template
        context.go('/active-workout?templateId=$templateId');
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error starting workout: $e',
              body: '',
            )
            .catchError((_) {});
      }
    }
  }
}

class RecoveryAnalysisTab extends HookConsumerWidget {
  const RecoveryAnalysisTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recoveryAsync = ref.watch(recoveryAnalysisProvider(_kDefaultUserId));

    return recoveryAsync.when(
      data: (analysis) => _buildRecoveryAnalysis(context, analysis),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildRecoveryAnalysis(
    BuildContext context,
    RecoveryAnalysis analysis,
  ) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Recovery Score',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    CircularProgressIndicator(
                      value: analysis.recoveryScore,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getRecoveryColor(analysis.recoveryScore),
                      ),
                      strokeWidth: 8,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${(analysis.recoveryScore * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getRecoveryStatus(analysis.recoveryScore),
                      style: TextStyle(
                        color: _getRecoveryColor(analysis.recoveryScore),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fatigue Level',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getFatigueColor(analysis.fatigueLevel)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        analysis.fatigueLevel.name.toUpperCase(),
                        style: TextStyle(
                          color: _getFatigueColor(analysis.fatigueLevel),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (analysis.sleepQuality != null ||
                analysis.stressLevel != null ||
                analysis.nutritionScore != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Metrics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (analysis.sleepQuality != null)
                        _buildMetricRow(
                          'Sleep Quality',
                          analysis.sleepQuality!,
                          Icons.bedtime,
                        ),
                      if (analysis.stressLevel != null)
                        _buildMetricRow(
                          'Stress Level',
                          1 - analysis.stressLevel!,
                          Icons.psychology,
                        ),
                      if (analysis.nutritionScore != null)
                        _buildMetricRow(
                          'Nutrition',
                          analysis.nutritionScore!,
                          Icons.restaurant,
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Workout Suggestion',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      analysis.nextWorkoutSuggestion,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recovery Recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...analysis.recommendations.map(_buildRecommendationItem),
          ],
        ),
      );

  Widget _buildMetricRow(String label, double value, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label),
            ),
            Container(
              width: 100,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getRecoveryColor(value),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );

  Widget _buildRecommendationItem(RecoveryRecommendation recommendation) =>
      Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getPriorityColor(recommendation.priority)
                      .withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getRecoveryTypeIcon(recommendation.type),
                  color: _getPriorityColor(recommendation.priority),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      recommendation.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(recommendation.priority)
                      .withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recommendation.priority.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(recommendation.priority),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Color _getRecoveryColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getRecoveryStatus(double score) {
    if (score >= 0.8) return 'Excellent';
    if (score >= 0.6) return 'Good';
    if (score >= 0.4) return 'Fair';
    return 'Poor';
  }

  Color _getFatigueColor(FatigueLevel level) {
    switch (level) {
      case FatigueLevel.low:
        return Colors.green;
      case FatigueLevel.moderate:
        return Colors.orange;
      case FatigueLevel.high:
        return Colors.red;
      case FatigueLevel.severe:
        return Colors.red[900]!;
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.critical:
        return Colors.red[900]!;
    }
  }

  IconData _getRecoveryTypeIcon(RecoveryType type) {
    switch (type) {
      case RecoveryType.rest:
        return Icons.hotel;
      case RecoveryType.sleep:
        return Icons.bedtime;
      case RecoveryType.nutrition:
        return Icons.restaurant;
      case RecoveryType.hydration:
        return Icons.water_drop;
      case RecoveryType.stretching:
        return Icons.accessibility_new;
      case RecoveryType.massage:
        return Icons.spa;
    }
  }
}

class ProgressAnalysisTab extends HookConsumerWidget {
  const ProgressAnalysisTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const params = ProgressiveOverloadParams(
      userId: _kDefaultUserId,
      exerciseId: 'bench_press',
    );

    final progressAsync = ref.watch(progressiveOverloadProvider(params));

    return progressAsync.when(
      data: (suggestions) => _buildProgressAnalysis(context, ref, suggestions),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildProgressAnalysis(
    BuildContext context,
    WidgetRef ref,
    List<ProgressiveOverloadSuggestion> suggestions,
  ) =>
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return _buildProgressCard(context, ref, suggestion);
        },
      );

  Widget _buildProgressCard(
    BuildContext context,
    WidgetRef ref,
    ProgressiveOverloadSuggestion suggestion,
  ) =>
      Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Progressive Overload',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(suggestion.confidence * 100).round()}% confidence',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildCurrentStats(suggestion),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSuggestedStats(suggestion),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                suggestion.reasoning,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (suggestion.timeframe != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Timeframe: ${suggestion.timeframe}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final appliedSuggestions =
                      ref.watch(appliedProgressSuggestionsProvider);
                  final isApplied =
                      appliedSuggestions.contains(suggestion.exerciseId);

                  return ElevatedButton(
                    onPressed: isApplied
                        ? null
                        : () => _applyProgressiveOverloadSuggestion(
                              context,
                              ref,
                              suggestion,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApplied ? Colors.green : null,
                    ),
                    child: Text(isApplied ? 'Applied' : 'Apply Suggestion'),
                  );
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildCurrentStats(ProgressiveOverloadSuggestion suggestion) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text('${suggestion.currentWeight}kg'),
          Text('${suggestion.currentReps} reps'),
          Text('${suggestion.currentSets} sets'),
        ],
      );

  Widget _buildSuggestedStats(ProgressiveOverloadSuggestion suggestion) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${suggestion.suggestedWeight}kg',
            style: TextStyle(
              color: suggestion.suggestedWeight != suggestion.currentWeight
                  ? Colors.blue
                  : null,
              fontWeight: suggestion.suggestedWeight != suggestion.currentWeight
                  ? FontWeight.bold
                  : null,
            ),
          ),
          Text(
            '${suggestion.suggestedReps} reps',
            style: TextStyle(
              color: suggestion.suggestedReps != suggestion.currentReps
                  ? Colors.blue
                  : null,
              fontWeight: suggestion.suggestedReps != suggestion.currentReps
                  ? FontWeight.bold
                  : null,
            ),
          ),
          Text(
            '${suggestion.suggestedSets} sets',
            style: TextStyle(
              color: suggestion.suggestedSets != suggestion.currentSets
                  ? Colors.blue
                  : null,
              fontWeight: suggestion.suggestedSets != suggestion.currentSets
                  ? FontWeight.bold
                  : null,
            ),
          ),
        ],
      );

  Future<void> _applyProgressiveOverloadSuggestion(
    BuildContext context,
    WidgetRef ref,
    ProgressiveOverloadSuggestion suggestion,
  ) async {
    try {
      // For now, let's show a detailed confirmation and save the suggestion as a preference
      // In a full implementation, this would integrate with user preferences or workout templates

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context)!.applyProgressiveOverload),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context)!.applySuggestionQuestion(suggestion.exerciseId),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withAlpha((0.3 * 255).round()),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Targets:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S.of(context)!.suggestedWeight(
                            suggestion.suggestedWeight.toString(),
                          ),
                    ),
                    Text(
                      S
                          .of(context)!
                          .suggestedReps(suggestion.suggestedReps.toString()),
                    ),
                    Text(
                      S
                          .of(context)!
                          .suggestedSets(suggestion.suggestedSets.toString()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                suggestion.reasoning,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Apply'),
            ),
          ],
        ),
      );

      if (confirmed ?? false && context.mounted) {
        // Mark suggestion as applied
        ref.read(appliedProgressSuggestionsProvider.notifier).update(
              (state) => {...state, suggestion.exerciseId},
            );

        // Here you would normally save to user preferences or update templates
        // For this implementation, we'll show a success message
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Progressive overload applied!',
              body: 'Next ${suggestion.exerciseId} workout: '
                  '${suggestion.suggestedWeight}kg × ${suggestion.suggestedReps} × ${suggestion.suggestedSets}',
            )
            .catchError((_) {});
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error applying suggestion',
              body: '$e',
            )
            .catchError((_) {});
      }
    }
  }
}

class GeneralSuggestionsTab extends HookConsumerWidget {
  const GeneralSuggestionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(aiSuggestionsProvider(_kDefaultUserId));

    return suggestionsAsync.when(
      data: (suggestions) => _buildSuggestionsList(context, ref, suggestions),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildSuggestionsList(
    BuildContext context,
    WidgetRef ref,
    List<AISuggestion> suggestions,
  ) =>
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return _buildSuggestionCard(context, ref, suggestion);
        },
      );

  Widget _buildSuggestionCard(
    BuildContext context,
    WidgetRef ref,
    AISuggestion suggestion,
  ) =>
      Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getSuggestionTypeIcon(suggestion.type),
                    color: _getSuggestionTypeColor(suggestion.type),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(suggestion.confidence * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                suggestion.description,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              if (suggestion.reasoning != null) ...[
                const SizedBox(height: 8),
                Text(
                  suggestion.reasoning!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (suggestion.actionable) ...[
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final appliedSuggestions =
                        ref.watch(appliedSuggestionsProvider);
                    final dismissedSuggestions =
                        ref.watch(dismissedSuggestionsProvider);
                    final isApplied =
                        appliedSuggestions.contains(suggestion.id);
                    final isDismissed =
                        dismissedSuggestions.contains(suggestion.id);

                    if (isDismissed) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility_off,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Dismissed',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    return Row(
                      children: [
                        TextButton(
                          onPressed: isApplied
                              ? null
                              : () {
                                  ref
                                      .read(
                                          dismissedSuggestionsProvider.notifier)
                                      .update(
                                        (state) => {...state, suggestion.id},
                                      );
                                },
                          child: const Text('Dismiss'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: isApplied
                              ? null
                              : () => _applyGeneralSuggestion(
                                    context,
                                    ref,
                                    suggestion,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isApplied ? Colors.green : null,
                          ),
                          child: Text(isApplied ? 'Applied' : 'Apply'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      );

  IconData _getSuggestionTypeIcon(SuggestionType type) {
    switch (type) {
      case SuggestionType.workoutRecommendation:
        return Icons.fitness_center;
      case SuggestionType.exerciseSubstitution:
        return Icons.swap_horiz;
      case SuggestionType.progressiveOverload:
        return Icons.trending_up;
      case SuggestionType.recoveryAdvice:
        return Icons.spa;
      case SuggestionType.formTip:
        return Icons.school;
      case SuggestionType.deloadSuggestion:
        return Icons.trending_down;
      case SuggestionType.nutritionTip:
        return Icons.restaurant;
    }
  }

  Color _getSuggestionTypeColor(SuggestionType type) {
    switch (type) {
      case SuggestionType.workoutRecommendation:
        return Colors.blue;
      case SuggestionType.exerciseSubstitution:
        return Colors.orange;
      case SuggestionType.progressiveOverload:
        return Colors.green;
      case SuggestionType.recoveryAdvice:
        return Colors.purple;
      case SuggestionType.formTip:
        return Colors.teal;
      case SuggestionType.deloadSuggestion:
        return Colors.red;
      case SuggestionType.nutritionTip:
        return Colors.brown;
    }
  }

  Future<void> _applyGeneralSuggestion(
    BuildContext context,
    WidgetRef ref,
    AISuggestion suggestion,
  ) async {
    try {
      // Handle different types of suggestions with specific actions
      switch (suggestion.type) {
        case SuggestionType.exerciseSubstitution:
          await _handleExerciseSubstitution(context, suggestion);
          break;
        case SuggestionType.nutritionTip:
          await _handleNutritionTip(context, suggestion);
          break;
        case SuggestionType.formTip:
          await _handleFormTip(context, suggestion);
          break;
        case SuggestionType.recoveryAdvice:
          await _handleRecoveryAdvice(context, suggestion);
          break;
        case SuggestionType.deloadSuggestion:
          await _handleDeloadSuggestion(context, suggestion);
          break;
        case SuggestionType.workoutRecommendation:
          await _handleWorkoutRecommendation(context, suggestion);
          break;
        default:
          // Generic handling for unknown suggestion types
          await _handleGenericSuggestion(context, suggestion);
      }

      // Mark suggestion as applied after successful handling
      ref.read(appliedSuggestionsProvider.notifier).update(
            (state) => {...state, suggestion.id},
          );
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error applying suggestion',
              body: '$e',
            )
            .catchError((_) {});
      }
    }
  }

  Future<void> _handleExerciseSubstitution(
    BuildContext context,
    AISuggestion suggestion,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Substitution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add this exercise substitution to your preferences?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                suggestion.description,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add to Preferences'),
          ),
        ],
      ),
    );

    if (confirmed ?? false && context.mounted) {
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Exercise saved',
            body: 'Exercise substitution saved to preferences!',
          )
          .catchError((_) {});
    }
  }

  Future<void> _handleNutritionTip(
    BuildContext context,
    AISuggestion suggestion,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nutrition Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a reminder for this nutrition tip?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                suggestion.description,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );

    if (confirmed ?? false && context.mounted) {
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Reminder set',
            body: 'Nutrition reminder set!',
          )
          .catchError((_) {});
    }
  }

  Future<void> _handleFormTip(
    BuildContext context,
    AISuggestion suggestion,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Tip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Save this form tip for future reference?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                suggestion.description,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save Tip'),
          ),
        ],
      ),
    );

    if (confirmed ?? false && context.mounted) {
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Saved',
            body: 'Form tip saved!',
          )
          .catchError((_) {});
    }
  }

  Future<void> _handleRecoveryAdvice(
    BuildContext context,
    AISuggestion suggestion,
  ) async {
    if (context.mounted) {
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Recovery advice noted',
            body: suggestion.title,
          )
          .catchError((_) {});
    }
  }

  Future<void> _handleDeloadSuggestion(
    BuildContext context,
    AISuggestion suggestion,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deload Week'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Schedule a deload week as suggested?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                suggestion.description,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Schedule Deload'),
          ),
        ],
      ),
    );

    if (confirmed ?? false && context.mounted) {
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Deload scheduled',
            body: 'Deload week scheduled!',
          )
          .catchError((_) {});
    }
  }

  Future<void> _handleWorkoutRecommendation(
    BuildContext context,
    AISuggestion suggestion,
  ) async {
    if (context.mounted) {
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Workout suggestions',
            body: 'Check the Recommendations tab for workout suggestions!',
            primaryActionLabel: 'View',
            onPrimaryAction: () =>
                DefaultTabController.of(context).animateTo(0),
          )
          .catchError((_) {});
    }
  }

  Future<void> _handleGenericSuggestion(
    BuildContext context,
    AISuggestion suggestion,
  ) async {
    if (context.mounted) {
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Applied',
            body: suggestion.title,
          )
          .catchError((_) {});
    }
  }
}
