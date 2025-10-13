/// Utility for automatically assigning exercise types based on exercise name, equipment, and category
library;

import '../constants/exercise_types.dart';

class ExerciseTypeMapper {
  /// Assign exercise type based on exercise properties
  /// Returns the most appropriate ExerciseType based on name, equipment, and category
  static ExerciseType assignExerciseType({
    required String name,
    String? equipment,
    String? category,
  }) {
    final nameLower = name.toLowerCase().trim();
    final equipmentLower = equipment?.toLowerCase().trim() ?? '';
    final categoryLower = category?.toLowerCase().trim() ?? '';

    // Duration-based exercises (holds, planks, isometric)
    if (_isDurationExercise(nameLower)) {
      return ExerciseType.duration;
    }

    // Distance & Duration (cardio)
    if (_isDistanceDurationExercise(nameLower, categoryLower)) {
      return ExerciseType.distanceDuration;
    }

    // Duration & Weight (loaded carries for time)
    if (_isDurationWeightExercise(nameLower)) {
      return ExerciseType.durationWeight;
    }

    // Weight & Distance (loaded carries for distance)
    if (_isWeightDistanceExercise(nameLower)) {
      return ExerciseType.weightDistance;
    }

    // Weighted Bodyweight (bodyweight + additional load)
    if (_isWeightedBodyweightExercise(nameLower)) {
      return ExerciseType.weightedBodyweight;
    }

    // Assisted Bodyweight (machine or band assistance)
    if (_isAssistedBodyweightExercise(nameLower, equipmentLower)) {
      return ExerciseType.assistedBodyweight;
    }

    // Bodyweight Reps (no weight, just reps)
    if (_isBodyweightRepsExercise(nameLower, equipmentLower, categoryLower)) {
      return ExerciseType.bodyweightReps;
    }

    // Default: Weight & Reps (most common)
    return ExerciseType.weightReps;
  }

  /// Check if exercise is duration-based (holds, planks, isometric)
  static bool _isDurationExercise(String name) {
    final durationKeywords = [
      'plank',
      'hold',
      'wall sit',
      'dead hang',
      'hollow hold',
      'l-sit',
      'l sit',
      'handstand',
      'hollow body',
      'arch hold',
      'support hold',
      'static hold',
      'isometric',
      'bridge hold',
      'horse stance',
    ];

    return durationKeywords.any((keyword) => name.contains(keyword));
  }

  /// Check if exercise is distance & duration (cardio)
  static bool _isDistanceDurationExercise(String name, String category) {
    final distanceDurationKeywords = [
      'run',
      'running',
      'jog',
      'jogging',
      'sprint',
      'row',
      'rowing',
      'swim',
      'swimming',
      'cycle',
      'cycling',
      'bike',
      'biking',
      'elliptical',
      'treadmill',
      'ski erg',
      'assault bike',
      'air bike',
    ];

    final isCardioCategory = category.contains('cardio') || category.contains('conditioning');
    final hasDistanceKeyword = distanceDurationKeywords.any((keyword) => name.contains(keyword));

    return hasDistanceKeyword || isCardioCategory;
  }

  /// Check if exercise is duration & weight (loaded carries for time)
  static bool _isDurationWeightExercise(String name) {
    final durationWeightKeywords = [
      'farmer walk',
      'farmers walk',
      'sled push',
      'sled pull',
      'prowler push',
      'weighted carry time',
    ];

    // Only specific exercises that are explicitly timed carries
    return durationWeightKeywords.any((keyword) => name.contains(keyword));
  }

  /// Check if exercise is weight & distance (loaded carries for distance)
  static bool _isWeightDistanceExercise(String name) {
    final weightDistanceKeywords = [
      'farmer carry',
      'farmers carry',
      'waiter carry',
      'waiters carry',
      'overhead carry',
      'suitcase carry',
      'goblet carry',
      'yoke walk',
      'yoke carry',
    ];

    return weightDistanceKeywords.any((keyword) => name.contains(keyword));
  }

  /// Check if exercise is weighted bodyweight
  static bool _isWeightedBodyweightExercise(String name) {
    final weightedKeywords = [
      'weighted pull',
      'weighted pull-up',
      'weighted pullup',
      'weighted chin',
      'weighted chin-up',
      'weighted chinup',
      'weighted dip',
      'weighted push',
      'weighted push-up',
      'weighted pushup',
      'weighted muscle',
      'weighted pistol',
      '+weight',
      '+ weight',
    ];

    return weightedKeywords.any((keyword) => name.contains(keyword));
  }

  /// Check if exercise is assisted bodyweight
  static bool _isAssistedBodyweightExercise(String name, String equipment) {
    final assistedKeywords = [
      'assisted pull',
      'assisted chin',
      'assisted dip',
      'assisted muscle',
      'band pull',
      'band chin',
      'band dip',
      'machine pull',
      'machine chin',
      'machine dip',
    ];

    final hasAssistedKeyword = assistedKeywords.any((keyword) => name.contains(keyword));
    final hasAssistedEquipment = equipment.contains('assisted') || 
                                  equipment.contains('machine') || 
                                  equipment.contains('band');

    // Must have assisted keyword in name or be a bodyweight exercise with assisted equipment
    return hasAssistedKeyword || (hasAssistedEquipment && _isBodyweightExerciseBase(name));
  }

  /// Check if exercise is bodyweight reps (no weight, just reps)
  static bool _isBodyweightRepsExercise(String name, String equipment, String category) {
    // Check if it's a calisthenics category
    final isCalisthenics = category.contains('calisthenics') || category.contains('bodyweight');
    
    // Check if equipment is bodyweight
    final isBodyweightEquipment = equipment.contains('bodyweight') || 
                                   equipment.contains('none') || 
                                   equipment.isEmpty;

    // Common bodyweight exercises
    final bodyweightKeywords = [
      'push-up',
      'pushup',
      'push up',
      'pull-up',
      'pullup',
      'pull up',
      'chin-up',
      'chinup',
      'chin up',
      'dip',
      'dips',
      'muscle-up',
      'muscle up',
      'burpee',
      'squat' // bodyweight squat
      'lunge',
      'jump',
      'jumping',
      'pistol squat',
      'sissy squat',
      'nordic curl',
      'nordic hamstring',
      'inverted row',
      'bodyweight',
      'air squat',
      'box jump',
      'tuck',
      'hollow body',
      'crunch',
      'sit-up',
      'sit up',
      'leg raise',
      'knee raise',
      'toe to bar',
      'toes to bar',
      'mountain climber',
    ];

    final hasBodyweightKeyword = bodyweightKeywords.any((keyword) => name.contains(keyword));

    // Bodyweight if: calisthenics category, bodyweight equipment, or has bodyweight keyword
    // BUT not if it's weighted or assisted
    final isWeighted = _isWeightedBodyweightExercise(name);
    final isAssisted = _isAssistedBodyweightExercise(name, equipment);

    return (isCalisthenics || isBodyweightEquipment || hasBodyweightKeyword) && 
           !isWeighted && 
           !isAssisted;
  }

  /// Check if base exercise is a bodyweight movement (for assisted detection)
  static bool _isBodyweightExerciseBase(String name) {
    final bodyweightBases = [
      'pull',
      'chin',
      'dip',
      'muscle',
      'push',
      'squat',
    ];

    return bodyweightBases.any((base) => name.contains(base));
  }

  /// Get a human-readable description of why an exercise was assigned a type
  static String getAssignmentReason({
    required String name,
    String? equipment,
    String? category,
  }) {
    final type = assignExerciseType(name: name, equipment: equipment, category: category);

    switch (type) {
      case ExerciseType.duration:
        return 'Time-based exercise (hold or isometric)';
      case ExerciseType.distanceDuration:
        return 'Cardio exercise with distance tracking';
      case ExerciseType.durationWeight:
        return 'Loaded carry for time';
      case ExerciseType.weightDistance:
        return 'Loaded carry for distance';
      case ExerciseType.weightedBodyweight:
        return 'Bodyweight exercise with additional weight';
      case ExerciseType.assistedBodyweight:
        return 'Bodyweight exercise with assistance';
      case ExerciseType.bodyweightReps:
        return 'Bodyweight exercise';
      case ExerciseType.weightReps:
        return 'Standard weighted exercise';
    }
  }
}

