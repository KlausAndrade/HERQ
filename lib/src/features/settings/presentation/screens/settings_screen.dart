import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Signed out successfully')),
                            );
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
                SwitchListTile(
                  secondary: const Icon(Icons.vibration),
                  title: const Text('Haptic Feedback'),
                  subtitle: const Text('Vibrate on timer completion'),
                  value: workoutSettings.hapticFeedback,
                  onChanged: (value) {
                    ref
                        .read(workoutSettingsProvider.notifier)
                        .setHapticFeedback(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.play_circle_outline),
                  title: const Text('Auto-start Rest Timer'),
                  subtitle: const Text('Start timer after completing a set'),
                  value: workoutSettings.autoStartRestTimer,
                  onChanged: (value) {
                    ref
                        .read(workoutSettingsProvider.notifier)
                        .setAutoStartRestTimer(value);
                  },
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data exported to clipboard as JSON'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportAsCsv(BuildContext context, WidgetRef ref) async {
    try {
      final exportService = ref.read(dataExportServiceProvider);
      final csvData = await exportService.exportWorkoutsAsCsv();

      await Clipboard.setData(ClipboardData(text: csvData));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workouts exported to clipboard as CSV'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account data deleted'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please type DELETE to confirm'),
                    backgroundColor: Colors.orange,
                  ),
                );
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
}
