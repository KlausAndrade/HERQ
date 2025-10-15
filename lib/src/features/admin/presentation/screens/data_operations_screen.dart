import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/admin_data_provider.dart';

class DataOperationsScreen extends ConsumerStatefulWidget {
  const DataOperationsScreen({super.key});

  @override
  ConsumerState<DataOperationsScreen> createState() =>
      _DataOperationsScreenState();
}

class _DataOperationsScreenState extends ConsumerState<DataOperationsScreen>
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
    final systemHealth = ref.watch(systemHealthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Operations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Backup', icon: Icon(Icons.backup)),
            Tab(text: 'Export', icon: Icon(Icons.download)),
            Tab(text: 'Import', icon: Icon(Icons.upload)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(systemHealthProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: systemHealth.when(
        data: (data) => TabBarView(
          controller: _tabController,
          children: [
            _BackupTab(data: data),
            _ExportTab(data: data),
            _ImportTab(data: data),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading data operations: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(systemHealthProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackupTab extends StatelessWidget {
  final Map<String, dynamic> data;

  const _BackupTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Backup Status
          _buildBackupStatus(context),
          const SizedBox(height: 24),

          // Backup Actions
          _buildBackupActions(context),
          const SizedBox(height: 24),

          // Recent Backups
          _buildRecentBackups(context),
        ],
      ),
    );
  }

  Widget _buildBackupStatus(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    title: 'Last Backup',
                    value: '2 hours ago',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'Backup Size',
                    value: '2.3 GB',
                    color: Colors.blue,
                    icon: Icons.storage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'Auto Backup',
                    value: 'Enabled',
                    color: Colors.green,
                    icon: Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'Retention',
                    value: '30 days',
                    color: Colors.orange,
                    icon: Icons.history,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _BackupAction(
              title: 'Create Full Backup',
              description: 'Create a complete backup of all data',
              icon: Icons.backup,
              color: Colors.blue,
              onTap: () => _createFullBackup(context),
            ),
            _BackupAction(
              title: 'Incremental Backup',
              description: 'Create a backup of changes since last backup',
              icon: Icons.update,
              color: Colors.green,
              onTap: () => _createIncrementalBackup(context),
            ),
            _BackupAction(
              title: 'Schedule Backup',
              description: 'Set up automated backup schedule',
              icon: Icons.schedule,
              color: Colors.orange,
              onTap: () => _scheduleBackup(context),
            ),
            _BackupAction(
              title: 'Restore from Backup',
              description: 'Restore data from a previous backup',
              icon: Icons.restore,
              color: Colors.red,
              onTap: () => _restoreFromBackup(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBackups(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Backups',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _BackupItem(
              name: 'Full Backup - 2024-01-15',
              size: '2.3 GB',
              createdAt: '2 hours ago',
              status: 'Completed',
              type: 'Full',
            ),
            _BackupItem(
              name: 'Incremental Backup - 2024-01-14',
              size: '156 MB',
              createdAt: '1 day ago',
              status: 'Completed',
              type: 'Incremental',
            ),
            _BackupItem(
              name: 'Full Backup - 2024-01-13',
              size: '2.1 GB',
              createdAt: '2 days ago',
              status: 'Completed',
              type: 'Full',
            ),
            _BackupItem(
              name: 'Full Backup - 2024-01-12',
              size: '2.0 GB',
              createdAt: '3 days ago',
              status: 'Failed',
              type: 'Full',
            ),
          ],
        ),
      ),
    );
  }

  void _createFullBackup(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Create Full Backup',
      'This will create a complete backup of all data. This may take several minutes.',
      () {
        // TODO: Implement full backup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Full backup started')),
        );
      },
    );
  }

  void _createIncrementalBackup(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Create Incremental Backup',
      'This will create a backup of changes since the last backup.',
      () {
        // TODO: Implement incremental backup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incremental backup started')),
        );
      },
    );
  }

  void _scheduleBackup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleBackupDialog(),
    );
  }

  void _restoreFromBackup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RestoreBackupDialog(),
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

class _ExportTab extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ExportTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export Options
          _buildExportOptions(context),
          const SizedBox(height: 24),

          // Export History
          _buildExportHistory(context),
        ],
      ),
    );
  }

  Widget _buildExportOptions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _ExportOption(
              title: 'User Data Export',
              description: 'Export all user data (GDPR compliance)',
              icon: Icons.people,
              color: Colors.blue,
              onTap: () => _exportUserData(context),
            ),
            _ExportOption(
              title: 'Workout Data Export',
              description: 'Export all workout sessions and templates',
              icon: Icons.fitness_center,
              color: Colors.green,
              onTap: () => _exportWorkoutData(context),
            ),
            _ExportOption(
              title: 'Analytics Export',
              description: 'Export analytics and usage data',
              icon: Icons.analytics,
              color: Colors.orange,
              onTap: () => _exportAnalytics(context),
            ),
            _ExportOption(
              title: 'Database Export',
              description: 'Export complete database dump',
              icon: Icons.storage,
              color: Colors.purple,
              onTap: () => _exportDatabase(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportHistory(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _ExportItem(
              name: 'User Data Export - 2024-01-15',
              type: 'User Data',
              size: '45 MB',
              createdAt: '1 hour ago',
              status: 'Completed',
            ),
            _ExportItem(
              name: 'Workout Data Export - 2024-01-14',
              type: 'Workout Data',
              size: '123 MB',
              createdAt: '1 day ago',
              status: 'Completed',
            ),
            _ExportItem(
              name: 'Analytics Export - 2024-01-13',
              type: 'Analytics',
              size: '12 MB',
              createdAt: '2 days ago',
              status: 'Completed',
            ),
          ],
        ),
      ),
    );
  }

  void _exportUserData(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Export User Data',
      'This will export all user data for GDPR compliance.',
      () {
        // TODO: Implement user data export
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data export started')),
        );
      },
    );
  }

  void _exportWorkoutData(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Export Workout Data',
      'This will export all workout sessions and templates.',
      () {
        // TODO: Implement workout data export
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout data export started')),
        );
      },
    );
  }

  void _exportAnalytics(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Export Analytics',
      'This will export analytics and usage data.',
      () {
        // TODO: Implement analytics export
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analytics export started')),
        );
      },
    );
  }

  void _exportDatabase(BuildContext context) {
    _showConfirmationDialog(
      context,
      'Export Database',
      'This will export a complete database dump.',
      () {
        // TODO: Implement database export
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database export started')),
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

class _ImportTab extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ImportTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Import Options
          _buildImportOptions(context),
          const SizedBox(height: 24),

          // Import History
          _buildImportHistory(context),
        ],
      ),
    );
  }

  Widget _buildImportOptions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _ImportOption(
              title: 'Import from File',
              description: 'Import data from a file',
              icon: Icons.file_upload,
              color: Colors.blue,
              onTap: () => _importFromFile(context),
            ),
            _ImportOption(
              title: 'Import from Backup',
              description: 'Import data from a backup file',
              icon: Icons.restore,
              color: Colors.green,
              onTap: () => _importFromBackup(context),
            ),
            _ImportOption(
              title: 'Import from CSV',
              description: 'Import data from CSV file',
              icon: Icons.table_chart,
              color: Colors.orange,
              onTap: () => _importFromCSV(context),
            ),
            _ImportOption(
              title: 'Import from JSON',
              description: 'Import data from JSON file',
              icon: Icons.code,
              color: Colors.purple,
              onTap: () => _importFromJSON(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportHistory(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _ImportItem(
              name: 'User Data Import - 2024-01-15',
              type: 'User Data',
              size: '45 MB',
              createdAt: '2 hours ago',
              status: 'Completed',
            ),
            _ImportItem(
              name: 'Workout Data Import - 2024-01-14',
              type: 'Workout Data',
              size: '123 MB',
              createdAt: '1 day ago',
              status: 'Failed',
            ),
            _ImportItem(
              name: 'CSV Import - 2024-01-13',
              type: 'CSV',
              size: '12 MB',
              createdAt: '2 days ago',
              status: 'Completed',
            ),
          ],
        ),
      ),
    );
  }

  void _importFromFile(BuildContext context) {
    // TODO: Implement file import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File import functionality coming soon')),
    );
  }

  void _importFromBackup(BuildContext context) {
    // TODO: Implement backup import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup import functionality coming soon')),
    );
  }

  void _importFromCSV(BuildContext context) {
    // TODO: Implement CSV import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV import functionality coming soon')),
    );
  }

  void _importFromJSON(BuildContext context) {
    // TODO: Implement JSON import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON import functionality coming soon')),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _BackupAction extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BackupAction({
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

class _BackupItem extends StatelessWidget {
  final String name;
  final String size;
  final String createdAt;
  final String status;
  final String type;

  const _BackupItem({
    required this.name,
    required this.size,
    required this.createdAt,
    required this.status,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(type),
          child: Text(
            type[0],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: $size'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(status),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  createdAt,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            // TODO: Implement backup actions
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, size: 20),
                  SizedBox(width: 8),
                  Text('Restore'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'full':
        return Colors.blue;
      case 'incremental':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _ExportOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({
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

class _ExportItem extends StatelessWidget {
  final String name;
  final String type;
  final String size;
  final String createdAt;
  final String status;

  const _ExportItem({
    required this.name,
    required this.type,
    required this.size,
    required this.createdAt,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.download, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $type • Size: $size'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(status),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  createdAt,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            // TODO: Implement export actions
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _ImportOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ImportOption({
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

class _ImportItem extends StatelessWidget {
  final String name;
  final String type;
  final String size;
  final String createdAt;
  final String status;

  const _ImportItem({
    required this.name,
    required this.type,
    required this.size,
    required this.createdAt,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.upload, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $type • Size: $size'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(status),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  createdAt,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            // TODO: Implement import actions
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'in progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _ScheduleBackupDialog extends StatefulWidget {
  @override
  State<_ScheduleBackupDialog> createState() => _ScheduleBackupDialogState();
}

class _ScheduleBackupDialogState extends State<_ScheduleBackupDialog> {
  String _selectedFrequency = 'Daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 2, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Backup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedFrequency,
            decoration: const InputDecoration(
              labelText: 'Frequency',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Daily', child: Text('Daily')),
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFrequency = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Time'),
            subtitle: Text(
              '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) {
                setState(() {
                  _selectedTime = time;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // TODO: Implement schedule backup
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup scheduled')),
            );
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

class _RestoreBackupDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore from Backup'),
      content: const Text(
          'Select a backup to restore from. This will replace all current data.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // TODO: Implement restore backup
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup restore started')),
            );
          },
          child: const Text('Restore'),
        ),
      ],
    );
  }
}
