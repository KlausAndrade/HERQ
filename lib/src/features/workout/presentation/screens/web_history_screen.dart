import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/workout_web_sessions_provider.dart';

class WebHistoryScreen extends ConsumerWidget {
  const WebHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(allSessionsWebProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: sessions.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 24),
                  Text('No workouts yet'),
                  SizedBox(height: 8),
                  Text('Start your first workout to see it here!'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final session = data[index];
              final date = DateTime.parse(session['started_at'] as String);
              final completed = session['completed_at'] != null;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Icon(
                    completed ? Icons.check_circle : Icons.pending,
                    color: completed ? Colors.green : Colors.orange,
                  ),
                  title: Text(session['name'] ?? 'Workout'),
                  subtitle: Text(_formatDate(date)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _StatRow(
                            label: 'Duration',
                            value: _formatDuration(
                              session['total_duration_seconds'] as int? ?? 0,
                            ),
                          ),
                          _StatRow(
                            label: 'Total Sets',
                            value: '${session['total_sets'] ?? 0}',
                          ),
                          _StatRow(
                            label: 'Total Reps',
                            value: '${session['total_reps'] ?? 0}',
                          ),
                          _StatRow(
                            label: 'Volume',
                            value:
                                '${session['total_volume']?.toStringAsFixed(1) ?? 0} kg',
                          ),
                          _StatRow(
                            label: 'Tonnage',
                            value:
                                '${session['total_tonnage']?.toStringAsFixed(1) ?? 0} kg',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('value', value));
  }
}
