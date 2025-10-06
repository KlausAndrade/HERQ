import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../providers/social_providers.dart';

class PostCard extends ConsumerWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  final Post post;
  final String currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLikedAsync = ref.watch(hasLikedPostProvider(post.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          ListTile(
            leading: CircleAvatar(
              child: Text(post.userId[0].toUpperCase()),
            ),
            title: Text(
              'User ${post.userId.substring(0, 8)}',
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
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.caption,
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
                Text('${post.likesCount}'),
                const SizedBox(width: 16),

                // Comment button
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => _showComments(context),
                ),
                Text('${post.commentsCount}'),

                const Spacer(),

                // Share button
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _sharePost(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(WidgetRef ref, bool hasLiked) async {
    final social = ref.read(socialServiceProvider);
    
    try {
      if (hasLiked) {
        await social.unlikePost(post.id, currentUserId);
      } else {
        await social.likePost(post.id, currentUserId);
      }
      
      // Refresh providers
      ref.invalidate(hasLikedPostProvider(post.id));
      ref.invalidate(feedPostsProvider);
    } catch (e) {
      // Handle error silently or show snackbar
      debugPrint('Error toggling like: $e');
    }
  }

  void _showComments(BuildContext context) {
    context.push('/post/${post.id}/comments');
  }

  void _sharePost() {
    // Implement share functionality
    debugPrint('Share post: ${post.id}');
  }

  void _showPostOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Post'),
                  content: const Text('Are you sure you want to delete this post?'),
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
                final social = ref.read(socialServiceProvider);
                await social.deletePost(post.id);
                ref.invalidate(feedPostsProvider);
              }
            },
          ),
        ],
      ),
    );
  }
}
