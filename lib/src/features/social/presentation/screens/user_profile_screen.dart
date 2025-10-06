import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_provider.dart';
import '../providers/social_providers.dart';
import '../widgets/post_card.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final profileUserAsync = ref.watch(userProfileProvider(userId));
    final isCurrentUser = currentUser?.id == userId;
    final isFollowingAsync = ref.watch(isFollowingProvider(userId));
    final followersCountAsync = ref.watch(followersCountProvider(userId));
    final followingCountAsync = ref.watch(followingCountProvider(userId));
    final userPostsAsync = ref.watch(userPostsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: profileUserAsync.when(
          data: (user) => Text(
            user?.displayName?.isNotEmpty ?? false
                ? user!.displayName!
                : 'Profile',
          ),
          loading: () => const Text('Profile'),
          error: (_, __) => const Text('Profile'),
        ),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.go('/settings'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider(userId));
          ref.invalidate(userPostsProvider(userId));
          ref.invalidate(followersCountProvider(userId));
          ref.invalidate(followingCountProvider(userId));
        },
        child: CustomScrollView(
          slivers: [
            // Profile header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: profileUserAsync.when(
                  data: (user) => Column(
                    children: [
                      // Avatar and name
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? Text(
                                ((user?.displayName?.isNotEmpty ?? false)
                                        ? user!.displayName!
                                        : userId)[0]
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 32),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (user?.displayName?.isNotEmpty ?? false)
                            ? user!.displayName!
                            : 'User ${userId.substring(0, 8)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (user?.bio != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          user!.bio!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatColumn(
                            label: 'Posts',
                            value: userPostsAsync.when(
                              data: (posts) => posts.length.toString(),
                              loading: () => '-',
                              error: (_, __) => '0',
                            ),
                          ),
                          _StatColumn(
                            label: 'Followers',
                            value: followersCountAsync.when(
                              data: (count) => count.toString(),
                              loading: () => '-',
                              error: (_, __) => '0',
                            ),
                            onTap: () => context.push('/user/$userId/followers'),
                          ),
                          _StatColumn(
                            label: 'Following',
                            value: followingCountAsync.when(
                              data: (count) => count.toString(),
                              loading: () => '-',
                              error: (_, __) => '0',
                            ),
                            onTap: () => context.push('/user/$userId/following'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Follow/Edit button
                      if (!isCurrentUser)
                        SizedBox(
                          width: double.infinity,
                          child: isFollowingAsync.when(
                            data: (isFollowing) => ElevatedButton(
                              onPressed: () => _toggleFollow(ref, isFollowing),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing
                                    ? Theme.of(context).colorScheme.surfaceVariant
                                    : Theme.of(context).colorScheme.primary,
                                foregroundColor: isFollowing
                                    ? Theme.of(context).colorScheme.onSurfaceVariant
                                    : Theme.of(context).colorScheme.onPrimary,
                              ),
                              child: Text(isFollowing ? 'Following' : 'Follow'),
                            ),
                            loading: () => const ElevatedButton(
                              onPressed: null,
                              child: Text('Loading...'),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ),
                      if (isCurrentUser)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.go('/settings'),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                    ],
                  ),
                  loading: () => const Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 32),
                      ),
                      SizedBox(height: 16),
                      CircularProgressIndicator(),
                    ],
                  ),
                  error: (_, __) => Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        child: Text(
                          userId[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'User ${userId.substring(0, 8)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Posts section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Posts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            // Posts grid/list
            userPostsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isCurrentUser ? 'No posts yet' : 'No posts',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = posts[index];
                      return PostCard(
                        post: post,
                        currentUserId: currentUser?.id ?? '',
                      );
                    },
                    childCount: posts.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFollow(WidgetRef ref, bool isFollowing) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      final social = ref.read(supabaseSocialServiceProvider);
      
      if (isFollowing) {
        await social.unfollowUser(currentUser.id, userId);
      } else {
        await social.followUser(currentUser.id, userId);
      }

      ref.invalidate(isFollowingProvider(userId));
      ref.invalidate(followersCountProvider(userId));
      ref.invalidate(feedPostsProvider);
    } catch (e) {
      debugPrint('Error toggling follow: $e');
    }
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}
