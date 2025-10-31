import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _AdminCard(
              icon: Icons.sync,
              title: 'Data Sync',
              subtitle: 'Sync local data to Supabase',
              color: Colors.blue,
              onTap: () => context.push('/admin/sync'),
            ),
            _AdminCard(
              icon: Icons.bug_report,
              title: 'Database Test',
              subtitle: 'Test database connection',
              color: Colors.orange,
              onTap: () => context.push('/admin/test'),
            ),
            _AdminCard(
              icon: Icons.people,
              title: 'User Management',
              subtitle: 'Manage users',
              color: Colors.green,
              onTap: () => context.push('/admin/users'),
            ),
            _AdminCard(
              icon: Icons.content_paste,
              title: 'Content Moderation',
              subtitle: 'Moderate content',
              color: Colors.purple,
              onTap: () => context.push('/admin/content'),
            ),
            _AdminCard(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'View analytics',
              color: Colors.teal,
              onTap: () => context.push('/admin/analytics'),
            ),
            _AdminCard(
              icon: Icons.settings_system_daydream,
              title: 'System Admin',
              subtitle: 'System settings',
              color: Colors.red,
              onTap: () => context.push('/admin/system'),
            ),
            _AdminCard(
              icon: Icons.storage,
              title: 'Data Operations',
              subtitle: 'Database operations',
              color: Colors.indigo,
              onTap: () => context.push('/admin/data'),
            ),
            _AdminCard(
              icon: Icons.settings,
              title: 'Admin Settings',
              subtitle: 'Admin configuration',
              color: Colors.blueGrey,
              onTap: () => context.push('/admin/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
