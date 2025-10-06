/// Professional Polish Components - Usage Examples
/// 
/// This file demonstrates how to use the new professional polish components
/// created in Phase 2 and Phase 3 of the polish implementation.

import 'package:flutter/material.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/skeleton_loader.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/animated_fab.dart';
import '../core/widgets/animated_switch.dart';
import '../core/widgets/custom_refresh_indicator.dart';
import '../core/services/snackbar_service.dart';
import '../core/theme/app_theme.dart';

/// Example screen showcasing all professional polish components
class PolishComponentsExample extends StatefulWidget {
  const PolishComponentsExample({super.key});

  @override
  State<PolishComponentsExample> createState() => _PolishComponentsExampleState();
}

class _PolishComponentsExampleState extends State<PolishComponentsExample> {
  bool _isLoading = false;
  bool _switchValue = false;
  bool _checkboxValue = false;

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      SnackbarService.showSuccess(context, 'Refreshed successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Components'),
      ),
      
      // Pull-to-refresh wrapper
      body: CustomRefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SECTION 1: Buttons
            const Text(
              'Buttons',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Primary button with icon
            AppButton(
              onPressed: () => SnackbarService.showSuccess(context, 'Action completed!'),
              variant: AppButtonVariant.primary,
              size: AppButtonSize.large,
              icon: Icons.play_arrow,
              child: const Text('Start Workout'),
            ),
            const SizedBox(height: 12),
            
            // Secondary button with loading state
            AppButton(
              onPressed: _isLoading ? null : () {
                setState(() => _isLoading = true);
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() => _isLoading = false);
                  SnackbarService.showSuccess(context, 'Saved!');
                });
              },
              variant: AppButtonVariant.secondary,
              isLoading: _isLoading,
              child: const Text('Save Template'),
            ),
            const SizedBox(height: 12),
            
            // Outlined button
            AppButton(
              onPressed: () {},
              variant: AppButtonVariant.outline,
              icon: Icons.edit_outlined,
              child: const Text('Edit'),
            ),
            const SizedBox(height: 12),
            
            // Danger button
            AppButton(
              onPressed: () => SnackbarService.showError(context, 'Item deleted'),
              variant: AppButtonVariant.danger,
              icon: Icons.delete_outline,
              child: const Text('Delete'),
            ),
            
            const SizedBox(height: 32),
            
            // SECTION 2: Cards
            const Text(
              'Cards',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Elevated card with gradient
            AppCard(
              variant: AppCardVariant.elevated,
              gradient: AppTheme.primaryGradient,
              onTap: () => SnackbarService.showInfo(context, 'Card tapped!'),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.fitness_center, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Workout Session',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '45 minutes • Upper Body',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Glass card
            AppCard(
              variant: AppCardVariant.glass,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Glass morphism card with frosted background effect',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // SECTION 3: Loading States
            const Text(
              'Loading States',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            SkeletonLoader(
              isLoading: _isLoading,
              child: const AppCard(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Content loaded!'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isLoading) ...[
              const SkeletonWorkoutCard(),
              const SizedBox(height: 8),
              const SkeletonListTile(),
            ],
            
            const SizedBox(height: 32),
            
            // SECTION 4: Switches & Checkboxes
            const Text(
              'Switches & Checkboxes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Enable notifications'),
                AnimatedSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() => _switchValue = value);
                    SnackbarService.showInfo(
                      context,
                      'Notifications ${value ? 'enabled' : 'disabled'}',
                    );
                  },
                  thumbIcon: Icons.notifications,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('I agree to terms'),
                AnimatedCheckbox(
                  value: _checkboxValue,
                  onChanged: (value) {
                    setState(() => _checkboxValue = value);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // SECTION 5: Empty States
            const Text(
              'Empty States',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            const SizedBox(
              height: 300,
              child: EmptyState(
                title: 'No Workouts Yet',
                subtitle: 'Start your first workout to see your progress here',
                icon: Icons.fitness_center_outlined,
                actionText: 'Create Workout',
                // onAction: () => context.go('/workout-templates'),
              ),
            ),
          ],
        ),
      ),
      
      // Animated FAB
      floatingActionButton: AnimatedFAB(
        icon: Icons.add,
        onPressed: () => SnackbarService.showSuccess(context, 'FAB pressed!'),
      ),
    );
  }
}

/// Example: Using components in a real workout screen
class WorkoutScreenExample extends StatefulWidget {
  const WorkoutScreenExample({super.key});

  @override
  State<WorkoutScreenExample> createState() => _WorkoutScreenExampleState();
}

class _WorkoutScreenExampleState extends State<WorkoutScreenExample> {
  bool _isLoading = true;
  final List<String> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _exercises.addAll(['Bench Press', 'Squats', 'Deadlifts']);
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      SnackbarService.showSuccess(context, 'Workout updated!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Workout'),
      ),
      body: AnimatedRefreshIndicator(
        onRefresh: _handleRefresh,
        child: _isLoading
            ? ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: SkeletonWorkoutCard(),
                ),
              )
            : _exercises.isEmpty
                ? const EmptyState(
                    title: 'No Exercises',
                    subtitle: 'Add exercises to start your workout',
                    icon: Icons.fitness_center,
                    actionText: 'Add Exercise',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AppCard(
                        variant: AppCardVariant.elevated,
                        heroTag: 'exercise-$index',
                        onTap: () {},
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center),
                          title: Text(_exercises[index]),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: ExpandableFAB(
        icon: Icons.add,
        distance: 70,
        children: [
          FABChild(
            icon: Icons.add,
            label: 'Add Exercise',
            onPressed: () => SnackbarService.showInfo(context, 'Add exercise'),
          ),
          FABChild(
            icon: Icons.timer,
            label: 'Start Timer',
            onPressed: () => SnackbarService.showInfo(context, 'Timer started'),
          ),
          FABChild(
            icon: Icons.save,
            label: 'Save Workout',
            onPressed: () => SnackbarService.showSuccess(context, 'Workout saved!'),
          ),
        ],
      ),
    );
  }
}

/// Example: Snackbar usage patterns
void snackbarExamples(BuildContext context) {
  // Success with action
  SnackbarService.show(
    context,
    message: 'Workout completed successfully!',
    type: SnackbarType.success,
    actionLabel: 'View Stats',
    onAction: () {
      // Navigate to stats
    },
  );

  // Error
  SnackbarService.showError(
    context,
    'Failed to save workout. Please try again.',
  );

  // Warning
  SnackbarService.showWarning(
    context,
    'Low battery. Consider saving your progress.',
  );

  // Info
  SnackbarService.showInfo(
    context,
    'New exercise library update available!',
  );

  // Simple success
  SnackbarService.showSuccess(
    context,
    'Template saved successfully',
  );
}
