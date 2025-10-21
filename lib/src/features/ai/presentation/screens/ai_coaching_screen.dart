import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/widgets/swipe_back_wrapper.dart';
import '../../../settings/providers/locale_provider.dart';
import '../providers/ai_providers.dart';
import '../widgets/generated_workout_card.dart';
import '../widgets/optimized_folder_view.dart';
import '../dialogs/folder_selection_dialog.dart';

class AICoachingScreen extends HookConsumerWidget {
  const AICoachingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if we're in admin mode from provider
    final isAdminMode = ref.watch(currentAdminModeProvider);
    
    return SwipeBackWrapperWithFeedback(
      onSwipeBack: () => context.go('/'),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
            title: Row(
              children: [
                Text(S.of(context)!.aiCoach),
                if (isAdminMode) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  text: S.of(context)!.buildWorkout,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                Tab(
                  text: S.of(context)!.optimizeWorkouts,
                  icon: const Icon(Icons.auto_fix_high),
                ),
                Tab(
                  text: S.of(context)!.evaluateProgress,
                  icon: const Icon(Icons.analytics),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              BuildNextWorkoutTab(isAdminMode: isAdminMode),
              OptimizeWorkoutsTab(isAdminMode: isAdminMode),
              EvaluateProgressTab(isAdminMode: isAdminMode),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab for building next workout based on user history
class BuildNextWorkoutTab extends HookConsumerWidget {
  const BuildNextWorkoutTab({super.key, this.isAdminMode = false});
  
  final bool isAdminMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context)!.buildMyNextWorkout,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              S.of(context)!.generatePersonalizedWorkout,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _generateWorkout(context, ref),
              icon: const Icon(Icons.auto_awesome),
              label: Text(S.of(context)!.generateMyNextWorkout),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context)!.howItWorks,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    S.of(context)!.buildWorkoutInstructions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateWorkout(BuildContext context, WidgetRef ref) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(S.of(context)!.generatingPersonalizedWorkout),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(S.of(context)!.cancelBtn),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Trigger the API call
      final workoutData = await ref.read(generateNextWorkoutProvider(isAdminMode).future);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show results dialog
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.95,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dialog header
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            S.of(context)!.generatedWorkout,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Divider(),
                    const SizedBox(height: 2),
                    
                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        child: GeneratedWorkoutCard(
                          workoutData: workoutData,
                          isAdminMode: isAdminMode,
                          onSave: () {
                            Navigator.of(context).pop();
                            ref.invalidate(generateNextWorkoutProvider(isAdminMode));
                          },
                          onStart: () {
                            Navigator.of(context).pop();
                            context.go('/active-workout');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context)!.failedToGenerateWorkout),
            content: Text('${S.of(context)!.error}: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(S.of(context)!.ok),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _generateWorkout(context, ref);
                },
                child: Text(S.of(context)!.tryAgain),
              ),
            ],
          ),
        );
      }
    }
  }
}

/// Tab for optimizing workout folders
class OptimizeWorkoutsTab extends HookConsumerWidget {
  const OptimizeWorkoutsTab({super.key, this.isAdminMode = false});
  
  final bool isAdminMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context)!.optimizeMyWorkouts,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              S.of(context)!.aiPoweredOptimization,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Select folder button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showFolderSelectionDialog(context, ref),
              icon: const Icon(Icons.folder_open),
              label: Text(S.of(context)!.selectFolderToOptimize),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context)!.howItWorks,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    S.of(context)!.optimizeWorkoutInstructions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFolderSelectionDialog(BuildContext context, WidgetRef ref) async {
    final selectedFolderId = await showDialog<String>(
      context: context,
      builder: (context) => const FolderSelectionDialog(),
    );

    if (selectedFolderId != null && context.mounted) {
      _showOptimizationResults(context, ref, selectedFolderId);
    }
  }

  Future<void> _showOptimizationResults(BuildContext context, WidgetRef ref, String folderId) async {
    final optimizeAsync = ref.watch(optimizeFolderProvider(folderId));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog header
                Row(
                  children: [
                    Icon(
                      Icons.auto_fix_high,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        S.of(context)!.optimizedWorkoutFolder,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    child: optimizeAsync.when(
                      data: (optimizedData) => OptimizedFolderView(
                        optimizedData: optimizedData,
                        originalFolderId: folderId,
                        onSave: () {
                          Navigator.of(context).pop();
                          ref.invalidate(optimizeFolderProvider(folderId));
                        },
                        onReplace: () {
                          Navigator.of(context).pop();
                          ref.invalidate(optimizeFolderProvider(folderId));
                        },
                      ),
                      loading: () => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(S.of(context)!.analyzingAndOptimizing),
                          ],
                        ),
                      ),
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
                              S.of(context)!.failedToOptimizeFolder,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                ref.invalidate(optimizeFolderProvider(folderId));
                              },
                              child: Text(S.of(context)!.tryAgain),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab for evaluating user's progress with AI analysis
class EvaluateProgressTab extends HookConsumerWidget {
  const EvaluateProgressTab({super.key, this.isAdminMode = false});

  final bool isAdminMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context)!.evaluateMyProgress,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              S.of(context)!.getProfessionalAnalysis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Start Evaluation Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startEvaluation(context, ref),
              icon: const Icon(Icons.analytics),
              label: Text(S.of(context)!.startEvaluation),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context)!.howItWorks,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    S.of(context)!.evaluateProgressInstructions,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Warning/Notice
          Card(
            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      S.of(context)!.evaluateProgressWarning,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startEvaluation(BuildContext context, WidgetRef ref) async {
    final l10n = S.of(context)!;
    
    // Check if user has already evaluated today
    try {
      final prefsAsync = await ref.read(userPreferencesProvider.future);
      final lastEvaluationDate = prefsAsync['lastProgressEvaluationDate'] as String?;
      
      if (lastEvaluationDate != null) {
        final lastDate = DateTime.parse(lastEvaluationDate);
        final today = DateTime.now();
        
        // Check if evaluation was done today
        if (lastDate.year == today.year && 
            lastDate.month == today.month && 
            lastDate.day == today.day) {
          // Already evaluated today - show message with option to see again
          final lastResults = prefsAsync['lastProgressEvaluationResults'] as Map<String, dynamic>?;
          
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l10n.evaluationAlreadyDone),
                    ),
                  ],
                ),
                content: Text(l10n.evaluationAlreadyDoneMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.ok),
                  ),
                  if (lastResults != null)
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showEvaluationResults(context, lastResults);
                      },
                      child: Text(l10n.seeAgain),
                    ),
                ],
              ),
            );
          }
          return;
        }
      }
    } catch (e) {
      // If there's an error reading preferences, continue with evaluation
      print('Error checking last evaluation date: $e');
    }
    
    // Show loading dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              l10n.analyzingTrainingHistory,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.thisMayTakeMoment,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );

    try {
      // Get current locale
      final locale = ref.read(localeProvider);
      
      // Get evaluation from AI provider
      final evaluation = await ref.read(
        evaluateProgressProvider(
          EvaluateProgressParams(
            isAdminMode: isAdminMode,
            languageCode: locale.languageCode,
          ),
        ).future,
      );

      // Save the evaluation date and results
      try {
        final prefsService = ref.read(preferencesUpdateProvider);
        await prefsService.updatePreferences({
          'lastProgressEvaluationDate': DateTime.now().toIso8601String(),
          'lastProgressEvaluationResults': evaluation,
        });
      } catch (e) {
        print('Error saving evaluation date and results: $e');
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show evaluation results
        _showEvaluationResults(context, evaluation);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.evaluationFailed),
            content: Text(l10n.failedToAnalyzeProgress(e.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showEvaluationResults(BuildContext context, Map<String, dynamic> evaluation) {
    final l10n = S.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.progressEvaluation,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overall Assessment
                      if (evaluation['overall_assessment'] != null) ...[
                        _buildSection(
                          context,
                          l10n.overallAssessment,
                          Icons.summarize,
                          evaluation['overall_assessment'] as String,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Strengths
                      if (evaluation['strengths'] != null) ...[
                        _buildSection(
                          context,
                          l10n.strengths,
                          Icons.thumb_up,
                          evaluation['strengths'] as String,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Weaknesses (Direct feedback)
                      if (evaluation['weaknesses'] != null) ...[
                        _buildSection(
                          context,
                          l10n.areasNeedingAttention,
                          Icons.warning_amber,
                          evaluation['weaknesses'] as String,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Muscle Balance
                      if (evaluation['muscle_balance'] != null) ...[
                        _buildSection(
                          context,
                          l10n.muscleGroupBalance,
                          Icons.balance,
                          evaluation['muscle_balance'] as String,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Training Goal
                      if (evaluation['detected_goal'] != null) ...[
                        _buildSection(
                          context,
                          l10n.detectedTrainingGoal,
                          Icons.flag,
                          evaluation['detected_goal'] as String,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Recommendations
                      if (evaluation['recommendations'] != null) ...[
                        _buildSection(
                          context,
                          l10n.professionalRecommendations,
                          Icons.recommend,
                          evaluation['recommendations'] as String,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.gotIt),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    String content, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? Theme.of(context).colorScheme.primary)
              .withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color ?? Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color ?? Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
