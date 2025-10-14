import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';

/// Web-only exercise provider (for MVP)
final exercisesWebProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  if (!kIsWeb) {
    throw UnimplementedError(
      'Use mobile exercise provider for non-web platforms',
    );
  }

  // Web: Fetch from Supabase
  final supabase = ref.watch(supabaseClientProvider);
  final data = await supabase.from('exercises').select().order('name');
  return List<Map<String, dynamic>>.from(data);
});

/// Get exercise by ID (web-only)
final exerciseByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  if (!kIsWeb) {
    throw UnimplementedError(
      'Use mobile exercise provider for non-web platforms',
    );
  }

  final supabase = ref.watch(supabaseClientProvider);
  final data =
      await supabase.from('exercises').select().eq('id', id).maybeSingle();
  return data;
});

/// Filter exercises by category (web-only)
final exercisesByCategoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, category) async {
  if (!kIsWeb) {
    throw UnimplementedError(
      'Use mobile exercise provider for non-web platforms',
    );
  }

  final supabase = ref.watch(supabaseClientProvider);
  final data = await supabase
      .from('exercises')
      .select()
      .eq('category', category)
      .order('name');
  return List<Map<String, dynamic>>.from(data);
});
