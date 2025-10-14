import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_provider.dart';
import '../providers/social_providers.dart';

class FollowersScreen extends ConsumerWidget {
  const FollowersScreen({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followersAsync = ref.watch(followersProvider(userId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
      ),
      body: followersAsync.when(
        data: (followers) {
          if (followers.isEmpty) {
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
                    'No followers yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) {
              final user = followers[index];
              final isCurrentUser = user.id == currentUser?.id;
              final isFollowingAsync = ref.watch(isFollowingProvider(user.id));

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          (user.displayName?.isNotEmpty ?? false
                                  ? user.displayName!
                                  : user.id)[0]
                              .toUpperCase(),
                        )
                      : null,
                ),
                title: Text(
                  user.displayName?.isNotEmpty ?? false
                      ? user.displayName!
                      : 'User ${user.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: user.bio != null
                    ? Text(
                        user.bio!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: isCurrentUser
                    ? null
                    : isFollowingAsync.when(
                        data: (isFollowing) => OutlinedButton(
                          onPressed: () =>
                              _toggleFollow(ref, user.id, isFollowing),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
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
                onTap: () => context.push('/user/${user.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(followersProvider(userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFollow(
    WidgetRef ref,
    String targetUserId,
    bool isFollowing,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      final social = ref.read(supabaseSocialServiceProvider);

      if (isFollowing) {
        await social.unfollowUser(currentUser.id, targetUserId);
      } else {
        await social.followUser(currentUser.id, targetUserId);
      }

      ref.invalidate(isFollowingProvider(targetUserId));
      ref.invalidate(followersProvider(userId));
      ref.invalidate(followingProvider(currentUser.id));
    } catch (e) {
      debugPrint('Error toggling follow: $e');
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}
