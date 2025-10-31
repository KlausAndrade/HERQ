import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';

const _uuid = Uuid();

class SocialService {
  SocialService(this._db);

  final AppDatabase _db;

  // ===== POSTS =====

  /// Create a new post
  Future<Post> createPost({
    required String userId,
    required String caption,
    String? imageUrl,
    String? workoutSessionId,
  }) async {
    final post = PostsCompanion(
      id: Value(_uuid.v4()),
      userId: Value(userId),
      caption: Value(caption),
      imageUrl: Value(imageUrl),
      workoutSessionId: Value(workoutSessionId),
      likesCount: const Value(0),
      commentsCount: const Value(0),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    await _db.into(_db.posts).insert(post);
    return getPost(post.id.value);
  }

  /// Get a single post
  Future<Post> getPost(String postId) async =>
      (_db.select(_db.posts)..where((p) => p.id.equals(postId))).getSingle();

  /// Get feed posts (all posts from followed users + own posts)
  Future<List<Post>> getFeedPosts(String userId, {int limit = 50}) async {
    // Get list of followed user IDs
    final followingIds =
        await (_db.select(_db.userFollows)
              ..where((f) => f.followerId.equals(userId)))
            .map((f) => f.followingId)
            .get();

    // Include the user's own posts
    final userIds = [...followingIds, userId];

    // Get posts from followed users and self
    return (_db.select(_db.posts)
          ..where((p) => p.userId.isIn(userIds))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Get posts by a specific user
  Future<List<Post>> getUserPosts(String userId, {int limit = 50}) async =>
      (_db.select(_db.posts)
            ..where((p) => p.userId.equals(userId))
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
            ..limit(limit))
          .get();

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await (_db.delete(_db.posts)..where((p) => p.id.equals(postId))).go();
  }

  // ===== LIKES =====

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    // Check if already liked
    final existing =
        await (_db.select(_db.postLikes)
              ..where((l) => l.postId.equals(postId) & l.userId.equals(userId)))
            .getSingleOrNull();

    if (existing != null) return; // Already liked

    // Create like
    await _db
        .into(_db.postLikes)
        .insert(
          PostLikesCompanion(
            id: Value(_uuid.v4()),
            postId: Value(postId),
            userId: Value(userId),
            createdAt: Value(DateTime.now()),
          ),
        );

    // Increment likes count
    await (_db.update(_db.posts)..where((p) => p.id.equals(postId))).write(
      PostsCompanion(likesCount: Value(await _getLikesCount(postId))),
    );
  }

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    await (_db.delete(
      _db.postLikes,
    )..where((l) => l.postId.equals(postId) & l.userId.equals(userId))).go();

    // Decrement likes count
    await (_db.update(_db.posts)..where((p) => p.id.equals(postId))).write(
      PostsCompanion(likesCount: Value(await _getLikesCount(postId))),
    );
  }

  /// Check if user liked a post
  Future<bool> hasLikedPost(String postId, String userId) async {
    final like =
        await (_db.select(_db.postLikes)
              ..where((l) => l.postId.equals(postId) & l.userId.equals(userId)))
            .getSingleOrNull();
    return like != null;
  }

  /// Get likes count for a post
  Future<int> _getLikesCount(String postId) async {
    final count = await _db
        .customSelect(
          'SELECT COUNT(*) as count FROM post_likes WHERE post_id = ?',
          variables: [Variable(postId)],
          readsFrom: {_db.postLikes},
        )
        .getSingle();
    return count.read<int>('count');
  }

  /// Get users who liked a post
  Future<List<User>> getPostLikers(String postId) async {
    final query = _db.select(_db.users).join([
      innerJoin(_db.postLikes, _db.postLikes.userId.equalsExp(_db.users.id)),
    ])..where(_db.postLikes.postId.equals(postId));

    final results = await query.get();
    return results.map((row) => row.readTable(_db.users)).toList();
  }

  // ===== COMMENTS =====

  /// Add a comment to a post
  Future<PostComment> addComment({
    required String postId,
    required String userId,
    required String comment,
  }) async {
    final commentData = PostCommentsCompanion(
      id: Value(_uuid.v4()),
      postId: Value(postId),
      userId: Value(userId),
      comment: Value(comment),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    await _db.into(_db.postComments).insert(commentData);

    // Increment comments count
    await (_db.update(_db.posts)..where((p) => p.id.equals(postId))).write(
      PostsCompanion(commentsCount: Value(await _getCommentsCount(postId))),
    );

    return (_db.select(
      _db.postComments,
    )..where((c) => c.id.equals(commentData.id.value))).getSingle();
  }

  /// Get comments for a post
  Future<List<PostComment>> getPostComments(String postId) async =>
      (_db.select(_db.postComments)
            ..where((c) => c.postId.equals(postId))
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .get();

  /// Delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    await (_db.delete(
      _db.postComments,
    )..where((c) => c.id.equals(commentId))).go();

    // Decrement comments count
    await (_db.update(_db.posts)..where((p) => p.id.equals(postId))).write(
      PostsCompanion(commentsCount: Value(await _getCommentsCount(postId))),
    );
  }

  /// Get comments count for a post
  Future<int> _getCommentsCount(String postId) async {
    final count = await _db
        .customSelect(
          'SELECT COUNT(*) as count FROM post_comments WHERE post_id = ?',
          variables: [Variable(postId)],
          readsFrom: {_db.postComments},
        )
        .getSingle();
    return count.read<int>('count');
  }

  // ===== FOLLOWS =====

  /// Follow a user
  Future<void> followUser(String followerId, String followingId) async {
    // Check if already following
    final existing =
        await (_db.select(_db.userFollows)..where(
              (f) =>
                  f.followerId.equals(followerId) &
                  f.followingId.equals(followingId),
            ))
            .getSingleOrNull();

    if (existing != null) return; // Already following

    await _db
        .into(_db.userFollows)
        .insert(
          UserFollowsCompanion(
            id: Value(_uuid.v4()),
            followerId: Value(followerId),
            followingId: Value(followingId),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  /// Unfollow a user
  Future<void> unfollowUser(String followerId, String followingId) async {
    await (_db.delete(_db.userFollows)..where(
          (f) =>
              f.followerId.equals(followerId) &
              f.followingId.equals(followingId),
        ))
        .go();
  }

  /// Check if user is following another user
  Future<bool> isFollowing(String followerId, String followingId) async {
    final follow =
        await (_db.select(_db.userFollows)..where(
              (f) =>
                  f.followerId.equals(followerId) &
                  f.followingId.equals(followingId),
            ))
            .getSingleOrNull();
    return follow != null;
  }

  /// Get followers of a user
  Future<List<User>> getFollowers(String userId) async {
    final query = _db.select(_db.users).join([
      innerJoin(
        _db.userFollows,
        _db.userFollows.followerId.equalsExp(_db.users.id),
      ),
    ])..where(_db.userFollows.followingId.equals(userId));

    final results = await query.get();
    return results.map((row) => row.readTable(_db.users)).toList();
  }

  /// Get users that a user is following
  Future<List<User>> getFollowing(String userId) async {
    final query = _db.select(_db.users).join([
      innerJoin(
        _db.userFollows,
        _db.userFollows.followingId.equalsExp(_db.users.id),
      ),
    ])..where(_db.userFollows.followerId.equals(userId));

    final results = await query.get();
    return results.map((row) => row.readTable(_db.users)).toList();
  }

  /// Get followers count
  Future<int> getFollowersCount(String userId) async {
    final count = await _db
        .customSelect(
          'SELECT COUNT(*) as count FROM user_follows WHERE following_id = ?',
          variables: [Variable(userId)],
          readsFrom: {_db.userFollows},
        )
        .getSingle();
    return count.read<int>('count');
  }

  /// Get following count
  Future<int> getFollowingCount(String userId) async {
    final count = await _db
        .customSelect(
          'SELECT COUNT(*) as count FROM user_follows WHERE follower_id = ?',
          variables: [Variable(userId)],
          readsFrom: {_db.userFollows},
        )
        .getSingle();
    return count.read<int>('count');
  }

  // ===== USER SEARCH =====

  /// Search for users by display name
  Future<List<User>> searchUsers(String query, {int limit = 20}) async =>
      (_db.select(_db.users)
            ..where((u) => u.displayName.like('%$query%'))
            ..limit(limit))
          .get();
}
