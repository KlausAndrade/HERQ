import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/ai_models.dart';
import '../providers/ai_providers.dart';

class AICoachingScreen extends HookConsumerWidget {
  const AICoachingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Coach'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Recommendations', icon: Icon(Icons.lightbulb_outline)),
              Tab(text: 'Recovery', icon: Icon(Icons.spa)),
              Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
              Tab(text: 'Suggestions', icon: Icon(Icons.tips_and_updates)),
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
}

class WorkoutRecommendationsTab extends HookConsumerWidget {
  const WorkoutRecommendationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = WorkoutRecommendationParams(
      userId: 'current_user',
      preferredMuscleGroups: ['chest', 'back', 'shoulders'],
      availableEquipment: ['barbell', 'dumbbell', 'bench'],
      maxDuration: 60,
    );

    final recommendationsAsync =
        ref.watch(workoutRecommendationsProvider(params));

    return recommendationsAsync.when(
      data: (recommendations) =>
          _buildRecommendationsList(context, recommendations),
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
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList(
      BuildContext context, List<WorkoutRecommendation> recommendations) {
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
        return _buildRecommendationCard(context, recommendation);
      },
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, WorkoutRecommendation recommendation) {
    return Card(
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
                        .withOpacity(0.2),
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
                    color: Colors.green.withOpacity(0.2),
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
            Text(
              'Exercises:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendation.exercises
                .map((exercise) => _buildExerciseItem(exercise)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // View details
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Start workout
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Starting ${recommendation.name}...'),
                        ),
                      );
                    },
                    child: const Text('Start Workout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(RecommendedExercise exercise) {
    return Padding(
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
  }

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
}

class RecoveryAnalysisTab extends HookConsumerWidget {
  const RecoveryAnalysisTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recoveryAsync = ref.watch(recoveryAnalysisProvider('current_user'));

    return recoveryAsync.when(
      data: (analysis) => _buildRecoveryAnalysis(context, analysis),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildRecoveryAnalysis(
      BuildContext context, RecoveryAnalysis analysis) {
    return SingleChildScrollView(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      _buildMetricRow('Sleep Quality', analysis.sleepQuality!,
                          Icons.bedtime),
                    if (analysis.stressLevel != null)
                      _buildMetricRow('Stress Level', 1 - analysis.stressLevel!,
                          Icons.psychology),
                    if (analysis.nutritionScore != null)
                      _buildMetricRow('Nutrition', analysis.nutritionScore!,
                          Icons.restaurant),
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
          ...analysis.recommendations
              .map((rec) => _buildRecommendationItem(rec)),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, double value, IconData icon) {
    return Padding(
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
  }

  Widget _buildRecommendationItem(RecoveryRecommendation recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    _getPriorityColor(recommendation.priority).withOpacity(0.2),
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
                color:
                    _getPriorityColor(recommendation.priority).withOpacity(0.2),
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
  }

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
    final params = ProgressiveOverloadParams(
      userId: 'current_user',
      exerciseId: 'bench_press',
    );

    final progressAsync = ref.watch(progressiveOverloadProvider(params));

    return progressAsync.when(
      data: (suggestions) => _buildProgressAnalysis(context, suggestions),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildProgressAnalysis(
      BuildContext context, List<ProgressiveOverloadSuggestion> suggestions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _buildProgressCard(context, suggestion);
      },
    );
  }

  Widget _buildProgressCard(
      BuildContext context, ProgressiveOverloadSuggestion suggestion) {
    return Card(
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
                    color: Colors.blue.withOpacity(0.2),
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
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Suggestion applied to next workout'),
                  ),
                );
              },
              child: const Text('Apply Suggestion'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStats(ProgressiveOverloadSuggestion suggestion) {
    return Column(
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
  }

  Widget _buildSuggestedStats(ProgressiveOverloadSuggestion suggestion) {
    return Column(
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
  }
}

class GeneralSuggestionsTab extends HookConsumerWidget {
  const GeneralSuggestionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(aiSuggestionsProvider('current_user'));

    return suggestionsAsync.when(
      data: (suggestions) => _buildSuggestionsList(context, suggestions),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildSuggestionsList(
      BuildContext context, List<AISuggestion> suggestions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _buildSuggestionCard(context, suggestion);
      },
    );
  }

  Widget _buildSuggestionCard(BuildContext context, AISuggestion suggestion) {
    return Card(
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
                    color: Colors.green.withOpacity(0.2),
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
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Dismiss suggestion
                    },
                    child: const Text('Dismiss'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Applied: ${suggestion.title}'),
                        ),
                      );
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

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
}
