import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'social_models.g.dart';

@JsonSerializable()
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    this.joinedAt,
    this.totalWorkouts = 0,
    this.totalVolume = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.isPublic = true,
    this.preferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final DateTime? joinedAt;
  final int totalWorkouts;
  final double totalVolume;
  final int currentStreak;
  final int maxStreak;
  final bool isPublic;
  final UserPreferences? preferences;
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    DateTime? joinedAt,
    int? totalWorkouts,
    double? totalVolume,
    int? currentStreak,
    int? maxStreak,
    bool? isPublic,
    UserPreferences? preferences,
  }) => UserProfile(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    bio: bio ?? this.bio,
    location: location ?? this.location,
    joinedAt: joinedAt ?? this.joinedAt,
    totalWorkouts: totalWorkouts ?? this.totalWorkouts,
    totalVolume: totalVolume ?? this.totalVolume,
    currentStreak: currentStreak ?? this.currentStreak,
    maxStreak: maxStreak ?? this.maxStreak,
    isPublic: isPublic ?? this.isPublic,
    preferences: preferences ?? this.preferences,
  );

  @override
  List<Object?> get props => [
    id,
    displayName,
    email,
    avatarUrl,
    bio,
    location,
    joinedAt,
    totalWorkouts,
    totalVolume,
    currentStreak,
    maxStreak,
    isPublic,
    preferences,
  ];
}

@JsonSerializable()
class UserPreferences extends Equatable {
  const UserPreferences({
    this.shareWorkouts = true,
    this.sharePRs = true,
    this.allowFriendRequests = true,
    this.showInLeaderboards = true,
    this.notifyOnFriendPR = true,
    this.notifyOnFriendWorkout = false,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  final bool shareWorkouts;
  final bool sharePRs;
  final bool allowFriendRequests;
  final bool showInLeaderboards;
  final bool notifyOnFriendPR;
  final bool notifyOnFriendWorkout;
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    bool? shareWorkouts,
    bool? sharePRs,
    bool? allowFriendRequests,
    bool? showInLeaderboards,
    bool? notifyOnFriendPR,
    bool? notifyOnFriendWorkout,
  }) => UserPreferences(
    shareWorkouts: shareWorkouts ?? this.shareWorkouts,
    sharePRs: sharePRs ?? this.sharePRs,
    allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
    showInLeaderboards: showInLeaderboards ?? this.showInLeaderboards,
    notifyOnFriendPR: notifyOnFriendPR ?? this.notifyOnFriendPR,
    notifyOnFriendWorkout: notifyOnFriendWorkout ?? this.notifyOnFriendWorkout,
  );

  @override
  List<Object?> get props => [
    shareWorkouts,
    sharePRs,
    allowFriendRequests,
    showInLeaderboards,
    notifyOnFriendPR,
    notifyOnFriendWorkout,
  ];
}

@JsonSerializable()
class FriendConnection extends Equatable {
  const FriendConnection({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  factory FriendConnection.fromJson(Map<String, dynamic> json) =>
      _$FriendConnectionFromJson(json);

  final String id;
  final String userId;
  final String friendId;
  final FriendStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  Map<String, dynamic> toJson() => _$FriendConnectionToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    friendId,
    status,
    createdAt,
    acceptedAt,
  ];
}

enum FriendStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined,
  @JsonValue('blocked')
  blocked,
}

@JsonSerializable()
class FeedItem extends Equatable {
  const FeedItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.createdAt,
    this.workoutId,
    this.exerciseId,
    this.achievement,
    this.metadata,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) =>
      _$FeedItemFromJson(json);

  final String id;
  final String userId;
  final FeedItemType type;
  final DateTime createdAt;
  final String? workoutId;
  final String? exerciseId;
  final Achievement? achievement;
  final Map<String, dynamic>? metadata;
  Map<String, dynamic> toJson() => _$FeedItemToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    createdAt,
    workoutId,
    exerciseId,
    achievement,
    metadata,
  ];
}

enum FeedItemType {
  @JsonValue('workout_completed')
  workoutCompleted,
  @JsonValue('pr_achieved')
  prAchieved,
  @JsonValue('streak_milestone')
  streakMilestone,
  @JsonValue('friend_joined')
  friendJoined,
  @JsonValue('challenge_completed')
  challengeCompleted,
}

@JsonSerializable()
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.unlockedAt,
    this.iconUrl,
    this.badgeColor,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final DateTime unlockedAt;
  final String? iconUrl;
  final String? badgeColor;
  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    unlockedAt,
    iconUrl,
    badgeColor,
  ];
}

enum AchievementType {
  @JsonValue('workout_count')
  workoutCount,
  @JsonValue('streak')
  streak,
  @JsonValue('volume')
  volume,
  @JsonValue('strength')
  strength,
  @JsonValue('consistency')
  consistency,
}

@JsonSerializable()
class Leaderboard extends Equatable {
  const Leaderboard({
    required this.id,
    required this.name,
    required this.type,
    required this.period,
    required this.entries,
    required this.updatedAt,
  });

  factory Leaderboard.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardFromJson(json);

  final String id;
  final String name;
  final LeaderboardType type;
  final Period period;
  final List<LeaderboardEntry> entries;
  final DateTime updatedAt;
  Map<String, dynamic> toJson() => _$LeaderboardToJson(this);

  @override
  List<Object?> get props => [id, name, type, period, entries, updatedAt];
}

enum LeaderboardType {
  @JsonValue('total_volume')
  totalVolume,
  @JsonValue('workout_count')
  workoutCount,
  @JsonValue('streak')
  streak,
  @JsonValue('pr_count')
  prCount,
}

enum Period {
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
  @JsonValue('all_time')
  allTime,
}

@JsonSerializable()
class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.rank,
    required this.score,
    this.avatarUrl,
    this.change,
  }); // Position change from previous period

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);

  final String userId;
  final String displayName;
  final int rank;
  final double score;
  final String? avatarUrl;
  final int? change;
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);

  @override
  List<Object?> get props => [
    userId,
    displayName,
    rank,
    score,
    avatarUrl,
    change,
  ];
}
