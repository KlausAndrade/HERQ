import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../domain/models/social_models.dart';
import '../providers/social_providers.dart';

class SocialFeedScreen extends HookConsumerWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        final feedAsync = ref.watch(socialFeedProvider('current_user'));
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Social Feed'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showUserSearch(context, ref),
              ),
            ],
          ),
          body: feedAsync.when(
            data: (feedItems) => _buildFeedList(context, feedItems),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load feed',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(socialFeedProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreatePost(context),
            child: const Icon(Icons.add),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Authentication error: $error'),
        ),
      ),
    );
  }

  Widget _buildFeedList(BuildContext context, List<FeedItem> feedItems) {
    if (feedItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Follow friends to see their workout activity!',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the feed
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: feedItems.length,
        itemBuilder: (context, index) {
          final item = feedItems[index];
          return _buildFeedItem(context, item);
        },
      ),
    );
  }

  Widget _buildFeedItem(BuildContext context, FeedItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    'https://avatar.iran.liara.run/public/${item.userId}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUserDisplayName(item.userId),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(item.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFeedTypeIcon(item.type),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeedContent(context, item),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTypeIcon(FeedItemType type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case FeedItemType.workoutCompleted:
        icon = Icons.fitness_center;
        color = Colors.green;
        break;
      case FeedItemType.prAchieved:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case FeedItemType.streakMilestone:
        icon = Icons.local_fire_department;
        color = Colors.orange;
        break;
      case FeedItemType.friendJoined:
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      case FeedItemType.challengeCompleted:
        icon = Icons.military_tech;
        color = Colors.purple;
        break;
    }
    
    return Icon(icon, color: color, size: 20);
  }

  Widget _buildFeedContent(BuildContext context, FeedItem item) {
    switch (item.type) {
      case FeedItemType.workoutCompleted:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed a workout',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              '💪 Push Day - 45 minutes',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        );
      
      case FeedItemType.prAchieved:
        final achievement = item.achievement;
        if (achievement != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Achieved a new PR!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Color(int.parse(achievement.badgeColor?.replaceFirst('#', '0xff') ?? '0xFFD700')),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            achievement.description,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        break;
      
      case FeedItemType.streakMilestone:
        final achievement = item.achievement;
        if (achievement != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hit a streak milestone! 🔥',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                achievement.description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          );
        }
        break;
      
      case FeedItemType.friendJoined:
        return const Text(
          'Joined GymAI! Welcome to the community! 🎉',
          style: TextStyle(fontWeight: FontWeight.w500),
        );
      
      case FeedItemType.challengeCompleted:
        return const Text(
          'Completed a fitness challenge! 🏆',
          style: TextStyle(fontWeight: FontWeight.w500),
        );
    }
    
    return const SizedBox.shrink();
  }

  String _getUserDisplayName(String userId) {
    // Mock user names based on userId
    const userNames = {
      '1': 'Alex Chen',
      '2': 'Sarah Johnson',
      '3': 'Mike Rodriguez',
    };
    return userNames[userId] ?? 'User $userId';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  void _showUserSearch(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const UserSearchSheet(),
    );
  }

  void _showCreatePost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post creation coming soon!'),
      ),
    );
  }
}

class UserSearchSheet extends HookConsumerWidget {
  const UserSearchSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(userSearchProvider);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (query) {
                        ref.read(userSearchProvider.notifier).searchUsers(query);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: searchResults.when(
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(
                        child: Text('No users found'),
                      );
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? Text(user.displayName[0].toUpperCase())
                                : null,
                          ),
                          title: Text(user.displayName),
                          subtitle: user.bio != null ? Text(user.bio!) : null,
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Send friend request
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Friend request sent to ${user.displayName}'),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Add Friend'),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}