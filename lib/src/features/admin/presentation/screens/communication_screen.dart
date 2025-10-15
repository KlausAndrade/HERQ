import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/admin_data_provider.dart';

class CommunicationScreen extends ConsumerStatefulWidget {
  const CommunicationScreen({super.key});

  @override
  ConsumerState<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends ConsumerState<CommunicationScreen>
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
    final contentModeration = ref.watch(contentModerationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Announcements', icon: Icon(Icons.campaign)),
            Tab(text: 'Messages', icon: Icon(Icons.message)),
            Tab(text: 'Feedback', icon: Icon(Icons.feedback)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(contentModerationProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: contentModeration.when(
        data: (data) => TabBarView(
          controller: _tabController,
          children: [
            _AnnouncementsTab(data: data),
            _MessagesTab(data: data),
            _FeedbackTab(data: data),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading communication data: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(contentModerationProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  final Map<String, dynamic> data;
  
  const _AnnouncementsTab({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          _buildQuickActions(context),
          const SizedBox(height: 24),
          
          // Recent Announcements
          _buildRecentAnnouncements(context),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    title: 'Send Announcement',
                    icon: Icons.campaign,
                    color: Colors.blue,
                    onTap: () => _sendAnnouncement(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    title: 'Schedule Message',
                    icon: Icons.schedule,
                    color: Colors.green,
                    onTap: () => _scheduleMessage(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnnouncements(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Announcements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _AnnouncementItem(
              title: 'New Feature Release',
              content: 'We\'ve added new workout tracking features!',
              sentAt: '2 hours ago',
              recipients: '1,234 users',
              status: 'Sent',
            ),
            _AnnouncementItem(
              title: 'Maintenance Notice',
              content: 'Scheduled maintenance on Sunday at 2 AM',
              sentAt: '1 day ago',
              recipients: 'All users',
              status: 'Sent',
            ),
            _AnnouncementItem(
              title: 'Welcome Message',
              content: 'Welcome to HERQ! Get started with your fitness journey.',
              sentAt: '3 days ago',
              recipients: 'New users',
              status: 'Sent',
            ),
          ],
        ),
      ),
    );
  }

  void _sendAnnouncement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SendAnnouncementDialog(),
    );
  }

  void _scheduleMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleMessageDialog(),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  final Map<String, dynamic> data;
  
  const _MessagesTab({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Messages functionality coming soon'),
        ],
      ),
    );
  }
}

class _FeedbackTab extends StatelessWidget {
  final Map<String, dynamic> data;
  
  const _FeedbackTab({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Feedback management coming soon'),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
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
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementItem extends StatelessWidget {
  final String title;
  final String content;
  final String sentAt;
  final String recipients;
  final String status;

  const _AnnouncementItem({
    required this.title,
    required this.content,
    required this.sentAt,
    required this.recipients,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.campaign, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(status),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.green, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  'To: $recipients',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          sentAt,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _SendAnnouncementDialog extends StatefulWidget {
  @override
  State<_SendAnnouncementDialog> createState() => _SendAnnouncementDialogState();
}

class _SendAnnouncementDialogState extends State<_SendAnnouncementDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedAudience = 'All Users';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Announcement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAudience,
              decoration: const InputDecoration(
                labelText: 'Audience',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'All Users', child: Text('All Users')),
                DropdownMenuItem(value: 'Active Users', child: Text('Active Users')),
                DropdownMenuItem(value: 'New Users', child: Text('New Users')),
                DropdownMenuItem(value: 'Premium Users', child: Text('Premium Users')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAudience = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // TODO: Implement send announcement
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Announcement sent')),
            );
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _ScheduleMessageDialog extends StatefulWidget {
  @override
  State<_ScheduleMessageDialog> createState() => _ScheduleMessageDialogState();
}

class _ScheduleMessageDialogState extends State<_ScheduleMessageDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Message'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Schedule Date'),
              subtitle: Text(
                '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year} ${_scheduledDate.hour}:${_scheduledDate.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _scheduledDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_scheduledDate),
                  );
                  if (time != null) {
                    setState(() {
                      _scheduledDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // TODO: Implement schedule message
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message scheduled')),
            );
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}
