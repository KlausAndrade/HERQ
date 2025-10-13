import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/widgets/animated_switch.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/database/seed_database.dart';
import '../../../gamification/data/providers/gamification_provider.dart';
import '../../../social/presentation/providers/leaderboard_providers.dart';
import '../../providers/data_export_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/workout_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final workoutSettings = ref.watch(workoutSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Builder(
              builder: (context) {
                final user = ref.watch(currentUserProvider);
                final isLoggedIn = user != null;

                if (isLoggedIn) {
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: const Text('Logged In'),
                        subtitle: Text(user.email ?? 'No email'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit Profile'),
                        subtitle: const Text('Update your display name and bio'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/edit-profile'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Sign Out'),
                          onTap: () async {
                          final authService = ref.read(authServiceProvider);
                          await authService.signOut();
                          if (context.mounted) {
                            NotificationService().showInAppNotification(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: 'Signed out',
                              body: 'Signed out successfully',
                            ).catchError((_) {});
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  return ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Sign In / Sign Up'),
                    subtitle: const Text('Sync your data across devices'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/auth'),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeModeText(themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Workout Settings Section
          Text(
            'Workout Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Default Rest Timer'),
                  subtitle: Text(ref
                      .read(workoutSettingsProvider.notifier)
                      .getFormattedRestTime()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRestTimerDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.scale_outlined),
                  title: const Text('Weight Unit'),
                  subtitle: Text(ref
                      .read(workoutSettingsProvider.notifier)
                      .getWeightUnitDisplay()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showWeightUnitDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.vibration),
                  title: const Text('Haptic Feedback'),
                  subtitle: const Text('Vibrate on timer completion'),
                  trailing: AnimatedSwitch(
                    value: workoutSettings.hapticFeedback,
                    onChanged: (value) {
                      ref
                          .read(workoutSettingsProvider.notifier)
                          .setHapticFeedback(value);
                    },
                    thumbIcon: Icons.vibration,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: const Text('Auto-start Rest Timer'),
                  subtitle: const Text('Start timer after completing a set'),
                  trailing: AnimatedSwitch(
                    value: workoutSettings.autoStartRestTimer,
                    onChanged: (value) {
                      ref
                          .read(workoutSettingsProvider.notifier)
                          .setAutoStartRestTimer(value);
                    },
                    thumbIcon: Icons.timer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Section
          Text(
            'Data & Privacy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined),
                  title: const Text('Sync Data'),
                  subtitle: const Text('Last synced: Never'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSyncDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Export Data'),
                  subtitle: const Text('Download your workout data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showExportDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete Account'),
                  subtitle: const Text('Permanently delete all data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Maintenance Section
          Text(
            'Maintenance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
              ListTile(
                leading: const Icon(Icons.bug_report, color: Colors.purple),
                title: const Text('Debug Exercise Types'),
                subtitle: const Text('Show all exercises and their types'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDebugExerciseTypesDialog(context, ref),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.leaderboard, color: Colors.green),
                title: const Text('Refresh Leaderboard Stats'),
                subtitle: const Text('Recalculate stats from all workouts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _refreshLeaderboardStats(context, ref),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text('Debug: Show User Stats'),
                subtitle: const Text('View raw user_stats table data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showUserStatsDebug(context, ref),
              ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.build_outlined, color: Colors.orange),
                  title: const Text('Update Exercise Types'),
                  subtitle: const Text('Reassign exercise types to all exercises'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMigrateExerciseTypesDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.blue),
                  title: const Text('Reload Templates & Exercises'),
                  subtitle: const Text('Load new workout templates and exercises'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showReloadTemplatesDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0+1'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _showTermsOfService(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: ref.read(themeModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: ref.read(themeModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: ref.read(themeModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRestTimerDialog(BuildContext context, WidgetRef ref) {
    final currentSettings = ref.read(workoutSettingsProvider);
    int selectedMinutes = currentSettings.defaultRestTimerSeconds ~/ 60;
    int selectedSeconds = currentSettings.defaultRestTimerSeconds % 60;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Default Rest Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minutes
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_up),
                        onPressed: () {
                          setState(() {
                            if (selectedMinutes < 10) selectedMinutes++;
                          });
                        },
                      ),
                      Container(
                        width: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedMinutes.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: () {
                          setState(() {
                            if (selectedMinutes > 0) selectedMinutes--;
                          });
                        },
                      ),
                      const Text('min'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Text(':', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  // Seconds
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_up),
                        onPressed: () {
                          setState(() {
                            selectedSeconds = (selectedSeconds + 15) % 60;
                          });
                        },
                      ),
                      Container(
                        width: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedSeconds.toString().padLeft(2, '0'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: () {
                          setState(() {
                            selectedSeconds = (selectedSeconds - 15) % 60;
                            if (selectedSeconds < 0) selectedSeconds = 45;
                          });
                        },
                      ),
                      const Text('sec'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final totalSeconds = (selectedMinutes * 60) + selectedSeconds;
                if (totalSeconds > 0) {
                  ref
                      .read(workoutSettingsProvider.notifier)
                      .setDefaultRestTimer(totalSeconds);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightUnitDialog(BuildContext context, WidgetRef ref) {
    final currentUnit = ref.read(workoutSettingsProvider).weightUnit;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weight Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Kilograms (kg)'),
              value: 'kg',
              groupValue: currentUnit,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(workoutSettingsProvider.notifier)
                      .setWeightUnit(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Pounds (lb)'),
              value: 'lb',
              groupValue: currentUnit,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(workoutSettingsProvider.notifier)
                      .setWeightUnit(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExportDialog(BuildContext context, WidgetRef ref) async {
    final exportService = ref.read(dataExportServiceProvider);
    final summary = await exportService.getExportSummary();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export your workout data as JSON or CSV'),
            const SizedBox(height: 16),
            Text('📊 Workouts: ${summary['workouts']}'),
            Text('📝 Templates: ${summary['templates']}'),
            Text('🏋️ Exercises: ${summary['exercises']}'),
            Text('🏆 Personal Records: ${summary['personalRecords']}'),
            const SizedBox(height: 16),
            const Text(
              'Choose export format:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _exportAsJson(context, ref);
            },
            child: const Text('JSON'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _exportAsCsv(context, ref);
            },
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAsJson(BuildContext context, WidgetRef ref) async {
    try {
      final exportService = ref.read(dataExportServiceProvider);
      final jsonData = await exportService.exportAllData();

      await Clipboard.setData(ClipboardData(text: jsonData));

      if (context.mounted) {
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Exported',
          body: 'Data exported to clipboard as JSON',
        ).catchError((_) {});
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Export failed',
          body: '${e.toString()}',
        ).catchError((_) {});
      }
    }
  }

  Future<void> _exportAsCsv(BuildContext context, WidgetRef ref) async {
    try {
      final exportService = ref.read(dataExportServiceProvider);
      final csvData = await exportService.exportWorkoutsAsCsv();

      await Clipboard.setData(ClipboardData(text: csvData));

      if (context.mounted) {
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Exported',
          body: 'Workouts exported to clipboard as CSV',
        ).catchError((_) {});
      }
    } catch (e) {
      if (context.mounted) {
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Export failed',
          body: '${e.toString()}',
        ).catchError((_) {});
      }
    }
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cloud sync is not yet configured.'),
            SizedBox(height: 16),
            Text(
              'This feature will allow you to:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• Backup your data to the cloud'),
            Text('• Sync across multiple devices'),
            Text('• Restore data if you lose your device'),
            SizedBox(height: 16),
            Text('Coming soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Warning: This action cannot be undone!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('This will permanently delete:'),
            const SizedBox(height: 8),
            const Text('• All your workout history'),
            const Text('• All workout templates'),
            const Text('• All personal records'),
            const Text('• All settings and preferences'),
            const SizedBox(height: 24),
            const Text(
              'Type DELETE to confirm:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'DELETE',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (confirmController.text == 'DELETE') {
                final database = ref.read(databaseProvider);
                if (database == null) return;

                try {
                  // Delete all data
                  await database.delete(database.workoutSessions).go();
                  await database.delete(database.workoutTemplates).go();
                  await database.delete(database.setEntries).go();
                  await database.delete(database.personalRecords).go();
                  await database.delete(database.exerciseFavorites).go();

                  if (context.mounted) {
                    Navigator.pop(context);
                    NotificationService().showInAppNotification(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: 'Deleted',
                      body: 'Account data deleted',
                    ).catchError((_) {});
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    NotificationService().showInAppNotification(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: 'Error',
                      body: '$e',
                    ).catchError((_) {});
                  }
                }
              } else {
                NotificationService().showInAppNotification(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: 'Confirmation required',
                  body: 'Please type DELETE to confirm',
                ).catchError((_) {});
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            '''GymAI Privacy Policy

Last updated: October 6, 2025

1. Data Collection
We collect and store your workout data locally on your device, including:
• Workout sessions and history
• Exercise performance data
• Personal records and achievements
• User preferences and settings

2. Data Storage
All data is stored locally on your device using encrypted storage. We do not transmit your personal workout data to external servers unless you explicitly enable cloud sync features.

3. Data Usage
Your data is used solely to:
• Track your fitness progress
• Generate insights and recommendations
• Provide personalized workout experiences

4. Data Sharing
We do not share, sell, or distribute your personal workout data to third parties.

5. Your Rights
You have the right to:
• Export your data at any time
• Delete your account and all associated data
• Request information about stored data

6. Contact
For privacy concerns, please contact: privacy@gymai.app

By using GymAI, you agree to this privacy policy.''',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            '''GymAI Terms of Service

Last updated: October 6, 2025

1. Acceptance of Terms
By using GymAI, you agree to these Terms of Service.

2. Service Description
GymAI is a fitness tracking application that helps users:
• Track workout sessions
• Monitor progress and achievements
• Create and manage workout templates
• Record personal records

3. User Responsibilities
You agree to:
• Provide accurate information
• Use the app for lawful purposes only
• Not attempt to reverse engineer the software
• Take responsibility for your own fitness decisions

4. Health Disclaimer
• GymAI is not a substitute for professional medical advice
• Consult healthcare professionals before starting new fitness programs
• We are not liable for injuries or health issues
• Use the app at your own risk

5. Data and Privacy
• Your data is stored locally on your device
• You can export or delete your data at any time
• See our Privacy Policy for more details

6. Intellectual Property
All app content, design, and features are owned by GymAI and protected by copyright laws.

7. Disclaimer of Warranties
The app is provided "as is" without warranties of any kind.

8. Limitation of Liability
We are not liable for any damages arising from app use.

9. Changes to Terms
We may update these terms. Continued use constitutes acceptance of changes.

10. Contact
For questions: support@gymai.app

By using GymAI, you agree to these terms.''',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUserStatsDebug(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    
    print('🔍 Fetching user_stats table...');
    final stats = await db.select(db.userStats).get();
    
    print('  Found ${stats.length} stats entries');
    for (final s in stats) {
      print('  - userId: ${s.userId}');
      print('    totalWorkouts: ${s.totalWorkouts}');
      print('    totalVolume: ${s.totalVolumeLifted}');
      print('    totalSets: ${s.totalSetsCompleted}');
      print('    streak: ${s.currentStreak}');
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Stats Table'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: stats.isEmpty
              ? const Center(child: Text('❌ No user stats found!\n\nRun "Refresh Leaderboard Stats" first.'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: stats.length,
                  itemBuilder: (context, index) {
                    final s = stats[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User: ${s.userId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            Text('Workouts: ${s.totalWorkouts}', style: const TextStyle(fontSize: 11)),
                            Text('Volume: ${s.totalVolumeLifted.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 11)),
                            Text('Sets: ${s.totalSetsCompleted}', style: const TextStyle(fontSize: 11)),
                            Text('Streak: ${s.currentStreak} days', style: const TextStyle(fontSize: 11)),
                            Text('Level: ${s.level}', style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _refreshLeaderboardStats(BuildContext context, WidgetRef ref) async {
    print('🔄 Refresh Leaderboard Stats button clicked');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Refreshing stats...'),
          ],
        ),
      ),
    );

    try {
      final gamificationService = ref.read(gamificationServiceProvider);
      if (gamificationService == null) {
        print('❌ Gamification service is null!');
        throw StateError('Gamification service not available');
      }
      
      print('✅ Gamification service found, calling recalculateUserStats...');
      final stats = await gamificationService.recalculateUserStats();
      print('✅ Stats recalculated: ${stats.totalWorkouts} workouts, ${stats.totalVolumeLifted} kg');

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Invalidate ALL leaderboard providers (it's a family provider)
      // This forces all leaderboard tabs to refresh with new data
      ref.invalidate(leaderboardServiceProvider);
      print('✅ Leaderboard service provider invalidated - all tabs will refresh');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Stats refreshed!\n${stats.totalWorkouts} workouts, ${stats.totalVolumeLifted.toStringAsFixed(1)} kg volume\n\nOpen Leaderboards to see updates!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error refreshing stats: $e');
      print('Stack trace: $stackTrace');
      
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e\nCheck console for details'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showDebugExerciseTypesDialog(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    
    final exercises = await (db.select(db.exercises)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Types in Database'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              return ListTile(
                dense: true,
                title: Text(ex.name, style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                  'Type: ${ex.exerciseType} | Category: ${ex.category}',
                  style: const TextStyle(fontSize: 11),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMigrateExerciseTypesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Exercise Types'),
        content: const Text(
          'This will reassign exercise types to all exercises based on their names and properties.\n\n'
          'Examples:\n'
          '• Plank → Duration\n'
          '• Pull-up → Bodyweight Reps\n'
          '• Assisted Pull-up → Assisted Bodyweight\n'
          '• Running → Distance & Duration\n\n'
          'This may take a moment. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Updating exercise types...'),
                    ],
                  ),
                ),
              );
              
              try {
                final database = ref.read(databaseProvider);
                if (database != null) {
                  await database.migrateExerciseTypes();
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    
                    NotificationService().showInAppNotification(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: 'Exercise types updated',
                      body: 'All exercises have been updated with correct types',
                    ).catchError((_) {});
                  }
                } else {
                  throw Exception('Database not available');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog
                  
                  NotificationService().showInAppNotification(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: 'Error',
                    body: 'Failed to update exercise types: $e',
                  ).catchError((_) {});
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showReloadTemplatesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reload Templates & Exercises'),
        content: const Text(
          'This will reload all workout templates and exercises, including:\n\n'
          '• Calisthenics templates (5 workouts)\n'
          '• AcroYoga folder and templates (4 workouts)\n'
          '• 16 new AcroYoga exercises\n\n'
          'Existing custom data will not be affected. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Reloading templates and exercises...'),
                    ],
                  ),
                ),
              );
              
              try {
                final database = ref.read(databaseProvider);
                if (database != null) {
                  await seedDatabase(database);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    
                    NotificationService().showInAppNotification(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: 'Templates reloaded',
                      body: 'All templates and exercises have been updated',
                    ).catchError((_) {});
                  }
                } else {
                  throw Exception('Database not available');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog
                  
                  NotificationService().showInAppNotification(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: 'Error',
                    body: 'Failed to reload templates: $e',
                  ).catchError((_) {});
                }
              }
            },
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }
}
