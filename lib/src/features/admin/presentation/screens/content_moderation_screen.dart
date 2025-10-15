import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/providers/admin_data_provider.dart';

class ContentModerationScreen extends ConsumerStatefulWidget {
  const ContentModerationScreen({super.key});

  @override
  ConsumerState<ContentModerationScreen> createState() => _ContentModerationScreenState();
}

class _ContentModerationScreenState extends ConsumerState<ContentModerationScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedType = 'All';
  String _sortBy = 'Created Date';
  bool _sortAscending = false;

  final List<String> _filterOptions = ['All', 'Pending', 'Approved', 'Rejected', 'Flagged'];
  final List<String> _typeOptions = ['All', 'Posts', 'Comments', 'Reports'];
  final List<String> _sortOptions = ['Created Date', 'Updated Date', 'Author', 'Content'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentData = ref.watch(contentModerationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Moderation'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(contentModerationProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: contentData.when(
        data: (data) => Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search content by author, text, or ID...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Filter Controls - Use Wrap to prevent overflow
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      // Status Filter
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedFilter,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _filterOptions.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                          },
                        ),
                      ),

                      // Type Filter
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _typeOptions.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sort Controls - Use Wrap to prevent overflow
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      // Sort Dropdown
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _sortBy,
                          decoration: const InputDecoration(
                            labelText: 'Sort by',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _sortOptions.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _sortBy = value!;
                            });
                          },
                        ),
                      ),

                      // Sort Direction
                      IconButton(
                        icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                        onPressed: () {
                          setState(() {
                            _sortAscending = !_sortAscending;
                          });
                        },
                        tooltip: _sortAscending ? 'Sort Ascending' : 'Sort Descending',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: _ContentList(
                content: data,
                searchQuery: _searchController.text,
                statusFilter: _selectedFilter,
                typeFilter: _selectedType,
                sortBy: _sortBy,
                sortAscending: _sortAscending,
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading content: $error'),
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

class _ContentList extends ConsumerWidget {
  final Map<String, dynamic> content;
  final String searchQuery;
  final String statusFilter;
  final String typeFilter;
  final String sortBy;
  final bool sortAscending;

  const _ContentList({
    required this.content,
    required this.searchQuery,
    required this.statusFilter,
    required this.typeFilter,
    required this.sortBy,
    required this.sortAscending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = content['posts'] as List<dynamic>? ?? [];
    final comments = content['comments'] as List<dynamic>? ?? [];
    final reports = content['reports'] as List<dynamic>? ?? [];

    // Combine all content
    final allContent = <Map<String, dynamic>>[];
    allContent.addAll(posts.map((p) => {...p, 'type': 'post'}));
    allContent.addAll(comments.map((c) => {...c, 'type': 'comment'}));
    allContent.addAll(reports.map((r) => {...r, 'type': 'report'}));

    final filteredContent = _filterContent(allContent);

    if (filteredContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No content found matching your criteria.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredContent.length,
      itemBuilder: (context, index) {
        final item = filteredContent[index];
        return ContentCard(
          content: item,
          onApprove: () => _approveContent(context, ref, item),
          onReject: () => _rejectContent(context, ref, item),
          onFlag: () => _flagContent(context, ref, item),
          onDelete: () => _deleteContent(context, ref, item),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterContent(List<Map<String, dynamic>> content) {
    var filtered = content;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final searchLower = searchQuery.toLowerCase();
        return (item['content']?.toString().toLowerCase().contains(searchLower) ?? false) ||
               (item['author']?.toString().toLowerCase().contains(searchLower) ?? false) ||
               (item['id']?.toString().toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    // Apply status filter
    if (statusFilter != 'All') {
      filtered = filtered.where((item) {
        switch (statusFilter) {
          case 'Pending':
            return item['status'] == 'pending';
          case 'Approved':
            return item['status'] == 'approved';
          case 'Rejected':
            return item['status'] == 'rejected';
          case 'Flagged':
            return item['flagged'] == true;
          default:
            return true;
        }
      }).toList();
    }

    // Apply type filter
    if (typeFilter != 'All') {
      filtered = filtered.where((item) {
        switch (typeFilter) {
          case 'Posts':
            return item['type'] == 'post';
          case 'Comments':
            return item['type'] == 'comment';
          case 'Reports':
            return item['type'] == 'report';
          default:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case 'Created Date':
          comparison = (a['createdAt'] as String).compareTo(b['createdAt'] as String);
          break;
        case 'Updated Date':
          comparison = (a['updatedAt'] as String).compareTo(b['updatedAt'] as String);
          break;
        case 'Author':
          comparison = (a['author'] as String).compareTo(b['author'] as String);
          break;
        case 'Content':
          comparison = (a['content'] as String).compareTo(b['content'] as String);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _approveContent(BuildContext context, WidgetRef ref, Map<String, dynamic> content) {
    // TODO: Implement approve content functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved ${content['type']} ${content['id']}')),
    );
    ref.refresh(contentModerationProvider);
  }

  void _rejectContent(BuildContext context, WidgetRef ref, Map<String, dynamic> content) {
    // TODO: Implement reject content functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected ${content['type']} ${content['id']}')),
    );
    ref.refresh(contentModerationProvider);
  }

  void _flagContent(BuildContext context, WidgetRef ref, Map<String, dynamic> content) {
    // TODO: Implement flag content functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Flagged ${content['type']} ${content['id']}')),
    );
    ref.refresh(contentModerationProvider);
  }

  void _deleteContent(BuildContext context, WidgetRef ref, Map<String, dynamic> content) {
    // TODO: Implement delete content functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted ${content['type']} ${content['id']}')),
    );
    ref.refresh(contentModerationProvider);
  }
}

class ContentCard extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onFlag;
  final VoidCallback onDelete;

  const ContentCard({
    super.key,
    required this.content,
    required this.onApprove,
    required this.onReject,
    required this.onFlag,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isFlagged = content['flagged'] == true;
    final status = content['status'] as String? ?? 'pending';
    final type = content['type'] as String;
    final author = content['author'] as String? ?? 'Unknown';
    final contentText = content['content'] as String? ?? '';
    final createdAt = content['createdAt'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getTypeColor(type)),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: _getTypeColor(type),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (isFlagged) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Text(
                      'FLAGGED',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  _formatDate(createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Author
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Author: $author',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                contentText,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),

            // Actions - Use Wrap to prevent overflow
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.check,
                  label: 'Approve',
                  color: Colors.green,
                  onPressed: onApprove,
                ),
                _ActionButton(
                  icon: Icons.close,
                  label: 'Reject',
                  color: Colors.red,
                  onPressed: onReject,
                ),
                _ActionButton(
                  icon: Icons.flag,
                  label: 'Flag',
                  color: Colors.orange,
                  onPressed: onFlag,
                ),
                _ActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: Colors.red[700]!,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'post':
        return Colors.blue;
      case 'comment':
        return Colors.green;
      case 'report':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}