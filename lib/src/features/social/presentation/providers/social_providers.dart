import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../data/supabase_social_service.dart';

// Supabase client provider
final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// Supabase social service provider
final supabaseSocialServiceProvider = Provider<SupabaseSocialService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseSocialService(supabase);
});

// Models for Supabase data
class SupabasePost {
  SupabasePost({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.caption,
    this.imageUrl,
    this.userName,
    this.userAvatar,
    this.workoutSessionId,
  });

  factory SupabasePost.fromJson(Map<String, dynamic> json) => SupabasePost(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    caption: json['caption'] as String?,
    imageUrl: json['image_url'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    userName: json['profiles']?['display_name'] as String?,
    userAvatar: json['profiles']?['avatar_url'] as String?,
    workoutSessionId: json['workout_session_id'] as String?,
  );
  final String id;
  final String userId;
  final String? caption;
  final String? imageUrl;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;
  final String? workoutSessionId;
}

class SupabaseComment {
  SupabaseComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
    this.userName,
  });

  factory SupabaseComment.fromJson(Map<String, dynamic> json) =>
      SupabaseComment(
        id: json['id'] as String,
        postId: json['post_id'] as String,
        userId: json['user_id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        userName: json['profiles']?['display_name'] as String?,
      );
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final String? userName;
}

class SupabaseProfile {
  SupabaseProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.isPrivate = false,
  });

  factory SupabaseProfile.fromJson(Map<String, dynamic> json) =>
      SupabaseProfile(
        id: json['id'] as String,
        displayName: json['display_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        isPrivate: json['is_private'] as bool? ?? false,
      );
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isPrivate;
}

// Feed posts provider (posts from followed users)
final feedPostsProvider = FutureProvider.autoDispose<List<SupabasePost>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  try {
    // Get followed user IDs
    final followsData = await supabase
        .from('follows')
        .select('following_id')
        .eq('follower_id', user.id);

    final followingIds = (followsData as List)
        .map((f) => f['following_id'] as String)
        .toList();

    // Include own posts
    followingIds.add(user.id);

    // Get posts from followed users
    final postsData = await supabase
        .from('posts')
        .select('*, profiles(display_name, avatar_url)')
        .inFilter('user_id', followingIds)
        .order('created_at', ascending: false)
        .limit(50);

    return (postsData as List)
        .map((json) => SupabasePost.fromJson(json))
        .toList();
  } catch (e) {
    print('Error fetching feed posts: $e');
    return [];
  }
});

// ===== REAL-TIME STREAM PROVIDERS =====

// Real-time feed posts stream provider
final feedPostsStreamProvider = StreamProvider.autoDispose<List<SupabasePost>>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return Stream.value([]);

  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .limit(50)
      .map(
        (data) =>
            (data as List).map((json) => SupabasePost.fromJson(json)).toList(),
      );
});

// Real-time comments stream provider
final postCommentsStreamProvider = StreamProvider.autoDispose
    .family<List<SupabaseComment>, String>((ref, postId) {
      final supabase = ref.watch(supabaseProvider);

      return supabase
          .from('comments')
          .stream(primaryKey: ['id'])
          .eq('post_id', postId)
          .order('created_at', ascending: true)
          .map(
            (data) => (data as List)
                .map((json) => SupabaseComment.fromJson(json))
                .toList(),
          );
    });

// Explore posts provider (all recent posts)
final explorePostsProvider = FutureProvider.autoDispose<List<SupabasePost>>((
  ref,
) async {
  final supabase = ref.watch(supabaseProvider);

  try {
    final postsData = await supabase
        .from('posts')
        .select('*, profiles(display_name, avatar_url)')
        .order('created_at', ascending: false)
        .limit(50);

    return (postsData as List)
        .map((json) => SupabasePost.fromJson(json))
        .toList();
  } catch (e) {
    print('Error fetching explore posts: $e');
    return [];
  }
});

// User posts provider
final userPostsProvider = FutureProvider.autoDispose
    .family<List<SupabasePost>, String>((ref, userId) async {
      final supabase = ref.watch(supabaseProvider);

      try {
        final postsData = await supabase
            .from('posts')
            .select('*, profiles(display_name, avatar_url)')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(50);

        return (postsData as List)
            .map((json) => SupabasePost.fromJson(json))
            .toList();
      } catch (e) {
        print('Error fetching user posts: $e');
        return [];
      }
    });

// Post comments provider
final postCommentsProvider = FutureProvider.autoDispose
    .family<List<SupabaseComment>, String>((ref, postId) async {
      final supabase = ref.watch(supabaseProvider);

      try {
        final commentsData = await supabase
            .from('comments')
            .select('*, profiles!inner(display_name)')
            .eq('post_id', postId)
            .order('created_at', ascending: true);

        return (commentsData as List)
            .map((json) => SupabaseComment.fromJson(json))
            .toList();
      } catch (e) {
        print('Error fetching comments: $e');
        return [];
      }
    });

// Is following provider
final isFollowingProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  userId,
) async {
  final supabase = ref.watch(supabaseProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) return false;

  try {
    final data = await supabase
        .from('follows')
        .select('id')
        .eq('follower_id', currentUser.id)
        .eq('following_id', userId)
        .maybeSingle();

    return data != null;
  } catch (e) {
    print('Error checking follow status: $e');
    return false;
  }
});

// Followers provider
final followersProvider = FutureProvider.autoDispose
    .family<List<SupabaseProfile>, String>((ref, userId) async {
      final supabase = ref.watch(supabaseProvider);

      try {
        final data = await supabase
            .from('follows')
            .select(
              'profiles!follows_follower_id_fkey(id, display_name, avatar_url, bio)',
            )
            .eq('following_id', userId);

        return (data as List)
            .map((item) => SupabaseProfile.fromJson(item['profiles']))
            .toList();
      } catch (e) {
        print('Error fetching followers: $e');
        return [];
      }
    });

// Following provider
final followingProvider = FutureProvider.autoDispose
    .family<List<SupabaseProfile>, String>((ref, userId) async {
      final supabase = ref.watch(supabaseProvider);

      try {
        final data = await supabase
            .from('follows')
            .select(
              'profiles!follows_following_id_fkey(id, display_name, avatar_url, bio)',
            )
            .eq('follower_id', userId);

        return (data as List)
            .map((item) => SupabaseProfile.fromJson(item['profiles']))
            .toList();
      } catch (e) {
        print('Error fetching following: $e');
        return [];
      }
    });

// Followers count provider
final followersCountProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  userId,
) async {
  final supabase = ref.watch(supabaseProvider);

  try {
    final response = await supabase
        .from('follows')
        .select('id')
        .eq('following_id', userId);

    return (response as List).length;
  } catch (e) {
    print('Error fetching followers count: $e');
    return 0;
  }
});

// Following count provider
final followingCountProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  userId,
) async {
  final supabase = ref.watch(supabaseProvider);

  try {
    final response = await supabase
        .from('follows')
        .select('id')
        .eq('follower_id', userId);

    return (response as List).length;
  } catch (e) {
    print('Error fetching following count: $e');
    return 0;
  }
});

// Has liked post provider
final hasLikedPostProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  postId,
) async {
  final supabase = ref.watch(supabaseProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) return false;

  try {
    final data = await supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', currentUser.id)
        .maybeSingle();

    return data != null;
  } catch (e) {
    print('Error checking like status: $e');
    return false;
  }
});

// Likes count provider
final likesCountProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  postId,
) async {
  final supabase = ref.watch(supabaseProvider);

  try {
    final response = await supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId);

    return (response as List).length;
  } catch (e) {
    print('Error fetching likes count: $e');
    return 0;
  }
});

// Comments count provider
final commentsCountProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  postId,
) async {
  final supabase = ref.watch(supabaseProvider);

  try {
    final response = await supabase
        .from('comments')
        .select('id')
        .eq('post_id', postId);

    return (response as List).length;
  } catch (e) {
    print('Error fetching comments count: $e');
    return 0;
  }
});

// Search users provider
final searchUsersProvider = FutureProvider.autoDispose
    .family<List<SupabaseProfile>, String>((ref, query) async {
      final supabase = ref.watch(supabaseProvider);

      if (query.isEmpty) return [];

      try {
        final data = await supabase
            .from('profiles')
            .select('id, display_name, avatar_url, bio')
            .ilike('display_name', '%$query%')
            .limit(20);

        return (data as List)
            .map((json) => SupabaseProfile.fromJson(json))
            .toList();
      } catch (e) {
        print('Error searching users: $e');
        return [];
      }
    });

// Get user profile by ID
final userProfileProvider = FutureProvider.autoDispose
    .family<SupabaseProfile?, String>((ref, userId) async {
      final supabase = ref.watch(supabaseProvider);

      try {
        final data = await supabase
            .from('profiles')
            .select('id, display_name, avatar_url, bio')
            .eq('id', userId)
            .maybeSingle();

        if (data == null) return null;
        return SupabaseProfile.fromJson(data);
      } catch (e) {
        print('Error fetching user profile: $e');
        return null;
      }
    });

// ===== ACTION PROVIDERS =====

// Edit post provider
final editPostProvider = FutureProvider.autoDispose
    .family<void, ({String postId, String caption})>((ref, params) async {
      final service = ref.watch(supabaseSocialServiceProvider);
      await service.updatePost(postId: params.postId, caption: params.caption);

      // Invalidate related providers to refresh data
      ref.invalidate(singlePostProvider(params.postId));
      ref.invalidate(feedPostsProvider);
      ref.invalidate(explorePostsProvider);
    });

// Get single post by ID
final singlePostProvider = FutureProvider.autoDispose
    .family<SupabasePost?, String>((ref, postId) async {
      final supabase = ref.watch(supabaseProvider);

      try {
        final data = await supabase
            .from('posts')
            .select('''
          *,
          profiles(
            display_name,
            avatar_url
          )
        ''')
            .eq('id', postId)
            .maybeSingle();

        if (data == null) return null;
        return SupabasePost.fromJson(data);
      } catch (e) {
        print('Error fetching post: $e');
        return null;
      }
    });
