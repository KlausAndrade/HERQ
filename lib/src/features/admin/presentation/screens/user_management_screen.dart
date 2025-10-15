import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/providers/admin_data_provider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _sortBy = 'Created Date';
  bool _sortAscending = false;

  final List<String> _filterOptions = ['All', 'Active', 'Suspended', 'Banned'];
  final List<String> _sortOptions = ['Created Date', 'Last Active', 'Name', 'Email'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersData = ref.watch(userManagementProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportUsers,
            tooltip: 'Export Users',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(userManagementProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: usersData.when(
        data: (users) => Column(
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
                    hintText: 'Search users by name, email, or ID...',
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
                
                // Filter and Sort Controls
                Row(
                  children: [
                    // Filter Dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter',
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
                    const SizedBox(width: 12),
                    
                    // Sort Dropdown
                    Expanded(
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
                    const SizedBox(width: 12),
                    
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
          
          // User List
          Expanded(
            child: _UserList(
              users: users,
              searchQuery: _searchController.text,
              filter: _selectedFilter,
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
              Text('Error loading users: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userManagementProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(Icons.person_add),
        tooltip: 'Add User',
      ),
    );
}

  void _exportUsers() {
    // TODO: Implement user export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _refreshUsers() {
    setState(() {});
  }

  void _addUser() {
    showDialog(
      context: context,
      builder: (context) => _AddUserDialog(),
    );
  }
}

class _UserList extends ConsumerWidget {
  final List<Map<String, dynamic>> users;
  final String searchQuery;
  final String filter;
  final String sortBy;
  final bool sortAscending;

  const _UserList({
    required this.users,
    required this.searchQuery,
    required this.filter,
    required this.sortBy,
    required this.sortAscending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredUsers = _filterUsers(users);

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No users found matching "$searchQuery"'
                      : 'No users found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _UserCard(
              user: user,
              onTap: () => _showUserDetails(context, user),
              onEdit: () => _editUser(context, user),
              onSuspend: () => _suspendUser(context, user),
              onBan: () => _banUser(context, user),
              onDelete: () => _deleteUser(context, user),
            );
          },
        );
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Fetch users from auth.users table
      final response = await supabase
          .from('auth.users')
          .select('*')
          .order('created_at', ascending: false);
      
      // Also fetch profiles for additional info
      final profiles = await supabase
          .from('profiles')
          .select('*');
      
      // Combine user data with profile data
      final users = <Map<String, dynamic>>[];
      for (final user in response) {
        final profile = profiles.firstWhere(
          (p) => p['id'] == user['id'],
          orElse: () => <String, dynamic>{},
        );
        
        users.add({
          ...user,
          'display_name': profile['display_name'] ?? user['email']?.split('@')[0],
          'bio': profile['bio'],
          'avatar_url': profile['avatar_url'],
          'is_private': profile['is_private'] ?? false,
        });
      }
      
      return users;
    } catch (e) {
      // Fallback to mock data for development
      return _getMockUsers();
    }
  }

  List<Map<String, dynamic>> _filterUsers(List<Map<String, dynamic>> users) {
    var filtered = users;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final searchLower = searchQuery.toLowerCase();
        return (user['email']?.toString().toLowerCase().contains(searchLower) ?? false) ||
               (user['displayName']?.toString().toLowerCase().contains(searchLower) ?? false) ||
               (user['id']?.toString().toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    // Apply status filter
    if (filter != 'All') {
      filtered = filtered.where((user) {
        switch (filter) {
          case 'Active':
            return user['bannedUntil'] == null;
          case 'Suspended':
            return user['status'] == 'suspended';
          case 'Banned':
            return user['bannedUntil'] != null;
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
          comparison = DateTime.parse(a['created_at'] ?? '')
              .compareTo(DateTime.parse(b['created_at'] ?? ''));
          break;
        case 'Last Active':
          comparison = DateTime.parse(a['last_sign_in_at'] ?? '')
              .compareTo(DateTime.parse(b['last_sign_in_at'] ?? ''));
          break;
        case 'Name':
          comparison = (a['display_name'] ?? '').compareTo(b['display_name'] ?? '');
          break;
        case 'Email':
          comparison = (a['email'] ?? '').compareTo(b['email'] ?? '');
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => _UserDetailsDialog(user: user),
    );
  }

  void _editUser(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(user: user),
    );
  }

  void _suspendUser(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Text('Are you sure you want to suspend ${user['display_name'] ?? user['email']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement suspend user
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User suspended')),
              );
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _banUser(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban User'),
        content: Text('Are you sure you want to ban ${user['display_name'] ?? user['email']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement ban user
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User banned')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ban'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to permanently delete ${user['display_name'] ?? user['email']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete user
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockUsers() {
    return [
      {
        'id': '1',
        'email': 'john.doe@example.com',
        'display_name': 'John Doe',
        'bio': 'Fitness enthusiast',
        'avatar_url': null,
        'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'last_sign_in_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'banned_until': null,
        'is_private': false,
      },
      {
        'id': '2',
        'email': 'jane.smith@example.com',
        'display_name': 'Jane Smith',
        'bio': 'Personal trainer',
        'avatar_url': null,
        'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'last_sign_in_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'banned_until': null,
        'is_private': true,
      },
      {
        'id': '3',
        'email': 'bob.wilson@example.com',
        'display_name': 'Bob Wilson',
        'bio': 'Gym owner',
        'avatar_url': null,
        'created_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'last_sign_in_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'banned_until': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'is_private': false,
      },
    ];
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onSuspend;
  final VoidCallback onBan;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onEdit,
    required this.onSuspend,
    required this.onBan,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBanned = user['banned_until'] != null;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user['avatar_url'] != null 
              ? NetworkImage(user['avatar_url']) 
              : null,
          child: user['avatar_url'] == null 
              ? Text((user['display_name'] ?? user['email'] ?? 'U')[0].toUpperCase())
              : null,
        ),
        title: Text(
          user['display_name'] ?? user['email'] ?? 'Unknown User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isBanned ? Colors.red : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? 'No email'),
            if (user['bio'] != null) Text(user['bio']),
            Row(
              children: [
                Icon(
                  isBanned ? Icons.block : Icons.check_circle,
                  size: 16,
                  color: isBanned ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  isBanned ? 'Banned' : 'Active',
                  style: TextStyle(
                    color: isBanned ? Colors.red : Colors.green,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  user['is_private'] ? Icons.lock : Icons.public,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  user['is_private'] ? 'Private' : 'Public',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'suspend':
                onSuspend();
                break;
              case 'ban':
                onBan();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'suspend',
              child: Row(
                children: [
                  Icon(Icons.pause, size: 20),
                  SizedBox(width: 8),
                  Text('Suspend'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'ban',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Ban', style: TextStyle(color: Colors.red)),
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
        onTap: onTap,
      ),
    );
  }
}

class _AddUserDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add User'),
      content: const Text('Add user functionality coming soon'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserDetailsDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(user['display_name'] ?? user['email'] ?? 'User Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow('ID', user['id'] ?? 'N/A'),
            _DetailRow('Email', user['email'] ?? 'N/A'),
            _DetailRow('Display Name', user['display_name'] ?? 'N/A'),
            _DetailRow('Bio', user['bio'] ?? 'N/A'),
            _DetailRow('Created', _formatDate(user['created_at'])),
            _DetailRow('Last Sign In', _formatDate(user['last_sign_in_at'])),
            _DetailRow('Status', user['banned_until'] != null ? 'Banned' : 'Active'),
            _DetailRow('Privacy', user['is_private'] ? 'Private' : 'Public'),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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

class _EditUserDialog extends StatelessWidget {
  final Map<String, dynamic> user;

  const _EditUserDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: const Text('Edit user functionality coming soon'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
