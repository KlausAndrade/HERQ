import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

/// Provider to check if current user is an admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  
  if (user?.email == null) return false;
  
  // List of admin emails - add your email here
  const adminEmails = [
    'klaus.dev@outlook.com', // Your email
    'test@test.com',          // Test email for development
  ];
  
  return adminEmails.contains(user!.email);
});

/// Provider to check if maintenance section should be shown
final showMaintenanceProvider = Provider<bool>((ref) {
  return ref.watch(isAdminProvider);
});
