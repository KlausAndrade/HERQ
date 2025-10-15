import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SystemAdminScreen extends ConsumerStatefulWidget {
  const SystemAdminScreen({super.key});

  @override
  ConsumerState<SystemAdminScreen> createState() => _SystemAdminScreenState();
}

class _SystemAdminScreenState extends ConsumerState<SystemAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Administration'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Monitoring', icon: Icon(Icons.monitor)),
            Tab(text: 'Configuration', icon: Icon(Icons.settings)),
            Tab(text: 'Maintenance', icon: Icon(Icons.build)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSystem,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MonitoringTab(),
          _ConfigurationTab(),
          _MaintenanceTab(),
        ],
      ),
    );
  }

  void _refreshSystem() {
    setState(() {});
  }
}

class _MonitoringTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Status
          _buildSystemStatus(context),
          const SizedBox(height: 24),
          
          // Performance Metrics
          _buildPerformanceMetrics(context),
          const SizedBox(height: 24),
          
          // Recent Logs
          _buildRecentLogs(context),
        ],
      ),
    );
  }

  Widget _buildSystemStatus(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    title: 'Database',
                    status: 'Online',
                    color: Colors.green,
                    uptime: '99.9%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'API Server',
                    status: 'Online',
                    color: Colors.green,
                    uptime: '99.8%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'Storage',
                    status: 'Online',
                    color: Colors.green,
                    uptime: '99.7%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'Cache',
                    status: 'Warning',
                    color: Colors.orange,
                    uptime: '95.2%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Mobile: 2x2 grid
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'CPU Usage',
                              value: '45%',
                              color: Colors.blue,
                              icon: Icons.memory,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MetricCard(
                              title: 'Memory',
                              value: '2.1GB',
                              color: Colors.green,
                              icon: Icons.storage,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              title: 'Disk Space',
                              value: '78%',
                              color: Colors.orange,
                              icon: Icons.storage,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MetricCard(
                              title: 'Network',
                              value: '125MB/s',
                              color: Colors.purple,
                              icon: Icons.network_check,
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
                        child: _MetricCard(
                          title: 'CPU Usage',
                          value: '45%',
                          color: Colors.blue,
                          icon: Icons.memory,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Memory',
                          value: '2.1GB',
                          color: Colors.green,
                          icon: Icons.storage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Disk Space',
                          value: '78%',
                          color: Colors.orange,
                          icon: Icons.storage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Network',
                          value: '125MB/s',
                          color: Colors.purple,
                          icon: Icons.network_check,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLogs(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Logs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _viewAllLogs,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _LogItem(
              level: 'INFO',
              message: 'User authentication successful',
              timestamp: '2 minutes ago',
              color: Colors.blue,
            ),
            _LogItem(
              level: 'WARN',
              message: 'High memory usage detected',
              timestamp: '5 minutes ago',
              color: Colors.orange,
            ),
            _LogItem(
              level: 'ERROR',
              message: 'Database connection timeout',
              timestamp: '8 minutes ago',
              color: Colors.red,
            ),
            _LogItem(
              level: 'INFO',
              message: 'Cache cleared successfully',
              timestamp: '12 minutes ago',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  void _viewAllLogs() {
    // TODO: Implement view all logs
  }
}

class _ConfigurationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Settings
          _buildAppSettings(context),
          const SizedBox(height: 24),
          
          // Feature Flags
          _buildFeatureFlags(context),
          const SizedBox(height: 24),
          
          // Environment Variables
          _buildEnvironmentVariables(context),
        ],
      ),
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SettingItem(
              title: 'Maintenance Mode',
              subtitle: 'Enable maintenance mode for all users',
              value: false,
              onChanged: (value) {
                // TODO: Implement maintenance mode toggle
              },
            ),
            _SettingItem(
              title: 'Registration',
              subtitle: 'Allow new user registrations',
              value: true,
              onChanged: (value) {
                // TODO: Implement registration toggle
              },
            ),
            _SettingItem(
              title: 'Social Features',
              subtitle: 'Enable social features and interactions',
              value: true,
              onChanged: (value) {
                // TODO: Implement social features toggle
              },
            ),
            _SettingItem(
              title: 'AI Coaching',
              subtitle: 'Enable AI-powered coaching features',
              value: true,
              onChanged: (value) {
                // TODO: Implement AI coaching toggle
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureFlags(BuildContext context) {
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
            _FeatureFlag(
              name: 'leaderboards',
              description: 'Enable competitive leaderboards',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement feature flag toggle
              },
            ),
            _FeatureFlag(
              name: 'achievements',
              description: 'Enable achievement system',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement feature flag toggle
              },
            ),
            _FeatureFlag(
              name: 'real_time_sync',
              description: 'Enable real-time data synchronization',
              enabled: false,
              onChanged: (value) {
                // TODO: Implement feature flag toggle
              },
            ),
            _FeatureFlag(
              name: 'advanced_analytics',
              description: 'Enable advanced analytics features',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement feature flag toggle
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentVariables(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Environment Variables',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _EnvVariable(
              name: 'SUPABASE_URL',
              value: 'https://your-project.supabase.co',
              isSecret: false,
            ),
            _EnvVariable(
              name: 'SUPABASE_ANON_KEY',
              value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
              isSecret: true,
            ),
            _EnvVariable(
              name: 'GROQ_API_KEY',
              value: 'gsk_1234567890abcdef...',
              isSecret: true,
            ),
            _EnvVariable(
              name: 'APP_VERSION',
              value: '1.0.0',
              isSecret: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _MaintenanceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Maintenance Actions
          _buildMaintenanceActions(context),
          const SizedBox(height: 24),
          
          // Database Operations
          _buildDatabaseOperations(context),
          const SizedBox(height: 24),
          
          // System Health
          _buildSystemHealth(context),
        ],
      ),
    );
  }

  Widget _buildMaintenanceActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _MaintenanceAction(
              title: 'Clear Cache',
              description: 'Clear all cached data',
              icon: Icons.cached,
              color: Colors.blue,
              onTap: () => _clearCache(context),
            ),
            _MaintenanceAction(
              title: 'Optimize Database',
              description: 'Optimize database performance',
              icon: Icons.storage,
              color: Colors.green,
              onTap: () => _optimizeDatabase(context),
            ),
            _MaintenanceAction(
              title: 'Backup Data',
              description: 'Create a full data backup',
              icon: Icons.backup,
              color: Colors.orange,
              onTap: () => _backupData(context),
            ),
            _MaintenanceAction(
              title: 'Restart Services',
              description: 'Restart all system services',
              icon: Icons.restart_alt,
              color: Colors.red,
              onTap: () => _restartServices(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseOperations(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Database Operations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _DatabaseOperation(
              title: 'Clean Old Data',
              description: 'Remove data older than 1 year',
              onTap: () => _cleanOldData(context),
            ),
            _DatabaseOperation(
              title: 'Rebuild Indexes',
              description: 'Rebuild database indexes for better performance',
              onTap: () => _rebuildIndexes(context),
            ),
            _DatabaseOperation(
              title: 'Vacuum Database',
              description: 'Reclaim unused disk space',
              onTap: () => _vacuumDatabase(context),
            ),
            _DatabaseOperation(
              title: 'Check Integrity',
              description: 'Verify database integrity',
              onTap: () => _checkIntegrity(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Health',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _HealthCheck(
              title: 'Database Connection',
              status: 'Healthy',
              color: Colors.green,
              lastChecked: '2 minutes ago',
            ),
            _HealthCheck(
              title: 'API Response Time',
              status: 'Good',
              color: Colors.green,
              lastChecked: '1 minute ago',
            ),
            _HealthCheck(
              title: 'Storage Usage',
              status: 'Warning',
              color: Colors.orange,
              lastChecked: '5 minutes ago',
            ),
            _HealthCheck(
              title: 'Memory Usage',
              status: 'Healthy',
              color: Colors.green,
              lastChecked: '1 minute ago',
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Clear Cache',
      'Are you sure you want to clear all cached data?',
      () {
        // TODO: Implement cache clearing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      },
    );
  }

  void _optimizeDatabase(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Optimize Database',
      'This may take several minutes. Continue?',
      () {
        // TODO: Implement database optimization
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database optimization started')),
        );
      },
    );
  }

  void _backupData(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Backup Data',
      'Create a full backup of all data?',
      () {
        // TODO: Implement data backup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup process started')),
        );
      },
    );
  }

  void _restartServices(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Restart Services',
      'This will cause temporary downtime. Continue?',
      () {
        // TODO: Implement service restart
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Services restart initiated')),
        );
      },
    );
  }

  void _cleanOldData(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Clean Old Data',
      'Remove data older than 1 year?',
      () {
        // TODO: Implement old data cleaning
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Old data cleaning started')),
        );
      },
    );
  }

  void _rebuildIndexes(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Rebuild Indexes',
      'This may take several minutes. Continue?',
      () {
        // TODO: Implement index rebuilding
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Index rebuilding started')),
        );
      },
    );
  }

  void _vacuumDatabase(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Vacuum Database',
      'Reclaim unused disk space?',
      () {
        // TODO: Implement database vacuum
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database vacuum started')),
        );
      },
    );
  }

  void _checkIntegrity(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Check Integrity',
      'Verify database integrity?',
      () {
        // TODO: Implement integrity check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Integrity check started')),
        );
      },
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String status;
  final Color color;
  final String uptime;

  const _StatusCard({
    required this.title,
    required this.status,
    required this.color,
    required this.uptime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Uptime: $uptime',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final String level;
  final String message;
  final String timestamp;
  final Color color;

  const _LogItem({
    required this.level,
    required this.message,
    required this.timestamp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            timestamp,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _FeatureFlag extends StatelessWidget {
  final String name;
  final String description;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _FeatureFlag({
    required this.name,
    required this.description,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(description),
      trailing: Switch(
        value: enabled,
        onChanged: onChanged,
      ),
    );
  }
}

class _EnvVariable extends StatelessWidget {
  final String name;
  final String value;
  final bool isSecret;

  const _EnvVariable({
    required this.name,
    required this.value,
    required this.isSecret,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text(
        isSecret ? '••••••••••••••••' : value,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () {
          // TODO: Implement copy to clipboard
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied to clipboard')),
          );
        },
      ),
    );
  }
}

class _MaintenanceAction extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MaintenanceAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _DatabaseOperation extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DatabaseOperation({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.storage),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _HealthCheck extends StatelessWidget {
  final String title;
  final String status;
  final Color color;
  final String lastChecked;

  const _HealthCheck({
    required this.title,
    required this.status,
    required this.color,
    required this.lastChecked,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.circle,
        color: color,
        size: 16,
      ),
      title: Text(title),
      subtitle: Text('Last checked: $lastChecked'),
      trailing: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
