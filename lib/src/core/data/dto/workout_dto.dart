import 'package:equatable/equatable.dart';

/// Platform-agnostic workout session data model
/// Can be used on both mobile (from Drift) and web (from Supabase)
class WorkoutSessionDto extends Equatable {
  const WorkoutSessionDto({
    required this.id,
    required this.name,
    required this.startedAt,
    required this.createdAt,
    required this.updatedAt,
    this.templateId,
    this.notes,
    this.completedAt,
    this.totalDurationSeconds,
    this.totalVolume = 0.0,
    this.totalTonnage = 0.0,
    this.totalSets = 0,
    this.totalReps = 0,
  });

  factory WorkoutSessionDto.fromJson(Map<String, dynamic> json) =>
      WorkoutSessionDto(
        id: json['id'] as String,
        templateId: json['template_id'] as String?,
        name: json['name'] as String,
        notes: json['notes'] as String?,
        startedAt: DateTime.parse(json['started_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        totalDurationSeconds: json['total_duration_seconds'] as int?,
        totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
        totalTonnage: (json['total_tonnage'] as num?)?.toDouble() ?? 0.0,
        totalSets: (json['total_sets'] as int?) ?? 0,
        totalReps: (json['total_reps'] as int?) ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
  final String id;
  final String? templateId;
  final String name;
  final String? notes;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? totalDurationSeconds;
  final double totalVolume;
  final double totalTonnage;
  final int totalSets;
  final int totalReps;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'template_id': templateId,
    'name': name,
    'notes': notes,
    'started_at': startedAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'total_duration_seconds': totalDurationSeconds,
    'total_volume': totalVolume,
    'total_tonnage': totalTonnage,
    'total_sets': totalSets,
    'total_reps': totalReps,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    templateId,
    name,
    notes,
    startedAt,
    completedAt,
    totalDurationSeconds,
    totalVolume,
    totalTonnage,
    totalSets,
    totalReps,
    createdAt,
    updatedAt,
  ];
}

/// Platform-agnostic set entry data model
class SetEntryDto extends Equatable {
  const SetEntryDto({
    required this.id,
    required this.workoutSessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.createdAt,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.distance,
    this.assistanceWeight,
    this.addedWeight,
    this.rpe,
    this.notes,
    this.completed = false,
  });

  factory SetEntryDto.fromJson(Map<String, dynamic> json) => SetEntryDto(
    id: json['id'] as String,
    workoutSessionId: json['workout_session_id'] as String,
    exerciseId: json['exercise_id'] as String,
    setNumber: json['set_number'] as int,
    weight: (json['weight'] as num?)?.toDouble(),
    reps: json['reps'] as int?,
    durationSeconds: json['duration_seconds'] as int?,
    distance: (json['distance'] as num?)?.toDouble(),
    assistanceWeight: (json['assistance_weight'] as num?)?.toDouble(),
    addedWeight: (json['added_weight'] as num?)?.toDouble(),
    rpe: json['rpe'] as int?,
    notes: json['notes'] as String?,
    completed: (json['completed'] as bool?) ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
  final String id;
  final String workoutSessionId;
  final String exerciseId;
  final int setNumber;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final double? distance;
  final double? assistanceWeight;
  final double? addedWeight;
  final int? rpe;
  final String? notes;
  final bool completed;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'workout_session_id': workoutSessionId,
    'exercise_id': exerciseId,
    'set_number': setNumber,
    'weight': weight,
    'reps': reps,
    'duration_seconds': durationSeconds,
    'distance': distance,
    'assistance_weight': assistanceWeight,
    'added_weight': addedWeight,
    'rpe': rpe,
    'notes': notes,
    'completed': completed,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    workoutSessionId,
    exerciseId,
    setNumber,
    weight,
    reps,
    durationSeconds,
    distance,
    assistanceWeight,
    addedWeight,
    rpe,
    notes,
    completed,
    createdAt,
  ];
}

/// Platform-agnostic workout template data model
class WorkoutTemplateDto extends Equatable {
  const WorkoutTemplateDto({
    required this.id,
    required this.name,
    required this.exerciseIds,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.folderId,
  });

  factory WorkoutTemplateDto.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplateDto(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        folderId: json['folder_id'] as String?,
        exerciseIds:
            (json['exercise_ids'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
  final String id;
  final String name;
  final String? description;
  final String? folderId;
  final List<String> exerciseIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'folder_id': folderId,
    'exercise_ids': exerciseIds,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    folderId,
    exerciseIds,
    createdAt,
    updatedAt,
  ];
}

/// Platform-agnostic exercise data model
class ExerciseDto extends Equatable {
  const ExerciseDto({
    required this.id,
    required this.name,
    required this.primaryMuscleGroup,
    required this.equipmentType,
    required this.category,
    required this.difficulty,
    this.description,
    this.secondaryMuscleGroups = const [],
    this.isCustom = false,
  });

  factory ExerciseDto.fromJson(Map<String, dynamic> json) => ExerciseDto(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    primaryMuscleGroup: json['primary_muscle_group'] as String,
    secondaryMuscleGroups:
        (json['secondary_muscle_groups'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    equipmentType: json['equipment_type'] as String,
    category: json['category'] as String,
    difficulty: json['difficulty'] as String,
    isCustom: (json['is_custom'] as bool?) ?? false,
  );
  final String id;
  final String name;
  final String? description;
  final String primaryMuscleGroup;
  final List<String> secondaryMuscleGroups;
  final String equipmentType;
  final String category;
  final String difficulty;
  final bool isCustom;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'primary_muscle_group': primaryMuscleGroup,
    'secondary_muscle_groups': secondaryMuscleGroups,
    'equipment_type': equipmentType,
    'category': category,
    'difficulty': difficulty,
    'is_custom': isCustom,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    primaryMuscleGroup,
    secondaryMuscleGroups,
    equipmentType,
    category,
    difficulty,
    isCustom,
  ];
}
