import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/user_context_service.dart';
import '../../../workout/presentation/providers/template_providers.dart';
import '../../domain/models/ai_models.dart';
import '../providers/ai_providers.dart';
import '../widgets/generated_workout_card.dart';
import '../widgets/optimized_folder_view.dart';
import '../dialogs/folder_selection_dialog.dart';

// Default user ID for AI coaching - TODO: Replace with actual user ID when auth implemented
const String _kDefaultUserId = 'default_user';

class AICoachingScreen extends HookConsumerWidget {
  const AICoachingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
        length: 2,
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
                const Tab(
                  text: 'Build Workout',
                  icon: Icon(Icons.add_circle_outline),
                ),
                const Tab(
                  text: 'Optimize',
                  icon: Icon(Icons.auto_fix_high),
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              BuildNextWorkoutTab(),
              OptimizeWorkoutsTab(),
            ],
          ),
        ),
      );
}

/// Tab for building next workout based on user history
class BuildNextWorkoutTab extends HookConsumerWidget {
  const BuildNextWorkoutTab({super.key});

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
                              'Build My Next Workout',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Generate a personalized workout based on your training history',
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
              label: const Text('Generate My Next Workout'),
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
                    'How it works:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. AI analyzes your last 14 workout sessions\n'
                    '2. Identifies training patterns and progression\n'
                    '3. Generates a personalized workout plan\n'
                    '4. Save as template or start immediately',
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
              const Text('Generating your personalized workout...'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Trigger the API call
      final workoutData = await ref.read(generateNextWorkoutProvider.future);
      
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
                            'Generated Workout',
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
                          onSave: () {
                            Navigator.of(context).pop();
                            ref.invalidate(generateNextWorkoutProvider);
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
            title: const Text('Failed to Generate Workout'),
            content: Text('Error: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _generateWorkout(context, ref);
                },
                child: const Text('Try Again'),
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
  const OptimizeWorkoutsTab({super.key});

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
                              'Optimize My Workouts',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI-powered optimization of your existing workout routines',
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
              label: const Text('Select Folder to Optimize'),
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
                    'How it works:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Select a workout folder from your templates\n'
                    '2. AI analyzes all templates in the folder\n'
                    '3. Get optimized versions with improvements\n'
                    '4. Save as new templates or replace originals',
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
                        'Optimized Workout Folder',
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
                      loading: () => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Analyzing and optimizing your workouts...'),
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
                              'Failed to optimize folder',
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
                              child: const Text('Try Again'),
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