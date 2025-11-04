import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for fetching workout templates from Supabase (web only)
final templatesWebProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return [];
  }

  try {
    // Fetch user's templates and default templates
    final response = await supabase
        .from('workout_templates')
        .select()
        .or('user_id.eq.${user.id},is_default.eq.true')
        .order('sort_order');

    return List<Map<String, dynamic>>.from(response);
  } on Exception catch (_) {
    return [];
  }
});

/// Provider for fetching template folders from Supabase (web only)
final foldersWebProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return [];
  }

  try {
    final response = await supabase
        .from('template_folders')
        .select()
        .eq('user_id', user.id)
        .order('sort_order');

    return List<Map<String, dynamic>>.from(response);
  } on Exception catch (_) {
    return [];
  }
});

/// Provider for templates in a specific folder (web only)
final templatesInFolderWebProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>(
        (ref, folderId) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return [];
  }

  try {
    if (folderId == null) {
      // Templates not in any folder
      final response = await supabase
          .from('workout_templates')
          .select()
          .eq('user_id', user.id)
          .isFilter('folder_id', null)
          .order('sort_order');

      return List<Map<String, dynamic>>.from(response);
    } else {
      // Templates in specific folder
      final response = await supabase
          .from('workout_templates')
          .select()
          .eq('folder_id', folderId)
          .order('sort_order');

      return List<Map<String, dynamic>>.from(response);
    }
  } on Exception catch (_) {
    return [];
  }
});

/// Alias for workoutTemplatesWebProvider (for compatibility)
final workoutTemplatesWebProvider = templatesWebProvider;

/// Provider for creating a new workout template (web only)
final createTemplateWebProvider = Provider<
    Future<void> Function({
      required String name,
      required List<String> exerciseIds,
    })>((ref) {
  return ({required String name, required List<String> exerciseIds}) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      await supabase.from('workout_templates').insert({
        'user_id': user.id,
        'name': name,
        'exercise_ids': exerciseIds,
        'is_default': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Invalidate the templates provider to refresh the list
      ref.invalidate(templatesWebProvider);
    } on Exception catch (e) {
      throw Exception('Failed to create template: $e');
    }
  };
});

/// Provider for deleting a workout template (web only)
final deleteTemplateWebProvider =
    Provider<Future<void> Function(String)>((ref) {
  return (String templateId) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('workout_templates').delete().eq('id', templateId);

      // Invalidate the templates provider to refresh the list
      ref.invalidate(templatesWebProvider);
    } on Exception catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  };
});
