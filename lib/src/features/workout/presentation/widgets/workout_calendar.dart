import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database.dart';

class WorkoutCalendar extends StatefulWidget {
  const WorkoutCalendar({
    required this.workouts,
    super.key,
    this.onDaySelected,
    this.onWorkoutTap,
  });
  final List<WorkoutSession> workouts;
  final Function(DateTime)? onDaySelected;
  final Function(WorkoutSession)? onWorkoutTap;

  @override
  State<WorkoutCalendar> createState() => _WorkoutCalendarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<WorkoutSession>('workouts', workouts));
    properties.add(ObjectFlagProperty<Function(DateTime p1)?>.has(
        'onDaySelected', onDaySelected));
    properties.add(ObjectFlagProperty<Function(WorkoutSession p1)?>.has(
        'onWorkoutTap', onWorkoutTap));
  }
}

class _WorkoutCalendarState extends State<WorkoutCalendar> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Month Navigation
          _buildMonthNavigation(),

          // Calendar Grid
          Expanded(
            child: _buildCalendarGrid(),
          ),

          // Selected Day Workouts
          if (_selectedDay != null) _buildSelectedDayWorkouts(),
        ],
      );

  Widget _buildMonthNavigation() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat('MMMM y').format(_focusedMonth),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              onPressed: _canGoToNextMonth()
                  ? () {
                      setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1,
                        );
                      });
                    }
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      );

  bool _canGoToNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    return nextMonth.isBefore(DateTime(now.year, now.month + 1));
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth();
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final workoutsByDate = _groupWorkoutsByDate();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 7 + firstWeekday + daysInMonth, // Headers + empty cells + days
      itemBuilder: (context, index) {
        // Day headers (Sun, Mon, etc.)
        if (index < 7) {
          return Center(
            child: Text(
              _getWeekdayName(index),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          );
        }

        // Empty cells before first day
        if (index < 7 + firstWeekday) {
          return const SizedBox.shrink();
        }

        // Day cells
        final dayNumber = index - 6 - firstWeekday;
        final date =
            DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
        final isToday = _isToday(date);
        final isSelected =
            _selectedDay != null && _isSameDay(date, _selectedDay!);
        final workoutsOnDay = workoutsByDate[_dateKey(date)] ?? [];
        final hasWorkout = workoutsOnDay.isNotEmpty;
        final isFutureDate = date.isAfter(DateTime.now());

        return GestureDetector(
          onTap: isFutureDate
              ? null
              : () {
                  setState(() {
                    _selectedDay = date;
                  });
                  widget.onDaySelected?.call(date);
                },
          child: _buildDayCell(
            dayNumber,
            isToday: isToday,
            isSelected: isSelected,
            hasWorkout: hasWorkout,
            workoutCount: workoutsOnDay.length,
            isFutureDate: isFutureDate,
          ),
        );
      },
    );
  }

  Widget _buildDayCell(
    int day, {
    required bool isToday,
    required bool isSelected,
    required bool hasWorkout,
    required int workoutCount,
    required bool isFutureDate,
  }) {
    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;

    if (isFutureDate) {
      textColor = Colors.grey.shade400;
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Colors.white;
    } else if (isToday) {
      borderColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.primary;
    } else if (hasWorkout) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        hasWorkout ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
            ),
          ),
          // Workout indicator dots
          if (hasWorkout && !isSelected)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  workoutCount > 3 ? 3 : workoutCount,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          // Multiple workouts indicator
          if (workoutCount > 1 && !isFutureDate)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$workoutCount',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayWorkouts() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final workoutsOnDay = _groupWorkoutsByDate()[_dateKey(_selectedDay!)] ?? [];

    if (workoutsOnDay.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.5),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Center(
          child: Text(
            'No workouts on ${DateFormat('MMMM d, y').format(_selectedDay!)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${DateFormat('MMMM d, y').format(_selectedDay!)} • ${workoutsOnDay.length} workout${workoutsOnDay.length != 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: workoutsOnDay.length,
              itemBuilder: (context, index) {
                final workout = workoutsOnDay[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.fitness_center,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      workout.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      '${workout.totalSets} sets • ${workout.totalVolume.toStringAsFixed(0)} kg',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: workout.completedAt != null
                        ? Text(
                            DateFormat('HH:mm').format(workout.completedAt!),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    onTap: () => widget.onWorkoutTap?.call(workout),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  int _getDaysInMonth() =>
      DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

  String _getWeekdayName(int weekday) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays[weekday];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  bool _isSameDay(DateTime date1, DateTime date2) =>
      date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Map<String, List<WorkoutSession>> _groupWorkoutsByDate() {
    final Map<String, List<WorkoutSession>> grouped = {};

    for (final workout in widget.workouts) {
      if (workout.completedAt == null) continue;

      final date = workout.completedAt!;
      // Only include workouts from the focused month
      if (date.year == _focusedMonth.year &&
          date.month == _focusedMonth.month) {
        final key = _dateKey(date);
        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(workout);
      }
    }

    // Sort workouts within each day by time
    grouped.forEach((key, workouts) {
      workouts.sort((a, b) {
        final aTime = a.completedAt ?? DateTime(0);
        final bTime = b.completedAt ?? DateTime(0);
        return aTime.compareTo(bTime);
      });
    });

    return grouped;
  }
}
