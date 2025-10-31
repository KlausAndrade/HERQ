import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider to track admin mode globally (persistent)
final adminModeProvider = StateNotifierProvider<AdminModeNotifier, bool>(
  (ref) => AdminModeNotifier(),
);

/// Provider to check if user is admin (based on email from .env)
final isAdminProvider = Provider<bool>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user?.email == null) {
    return false;
  }

  // Get admin emails from environment variables
  const adminEmails = String.fromEnvironment('ADMIN_EMAILS');
  if (adminEmails.isEmpty) {
    return false;
  }

  // Parse admin emails (comma-separated)
  final adminEmailList = adminEmails
      .split(',')
      .map((email) => email.trim().toLowerCase())
      .toList();

  // Check if current user's email is in admin list
  final userEmail = user!.email!.toLowerCase();
  return adminEmailList.contains(userEmail);
});

/// Provider to get current admin mode (combines admin status and toggle)
final currentAdminModeProvider = Provider<bool>((ref) {
  final isAdmin = ref.watch(isAdminProvider);
  final adminMode = ref.watch(adminModeProvider);
  return isAdmin && adminMode;
});

class AdminModeNotifier extends StateNotifier<bool> {
  AdminModeNotifier() : super(false) {
    _loadAdminMode();
  }

  Future<void> _loadAdminMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('admin_mode') ?? false;
  }

  Future<void> toggleAdminMode() async {
    // Only allow toggling if user is actually an admin
    if (!_isCurrentUserAdmin()) {
      return; // Do nothing if user is not admin
    }

    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('admin_mode', state);
  }

  Future<void> setAdminMode({required bool enabled}) async {
    // Only allow setting if user is actually an admin
    if (!_isCurrentUserAdmin()) {
      return; // Do nothing if user is not admin
    }

    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('admin_mode', enabled);
  }

  /// Check if current user is admin based on email
  bool _isCurrentUserAdmin() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user?.email == null) {
      return false;
    }

    // Get admin emails from environment variables
    const adminEmails = String.fromEnvironment('ADMIN_EMAILS');
    if (adminEmails.isEmpty) {
      return false;
    }

    // Parse admin emails (comma-separated)
    final adminEmailList = adminEmails
        .split(',')
        .map((email) => email.trim().toLowerCase())
        .toList();

    // Check if current user's email is in admin list
    final userEmail = user!.email!.toLowerCase();
    return adminEmailList.contains(userEmail);
  }
}

/// Helper function to navigate with admin mode preserved
void navigateWithAdminMode(
  BuildContext context,
  String route, {
  bool preserveAdmin = true,
}) {
  // Since we're now using persistent admin mode, we don't need URL parameters
  // Just navigate normally - the admin mode is handled by the provider
  context.go(route);
}

/// Helper function to get admin query parameter (deprecated - use adminModeProvider instead)
String getAdminQueryParam(BuildContext context) =>
    ''; // No longer needed with persistent admin mode
