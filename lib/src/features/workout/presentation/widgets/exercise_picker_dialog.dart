import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';

class ExercisePickerDialog extends ConsumerStatefulWidget {
  const ExercisePickerDialog({super.key});

  @override
  ConsumerState<ExercisePickerDialog> createState() =>
      _ExercisePickerDialogState();
}

class _ExercisePickerDialogState extends ConsumerState<ExercisePickerDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  Exercise? _selectedExercise;

  // Exercise settings
  double? _initialWeight;
  int _restTimerSeconds = 90;
  bool _isAssisted = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseSearchProvider(_searchQuery));
    final categoriesAsync = ref.watch(exerciseCategoriesProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Add Exercise',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Category Filter
                  categoriesAsync.when(
                    data: (categories) => SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected ? category : null;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Exercise List
            Expanded(
              child: exercisesAsync.when(
                data: (exercises) {
                  final filteredExercises =
                      _selectedCategory == null || _selectedCategory == 'All'
                          ? exercises
                          : exercises
                              .where((e) =>
                                  e.category.toLowerCase() ==
                                  _selectedCategory!.toLowerCase())
                              .toList();

                  if (filteredExercises.isEmpty) {
                    return const Center(
                      child: Text('No exercises found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      final isSelected = _selectedExercise?.id == exercise.id;

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          exercise.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${exercise.primaryMuscleGroup.toUpperCase()} • ${exercise.category}',
                          style: TextStyle(fontSize: 12),
                        ),
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedExercise = exercise;
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading exercises: $error'),
                ),
              ),
            ),

            // Exercise Settings (shown when exercise is selected)
            if (_selectedExercise != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exercise Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Initial Weight (optional)
                    if (_selectedExercise!.exerciseType == 'reps')
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Starting Weight (optional)',
                          hintText: 'e.g., 20',
                          suffixText: 'kg',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _initialWeight = double.tryParse(value);
                        },
                      ),

                    if (_selectedExercise!.exerciseType == 'reps')
                      const SizedBox(height: 12),

                    // Rest Timer
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Rest Timer',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _restTimerSeconds > 15
                              ? () {
                                  setState(() {
                                    _restTimerSeconds -= 15;
                                  });
                                }
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_restTimerSeconds}s',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              _restTimerSeconds += 15;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Assisted Toggle (for bodyweight exercises)
                    if (_selectedExercise!.isBodyweight)
                      SwitchListTile(
                        title: const Text('Assisted'),
                        subtitle: const Text(
                            'Use assistance (e.g., resistance band)'),
                        value: _isAssisted,
                        onChanged: (value) {
                          setState(() {
                            _isAssisted = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedExercise == null
                          ? null
                          : () {
                              Navigator.of(context).pop({
                                'exercise': _selectedExercise,
                                'initialWeight': _initialWeight,
                                'restTimerSeconds': _restTimerSeconds,
                                'isAssisted': _isAssisted,
                              });
                            },
                      child: const Text('Add Exercise'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
