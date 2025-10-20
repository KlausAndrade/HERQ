import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';
import '../../../exercises/presentation/providers/exercise_unified_provider.dart';

class MultiExercisePickerDialog extends ConsumerStatefulWidget {
  const MultiExercisePickerDialog({super.key});

  @override
  ConsumerState<MultiExercisePickerDialog> createState() =>
      _MultiExercisePickerDialogState();
}

class _MultiExercisePickerDialogState
    extends ConsumerState<MultiExercisePickerDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  final Set<Exercise> _selectedExercises = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use unified provider that works on both web and mobile
    final exercisesAsync = kIsWeb 
        ? ref.watch(exerciseSearchUnifiedProvider(_searchQuery))
        : ref.watch(exerciseSearchProvider(_searchQuery));
    final categoriesAsync = kIsWeb
        ? ref.watch(exerciseCategoriesUnifiedProvider)
        : ref.watch(exerciseCategoriesProvider);

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
                        'Add Exercises',
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
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                              .where((e) {
                                final category = kIsWeb 
                                    ? (e as Map<String, dynamic>)['category'] 
                                    : (e as Exercise).category;
                                return category.toString().toLowerCase() ==
                                    _selectedCategory!.toLowerCase();
                              })
                              .toList();
                  if (filteredExercises.isEmpty) {
                    return const Center(
                      child: Text('No exercises found'),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exerciseData = filteredExercises[index];
                      
                      // Handle both web (Map) and mobile (Exercise object)
                      final String name, category, muscleGroup;
                      final Exercise? exerciseObj;
                      
                      if (kIsWeb) {
                        final map = exerciseData as Map<String, dynamic>;
                        name = map['name'] as String;
                        category = map['category'] as String;
                        muscleGroup = map['primary_muscle_group'] as String? ?? category;
                        exerciseObj = mapToExercise(map);
                      } else {
                        exerciseObj = exerciseData as Exercise;
                        name = exerciseObj.name;
                        category = exerciseObj.category;
                        muscleGroup = exerciseObj.primaryMuscleGroup;
                      }
                      
                      final isSelected = exerciseObj != null && _selectedExercises.contains(exerciseObj);
                      
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(name),
                        subtitle: Text(
                          '${muscleGroup.toUpperCase()} • $category',
                        ),
                        onChanged: exerciseObj == null ? null : (selected) {
                          setState(() {
                            if (selected ?? false) {
                              if (exerciseObj != null) {
                                _selectedExercises.add(exerciseObj);
                              }
                            } else {
                              _selectedExercises.remove(exerciseObj);
                            }
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
                      onPressed: _selectedExercises.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).pop({
                                'exercises': _selectedExercises.toList(),
                              });
                            },
                      child: const Text('Add'),
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
