import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for fetching workout templates from Supabase (web only)
final templatesWebProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    print('❌ No authenticated user for template fetch');
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
  } catch (e) {
    print('❌ Failed to fetch templates from Supabase: $e');
    return [];
  }
});

/// Provider for fetching template folders from Supabase (web only)
final foldersWebProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    print('❌ No authenticated user for folder fetch');
    return [];
  }
  
  try {
    final response = await supabase
        .from('template_folders')
        .select()
        .eq('user_id', user.id)
        .order('sort_order');
    
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('❌ Failed to fetch folders from Supabase: $e');
    return [];
  }
});

/// Provider for templates in a specific folder (web only)
final templatesInFolderWebProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, folderId) async {
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
  } catch (e) {
    print('❌ Failed to fetch templates in folder: $e');
    return [];
  }
});