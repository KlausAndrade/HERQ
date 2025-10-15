import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to manage current user context for data isolation
class UserContextService {
  static UserContextService? _instance;
  static UserContextService get instance => _instance ??= UserContextService._();
  
  UserContextService._();
  
  /// Get current user ID for data isolation
  String getCurrentUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Fallback for offline mode or when not authenticated
      return 'offline_user';
    }
    return user.id;
  }
  
  /// Check if user is authenticated
  bool get isAuthenticated {
    return Supabase.instance.client.auth.currentUser != null;
  }
  
  /// Get current user email
  String? getCurrentUserEmail() {
    return Supabase.instance.client.auth.currentUser?.email;
  }
  
  /// Get current user display name
  String getCurrentUserDisplayName() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 'Offline User';
    
    final metadata = user.userMetadata ?? {};
    return metadata['display_name'] ?? 
           metadata['full_name'] ?? 
           user.email?.split('@')[0] ?? 
           'User';
  }
}
