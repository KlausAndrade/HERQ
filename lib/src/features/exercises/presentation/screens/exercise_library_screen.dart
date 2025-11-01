import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/database/database.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/widgets/animated_fab.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../providers/exercise_favorites_provider.dart';
import '../providers/exercise_providers.dart';
import '../providers/exercise_unified_provider.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String _selectedMuscleGroup = 'All';
  String _selectedCategory = 'All';
  final String _searchQuery = '';
  bool _showVariants = false;
  bool _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final muscleGroupsAsync = ref.watch(muscleGroupsProvider);
    final categoriesAsync = kIsWeb
        ? ref.watch(exerciseCategoriesUnifiedProvider)
        : ref.watch(exerciseCategoriesProvider);
    final isAdminMode = ref.watch(currentAdminModeProvider);

    final exercisesAsync = _getFilteredExercises();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(S.of(context)!.exerciseLibrary),
            ),
            if (isAdminMode) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: ExerciseSearchDelegate(ref),
              );
            },
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'progressions') {
                _showProgressionsBottomSheet(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'progressions',
                child: Row(
                  children: [
                    const Icon(Icons.trending_up),
                    const SizedBox(width: 8),
                    Text(S.of(context)!.viewProgressions),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Favorites and variants toggles as chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(S.of(context)!.favorites),
                      avatar: Icon(
                        Icons.favorite,
                        size: 16,
                        color: _showOnlyFavorites ? Colors.white : Colors.red,
                      ),
                      selected: _showOnlyFavorites,
                      selectedColor: Colors.red.shade400,
                      onSelected: (selected) {
                        setState(() {
                          _showOnlyFavorites = selected;
                        });
                      },
                      showCheckmark: false,
                    ),
                    FilterChip(
                      label: Text(S.of(context)!.showVariants),
                      avatar: Icon(
                        Icons.repeat,
                        size: 16,
                        color: _showVariants
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                      selected: _showVariants,
                      onSelected: (selected) {
                        setState(() {
                          _showVariants = selected;
                        });
                      },
                      showCheckmark: false,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Category Filter Chips
                categoriesAsync.when(
                  data: (categories) => SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                                _selectedMuscleGroup =
                                    'All'; // Reset muscle group filter
                              });
                            },
                            avatar: _getCategoryIcon(category),
                          ),
                        );
                      },
                    ),
                  ),
                  loading: () => const SizedBox(height: 40),
                  error: (error, stack) => const SizedBox(height: 40),
                ),

                const SizedBox(height: 8),

                // Muscle Group Filter Chips
                muscleGroupsAsync.when(
                  data: (muscleGroups) => SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: muscleGroups.length,
                      itemBuilder: (context, index) {
                        final group = muscleGroups[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(group),
                            selected: _selectedMuscleGroup == group,
                            onSelected: (selected) {
                              setState(() {
                                _selectedMuscleGroup = group;
                                _selectedCategory =
                                    'All'; // Reset category filter
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  loading: () => const SizedBox(height: 40),
                  error: (error, stack) => const SizedBox(height: 40),
                ),
              ],
            ),
          ),

          // Exercise List
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return EmptyState(
                    title: S.of(context)!.noExercisesFound,
                    subtitle: S.of(context)!.tryAdjustingFilters,
                    icon: Icons.fitness_center_outlined,
                    actionText: S.of(context)!.createExercise,
                    onAction: () => context.push('/exercises/create'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _ExerciseCard(
                      exercise: exercise,
                      onTap: () => context.go('/exercise/${exercise.id}'),
                      onEdit: isAdminMode || exercise.id.startsWith('custom_')
                          ? () => context
                              .push('/exercises/create?id=${exercise.id}')
                          : null,
                      isAdminMode: isAdminMode,
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 8,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: SkeletonListTile(),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context)!.errorLoadingExercises,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFAB(
        icon: Icons.add,
        onPressed: () => context.push('/exercises/create'),
        tooltip: S.of(context)!.createExercise,
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget? _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return const Icon(Icons.fitness_center, size: 16);
      case 'calisthenics':
        return const Icon(Icons.accessibility, size: 16);
      case 'yoga':
        return const Icon(Icons.self_improvement, size: 16);
      case 'cardio':
        return const Icon(Icons.directions_run, size: 16);
      default:
        return null;
    }
  }

  AsyncValue<List<Exercise>> _getFilteredExercises() {
    // Use unified provider for web, fallback to mobile providers
    if (kIsWeb) {
      final exercisesAsync = ref.watch(exercisesUnifiedProvider);
      return exercisesAsync.when(
        data: (exerciseData) {
          // Convert web data to Exercise objects
          List<Exercise> exercises = [];
          for (var data in exerciseData) {
            if (data is Map<String, dynamic>) {
              final exercise = mapToExercise(data);
              if (exercise != null) {
                exercises.add(exercise);
              }
            } else if (data is Exercise) {
              exercises.add(data);
            }
          }

          var filtered = exercises;

          // Apply category filter
          if (_selectedCategory != 'All') {
            filtered = filtered
                .where(
                  (e) =>
                      e.category.toLowerCase() ==
                      _selectedCategory.toLowerCase(),
                )
                .toList();
          }

          // Apply muscle group filter
          if (_selectedMuscleGroup != 'All') {
            filtered = filtered
                .where(
                  (e) =>
                      e.primaryMuscleGroup.toLowerCase() ==
                      _selectedMuscleGroup.toLowerCase(),
                )
                .toList();
          }

          // Apply search query
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            filtered = filtered
                .where(
                  (e) =>
                      e.name.toLowerCase().contains(query) ||
                      e.primaryMuscleGroup.toLowerCase().contains(query) ||
                      e.equipment.toLowerCase().contains(query),
                )
                .toList();
          }

          // Apply variants filter
          if (!_showVariants) {
            filtered =
                filtered.where((e) => e.parentExerciseId == null).toList();
          }

          return AsyncValue.data(filtered);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    }

    // Mobile: Use original logic
    // If showing favorites only
    if (_showOnlyFavorites) {
      final favoritesAsync = ref.watch(favoriteExercisesProvider);
      return favoritesAsync.when(
        data: (exercises) {
          var filtered = exercises;

          // Apply category filter
          if (_selectedCategory != 'All') {
            filtered = filtered
                .where(
                  (e) =>
                      e.category.toLowerCase() ==
                      _selectedCategory.toLowerCase(),
                )
                .toList();
          }

          // Apply muscle group filter
          if (_selectedMuscleGroup != 'All') {
            filtered = filtered
                .where(
                  (e) =>
                      e.primaryMuscleGroup.toLowerCase() ==
                      _selectedMuscleGroup.toLowerCase(),
                )
                .toList();
          }

          // Apply search query
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            filtered = filtered
                .where(
                  (e) =>
                      e.name.toLowerCase().contains(query) ||
                      e.primaryMuscleGroup.toLowerCase().contains(query) ||
                      e.equipment.toLowerCase().contains(query),
                )
                .toList();
          }

          // Apply variants filter
          if (!_showVariants) {
            filtered =
                filtered.where((e) => e.parentExerciseId == null).toList();
          }

          return AsyncValue.data(filtered);
        },
        loading: () => const AsyncValue.loading(),
        error: AsyncValue.error,
      );
    }

    if (_searchQuery.isNotEmpty) {
      return ref.watch(exerciseSearchProvider(_searchQuery));
    }

    if (_selectedCategory != 'All') {
      final categoryExercises = ref
          .watch(exercisesByCategoryProvider(_selectedCategory.toLowerCase()));
      if (!_showVariants) {
        return categoryExercises.whenData(
          (exercises) =>
              exercises.where((e) => e.parentExerciseId == null).toList(),
        );
      }
      return categoryExercises;
    }

    if (_selectedMuscleGroup != 'All') {
      final muscleExercises = ref.watch(
        exercisesByMuscleGroupProvider(_selectedMuscleGroup.toLowerCase()),
      );
      if (!_showVariants) {
        return muscleExercises.whenData(
          (exercises) =>
              exercises.where((e) => e.parentExerciseId == null).toList(),
        );
      }
      return muscleExercises;
    }

    final allExercises = ref.watch(exercisesProvider);
    if (!_showVariants) {
      return allExercises.whenData(
        (exercises) =>
            exercises.where((e) => e.parentExerciseId == null).toList(),
      );
    }
    return allExercises;
  }

  void _showProgressionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        S.of(context)!.exerciseProgressions,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _ExerciseProgressionsView(
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/workout-templates');
              break;
            case 2:
              context.go('/exercises');
              break;
            case 3:
              context.go('/progress');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: S.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center_outlined),
            activeIcon: const Icon(Icons.fitness_center),
            label: S.of(context)!.workouts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search),
            label: S.of(context)!.exercises,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up_outlined),
            activeIcon: const Icon(Icons.trending_up),
            label: S.of(context)!.progress,
          ),
        ],
      );
}

class _ExerciseCard extends ConsumerWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
    this.onEdit,
    this.isAdminMode = false,
  });

  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final bool isAdminMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteAsync = ref.watch(isExerciseFavorited(exercise.id));
    final favoritesNotifier = ref.read(favoritesNotifierProvider);

    return AppCard(
      heroTag: 'exercise-${exercise.id}',
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(context, exercise.category),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(exercise.category),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                exercise.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (exercise.parentExerciseId != null) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getVariantColor(context, exercise.variantType),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exercise.variantType?.toUpperCase() ?? 'VARIANT',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
            if (isAdminMode && !exercise.id.startsWith('custom_')) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${exercise.primaryMuscleGroup[0].toUpperCase() + exercise.primaryMuscleGroup.substring(1)} • ${exercise.equipment[0].toUpperCase() + exercise.equipment.substring(1).replaceAll('_', ' ')}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _DifficultyChip(difficulty: exercise.difficulty),
                _ExerciseTypeChip(type: exercise.exerciseType),
                if (exercise.isBodyweight)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BODYWEIGHT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favorite button
            isFavoriteAsync.when(
              data: (isFavorite) => IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () async {
                  try {
                    await favoritesNotifier.toggleFavorite(exercise.id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update favorite: $e'),
                        ),
                      );
                    }
                  }
                },
                tooltip:
                    isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),
              loading: () => const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            // Edit button (for custom exercises or admin mode) or chevron
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
                tooltip: isAdminMode
                    ? 'Edit exercise (Admin)'
                    : 'Edit custom exercise',
              )
            else
              const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'calisthenics':
        return Icons.accessibility;
      case 'yoga':
        return Icons.self_improvement;
      case 'cardio':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getCategoryColor(BuildContext context, String? category) {
    switch (category?.toLowerCase()) {
      case 'strength':
        return Colors.blue;
      case 'calisthenics':
        return Colors.orange;
      case 'yoga':
        return Colors.purple;
      case 'cardio':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getVariantColor(BuildContext context, String? variantType) {
    switch (variantType?.toLowerCase()) {
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
      default:
        return Colors.grey;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Exercise>('exercise', exercise));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onEdit', onEdit));
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});

  final String difficulty;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      case 'expert':
        color = Colors.deepPurple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('difficulty', difficulty));
  }
}

class _ExerciseTypeChip extends StatelessWidget {
  const _ExerciseTypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type.toLowerCase()) {
      case 'reps':
        icon = Icons.repeat;
        break;
      case 'timer':
        icon = Icons.timer;
        break;
      case 'body_weighted':
        icon = Icons.accessibility;
        break;
      case 'assisted':
        icon = Icons.support;
        break;
      default:
        icon = Icons.fitness_center;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            type.toUpperCase().replaceAll('_', ' '),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('type', type));
  }
}

class _ExerciseProgressionsView extends ConsumerWidget {
  const _ExerciseProgressionsView({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressionsAsync = ref.watch(exerciseProgressionsProvider);

    return progressionsAsync.when(
      data: (progressionsMap) {
        if (progressionsMap.isEmpty) {
          return const Center(
            child: Text('No exercise progressions found'),
          );
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: progressionsMap.length,
          itemBuilder: (context, index) {
            final entry = progressionsMap.entries.elementAt(index);
            final parent = entry.key;
            final variants = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(parent.category),
                          color: _getCategoryColor(context, parent.category),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            parent.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${variants.length + 1} variations',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Parent exercise
                    _ProgressionItem(
                      exercise: parent,
                      isParent: true,
                      onTap: () {
                        Navigator.of(context).pop(); // Close bottom sheet
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            context.go('/exercise/${parent.id}');
                          }
                        });
                      },
                    ),

                    // Variants
                    ...variants.map(
                      (variant) => _ProgressionItem(
                        exercise: variant,
                        isParent: false,
                        onTap: () {
                          Navigator.of(context).pop(); // Close bottom sheet
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (context.mounted) {
                              context.go('/exercise/${variant.id}');
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'calisthenics':
        return Icons.accessibility;
      case 'yoga':
        return Icons.self_improvement;
      case 'cardio':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getCategoryColor(BuildContext context, String? category) {
    switch (category?.toLowerCase()) {
      case 'strength':
        return Colors.blue;
      case 'calisthenics':
        return Colors.orange;
      case 'yoga':
        return Colors.purple;
      case 'cardio':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ScrollController>(
        'scrollController', scrollController));
  }
}

class _ProgressionItem extends StatelessWidget {
  const _ProgressionItem({
    required this.exercise,
    required this.isParent,
    required this.onTap,
  });

  final Exercise exercise;
  final bool isParent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: isParent ? 0 : 24, bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isParent
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                if (!isParent) ...[
                  const Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontWeight:
                              isParent ? FontWeight.bold : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _DifficultyChip(difficulty: exercise.difficulty),
                          if (!isParent && exercise.variantType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getVariantColor(exercise.variantType),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                exercise.variantType!.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      );

  Color _getVariantColor(String? variantType) {
    switch (variantType?.toLowerCase()) {
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
      default:
        return Colors.grey;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Exercise>('exercise', exercise));
    properties.add(DiagnosticsProperty<bool>('isParent', isParent));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }
}

class ExerciseSearchDelegate extends SearchDelegate<String> {
  ExerciseSearchDelegate(this.ref);
  final WidgetRef ref;

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        onPressed: () {
          close(context, '');
        },
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter exercise name to search'),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final exercisesAsync = ref.watch(exerciseSearchProvider(query));

        return exercisesAsync.when(
          data: (exercises) {
            if (exercises.isEmpty) {
              return const Center(
                child: Text('No exercises found'),
              );
            }

            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  leading: Icon(
                    exercise.isBodyweight
                        ? Icons.accessibility
                        : Icons.fitness_center,
                  ),
                  title: Text(exercise.name),
                  subtitle: Text(
                    '${exercise.primaryMuscleGroup[0].toUpperCase() + exercise.primaryMuscleGroup.substring(1)} • ${exercise.equipment[0].toUpperCase() + exercise.equipment.substring(1).replaceAll('_', ' ')}',
                  ),
                  onTap: () {
                    close(context, exercise.name);
                    context.go('/exercise/${exercise.id}');
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  }
}

/// Helper to convert web exercise map to Exercise object (for compatibility)
Exercise? mapToExercise(Map<String, dynamic> map) {
  try {
    print('🔍 Mapping exercise: ${map['name']}');

    // Handle equipment array - convert to comma-separated string
    String equipmentStr = '';
    if (map['equipment'] != null && map['equipment'] is List) {
      equipmentStr = (map['equipment'] as List).cast<String>().join(',');
    }

    // Handle secondary muscle groups
    List<String> secondaryMuscles = [];
    if (map['secondary_muscle_groups'] != null &&
        map['secondary_muscle_groups'] is List) {
      secondaryMuscles =
          (map['secondary_muscle_groups'] as List).cast<String>();
    }

    // Handle tags
    List<String> tagsList = [];
    if (map['tags'] != null && map['tags'] is List) {
      tagsList = (map['tags'] as List).cast<String>();
    }

    // Handle aliases
    List<String> aliasesList = [];
    if (map['aliases'] != null && map['aliases'] is List) {
      aliasesList = (map['aliases'] as List).cast<String>();
    }

    final exercise = Exercise(
      id: map['id'] as String? ??
          'unknown_${DateTime.now().millisecondsSinceEpoch}',
      userId: map['user_id'] as String?,
      name: map['name'] as String? ?? 'Unknown Exercise',
      primaryMuscleGroup: map['primary_muscle_group'] as String? ?? 'other',
      secondaryMuscleGroups: secondaryMuscles,
      equipment: equipmentStr,
      instructions: map['instructions'] as String? ?? '',
      tags: tagsList,
      aliases: aliasesList,
      isBodyweight: map['is_bodyweight'] as bool? ?? false,
      exerciseType: map['exercise_type'] as String? ?? 'weight_reps',
      category: map['category'] as String? ?? 'strength',
      difficulty: map['difficulty'] as String? ?? 'intermediate',
      parentExerciseId: map['parent_exercise_id'] as String?,
      variantType: map['variant_type'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );

    print('✅ Mapped exercise: ${exercise.name}');
    return exercise;
  } catch (e, stackTrace) {
    print('❌ Error mapping exercise: $e');
    print('   Stack: $stackTrace');
    print('   Data: $map');
    return null;
  }
}
