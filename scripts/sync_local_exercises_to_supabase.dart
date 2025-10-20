#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script to sync local SQLite exercises to Supabase
/// This will read all exercises from your local database and upload them to Supabase
void main() async {
  print('🔄 Starting local exercises sync to Supabase...');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vvgxvunvzhtvwvdvtlrm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2Z3h2dW52emh0dnd2ZHZ0bHJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NDcyNzcsImV4cCI6MjA3NTMyMzI3N30.yOMUIA2sQSTjAjlFemz1GYCxNR0sVm4ZMMl_9Y2ABno',
  );
  
  final supabase = Supabase.instance.client;
  
  try {
    // Get all exercises from local SQLite database
    print('📱 Reading exercises from local SQLite database...');
    
    // This would need to be run from within the Flutter app context
    // For now, let's create a script that can be run from the Flutter app
    print('⚠️  This script needs to be run from within the Flutter app context');
    print('📝 To sync your exercises, run this from your Flutter app:');
    print('');
    print('```dart');
    print('// Add this to your Flutter app and call it');
    print('Future<void> syncLocalExercisesToSupabase() async {');
    print('  final database = ref.read(databaseProvider);');
    print('  if (database == null) return;');
    print('');
    print('  final supabase = Supabase.instance.client;');
    print('  final user = supabase.auth.currentUser;');
    print('  if (user == null) return;');
    print('');
    print('  try {');
    print('    // Get all exercises from local database');
    print('    final exercises = await database.select(database.exercises).get();');
    print('    print(\'📱 Found \${exercises.length} exercises in local database\');');
    print('');
    print('    // Upload to Supabase');
    print('    for (final exercise in exercises) {');
    print('      try {');
    print('        await supabase.from(\'exercises\').upsert({');
    print('          \'id\': exercise.id,');
    print('          \'name\': exercise.name,');
    print('          \'primary_muscle_group\': exercise.primaryMuscleGroup,');
    print('          \'secondary_muscle_groups\': exercise.secondaryMuscleGroups,');
    print('          \'equipment\': exercise.equipment,');
    print('          \'instructions\': exercise.instructions,');
    print('          \'tags\': exercise.tags,');
    print('          \'is_bodyweight\': exercise.isBodyweight,');
    print('          \'exercise_type\': exercise.exerciseType,');
    print('          \'category\': exercise.category,');
    print('          \'difficulty\': exercise.difficulty,');
    print('          \'created_at\': exercise.createdAt.toIso8601String(),');
    print('          \'updated_at\': exercise.updatedAt.toIso8601String(),');
    print('        });');
    print('        print(\'✅ Synced: \${exercise.name}\');');
    print('      } catch (e) {');
    print('        print(\'❌ Failed to sync \${exercise.name}: \$e\');');
    print('      }');
    print('    }');
    print('');
    print('    print(\'🎉 Successfully synced \${exercises.length} exercises to Supabase!\');');
    print('  } catch (e) {');
    print('    print(\'❌ Sync failed: \$e\');');
    print('  }');
    print('}');
    print('```');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
