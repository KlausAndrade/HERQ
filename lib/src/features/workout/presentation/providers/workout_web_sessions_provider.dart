import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';

/// Recent workout sessions (web-only)
final recentSessionsWebProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  if (!kIsWeb) {
    throw UnimplementedError(
        'Use mobile sessions provider for non-web platforms');
  }

  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return [];

  final data = await supabase
      .from('workout_sessions')
      .select()
      .eq('user_id', user.id)
      .order('started_at', ascending: false)
      .limit(10);

  return List<Map<String, dynamic>>.from(data);
});

/// All workout sessions (web-only)
final allSessionsWebProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  if (!kIsWeb) {
    throw UnimplementedError(
        'Use mobile sessions provider for non-web platforms');
  }

  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    return Stream.value([]);
  }

  return supabase
      .from('workout_sessions')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .order('started_at', ascending: false)
      .map((data) => List<Map<String, dynamic>>.from(data));
});
