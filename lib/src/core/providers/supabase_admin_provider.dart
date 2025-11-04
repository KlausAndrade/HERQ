import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for Supabase admin client with Service Role Key
/// This is required for admin operations like listing users
final supabaseAdminProvider = Provider<SupabaseClient>((ref) {
  // Get the service role key from environment
  const serviceRoleKey = String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY');

  if (serviceRoleKey.isEmpty) {
    throw Exception(
        'SUPABASE_SERVICE_ROLE_KEY not found in environment variables');
  }

  // Get the Supabase URL from environment or use default
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  if (supabaseUrl.isEmpty) {
    throw Exception('SUPABASE_URL not found in environment variables');
  }

  // Create admin client with service role key
  return SupabaseClient(
    supabaseUrl,
    serviceRoleKey,
    authOptions: const AuthClientOptions(
      autoRefreshToken: false,
    ),
  );
});
