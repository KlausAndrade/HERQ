/// Notification types for social interactions
enum NotificationType {
  like, // Someone liked your post
  comment, // Someone commented on your post
  follow, // Someone followed you
  mention, // Someone mentioned you in a post/comment
  reply, // Someone replied to your comment
}

/// Social notification model
class SocialNotification {
  SocialNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.postId,
    this.commentId,
    this.fromUserId,
    this.fromUserName,
    this.fromUserAvatar,
    this.isRead = false,
  });

  factory SocialNotification.fromJson(Map<String, dynamic> json) =>
      SocialNotification(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.like,
        ),
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        postId: json['post_id'] as String?,
        commentId: json['comment_id'] as String?,
        fromUserId: json['from_user_id'] as String?,
        fromUserName: json['from_user_name'] as String?,
        fromUserAvatar: json['from_user_avatar'] as String?,
        isRead: (json['is_read'] as bool?) ?? false,
      );

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? postId;
  final String? commentId;
  final String? fromUserId;
  final String? fromUserName;
  final String? fromUserAvatar;
  final bool isRead;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type.name,
    'title': title,
    'body': body,
    'created_at': createdAt.toIso8601String(),
    'post_id': postId,
    'comment_id': commentId,
    'from_user_id': fromUserId,
    'from_user_name': fromUserName,
    'from_user_avatar': fromUserAvatar,
    'is_read': isRead,
  };
}
