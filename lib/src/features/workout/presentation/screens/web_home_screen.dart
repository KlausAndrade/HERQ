import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../l10n/app_localizations.dart';

import '../providers/template_web_provider.dart';
import '../providers/workout_web_sessions_provider.dart';

class WebHomeScreen extends ConsumerWidget {
  const WebHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final templates = ref.watch(workoutTemplatesWebProvider);
    final recentSessions = ref.watch(recentSessionsWebProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.email ?? "User"}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.fitness_center,
                    title: 'Templates',
                    subtitle: 'Create & Manage',
                    onTap: () => context.go('/templates'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.history,
                    title: 'History',
                    subtitle: 'View Progress',
                    onTap: () => context.go('/history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Templates
            Text(
              'Quick Start',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            templates.when(
              data: (data) {
                if (data.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text('No templates yet'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/templates'),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Template'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length > 3 ? 3 : data.length,
                  itemBuilder: (context, index) {
                    final template = data[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.fitness_center),
                        ),
                        title: Text(template['name'] ?? 'Unnamed'),
                        subtitle: Text(
                          '${(template['exercise_ids'] as List?)?.length ?? 0} exercises',
                        ),
                        trailing: const Icon(Icons.play_arrow),
                        onTap: () => context.go('/workout/${template['id']}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),

            const SizedBox(height: 32),

            // Recent Workouts
            Text(
              'Recent Workouts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            recentSessions.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child:
                            Text('No workouts yet. Start your first workout!'),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length > 5 ? 5 : data.length,
                  itemBuilder: (context, index) {
                    final session = data[index];
                    final date =
                        DateTime.parse(session['started_at'] as String);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading:
                            const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(session['name'] ?? 'Workout'),
                        subtitle: Text(
                          '${session['total_sets'] ?? 0} sets • ${_formatDate(date)}',
                        ),
                        trailing: Text(
                          '${session['total_volume']?.toStringAsFixed(0) ?? 0} kg',
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(icon, size: 48, color: const Color(0xFF6366F1)),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('subtitle', subtitle));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }
}
