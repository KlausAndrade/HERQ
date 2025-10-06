import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';

enum WorkoutFilter {
  all,
  completed,
  inProgress,
  thisWeek,
  thisMonth,
}

class WorkoutFilterState {
  const WorkoutFilterState({
    this.filter = WorkoutFilter.all,
    this.searchQuery = '',
  });

  final WorkoutFilter filter;
  final String searchQuery;

  WorkoutFilterState copyWith({
    WorkoutFilter? filter,
    String? searchQuery,
  }) {
    return WorkoutFilterState(
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class WorkoutFilterNotifier extends StateNotifier<WorkoutFilterState> {
  WorkoutFilterNotifier() : super(const WorkoutFilterState());

  void setFilter(WorkoutFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = const WorkoutFilterState();
  }
}

final workoutFilterProvider =
    StateNotifierProvider<WorkoutFilterNotifier, WorkoutFilterState>(
  (ref) => WorkoutFilterNotifier(),
);

// Provider for filtered workout sessions
final filteredWorkoutSessionsProvider =
    FutureProvider<List<WorkoutSession>>((ref) async {
  final database = ref.read(databaseProvider);
  if (database == null) {
    return [];
  }

  final filterState = ref.watch(workoutFilterProvider);
  final sessions = await (database.select(database.workoutSessions)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
      .get();

  var filteredSessions = sessions.where((session) {
    // Apply filter
    switch (filterState.filter) {
      case WorkoutFilter.completed:
        return session.completedAt != null;
      case WorkoutFilter.inProgress:
        return session.completedAt == null;
      case WorkoutFilter.thisWeek:
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDate =
            DateTime(weekStart.year, weekStart.month, weekStart.day);
        return session.startedAt.isAfter(weekStartDate);
      case WorkoutFilter.thisMonth:
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        return session.startedAt.isAfter(monthStart);
      case WorkoutFilter.all:
        return true;
    }
  });

  // Apply search query
  if (filterState.searchQuery.isNotEmpty) {
    final query = filterState.searchQuery.toLowerCase();
    filteredSessions = filteredSessions.where((session) {
      return session.name.toLowerCase().contains(query) ||
          session.notes?.toLowerCase().contains(query) == true;
    });
  }

  return filteredSessions.toList();
});
