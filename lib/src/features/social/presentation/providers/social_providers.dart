import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../domain/social_service.dart';

// Social service provider
final socialServiceProvider = Provider<SocialService>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) throw Exception('Database not initialized');
  return SocialService(db);
});

// Feed posts provider
final feedPostsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final social = ref.watch(socialServiceProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return [];
  
  return await social.getFeedPosts(user.id);
});

// User posts provider
final userPostsProvider = FutureProvider.autoDispose.family<List<Post>, String>((ref, userId) async {
  final social = ref.watch(socialServiceProvider);
  return await social.getUserPosts(userId);
});

// Post provider
final postProvider = FutureProvider.autoDispose.family<Post, String>((ref, postId) async {
  final social = ref.watch(socialServiceProvider);
  return await social.getPost(postId);
});

// Post comments provider
final postCommentsProvider = FutureProvider.autoDispose.family<List<PostComment>, String>((ref, postId) async {
  final social = ref.watch(socialServiceProvider);
  return await social.getPostComments(postId);
});

// Post likers provider
final postLikersProvider = FutureProvider.autoDispose.family<List<User>, String>((ref, postId) async {
  final social = ref.watch(socialServiceProvider);
  return await social.getPostLikers(postId);
});

// Is following provider
final isFollowingProvider = FutureProvider.autoDispose.family<bool, String>((ref, userId) async {
  final social = ref.watch(socialServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) return false;
  
  return await social.isFollowing(currentUser.id, userId);
});

// Followers provider
final followersProvider = FutureProvider.autoDispose.family<List<User>, String>((ref, userId) async {
  final social = ref.watch(socialServiceProvider);
  return await social.getFollowers(userId);
});

// Following provider
final followingProvider = FutureProvider.autoDispose.family<List<User>, String>((ref, userId) async {
  final social = ref.watch(socialServiceProvider);
  return await social.getFollowing(userId);
});

// Followers count provider
final followersCountProvider = FutureProvider.autoDispose.family<int, String>((ref, userId) async {
  final social = ref.watch(socialServiceProvider);
  return await social.getFollowersCount(userId);
});

// Following count provider
final followingCountProvider = FutureProvider.autoDispose.family<int, String>((ref, userId) async {
  final social = ref.watch(socialServiceProvider);
  return await social.getFollowingCount(userId);
});

// Has liked post provider
final hasLikedPostProvider = FutureProvider.autoDispose.family<bool, String>((ref, postId) async {
  final social = ref.watch(socialServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) return false;
  
  return await social.hasLikedPost(postId, currentUser.id);
});

// Search users provider
final searchUsersProvider = FutureProvider.autoDispose.family<List<User>, String>((ref, query) async {
  final social = ref.watch(socialServiceProvider);
  if (query.isEmpty) return [];
  return await social.searchUsers(query);
});
