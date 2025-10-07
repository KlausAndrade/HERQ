import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/auth_provider.dart';

/// Web-only workout templates provider
final workoutTemplatesWebProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  if (!kIsWeb) {
    throw UnimplementedError('Use mobile template provider for non-web platforms');
  }
  
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    return Stream.value([]);
  }
  
  return supabase
      .from('workout_templates')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .order('name')
      .map((data) => List<Map<String, dynamic>>.from(data));
});

/// Get single template by ID
final templateByIdWebProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  if (!kIsWeb) {
    throw UnimplementedError('Use mobile template provider for non-web platforms');
  }
  
  final supabase = ref.watch(supabaseClientProvider);
  final data = await supabase
      .from('workout_templates')
      .select()
      .eq('id', id)
      .maybeSingle();
  
  return data;
});

/// Create new template
final createTemplateWebProvider = Provider((ref) {
  if (!kIsWeb) {
    throw UnimplementedError('Use mobile template provider for non-web platforms');
  }
  
  final supabase = ref.watch(supabaseClientProvider);
  
  return ({
    required String name,
    String? description,
    required List<String> exerciseIds,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    
    await supabase.from('workout_templates').insert({
      'id': const Uuid().v4(),
      'user_id': user.id,
      'name': name,
      'description': description,
      'exercise_ids': exerciseIds,
    });
    
    // Invalidate to refresh
    ref.invalidate(workoutTemplatesWebProvider);
  };
});

/// Delete template
final deleteTemplateWebProvider = Provider((ref) {
  if (!kIsWeb) {
    throw UnimplementedError('Use mobile template provider for non-web platforms');
  }
  
  final supabase = ref.watch(supabaseClientProvider);
  
  return (String templateId) async {
    await supabase
        .from('workout_templates')
        .delete()
        .eq('id', templateId);
    
    // Invalidate to refresh
    ref.invalidate(workoutTemplatesWebProvider);
  };
});
