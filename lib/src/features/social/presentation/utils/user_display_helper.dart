import '../../../../core/database/database.dart';

class UserDisplayHelper {
  static String getDisplayName(User user) {
    return user.displayName.isNotEmpty 
        ? user.displayName 
        : 'User ${user.id.substring(0, 8)}';
  }

  static String getInitials(User user) {
    if (user.displayName.isNotEmpty) {
      final parts = user.displayName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return user.displayName[0].toUpperCase();
    }
    return user.id[0].toUpperCase();
  }
}
