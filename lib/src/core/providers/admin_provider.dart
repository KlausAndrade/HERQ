import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider to track admin mode globally (persistent)
final adminModeProvider = StateNotifierProvider<AdminModeNotifier, bool>((ref) {
  return AdminModeNotifier();
});

/// Provider to check if user is admin (based on email or other criteria)
final isAdminProvider = Provider<bool>((ref) {
  // TODO: Replace with actual admin check when auth is implemented
  // For now, we'll use a simple check based on email
  // This should be replaced with proper admin role checking
  return true; // Temporarily allow all users to be admin for testing
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
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('admin_mode', state);
  }

  Future<void> setAdminMode(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('admin_mode', enabled);
  }
}

/// Helper function to navigate with admin mode preserved
void navigateWithAdminMode(BuildContext context, String route, {bool preserveAdmin = true}) {
  // Since we're now using persistent admin mode, we don't need URL parameters
  // Just navigate normally - the admin mode is handled by the provider
  context.go(route);
}

/// Helper function to get admin query parameter (deprecated - use adminModeProvider instead)
String getAdminQueryParam(BuildContext context) {
  return ''; // No longer needed with persistent admin mode
}