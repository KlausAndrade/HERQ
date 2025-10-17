import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/widgets/swipe_back_wrapper.dart';
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
        length: 2,
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
              ],
            ),
          ),
          body: TabBarView(
            children: [
              BuildNextWorkoutTab(isAdminMode: isAdminMode),
              OptimizeWorkoutsTab(isAdminMode: isAdminMode),
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
