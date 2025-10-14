import 'package:supabase_flutter/supabase_flutter.dart';

import '../dto/workout_dto.dart';
import 'base_repository.dart';

/// Web implementation of WorkoutRepository using Supabase directly
/// No local database - all operations go straight to Supabase
class WebWorkoutRepository implements WorkoutRepository {
  final SupabaseClient _supabase;

  WebWorkoutRepository(this._supabase);

  @override
  Stream<List<WorkoutSessionDto>> watchWorkoutSessions() {
    return _supabase
        .from('workout_sessions')
        .stream(primaryKey: ['id'])
        .order('started_at', ascending: false)
        .map((data) =>
            data.map((json) => WorkoutSessionDto.fromJson(json)).toList());
  }

  @override
  Future<List<WorkoutSessionDto>> getWorkoutSessions() async {
    final response = await _supabase
        .from('workout_sessions')
        .select()
        .order('started_at', ascending: false);

    return (response as List)
        .map((json) => WorkoutSessionDto.fromJson(json))
        .toList();
  }

  @override
  Future<WorkoutSessionDto?> getWorkoutSessionById(String id) async {
    final response = await _supabase
        .from('workout_sessions')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? WorkoutSessionDto.fromJson(response) : null;
  }

  @override
  Future<WorkoutSessionDto> createWorkoutSession(
      WorkoutSessionDto session) async {
    final response = await _supabase
        .from('workout_sessions')
        .insert(session.toJson())
        .select()
        .single();

    return WorkoutSessionDto.fromJson(response);
  }

  @override
  Future<void> updateWorkoutSession(WorkoutSessionDto session) async {
    await _supabase
        .from('workout_sessions')
        .update(session.toJson())
        .eq('id', session.id);
  }

  @override
  Future<void> deleteWorkoutSession(String id) async {
    await _supabase.from('workout_sessions').delete().eq('id', id);
  }

  @override
  Future<List<SetEntryDto>> getSetEntriesBySession(String sessionId) async {
    final response = await _supabase
        .from('set_entries')
        .select()
        .eq('workout_session_id', sessionId)
        .order('exercise_id')
        .order('set_number');

    return (response as List)
        .map((json) => SetEntryDto.fromJson(json))
        .toList();
  }

  @override
  Stream<List<SetEntryDto>> watchSetEntriesBySession(String sessionId) {
    return _supabase
        .from('set_entries')
        .stream(primaryKey: ['id'])
        .eq('workout_session_id', sessionId)
        .order('exercise_id')
        .order('set_number')
        .map((data) => data.map((json) => SetEntryDto.fromJson(json)).toList());
  }

  @override
  Future<SetEntryDto> createSetEntry(SetEntryDto entry) async {
    final response = await _supabase
        .from('set_entries')
        .insert(entry.toJson())
        .select()
        .single();

    return SetEntryDto.fromJson(response);
  }

  @override
  Future<void> updateSetEntry(SetEntryDto entry) async {
    await _supabase
        .from('set_entries')
        .update(entry.toJson())
        .eq('id', entry.id);
  }

  @override
  Future<void> deleteSetEntry(String id) async {
    await _supabase.from('set_entries').delete().eq('id', id);
  }

  @override
  Future<List<WorkoutTemplateDto>> getWorkoutTemplates() async {
    final response =
        await _supabase.from('workout_templates').select().order('name');

    return (response as List)
        .map((json) => WorkoutTemplateDto.fromJson(json))
        .toList();
  }

  @override
  Stream<List<WorkoutTemplateDto>> watchWorkoutTemplates() {
    return _supabase
        .from('workout_templates')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) =>
            data.map((json) => WorkoutTemplateDto.fromJson(json)).toList());
  }

  @override
  Future<WorkoutTemplateDto?> getWorkoutTemplateById(String id) async {
    final response = await _supabase
        .from('workout_templates')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? WorkoutTemplateDto.fromJson(response) : null;
  }

  @override
  Future<WorkoutTemplateDto> createWorkoutTemplate(
      WorkoutTemplateDto template) async {
    final response = await _supabase
        .from('workout_templates')
        .insert(template.toJson())
        .select()
        .single();

    return WorkoutTemplateDto.fromJson(response);
  }

  @override
  Future<void> updateWorkoutTemplate(WorkoutTemplateDto template) async {
    await _supabase
        .from('workout_templates')
        .update(template.toJson())
        .eq('id', template.id);
  }

  @override
  Future<void> deleteWorkoutTemplate(String id) async {
    await _supabase.from('workout_templates').delete().eq('id', id);
  }
}

/// Web implementation of ExerciseRepository using Supabase directly
class WebExerciseRepository implements ExerciseRepository {
  final SupabaseClient _supabase;

  WebExerciseRepository(this._supabase);

  @override
  Stream<List<ExerciseDto>> watchExercises() {
    return _supabase
        .from('exercises')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) => data.map((json) => ExerciseDto.fromJson(json)).toList());
  }

  @override
  Future<List<ExerciseDto>> getExercises() async {
    final response = await _supabase.from('exercises').select().order('name');

    return (response as List)
        .map((json) => ExerciseDto.fromJson(json))
        .toList();
  }

  @override
  Future<ExerciseDto?> getExerciseById(String id) async {
    final response =
        await _supabase.from('exercises').select().eq('id', id).maybeSingle();

    return response != null ? ExerciseDto.fromJson(response) : null;
  }

  @override
  Future<List<ExerciseDto>> searchExercises(String query) async {
    final response = await _supabase
        .from('exercises')
        .select()
        .or('name.ilike.%$query%,primary_muscle_group.ilike.%$query%')
        .order('name');

    return (response as List)
        .map((json) => ExerciseDto.fromJson(json))
        .toList();
  }

  @override
  Future<ExerciseDto> createExercise(ExerciseDto exercise) async {
    final response = await _supabase
        .from('exercises')
        .insert(exercise.toJson())
        .select()
        .single();

    return ExerciseDto.fromJson(response);
  }

  @override
  Future<void> updateExercise(ExerciseDto exercise) async {
    await _supabase
        .from('exercises')
        .update(exercise.toJson())
        .eq('id', exercise.id);
  }

  @override
  Future<void> deleteExercise(String id) async {
    await _supabase.from('exercises').delete().eq('id', id);
  }

  @override
  Future<List<String>> getFavoriteExerciseIds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('exercise_favorites')
        .select('exercise_id')
        .eq('user_id', userId);

    return (response as List)
        .map((json) => json['exercise_id'] as String)
        .toList();
  }

  @override
  Future<void> addToFavorites(String exerciseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('exercise_favorites').insert({
      'user_id': userId,
      'exercise_id': exerciseId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeFromFavorites(String exerciseId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('exercise_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('exercise_id', exerciseId);
  }
}
