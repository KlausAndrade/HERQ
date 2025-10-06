import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_provider.dart';
import '../providers/social_providers.dart';

class FollowingScreen extends ConsumerWidget {
  const FollowingScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingProvider(userId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: followingAsync.when(
        data: (following) {
          if (following.isEmpty) {
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
                    'Not following anyone yet',
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
            itemCount: following.length,
            itemBuilder: (context, index) {
              final user = following[index];
              final isCurrentUser = user.id == currentUser?.id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          (user.displayName.isNotEmpty ? user.displayName : user.id)[0]
                              .toUpperCase(),
                        )
                      : null,
                ),
                title: Text(
                  user.displayName.isNotEmpty ? user.displayName : 'User ${user.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: user.email != null
                    ? Text(
                        user.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: isCurrentUser
                    ? null
                    : OutlinedButton(
                        onPressed: () => _unfollow(ref, user.id),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        child: const Text('Following'),
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
                onPressed: () => ref.invalidate(followingProvider(userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _unfollow(WidgetRef ref, String targetUserId) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      final social = ref.read(socialServiceProvider);
      await social.unfollowUser(currentUser.id, targetUserId);

      ref.invalidate(followingProvider(userId));
      ref.invalidate(followersProvider(targetUserId));
      ref.invalidate(isFollowingProvider(targetUserId));
    } catch (e) {
      debugPrint('Error unfollowing: $e');
    }
  }
}
