import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/admin_data_provider.dart';

// Admin screens will be imported when needed

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real Quick Stats
              _buildRealQuickStats(context, data),
              const SizedBox(height: 24),

              // Admin Features
              _buildFeatureGrid(context, [
                _FeatureCard(
                  title: 'User Management',
                  subtitle: 'Manage users, roles, and accounts',
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () => context.push('/admin/users'),
                ),
                _FeatureCard(
                  title: 'Content Moderation',
                  subtitle: 'Review posts, comments, and reports',
                  icon: Icons.shield,
                  color: Colors.orange,
                  onTap: () => context.push('/admin/content'),
                ),
                _FeatureCard(
                  title: 'Analytics',
                  subtitle: 'Platform metrics and insights',
                  icon: Icons.analytics,
                  color: Colors.green,
                  onTap: () => context.push('/admin/analytics'),
                ),
                _FeatureCard(
                  title: 'Data Operations',
                  subtitle: 'Backup, export, and data management',
                  icon: Icons.storage,
                  color: Colors.brown,
                  onTap: () => context.push('/admin/data'),
                ),
                _FeatureCard(
                  title: 'Admin Settings',
                  subtitle: 'System configuration and feature flags',
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () => context.push('/admin/settings'),
                ),
              ]),

              const SizedBox(height: 24),

              // Real Recent Activity
              _buildRealRecentActivity(context, data),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading admin data: $error'),
              const SizedBox(height: 16),
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
        if (constraints.maxWidth < 400) {
          // Very small screens: Single column
          return Column(
            children: [
              _StatCard(
                title: 'Total Users',
                value: '${data['totalUsers'] ?? 0}',
                change: '+${data['activeUsers'] ?? 0} active',
                icon: Icons.people,
                color: Colors.blue,
              ),
              const SizedBox(height: 4),
              _StatCard(
                title: 'Total Workouts',
                value: '${data['totalWorkouts'] ?? 0}',
                change: '+${data['recentWorkouts'] ?? 0} recent',
                icon: Icons.fitness_center,
                color: Colors.green,
              ),
              const SizedBox(height: 4),
              _StatCard(
                title: 'Templates',
                value: '${data['totalTemplates'] ?? 0}',
                change: '${data['totalExercises'] ?? 0} exercises',
                icon: Icons.list_alt,
                color: Colors.orange,
              ),
              const SizedBox(height: 4),
              _StatCard(
                title: 'Last Updated',
                value: _formatLastUpdated(data['lastUpdated']),
                change: 'Live data',
                icon: Icons.update,
                color: Colors.purple,
              ),
            ],
          );
        } else if (constraints.maxWidth < 600) {
          // Mobile: 2x2 grid
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Users',
                      value: '${data['totalUsers'] ?? 0}',
                      change: '+${data['activeUsers'] ?? 0} active',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: _StatCard(
                      title: 'Total Workouts',
                      value: '${data['totalWorkouts'] ?? 0}',
                      change: '+${data['recentWorkouts'] ?? 0} recent',
                      icon: Icons.fitness_center,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Templates',
                      value: '${data['totalTemplates'] ?? 0}',
                      change: '${data['totalExercises'] ?? 0} exercises',
                      icon: Icons.list_alt,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: _StatCard(
                      title: 'Last Updated',
                      value: _formatLastUpdated(data['lastUpdated']),
                      change: 'Live data',
                      icon: Icons.update,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Desktop: 4 columns
          return Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Users',
                  value: '${data['totalUsers'] ?? 0}',
                  change: '+${data['activeUsers'] ?? 0} active',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Total Workouts',
                  value: '${data['totalWorkouts'] ?? 0}',
                  change: '+${data['recentWorkouts'] ?? 0} recent',
                  icon: Icons.fitness_center,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Templates',
                  value: '${data['totalTemplates'] ?? 0}',
                  change: '${data['totalExercises'] ?? 0} exercises',
                  icon: Icons.list_alt,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Last Updated',
                  value: _formatLastUpdated(data['lastUpdated']),
                  change: 'Live data',
                  icon: Icons.update,
                  color: Colors.purple,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildRealRecentActivity(
      BuildContext context, Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              context,
              'Recent Workouts',
              '${data['recentWorkouts'] ?? 0} workouts completed in the last 7 days',
              Icons.fitness_center,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              context,
              'Active Users',
              '${data['activeUsers'] ?? 0} users have been active recently',
              Icons.people,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              context,
              'Database Status',
              'All systems operational - ${data['totalUsers'] ?? 0} users, ${data['totalWorkouts'] ?? 0} workouts',
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, String subtitle,
      IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatLastUpdated(String? lastUpdated) {
    if (lastUpdated == null) return 'Never';
    try {
      final date = DateTime.parse(lastUpdated);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildQuickStats(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use different layouts based on screen width
        if (constraints.maxWidth < 600) {
          // Mobile: 2x2 grid
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Users',
                      value: '1,234',
                      change: '+12%',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      title: 'Active Today',
                      value: '456',
                      change: '+8%',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Posts Today',
                      value: '89',
                      change: '+15%',
                      icon: Icons.post_add,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      title: 'Reports',
                      value: '3',
                      change: '-2',
                      icon: Icons.flag,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Desktop: 4 columns
          return Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Users',
                  value: '1,234',
                  change: '+12%',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Active Today',
                  value: '456',
                  change: '+8%',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Posts Today',
                  value: '89',
                  change: '+15%',
                  icon: Icons.post_add,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Reports',
                  value: '3',
                  change: '-2',
                  icon: Icons.flag,
                  color: Colors.red,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildFeatureGrid(BuildContext context, List<_FeatureCard> features) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0, // Square cards
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) => features[index],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _ActivityItem(
              icon: Icons.person_add,
              title: 'New user registered',
              subtitle: 'john.doe@example.com',
              time: '2 minutes ago',
            ),
            _ActivityItem(
              icon: Icons.flag,
              title: 'Content reported',
              subtitle: 'Post by user_123',
              time: '5 minutes ago',
            ),
            _ActivityItem(
              icon: Icons.fitness_center,
              title: 'Workout completed',
              subtitle: 'User completed "Push Day"',
              time: '8 minutes ago',
            ),
            _ActivityItem(
              icon: Icons.post_add,
              title: 'New post created',
              subtitle: 'User shared workout progress',
              time: '12 minutes ago',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 18,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              change,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: change.startsWith('+') ? Colors.green : Colors.red,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}
