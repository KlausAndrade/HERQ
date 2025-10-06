import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';
import '../providers/exercise_providers.dart';

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedMuscleGroup = 'Chest';
  String _selectedEquipment = 'Barbell';
  String _selectedCategory = 'strength';
  String _selectedDifficulty = 'intermediate';
  String _selectedExerciseType = 'reps';
  bool _isBodyweight = false;
  final List<String> _selectedSecondaryMuscles = [];
  final List<String> _selectedTags = [];
  
  // Variant fields
  bool _isVariant = false;
  String? _parentExerciseId;
  String? _variantType;

  bool _isLoading = false;

  // Muscle groups
  final List<String> _muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Glutes',
    'Calves',
    'Forearms',
    'Traps',
  ];

  // Equipment options
  final List<String> _equipmentOptions = [
    'Barbell',
    'Dumbbell',
    'Machine',
    'Bodyweight',
    'Cable',
    'Kettlebell',
    'Resistance Band',
    'Medicine Ball',
    'None',
  ];

  // Categories
  final List<String> _categories = [
    'strength',
    'calisthenics',
    'yoga',
    'cardio',
    'flexibility',
  ];

  // Difficulties
  final List<String> _difficulties = [
    'beginner',
    'intermediate',
    'advanced',
    'expert',
  ];

  // Exercise types
  final List<String> _exerciseTypes = [
    'reps',
    'timer',
    'body_weighted',
    'assisted',
  ];

  // Common tags
  final List<String> _availableTags = [
    'Compound',
    'Isolation',
    'Push',
    'Pull',
    'Unilateral',
    'Bilateral',
    'Core',
    'Stability',
    'Power',
    'Hypertrophy',
  ];
  
  // Variant types
  final List<String> _variantTypes = [
    'progression',
    'regression',
    'assisted',
    'weighted',
    'equipment',
    'strict',
    'angle',
    'tempo',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before saving'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Additional check for empty name
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final database = ref.read(databaseProvider);
      if (database == null) {
        throw Exception('Database not available');
      }

      // Generate unique ID with custom prefix
      final exerciseId = 'custom_${const Uuid().v4()}';

      // Create exercise
      await database.into(database.exercises).insert(
            ExercisesCompanion.insert(
              id: exerciseId,
              name: _nameController.text.trim(),
              primaryMuscleGroup: _selectedMuscleGroup,
              secondaryMuscleGroups: _selectedSecondaryMuscles,
              equipment: _selectedEquipment,
              instructions: _instructionsController.text.trim().isEmpty
                  ? 'No instructions provided'
                  : _instructionsController.text.trim(),
              tags: _selectedTags,
              isBodyweight: Value(_isBodyweight),
              exerciseType: Value(_selectedExerciseType),
              category: Value(_selectedCategory),
              difficulty: Value(_selectedDifficulty),
              parentExerciseId: Value(_isVariant ? _parentExerciseId : null),
              variantType: Value(_isVariant ? _variantType : null),
            ),
          );

      // Refresh exercises
      ref.invalidate(exercisesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exercise "${_nameController.text}" created!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Exercise'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveExercise,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Exercise Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name *',
                hintText: 'e.g., Barbell Bench Press',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an exercise name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Primary Muscle Group
            DropdownButtonFormField<String>(
              value: _selectedMuscleGroup,
              decoration: const InputDecoration(
                labelText: 'Primary Muscle Group *',
                border: OutlineInputBorder(),
              ),
              items: _muscleGroups.map((muscle) {
                return DropdownMenuItem(
                  value: muscle,
                  child: Text(muscle),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMuscleGroup = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Secondary Muscle Groups
            _buildMultiSelectChips(
              title: 'Secondary Muscle Groups',
              options: _muscleGroups
                  .where((m) => m != _selectedMuscleGroup)
                  .toList(),
              selectedValues: _selectedSecondaryMuscles,
              onChanged: (value) {
                setState(() {
                  if (_selectedSecondaryMuscles.contains(value)) {
                    _selectedSecondaryMuscles.remove(value);
                  } else {
                    _selectedSecondaryMuscles.add(value);
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Equipment
            DropdownButtonFormField<String>(
              value: _selectedEquipment,
              decoration: const InputDecoration(
                labelText: 'Equipment *',
                border: OutlineInputBorder(),
              ),
              items: _equipmentOptions.map((equipment) {
                return DropdownMenuItem(
                  value: equipment,
                  child: Text(equipment),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedEquipment = value;
                    _isBodyweight = value == 'Bodyweight' || value == 'None';
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category[0].toUpperCase() + category.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Exercise Type
            DropdownButtonFormField<String>(
              value: _selectedExerciseType,
              decoration: const InputDecoration(
                labelText: 'Exercise Type *',
                border: OutlineInputBorder(),
              ),
              items: _exerciseTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type.replaceAll('_', ' ').split(' ').map((word) {
                      return word[0].toUpperCase() + word.substring(1);
                    }).join(' '),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedExerciseType = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Difficulty
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty *',
                border: OutlineInputBorder(),
              ),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(
                    difficulty[0].toUpperCase() + difficulty.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDifficulty = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Tags
            _buildMultiSelectChips(
              title: 'Tags',
              options: _availableTags,
              selectedValues: _selectedTags,
              onChanged: (value) {
                setState(() {
                  if (_selectedTags.contains(value)) {
                    _selectedTags.remove(value);
                  } else {
                    _selectedTags.add(value);
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Is Bodyweight
            CheckboxListTile(
              value: _isBodyweight,
              onChanged: (value) {
                setState(() => _isBodyweight = value ?? false);
              },
              title: const Text('Bodyweight Exercise'),
              subtitle: const Text('Check if this exercise uses body weight'),
            ),
            const SizedBox(height: 16),

            // Variant Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.compare_arrows,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exercise Variant',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Is this a variation of another exercise?',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _isVariant,
                      onChanged: (value) {
                        setState(() {
                          _isVariant = value;
                          if (!value) {
                            _parentExerciseId = null;
                            _variantType = null;
                          }
                        });
                      },
                      title: const Text('This is a variant'),
                      subtitle: const Text('Set parent exercise and variant type'),
                    ),
                    if (_isVariant) ...[
                      const SizedBox(height: 16),
                      // Parent Exercise Selector
                      _buildParentExerciseSelector(),
                      const SizedBox(height: 16),
                      // Variant Type
                      DropdownButtonFormField<String>(
                        value: _variantType,
                        decoration: const InputDecoration(
                          labelText: 'Variant Type *',
                          border: OutlineInputBorder(),
                          helperText: 'How does this variant differ?',
                        ),
                        items: _variantTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getVariantColorPreview(type),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type[0].toUpperCase() + type.substring(1),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _variantType = value);
                        },
                        validator: _isVariant
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a variant type';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                hintText: 'How to perform this exercise...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildParentExerciseSelector() {
    final parentExercisesAsync = ref.watch(parentExercisesProvider);

    return parentExercisesAsync.when(
      data: (exercises) {
        return DropdownButtonFormField<String>(
          value: _parentExerciseId,
          decoration: const InputDecoration(
            labelText: 'Parent Exercise *',
            border: OutlineInputBorder(),
            helperText: 'Which exercise is this a variant of?',
          ),
          items: exercises.map((exercise) {
            return DropdownMenuItem(
              value: exercise.id,
              child: Text(exercise.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _parentExerciseId = value);
          },
          validator: _isVariant
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a parent exercise';
                  }
                  return null;
                }
              : null,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text(
        'Error loading exercises: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Color _getVariantColorPreview(String variantType) {
    switch (variantType.toLowerCase()) {
      case 'progression':
        return Colors.green;
      case 'regression':
        return Colors.amber;
      case 'assisted':
        return Colors.blue;
      case 'weighted':
        return Colors.deepPurple;
      case 'equipment':
        return Colors.teal;
      case 'strict':
        return Colors.indigo;
      case 'angle':
        return Colors.orange;
      case 'tempo':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
