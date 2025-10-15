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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        // Mobile: Stack vertically
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Filter',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    ),
                                    items: _filterOptions.map((option) {
                                      return DropdownMenuItem(
                                        value: option,
                                        child: Text(option, overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _sortBy,
                                    decoration: const InputDecoration(
                                      labelText: 'Sort by',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    ),
                                    items: _sortOptions.map((option) {
                                      return DropdownMenuItem(
                                        value: option,
                                        child: Text(option, overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _sortBy = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                        );
                      } else {
                        // Desktop: Horizontal layout
                        return Row(
                          children: [
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
                            const SizedBox(width: 8),

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
                            const SizedBox(width: 8),

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
                        );
                      }
                    },
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
                onEdit: _editUser,
                onSuspend: _suspendUser,
                onBan: _banUser,
                onDelete: _deleteUser,
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

  void _addUser() {
    showDialog(
      context: context,
      builder: (context) => _AddUserDialog(),
    );
  }

  void _editUser(BuildContext context, Map<String, dynamic> user) {
    // TODO: Implement user edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user ${user['displayName']} coming soon')),
    );
  }

  void _suspendUser(BuildContext context, Map<String, dynamic> user) {
    // TODO: Implement user suspend functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Suspend user ${user['displayName']} coming soon')),
    );
  }

  void _banUser(BuildContext context, Map<String, dynamic> user) {
    // TODO: Implement user ban functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ban user ${user['displayName']} coming soon')),
    );
  }

  void _deleteUser(BuildContext context, Map<String, dynamic> user) {
    // TODO: Implement user delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete user ${user['displayName']} coming soon')),
    );
  }
}

class _UserList extends ConsumerWidget {
  final List<Map<String, dynamic>> users;
  final String searchQuery;
  final String filter;
  final String sortBy;
  final bool sortAscending;
  final Function(BuildContext, Map<String, dynamic>) onEdit;
  final Function(BuildContext, Map<String, dynamic>) onSuspend;
  final Function(BuildContext, Map<String, dynamic>) onBan;
  final Function(BuildContext, Map<String, dynamic>) onDelete;

  const _UserList({
    super.key,
    required this.users,
    required this.searchQuery,
    required this.filter,
    required this.sortBy,
    required this.sortAscending,
    required this.onEdit,
    required this.onSuspend,
    required this.onBan,
    required this.onDelete,
  });


  List<Map<String, dynamic>> _filterUsers(List<Map<String, dynamic>> users) {
    var filtered = users;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final searchLower = searchQuery.toLowerCase();
      filtered = filtered.where((user) {
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
          comparison = (a['createdAt'] as String).compareTo(b['createdAt'] as String);
          break;
        case 'Last Active':
          final aLastSignIn = a['lastSignInAt'] as String?;
          final bLastSignIn = b['lastSignInAt'] as String?;
          if (aLastSignIn == null && bLastSignIn == null) comparison = 0;
          else if (aLastSignIn == null) comparison = -1;
          else if (bLastSignIn == null) comparison = 1;
          else comparison = aLastSignIn.compareTo(bLastSignIn);
          break;
        case 'Name':
          comparison = (a['displayName'] as String).compareTo(b['displayName'] as String);
          break;
        case 'Email':
          comparison = (a['email'] as String).compareTo(b['email'] as String);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredUsers = _filterUsers(users);

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No users found matching your criteria.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return UserCard(
          user: user,
          onEdit: () => onEdit(context, user),
          onSuspend: () => onSuspend(context, user),
          onBan: () => onBan(context, user),
          onDelete: () => onDelete(context, user),
        );
      },
    );
  }
}

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onEdit;
  final VoidCallback onSuspend;
  final VoidCallback onBan;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onSuspend,
    required this.onBan,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBanned = user['bannedUntil'] != null;
    final isSuspended = user['status'] == 'suspended';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user['displayName'][0]),
        ),
        title: Text(user['displayName']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email']),
            if (isSuspended)
              const Text('Status: Suspended', style: TextStyle(color: Colors.orange)),
            if (isBanned)
              Text('Status: Banned until ${DateTime.parse(user['bannedUntil']).toLocal().toShortDate()}',
                  style: const TextStyle(color: Colors.red)),
            Text('Workouts: ${user['workoutCount'] ?? 0}'),
            if (user['lastWorkoutAt'] != null)
              Text('Last Workout: ${DateTime.parse(user['lastWorkoutAt']).toLocal().toShortDate()}'),
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
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
                value: 'suspend',
                child: Text(isSuspended ? 'Unsuspend' : 'Suspend')),
            PopupMenuItem(
                value: 'ban', child: Text(isBanned ? 'Unban' : 'Ban')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _AddUserDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'displayName': _displayNameController.text.trim()},
      );

      if (response.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ${_displayNameController.text} added successfully!')),
          );
          Navigator.of(context).pop();
          ref.refresh(userManagementProvider); // Refresh user list
        }
      } else {
        throw Exception('Failed to add user: No user returned');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a display name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add User'),
        ),
      ],
    );
  }
}

extension on DateTime {
  String toShortDate() {
    return '${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}/${year.toString().substring(2)}';
  }
}