import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';
import '../providers/social_providers.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({
    required this.postId,
    super.key,
  });

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(singlePostProvider(postId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return const Center(
              child: Text('Post not found'),
            );
          }

          return SingleChildScrollView(
            child: PostCard(
              post: post,
              currentUserId: currentUser?.id ?? '',
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading post: $error'),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('postId', postId));
  }
}
