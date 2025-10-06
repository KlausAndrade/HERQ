import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../providers/social_providers.dart';
import '../widgets/create_post_sheet.dart';
import '../widgets/post_card.dart';

class SocialFeedScreen extends HookConsumerWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // Show posts from the feed
        final feedAsync = ref.watch(feedPostsProvider);

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
            data: (feedItems) => _buildFeedList(context, ref, feedItems),
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
                    onPressed: () => ref.invalidate(feedPostsProvider),
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

  Widget _buildFeedList(BuildContext context, WidgetRef ref, List<dynamic> feedItems) {
    if (feedItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first post to share with the community!',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return const Center(child: Text('Please sign in'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(feedPostsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: feedItems.length,
        itemBuilder: (context, index) {
          final post = feedItems[index] as Post;
          return PostCard(
            post: post,
            currentUserId: currentUser.id,
          );
        },
      ),
    );
  }

  void _showUserSearch(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const UserSearchSheet(),
    );
  }

  void _showCreatePost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreatePostSheet(),
    );
  }
}

class UserSearchSheet extends HookConsumerWidget {
  const UserSearchSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState('');
    final searchResults = ref.watch(searchUsersProvider(searchQuery.value));

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
                        searchQuery.value = query.trim();
                      },
                      autofocus: true,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: searchQuery.value.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Search for users',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : searchResults.when(
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
                              final currentUser = ref.watch(currentUserProvider);
                              final isCurrentUser = user.id == currentUser?.id;
                              final isFollowingAsync = ref.watch(isFollowingProvider(user.id));

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? Text(
                                          (user.displayName.isNotEmpty
                                                  ? user.displayName
                                                  : user.id)[0]
                                              .toUpperCase())
                                      : null,
                                ),
                                title: Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName
                                      : 'User ${user.id.substring(0, 8)}',
                                ),
                                subtitle: user.email != null ? Text(user.email!) : null,
                                trailing: isCurrentUser
                                    ? null
                                    : isFollowingAsync.when(
                                        data: (isFollowing) => OutlinedButton(
                                          onPressed: () async {
                                            final social = ref.read(socialServiceProvider);
                                            if (currentUser == null) return;

                                            if (isFollowing) {
                                              await social.unfollowUser(currentUser.id, user.id);
                                            } else {
                                              await social.followUser(currentUser.id, user.id);
                                            }

                                            ref.invalidate(isFollowingProvider(user.id));
                                            ref.invalidate(feedPostsProvider);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: isFollowing
                                                ? Theme.of(context).colorScheme.surfaceVariant
                                                : null,
                                          ),
                                          child: Text(isFollowing ? 'Following' : 'Follow'),
                                        ),
                                        loading: () => const SizedBox(
                                          width: 80,
                                          child: Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        ),
                                        error: (_, __) => const SizedBox.shrink(),
                                      ),
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/user/${user.id}');
                                },
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
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
