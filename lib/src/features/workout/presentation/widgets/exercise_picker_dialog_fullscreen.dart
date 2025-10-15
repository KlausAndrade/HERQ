import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';

class ExercisePickerDialogFullscreen extends ConsumerStatefulWidget {
  const ExercisePickerDialogFullscreen({super.key});

  @override
  ConsumerState<ExercisePickerDialogFullscreen> createState() =>
      _ExercisePickerDialogFullscreenState();
}

class _ExercisePickerDialogFullscreenState
    extends ConsumerState<ExercisePickerDialogFullscreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  Exercise? _selectedExercise;

  // Exercise settings
  double? _initialWeight;
  final int _restTimerSeconds = 90;
  final bool _isAssisted = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseSearchProvider(_searchQuery));
    final categoriesAsync = ref.watch(exerciseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)!.addExercise),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedExercise != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'exercise': _selectedExercise,
                  'initialWeight': _initialWeight,
                  'restTimerSeconds': _restTimerSeconds,
                  'isAssisted': _isAssisted,
                });
              },
              child: Text(S.of(context)!.add),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: S.of(context)!.searchExercises,
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
                                _selectedCategory = selected ? category : null;
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
                final filteredExercises = _selectedCategory == null ||
                        _selectedCategory == S.of(context)!.all
                    ? exercises
                    : exercises
                        .where(
                          (e) =>
                              e.category.toLowerCase() ==
                              _selectedCategory!.toLowerCase(),
                        )
                        .toList();

                if (filteredExercises.isEmpty) {
                  return Center(
                    child: Text(S.of(context)!.noExercisesFound),
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
                                  .withAlpha((0.1 * 255).round()),
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
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${exercise.primaryMuscleGroup.toUpperCase()} • ${exercise.category}',
                        style: const TextStyle(fontSize: 12),
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
                child: Text('${S.of(context)!.errorLoadingExercises}: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
