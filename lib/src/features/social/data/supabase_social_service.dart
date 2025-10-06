import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Social Service for handling social interactions
class SupabaseSocialService {
  final SupabaseClient _supabase;

  SupabaseSocialService(this._supabase);

  // ===== POSTS =====

  /// Create a new post
  Future<void> createPost({
    required String userId,
    required String caption,
    String? imageUrl,
  }) async {
    await _supabase.from('posts').insert({
      'user_id': userId,
      'caption': caption,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Update/Edit a post
  Future<void> updatePost({
    required String postId,
    String? caption,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (caption != null) updates['caption'] = caption;

    await _supabase.from('posts').update(updates).eq('id', postId);
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      // First, get the post to find the image URL
      final response = await _supabase
          .from('posts')
          .select('image_url, user_id')
          .eq('id', postId)
          .single();

      print('Deleting post: $postId, user: ${response['user_id']}, image: ${response['image_url']}');

      // Delete the post from database first
      await _supabase.from('posts').delete().eq('id', postId);
      print('Post deleted from database');

      // Delete the image from storage if it exists
      if (response['image_url'] != null && response['image_url'].toString().isNotEmpty) {
        try {
          // Extract the file path from the public URL
          final imageUrl = response['image_url'] as String;
          print('Attempting to delete image: $imageUrl');
          
          // URL format: https://.../storage/v1/object/public/post-images/USER_ID/filename.jpg
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          
          // Find the path after 'post-images/'
          final bucketIndex = pathSegments.indexOf('post-images');
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
            print('Deleting from storage: $filePath');
            
            final result = await _supabase.storage.from('post-images').remove([filePath]);
            print('Storage deletion result: $result');
          } else {
            print('Could not find post-images bucket in URL path');
          }
        } catch (e) {
          // If storage deletion fails, log but don't throw
          print('Failed to delete image from storage: $e');
        }
      } else {
        print('No image URL to delete');
      }
    } catch (e) {
      print('Error in deletePost: $e');
      rethrow;
    }
  }

  // ===== LIKES =====

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    try {
      await _supabase.from('likes').insert({
        'post_id': postId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore duplicate like errors
      if (!e.toString().contains('duplicate')) {
        rethrow;
      }
    }
  }

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    await _supabase
        .from('likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }

  // ===== COMMENTS =====

  /// Add a comment to a post
  Future<void> addComment({
    required String postId,
    required String userId,
    required String text,
  }) async {
    await _supabase.from('comments').insert({
      'post_id': postId,
      'user_id': userId,
      'text': text,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    await _supabase.from('comments').delete().eq('id', commentId);
  }

  // ===== FOLLOWS =====

  /// Follow a user
  Future<void> followUser(String followerId, String followingId) async {
    try {
      await _supabase.from('follows').insert({
        'follower_id': followerId,
        'following_id': followingId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore duplicate follow errors
      if (!e.toString().contains('duplicate')) {
        rethrow;
      }
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String followerId, String followingId) async {
    await _supabase
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', followingId);
  }

  // ===== PROFILES =====

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
    bool? isPrivate,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (bio != null) updates['bio'] = bio;
    if (isPrivate != null) updates['is_private'] = isPrivate;

    await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    final user = _supabase.auth.currentUser;
    if (user != null && user.email != null) {
      // Supabase handles this automatically on signup
      // This is a placeholder for custom verification logic if needed
    }
  }
}
