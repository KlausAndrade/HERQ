import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:herq/src/core/services/notification_service.dart';
import '../../../../../l10n/app_localizations.dart';

import '../providers/social_providers.dart';
import 'edit_post_dialog.dart';

class PostCard extends ConsumerWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  final SupabasePost post;
  final String currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLikedAsync = ref.watch(hasLikedPostProvider(post.id));
    final likesCountAsync = ref.watch(likesCountProvider(post.id));
    final commentsCountAsync = ref.watch(commentsCountProvider(post.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userAvatar != null
                  ? NetworkImage(post.userAvatar!)
                  : null,
              child: post.userAvatar == null
                  ? Text(
                      (post.userName ?? post.userId)[0].toUpperCase(),
                    )
                  : null,
            ),
            title: Text(
              post.userName ?? 'User ${post.userId.substring(0, 8)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              DateFormat('MMM d, yyyy • h:mm a').format(post.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: currentUserId == post.userId
                ? IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showPostOptions(context, ref),
                  )
                : null,
            onTap: () => context.push('/user/${post.userId}'),
          ),

          // Image if available
          if (post.imageUrl != null)
            CachedNetworkImage(
              imageUrl: post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.error)),
              ),
            ),

          // Caption
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.caption!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Like button
                hasLikedAsync.when(
                  data: (hasLiked) => IconButton(
                    icon: Icon(
                      hasLiked ? Icons.favorite : Icons.favorite_border,
                      color: hasLiked ? Colors.red : null,
                    ),
                    onPressed: () => _toggleLike(ref, hasLiked),
                  ),
                  loading: () => const IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: null,
                  ),
                  error: (_, __) => const IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: null,
                  ),
                ),
                likesCountAsync.when(
                  data: (count) => Text('$count'),
                  loading: () => const Text('...'),
                  error: (_, __) => const Text('0'),
                ),
                const SizedBox(width: 16),

                // Comment button
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => _showComments(context),
                ),
                commentsCountAsync.when(
                  data: (count) => Text('$count'),
                  loading: () => const Text('...'),
                  error: (_, __) => const Text('0'),
                ),

                const Spacer(),

                // Share button
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _sharePost(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(WidgetRef ref, bool hasLiked) async {
    final social = ref.read(supabaseSocialServiceProvider);

    try {
      if (hasLiked) {
        await social.unlikePost(post.id, currentUserId);
      } else {
        await social.likePost(post.id, currentUserId);
      }

      // Refresh providers
      ref.invalidate(hasLikedPostProvider(post.id));
      ref.invalidate(likesCountProvider(post.id));
      ref.invalidate(feedPostsProvider);
      ref.invalidate(explorePostsProvider);
    } catch (e) {
      // Handle error silently or show snackbar
      debugPrint('Error toggling like: $e');
    }
  }

  void _showComments(BuildContext context) {
    context.push('/post/${post.id}/comments');
  }

  Future<void> _sharePost(BuildContext context) async {
    try {
      // Create a shareable link to the post
      final webLink = 'https://herq.app/post/${post.id}';

      final l10n = S.of(context)!;
      final String shareText =
          (post.caption != null && post.caption!.isNotEmpty)
              ? '${post.caption}\n\n$webLink'
              : '${l10n.checkOutThisPost(l10n.appTitle)}\n$webLink';

      await Share.share(
        shareText,
        subject: l10n.postFrom(l10n.appTitle),
      );
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Failed to share',
              body: '$e',
            )
            .catchError((_) {});
      }
    }
  }

  void _showPostOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'Post Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Post'),
            onTap: () async {
              Navigator.pop(context);
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => EditPostDialog(
                  postId: post.id,
                  initialCaption: post.caption ?? '',
                ),
              );

              if (result == true && context.mounted) {
                ref.invalidate(feedPostsProvider);
                ref.invalidate(explorePostsProvider);
                ref.invalidate(userPostsProvider(currentUserId));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title:
                const Text('Delete Post', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Post'),
                  content:
                      const Text('Are you sure you want to delete this post?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                try {
                  final social = ref.read(supabaseSocialServiceProvider);
                  await social.deletePost(post.id);
                  ref.invalidate(feedPostsProvider);
                  ref.invalidate(explorePostsProvider);
                  ref.invalidate(userPostsProvider(currentUserId));

                  if (context.mounted) {
                    NotificationService()
                        .showInAppNotification(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: 'Deleted',
                          body: 'Post deleted successfully',
                        )
                        .catchError((_) {});
                  }
                } catch (e) {
                  if (context.mounted) {
                    NotificationService()
                        .showInAppNotification(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: 'Failed to delete post',
                          body: '$e',
                        )
                        .catchError((_) {});
                  }
                  print('Delete post error: $e');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
