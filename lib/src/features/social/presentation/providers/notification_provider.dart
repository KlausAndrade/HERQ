import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../domain/models/notification_model.dart';
import 'social_providers.dart';

/// Notifications provider - fetches user's notifications
final notificationsProvider =
    FutureProvider.autoDispose<List<SocialNotification>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  try {
    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(50);

    return (data as List)
        .map((json) => SocialNotification.fromJson(json))
        .toList();
  } catch (e) {
    print('Error fetching notifications: $e');
    return [];
  }
});

/// Real-time notifications stream
final notificationsStreamProvider =
    StreamProvider.autoDispose<List<SocialNotification>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return Stream.value([]);

  return supabase
      .from('notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .order('created_at', ascending: false)
      .limit(50)
      .map((data) => (data as List)
          .map((json) => SocialNotification.fromJson(json))
          .toList());
});

/// Unread notifications count provider
final unreadNotificationsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return 0;

  try {
    final data = await supabase
        .from('notifications')
        .select('id')
        .eq('user_id', user.id)
        .eq('is_read', false);

    return (data as List).length;
  } catch (e) {
    print('Error fetching unread count: $e');
    return 0;
  }
});

/// Mark notification as read
Future<void> markNotificationAsRead(SupabaseClient supabase, String notificationId) async {
  try {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  } catch (e) {
    print('Error marking notification as read: $e');
  }
}

/// Mark all notifications as read
Future<void> markAllNotificationsAsRead(SupabaseClient supabase, String userId) async {
  try {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  } catch (e) {
    print('Error marking all notifications as read: $e');
  }
}

/// Delete notification
Future<void> deleteNotification(SupabaseClient supabase, String notificationId) async {
  try {
    await supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId);
  } catch (e) {
    print('Error deleting notification: $e');
  }
}

