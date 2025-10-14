import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/animated_fab.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../providers/social_providers.dart';
import '../widgets/create_post_sheet.dart';
import '../widgets/email_verification_banner.dart';
import '../widgets/post_card.dart';
import '../widgets/profile_completion_banner.dart';

class SocialFeedScreen extends HookConsumerWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final tabController = useTabController(initialLength: 2);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: const Text('Social'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Please sign in to access social features'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: Text(S.of(context)!.social),
          bottom: TabBar(
            controller: tabController,
            tabs: [
              Tab(icon: const Icon(Icons.home), text: S.of(context)!.feed),
              Tab(
                icon: const Icon(Icons.explore),
                text: S.of(context)!.explore,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showUserSearch(context, ref),
            ),
          ],
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            Column(
              children: [
                const EmailVerificationBanner(),
                const ProfileCompletionBanner(),
                Expanded(child: _FeedTab(currentUserId: currentUser.id)),
              ],
            ),
            _ExploreTab(currentUserId: currentUser.id),
          ],
        ),
        floatingActionButton: AnimatedFAB(
          icon: Icons.add,
          onPressed: () => _showCreatePost(context),
          tooltip: S.of(context)!.createPost,
        ),
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

// Feed Tab Widget
class _FeedTab extends ConsumerWidget {
  const _FeedTab({required this.currentUserId});

  final String currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedPostsProvider);

    return feedAsync.when(
      data: (feedItems) =>
          _buildPostList(context, ref, feedItems, currentUserId),
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: SkeletonCard(height: 200),
        ),
      ),
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
              S.of(context)!.failedToLoadFeed,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(feedPostsProvider),
              child: Text(S.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('currentUserId', currentUserId));
  }
}

// Explore Tab Widget
class _ExploreTab extends ConsumerWidget {
  const _ExploreTab({required this.currentUserId});

  final String currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreAsync = ref.watch(explorePostsProvider);

    return exploreAsync.when(
      data: (posts) => _buildPostList(context, ref, posts, currentUserId),
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
              'Failed to load posts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(explorePostsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('currentUserId', currentUserId));
  }
}

// Shared post list builder
Widget _buildPostList(
  BuildContext context,
  WidgetRef ref,
  List<dynamic> feedItems,
  String currentUserId,
) {
  if (feedItems.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context)!.noPostsYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context)!.createFirstPost,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () async {
      ref.invalidate(feedPostsProvider);
      ref.invalidate(explorePostsProvider);
    },
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feedItems.length,
      itemBuilder: (context, index) {
        final post = feedItems[index];
        return PostCard(
          post: post,
          currentUserId: currentUserId,
        );
      },
    ),
  );
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
      builder: (context, scrollController) => DecoratedBox(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            S.of(context)!.searchForUsers,
                            style: const TextStyle(
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
                            final isFollowingAsync =
                                ref.watch(isFollowingProvider(user.id));

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: user.avatarUrl == null
                                    ? Text(
                                        ((user.displayName?.isNotEmpty ?? false)
                                                ? user.displayName!
                                                : user.id)[0]
                                            .toUpperCase(),
                                      )
                                    : null,
                              ),
                              title: Text(
                                (user.displayName?.isNotEmpty ?? false)
                                    ? user.displayName!
                                    : 'User ${user.id.substring(0, 8)}',
                              ),
                              subtitle:
                                  user.bio != null ? Text(user.bio!) : null,
                              trailing: isCurrentUser
                                  ? null
                                  : isFollowingAsync.when(
                                      data: (isFollowing) => OutlinedButton(
                                        onPressed: () async {
                                          final social = ref.read(
                                            supabaseSocialServiceProvider,
                                          );
                                          if (currentUser == null) return;

                                          if (isFollowing) {
                                            await social.unfollowUser(
                                              currentUser.id,
                                              user.id,
                                            );
                                          } else {
                                            await social.followUser(
                                              currentUser.id,
                                              user.id,
                                            );
                                          }

                                          ref.invalidate(
                                            isFollowingProvider(user.id),
                                          );
                                          ref.invalidate(feedPostsProvider);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: isFollowing
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest
                                              : null,
                                        ),
                                        child: Text(
                                          isFollowing ? 'Following' : 'Follow',
                                        ),
                                      ),
                                      loading: () => const SizedBox(
                                        width: 80,
                                        child: Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
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
      ),
    );
  }
}
