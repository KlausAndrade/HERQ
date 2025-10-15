import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _maintenanceMode = false;
  bool _registrationEnabled = true;
  bool _socialFeaturesEnabled = true;
  bool _aiCoachingEnabled = true;
  bool _analyticsEnabled = true;
  String _appVersion = '1.0.0';
  String _environment = 'production';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, 'System Configuration'),
          _buildSystemSettingsCard(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Feature Flags'),
          _buildFeatureFlagsCard(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Environment Info'),
          _buildEnvironmentCard(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Danger Zone'),
          _buildDangerZoneCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSystemSettingsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Maintenance Mode'),
              subtitle: const Text('Temporarily disable app for maintenance'),
              value: _maintenanceMode,
              onChanged: (value) {
                setState(() {
                  _maintenanceMode = value;
                });
                _showMaintenanceModeDialog(context, value);
              },
              secondary: const Icon(Icons.build, color: Colors.orange),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('User Registration'),
              subtitle: const Text('Allow new users to sign up'),
              value: _registrationEnabled,
              onChanged: (value) {
                setState(() {
                  _registrationEnabled = value;
                });
              },
              secondary: const Icon(Icons.person_add, color: Colors.blue),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.red),
              title: const Text('Clear All Caches'),
              subtitle: const Text('Clear app caches and temporary data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearCacheDialog(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.green),
              title: const Text('Restart Services'),
              subtitle: const Text('Restart background services and sync'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showRestartServicesDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureFlagsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feature Flags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Social Features'),
              subtitle:
                  const Text('Enable posts, comments, and social interactions'),
              value: _socialFeaturesEnabled,
              onChanged: (value) {
                setState(() {
                  _socialFeaturesEnabled = value;
                });
              },
              secondary: const Icon(Icons.share, color: Colors.purple),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('AI Coaching'),
              subtitle: const Text('Enable AI-powered workout coaching'),
              value: _aiCoachingEnabled,
              onChanged: (value) {
                setState(() {
                  _aiCoachingEnabled = value;
                });
              },
              secondary: const Icon(Icons.psychology, color: Colors.teal),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Collect usage analytics and metrics'),
              value: _analyticsEnabled,
              onChanged: (value) {
                setState(() {
                  _analyticsEnabled = value;
                });
              },
              secondary: const Icon(Icons.analytics, color: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Environment Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('App Version', _appVersion),
            _buildInfoRow('Environment', _environment),
            _buildInfoRow('Build Date', '2024-01-15'),
            _buildInfoRow('Last Update', '2 hours ago'),
            _buildInfoRow('Database Version', 'v2.1.0'),
            _buildInfoRow('API Version', 'v1.3.0'),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneCard(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
              title: Text(
                'Reset All Settings',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Reset all admin settings to defaults',
                style: TextStyle(color: Colors.red.shade600),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.red.shade700),
              onTap: () => _showResetSettingsDialog(context),
            ),
            const Divider(color: Colors.red),
            ListTile(
              leading: Icon(Icons.warning_amber, color: Colors.orange.shade700),
              title: Text(
                'Force Logout All Users',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Sign out all users from all devices',
                style: TextStyle(color: Colors.orange.shade600),
              ),
              trailing:
                  Icon(Icons.chevron_right, color: Colors.orange.shade700),
              onTap: () => _showForceLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceModeDialog(BuildContext context, bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            enabled ? 'Enable Maintenance Mode' : 'Disable Maintenance Mode'),
        content: Text(
          enabled
              ? 'This will temporarily disable the app for all users. Are you sure?'
              : 'This will re-enable the app for all users. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    enabled
                        ? 'Maintenance mode enabled'
                        : 'Maintenance mode disabled',
                  ),
                ),
              );
            },
            child: Text(enabled ? 'Enable' : 'Disable'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Caches'),
        content: const Text(
            'This will clear all app caches and temporary data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('All caches cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showRestartServicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Services'),
        content: const Text(
            'This will restart all background services and sync processes. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Services restarted successfully')),
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text(
            'This will reset all admin settings to their default values. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _maintenanceMode = false;
                _registrationEnabled = true;
                _socialFeaturesEnabled = true;
                _aiCoachingEnabled = true;
                _analyticsEnabled = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showForceLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Logout All Users'),
        content: const Text(
            'This will sign out all users from all devices. They will need to sign in again. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All users have been logged out')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Logout All'),
          ),
        ],
      ),
    );
  }
}
