import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentModerationScreen extends ConsumerStatefulWidget {
  const ContentModerationScreen({super.key});

  @override
  ConsumerState<ContentModerationScreen> createState() => _ContentModerationScreenState();
}

class _ContentModerationScreenState extends ConsumerState<ContentModerationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Moderation'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Reports', icon: Icon(Icons.flag)),
            Tab(text: 'Posts', icon: Icon(Icons.post_add)),
            Tab(text: 'Comments', icon: Icon(Icons.comment)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshContent,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search content...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ReportsTab(searchQuery: _searchController.text, filter: _selectedFilter),
                _PostsTab(searchQuery: _searchController.text, filter: _selectedFilter),
                _CommentsTab(searchQuery: _searchController.text, filter: _selectedFilter),
                _UsersTab(searchQuery: _searchController.text, filter: _selectedFilter),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _refreshContent() {
    setState(() {});
  }
}

class _ReportsTab extends StatelessWidget {
  final String searchQuery;
  final String filter;

  const _ReportsTab({
    required this.searchQuery,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final reports = snapshot.data ?? [];
        final filteredReports = _filterReports(reports);

        if (filteredReports.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No reports found'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredReports.length,
          itemBuilder: (context, index) {
            final report = filteredReports[index];
            return _ReportCard(
              report: report,
              onApprove: () => _handleReport(context, report, 'approved'),
              onReject: () => _handleReport(context, report, 'rejected'),
              onView: () => _viewReport(context, report),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    // Mock data for development
    return [
      {
        'id': '1',
        'type': 'inappropriate_content',
        'reason': 'Contains inappropriate language',
        'reporter': 'user_123',
        'reported_user': 'user_456',
        'content_id': 'post_789',
        'content_type': 'post',
        'status': 'pending',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'description': 'This post contains offensive language and should be removed.',
      },
      {
        'id': '2',
        'type': 'spam',
        'reason': 'Spam content',
        'reporter': 'user_789',
        'reported_user': 'user_456',
        'content_id': 'post_101',
        'content_type': 'post',
        'status': 'pending',
        'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'description': 'This user is posting spam content repeatedly.',
      },
      {
        'id': '3',
        'type': 'harassment',
        'reason': 'Harassment',
        'reporter': 'user_456',
        'reported_user': 'user_789',
        'content_id': 'comment_202',
        'content_type': 'comment',
        'status': 'approved',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'description': 'This user is harassing me in comments.',
      },
    ];
  }

  List<Map<String, dynamic>> _filterReports(List<Map<String, dynamic>> reports) {
    var filtered = reports;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        final searchLower = searchQuery.toLowerCase();
        return report['reason'].toString().toLowerCase().contains(searchLower) ||
               report['description'].toString().toLowerCase().contains(searchLower);
      }).toList();
    }

    if (filter != 'All') {
      filtered = filtered.where((report) => report['status'] == filter.toLowerCase()).toList();
    }

    return filtered;
  }

  void _handleReport(BuildContext context, Map<String, dynamic> report, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.toUpperCase()} Report'),
        content: Text('Are you sure you want to $action this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement report handling
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report $action')),
              );
            },
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _viewReport(BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => _ReportDetailsDialog(report: report),
    );
  }
}

class _PostsTab extends StatelessWidget {
  final String searchQuery;
  final String filter;

  const _PostsTab({
    required this.searchQuery,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final posts = snapshot.data ?? [];
        final filteredPosts = _filterPosts(posts);

        if (filteredPosts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No posts found'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) {
            final post = filteredPosts[index];
            return _PostCard(
              post: post,
              onApprove: () => _handlePost(context, post, 'approved'),
              onReject: () => _handlePost(context, post, 'rejected'),
              onDelete: () => _deletePost(context, post),
              onView: () => _viewPost(context, post),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    // Mock data for development
    return [
      {
        'id': '1',
        'content': 'Just finished an amazing workout! 💪',
        'author': 'user_123',
        'author_name': 'John Doe',
        'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'status': 'pending',
        'image_url': null,
        'likes_count': 5,
        'comments_count': 2,
      },
      {
        'id': '2',
        'content': 'Check out my new PR! 🏆',
        'author': 'user_456',
        'author_name': 'Jane Smith',
        'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'status': 'approved',
        'image_url': 'https://example.com/image.jpg',
        'likes_count': 12,
        'comments_count': 8,
      },
    ];
  }

  List<Map<String, dynamic>> _filterPosts(List<Map<String, dynamic>> posts) {
    var filtered = posts;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((post) {
        final searchLower = searchQuery.toLowerCase();
        return post['content'].toString().toLowerCase().contains(searchLower) ||
               post['author_name'].toString().toLowerCase().contains(searchLower);
      }).toList();
    }

    if (filter != 'All') {
      filtered = filtered.where((post) => post['status'] == filter.toLowerCase()).toList();
    }

    return filtered;
  }

  void _handlePost(BuildContext context, Map<String, dynamic> post, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.toUpperCase()} Post'),
        content: Text('Are you sure you want to $action this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement post handling
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Post $action')),
              );
            },
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _deletePost(BuildContext context, Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to permanently delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement post deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewPost(BuildContext context, Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => _PostDetailsDialog(post: post),
    );
  }
}

class _CommentsTab extends StatelessWidget {
  final String searchQuery;
  final String filter;

  const _CommentsTab({
    required this.searchQuery,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Comments moderation coming soon'),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final String searchQuery;
  final String filter;

  const _UsersTab({
    required this.searchQuery,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('User moderation coming soon'),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onView;

  const _ReportCard({
    required this.report,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final status = report['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          report['reason'] ?? 'Unknown Reason',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report['description'] ?? 'No description'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(status.toUpperCase()),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(report['created_at']),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                onView();
                break;
              case 'approve':
                onApprove();
                break;
              case 'reject':
                onReject();
                break;
            }
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
              value: 'approve',
              child: Row(
                children: [
                  Icon(Icons.check, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Approve', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reject',
              child: Row(
                children: [
                  Icon(Icons.close, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Reject', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _PostCard({
    required this.post,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final status = post['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          post['author_name'] ?? 'Unknown Author',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['content'] ?? 'No content'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(status.toUpperCase()),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(Icons.favorite, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text('${post['likes_count'] ?? 0}'),
                const SizedBox(width: 16),
                Icon(Icons.comment, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text('${post['comments_count'] ?? 0}'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                onView();
                break;
              case 'approve':
                onApprove();
                break;
              case 'reject':
                onReject();
                break;
              case 'delete':
                onDelete();
                break;
            }
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
              value: 'approve',
              child: Row(
                children: [
                  Icon(Icons.check, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Approve', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reject',
              child: Row(
                children: [
                  Icon(Icons.close, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Reject', style: TextStyle(color: Colors.red)),
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
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.help;
    }
  }
}

class _ReportDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportDetailsDialog({required this.report});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow('ID', report['id'] ?? 'N/A'),
            _DetailRow('Type', report['type'] ?? 'N/A'),
            _DetailRow('Reason', report['reason'] ?? 'N/A'),
            _DetailRow('Reporter', report['reporter'] ?? 'N/A'),
            _DetailRow('Reported User', report['reported_user'] ?? 'N/A'),
            _DetailRow('Content ID', report['content_id'] ?? 'N/A'),
            _DetailRow('Content Type', report['content_type'] ?? 'N/A'),
            _DetailRow('Status', report['status'] ?? 'N/A'),
            _DetailRow('Created', _formatDate(report['created_at'])),
            const SizedBox(height: 8),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(report['description'] ?? 'No description'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}

class _PostDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> post;

  const _PostDetailsDialog({required this.post});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Post Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow('ID', post['id'] ?? 'N/A'),
            _DetailRow('Author', post['author_name'] ?? 'N/A'),
            _DetailRow('Author ID', post['author'] ?? 'N/A'),
            _DetailRow('Status', post['status'] ?? 'N/A'),
            _DetailRow('Likes', '${post['likes_count'] ?? 0}'),
            _DetailRow('Comments', '${post['comments_count'] ?? 0}'),
            _DetailRow('Created', _formatDate(post['created_at'])),
            const SizedBox(height: 8),
            const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(post['content'] ?? 'No content'),
            if (post['image_url'] != null) ...[
              const SizedBox(height: 8),
              const Text('Image:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(post['image_url']),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
