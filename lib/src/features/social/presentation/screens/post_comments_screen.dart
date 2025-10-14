import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../providers/social_providers.dart';

class PostCommentsScreen extends ConsumerStatefulWidget {
  const PostCommentsScreen({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  ConsumerState<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends ConsumerState<PostCommentsScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(singlePostProvider(widget.postId));
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));
    final currentUser = ref.watch(currentUserProvider);
    final currentUserProfile =
        ref.watch(userProfileProvider(currentUser?.id ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          // Post summary
          postAsync.when(
            data: (post) {
              if (post == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: post.userAvatar != null
                          ? NetworkImage(post.userAvatar!)
                          : null,
                      child: post.userAvatar == null
                          ? Text(
                              (post.userName ?? post.userId)[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.userName ??
                                'User ${post.userId.substring(0, 8)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            post.caption ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Comments list
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return const Center(
                    child: Text('No comments yet.\nBe the first to comment!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isCurrentUser = comment.userId == currentUser?.id;
                    final commentUserAsync =
                        ref.watch(userProfileProvider(comment.userId));

                    return commentUserAsync.when(
                      data: (user) => ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundImage: user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null,
                          child: user?.avatarUrl == null
                              ? Text(
                                  ((user?.displayName?.isNotEmpty ?? false)
                                          ? user!.displayName!
                                          : comment.userId)[0]
                                      .toUpperCase(),
                                )
                              : null,
                        ),
                        title: Text(
                          (user?.displayName?.isNotEmpty ?? false)
                              ? user!.displayName!
                              : 'User ${comment.userId.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.text),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, h:mm a')
                                  .format(comment.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                        trailing: isCurrentUser
                            ? IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteComment(comment.id),
                              )
                            : null,
                      ),
                      loading: () => ListTile(
                        leading: const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 16),
                        ),
                        title: Text(
                          'User ${comment.userId.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.text),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, h:mm a')
                                  .format(comment.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      error: (_, __) => ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          child: Text(comment.userId[0].toUpperCase()),
                        ),
                        title: Text(
                          'User ${comment.userId.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.text),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, h:mm a')
                                  .format(comment.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                        trailing: isCurrentUser
                            ? IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteComment(comment.id),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  currentUserProfile.when(
                    data: (profile) {
                      if (profile?.avatarUrl != null &&
                          profile!.avatarUrl!.isNotEmpty) {
                        return CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(profile.avatarUrl!),
                        );
                      }
                      return CircleAvatar(
                        radius: 16,
                        child: Text(profile?.displayName?[0].toUpperCase() ??
                            currentUser?.id[0].toUpperCase() ??
                            '?'),
                      );
                    },
                    loading: () => const CircleAvatar(
                      radius: 16,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => CircleAvatar(
                      radius: 16,
                      child: Text(currentUser?.id[0].toUpperCase() ?? '?'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      final social = ref.read(supabaseSocialServiceProvider);
      await social.addComment(
        postId: widget.postId,
        userId: currentUser.id,
        text: comment,
      );

      _commentController.clear();
      ref.invalidate(postCommentsProvider(widget.postId));
      ref.invalidate(singlePostProvider(widget.postId));

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error adding comment',
              body: '$e',
            )
            .catchError((_) {});
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final social = ref.read(supabaseSocialServiceProvider);
      await social.deleteComment(commentId);
      ref.invalidate(postCommentsProvider(widget.postId));
      ref.invalidate(singlePostProvider(widget.postId));
    } catch (e) {
      if (mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Error deleting comment',
              body: '$e',
            )
            .catchError((_) {});
      }
    }
  }
}
