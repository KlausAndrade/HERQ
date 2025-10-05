import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/services/social_service.dart';
import '../../domain/models/social_models.dart';

// Service provider
final socialServiceProvider = Provider<SocialService>((ref) {
  return const SocialService();
});

// User search provider
final userSearchProvider = StateNotifierProvider<UserSearchNotifier, AsyncValue<List<UserProfile>>>((ref) {
  return UserSearchNotifier(ref.read(socialServiceProvider));
});

class UserSearchNotifier extends StateNotifier<AsyncValue<List<UserProfile>>> {
  UserSearchNotifier(this._socialService) : super(const AsyncValue.data([]));

  final SocialService _socialService;

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    
    try {
      final users = await _socialService.searchUsers(query);
      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

// Friends provider
final friendsProvider = FutureProvider.family<List<UserProfile>, String>((ref, userId) async {
  final socialService = ref.read(socialServiceProvider);
  return socialService.getFriends(userId);
});

// Friend requests provider
final friendRequestsProvider = FutureProvider.family<List<FriendConnection>, String>((ref, userId) async {
  final socialService = ref.read(socialServiceProvider);
  return socialService.getFriendRequests(userId);
});

// Social feed provider
final socialFeedProvider = FutureProvider.family<List<FeedItem>, String>((ref, userId) async {
  final socialService = ref.read(socialServiceProvider);
  return socialService.getFeed(userId);
});

// Leaderboards provider
final leaderboardProvider = FutureProvider.family<Leaderboard, LeaderboardParams>((ref, params) async {
  final socialService = ref.read(socialServiceProvider);
  return socialService.getLeaderboard(params.type, params.period);
});

// User achievements provider
final userAchievementsProvider = FutureProvider.family<List<Achievement>, String>((ref, userId) async {
  final socialService = ref.read(socialServiceProvider);
  return socialService.getUserAchievements(userId);
});

// Social actions provider
final socialActionsProvider = Provider<SocialActions>((ref) {
  return SocialActions(ref.read(socialServiceProvider));
});

class SocialActions {
  SocialActions(this._socialService);

  final SocialService _socialService;

  Future<bool> sendFriendRequest(String fromUserId, String toUserId) async {
    return _socialService.sendFriendRequest(fromUserId, toUserId);
  }

  Future<bool> acceptFriendRequest(String requestId) async {
    return _socialService.acceptFriendRequest(requestId);
  }

  Future<bool> declineFriendRequest(String requestId) async {
    return _socialService.declineFriendRequest(requestId);
  }
}

// Helper class for leaderboard parameters
class LeaderboardParams {
  const LeaderboardParams({
    required this.type,
    required this.period,
  });

  final LeaderboardType type;
  final Period period;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          period == other.period;

  @override
  int get hashCode => type.hashCode ^ period.hashCode;
}