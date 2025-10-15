import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SafetySecurityScreen extends ConsumerStatefulWidget {
  const SafetySecurityScreen({super.key});

  @override
  ConsumerState<SafetySecurityScreen> createState() => _SafetySecurityScreenState();
}

class _SafetySecurityScreenState extends ConsumerState<SafetySecurityScreen>
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
        title: const Text('Safety & Security'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Content Safety', icon: Icon(Icons.shield)),
            Tab(text: 'Security', icon: Icon(Icons.security)),
            Tab(text: 'Reports', icon: Icon(Icons.flag)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ContentSafetyTab(),
          _SecurityTab(),
          _ReportsTab(),
        ],
      ),
    );
  }
}

class _ContentSafetyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Safety Metrics
          _buildSafetyMetrics(context),
          const SizedBox(height: 24),
          
          // Content Filters
          _buildContentFilters(context),
          const SizedBox(height: 24),
          
          // Recent Violations
          _buildRecentViolations(context),
        ],
      ),
    );
  }

  Widget _buildSafetyMetrics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safety Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Content Violations',
                    value: '12',
                    change: '-3',
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Auto-Filtered',
                    value: '45',
                    change: '+8',
                    icon: Icons.filter_alt,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Manual Reviews',
                    value: '23',
                    change: '+5',
                    icon: Icons.visibility,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Resolved',
                    value: '89%',
                    change: '+2%',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentFilters(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FilterItem(
              title: 'Profanity Filter',
              description: 'Automatically detect and filter profane language',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement profanity filter toggle
              },
            ),
            _FilterItem(
              title: 'Spam Detection',
              description: 'Detect and prevent spam content',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement spam detection toggle
              },
            ),
            _FilterItem(
              title: 'Harassment Detection',
              description: 'Identify potential harassment and bullying',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement harassment detection toggle
              },
            ),
            _FilterItem(
              title: 'Inappropriate Images',
              description: 'Scan images for inappropriate content',
              enabled: false,
              onChanged: (value) {
                // TODO: Implement image scanning toggle
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentViolations(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Violations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ViolationItem(
              type: 'Profanity',
              content: 'This post contains inappropriate language',
              user: 'user_123',
              timestamp: '2 minutes ago',
              severity: 'Medium',
            ),
            _ViolationItem(
              type: 'Spam',
              content: 'Repeated promotional content',
              user: 'user_456',
              timestamp: '15 minutes ago',
              severity: 'High',
            ),
            _ViolationItem(
              type: 'Harassment',
              content: 'Bullying behavior detected',
              user: 'user_789',
              timestamp: '1 hour ago',
              severity: 'High',
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Metrics
          _buildSecurityMetrics(context),
          const SizedBox(height: 24),
          
          // Security Settings
          _buildSecuritySettings(context),
          const SizedBox(height: 24),
          
          // Recent Security Events
          _buildSecurityEvents(context),
        ],
      ),
    );
  }

  Widget _buildSecurityMetrics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Failed Logins',
                    value: '23',
                    change: '-5',
                    icon: Icons.lock,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Suspicious Activity',
                    value: '3',
                    change: '-1',
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Blocked IPs',
                    value: '12',
                    change: '+2',
                    icon: Icons.block,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Security Score',
                    value: '95%',
                    change: '+2%',
                    icon: Icons.security,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SecuritySetting(
              title: 'Two-Factor Authentication',
              description: 'Require 2FA for admin accounts',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement 2FA toggle
              },
            ),
            _SecuritySetting(
              title: 'Rate Limiting',
              description: 'Limit API requests per user',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement rate limiting toggle
              },
            ),
            _SecuritySetting(
              title: 'IP Blocking',
              description: 'Automatically block suspicious IPs',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement IP blocking toggle
              },
            ),
            _SecuritySetting(
              title: 'Audit Logging',
              description: 'Log all admin actions',
              enabled: true,
              onChanged: (value) {
                // TODO: Implement audit logging toggle
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityEvents(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Security Events',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SecurityEvent(
              type: 'Failed Login',
              description: 'Multiple failed login attempts from IP 192.168.1.1',
              timestamp: '5 minutes ago',
              severity: 'Medium',
            ),
            _SecurityEvent(
              type: 'Suspicious Activity',
              description: 'Unusual API usage pattern detected',
              timestamp: '1 hour ago',
              severity: 'High',
            ),
            _SecurityEvent(
              type: 'IP Blocked',
              description: 'IP 10.0.0.1 blocked due to suspicious activity',
              timestamp: '2 hours ago',
              severity: 'High',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Metrics
          _buildReportMetrics(context),
          const SizedBox(height: 24),
          
          // Recent Reports
          _buildRecentReports(context),
        ],
      ),
    );
  }

  Widget _buildReportMetrics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Reports',
                    value: '156',
                    change: '+12',
                    icon: Icons.flag,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Pending',
                    value: '23',
                    change: '+3',
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Resolved',
                    value: '89%',
                    change: '+5%',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'False Reports',
                    value: '12%',
                    change: '-2%',
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReports(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ReportItem(
              type: 'Inappropriate Content',
              reporter: 'user_123',
              reported: 'user_456',
              timestamp: '10 minutes ago',
              status: 'Pending',
            ),
            _ReportItem(
              type: 'Spam',
              reporter: 'user_789',
              reported: 'user_101',
              timestamp: '25 minutes ago',
              status: 'Under Review',
            ),
            _ReportItem(
              type: 'Harassment',
              reporter: 'user_202',
              reported: 'user_303',
              timestamp: '1 hour ago',
              status: 'Resolved',
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
  final String change;
  final IconData icon;
  final Color color;

  const _MetricCard({
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
            const SizedBox(height: 4),
            Text(
              change,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: change.startsWith('+') ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final String title;
  final String description;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _FilterItem({
    required this.title,
    required this.description,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: Switch(
        value: enabled,
        onChanged: onChanged,
      ),
    );
  }
}

class _ViolationItem extends StatelessWidget {
  final String type;
  final String content;
  final String user;
  final String timestamp;
  final String severity;

  const _ViolationItem({
    required this.type,
    required this.content,
    required this.user,
    required this.timestamp,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(severity);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: severityColor,
          child: Text(
            type[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(type),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(severity),
                  backgroundColor: severityColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: severityColor, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  'User: $user',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          timestamp,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}

class _SecuritySetting extends StatelessWidget {
  final String title;
  final String description;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SecuritySetting({
    required this.title,
    required this.description,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: Switch(
        value: enabled,
        onChanged: onChanged,
      ),
    );
  }
}

class _SecurityEvent extends StatelessWidget {
  final String type;
  final String description;
  final String timestamp;
  final String severity;

  const _SecurityEvent({
    required this.type,
    required this.description,
    required this.timestamp,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(severity);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.security,
          color: severityColor,
        ),
        title: Text(type),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(severity),
                  backgroundColor: severityColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: severityColor, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}

class _ReportItem extends StatelessWidget {
  final String type;
  final String reporter;
  final String reported;
  final String timestamp;
  final String status;

  const _ReportItem({
    required this.type,
    required this.reporter,
    required this.reported,
    required this.timestamp,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: const Icon(Icons.flag, color: Colors.white, size: 20),
        ),
        title: Text(type),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reporter: $reporter'),
            Text('Reported: $reported'),
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
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            // TODO: Implement report actions
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
              value: 'resolve',
              child: Row(
                children: [
                  Icon(Icons.check, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Resolve', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'dismiss',
              child: Row(
                children: [
                  Icon(Icons.close, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Dismiss', style: TextStyle(color: Colors.red)),
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
      case 'pending':
        return Colors.orange;
      case 'under review':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'dismissed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
