import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/admin_data_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminDashboardProvider),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/admin/settings'),
          ),
        ],
      ),
      body: dashboardData.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real Quick Stats
              _buildRealQuickStats(context, data),
              const SizedBox(height: 2),

              // Admin Features
              _buildFeatureGrid(context, [
                _FeatureCard(
                  title: 'Global Content Management',
                  subtitle: 'Manage exercises and templates for all users',
                  icon: Icons.fitness_center,
                  color: Colors.blue,
                  onTap: () => _showGlobalContentManagement(context, ref),
                ),
                _FeatureCard(
                  title: 'System Maintenance',
                  subtitle: 'Database cleanup and system operations',
                  icon: Icons.build,
                  color: Colors.orange,
                  onTap: () => _showSystemMaintenance(context, ref),
                ),
                _FeatureCard(
                  title: 'Debug Tools',
                  subtitle: 'Development and debugging utilities',
                  icon: Icons.bug_report,
                  color: Colors.purple,
                  onTap: () => _showDebugTools(context, ref),
                ),
                _FeatureCard(
                  title: 'User Management',
                  subtitle: 'Manage users, roles, and accounts',
                  icon: Icons.people,
                  color: Colors.green,
                  onTap: () => context.push('/admin/users'),
                ),
                _FeatureCard(
                  title: 'Analytics',
                  subtitle: 'Platform metrics and insights',
                  icon: Icons.analytics,
                  color: Colors.indigo,
                  onTap: () => context.push('/admin/analytics'),
                ),
                _FeatureCard(
                  title: 'Admin Settings',
                  subtitle: 'System configuration and feature flags',
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () => context.push('/admin/settings'),
                ),
              ]),

            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 4),
              Text('Error loading admin data: $error'),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () => ref.refresh(adminDashboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealQuickStats(BuildContext context, Map<String, dynamic> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StatCard(
                    title: 'Total Users',
                    value: '${data['totalUsers'] ?? 0}',
                    change: '+${data['activeUsers'] ?? 0} active',
                    color: Colors.blue,
                    isPositive: true,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _StatCard(
                    title: 'Total Workouts',
                    value: '${data['totalWorkouts'] ?? 0}',
                    change: '+${data['recentWorkouts'] ?? 0} recent',
                    color: Colors.green,
                    isPositive: true,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _StatCard(
                    title: 'Templates',
                    value: '${data['totalTemplates'] ?? 0}',
                    change: '${data['totalExercises'] ?? 0} exercises',
                    color: Colors.orange,
                    isPositive: true,
                  ),
                ),
              ),
            ],
          );
        }
    );
  }

  Widget _buildFeatureGrid(BuildContext context, List<_FeatureCard> features) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on screen width
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth < 400) {
          // Very small screens: Single column
          crossAxisCount = 1;
          childAspectRatio = 1.5;
        } else if (constraints.maxWidth < 600) {
          // Small screens: 2 columns
          crossAxisCount = 2;
          childAspectRatio = 1.3;
        } else if (constraints.maxWidth < 900) {
          // Medium screens: 2 columns with better ratio
          crossAxisCount = 2;
          childAspectRatio = 1.2;
        } else {
          // Large screens: 3 columns
          crossAxisCount = 3;
          childAspectRatio = 1.1;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) => features[index],
        );
      },
    );
  }

  /// Show Global Content Management dialog
  void _showGlobalContentManagement(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Global Content Management'),
        content: const Text(
          'Manage exercises and templates that are available to all users.\n\n'
          'Changes will affect all users immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to exercise library with admin mode
              context.go('/exercises?admin=true');
            },
            child: const Text('Manage Exercises'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to templates list with admin mode (for editing existing templates)
              context.go('/workout-templates?admin=true');
            },
            child: const Text('Manage Templates'),
          ),
        ],
      ),
    );
  }

  /// Show System Maintenance dialog
  void _showSystemMaintenance(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Maintenance'),
        content: const Text(
          'Database cleanup and system operations.\n\n'
          'Use with caution - these operations affect the entire system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to system admin screen
              context.go('/admin/system');
            },
            child: const Text('Open Maintenance'),
          ),
        ],
      ),
    );
  }

  /// Show Debug Tools dialog
  void _showDebugTools(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Tools'),
        content: const Text(
          'Development and debugging utilities.\n\n'
          'These tools are for development and troubleshooting purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to debug tools screen
              context.go('/admin/debug');
            },
            child: const Text('Open Debug Tools'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final Color color;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.color,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.03),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Main value
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            
            // Change indicator
            Text(
              change,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
