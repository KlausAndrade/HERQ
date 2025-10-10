import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/live_activity_provider.dart';
import '../../domain/models/active_workout.dart';
import '../providers/active_workout_provider.dart';

class SetEntryWidget extends ConsumerStatefulWidget {
  const SetEntryWidget({
    super.key,
    required this.set,
    required this.setNumber,
    required this.onChanged,
    this.restTimerSeconds = 90,
    this.exerciseName,
    this.totalSets,
    this.previousSet,
    this.isFirstSet = false,
    this.exerciseType,
  });
  final ActiveSet set;
  final int setNumber;
  final ValueChanged<ActiveSet> onChanged;
  final int restTimerSeconds;
  final String? exerciseName;
  final int? totalSets;
  final ActiveSet? previousSet; // Previous workout's set data
  final bool isFirstSet; // Whether this is the first set (to show header)
  final String? exerciseType;

  @override
  ConsumerState<SetEntryWidget> createState() => _SetEntryWidgetState();
}

class _SetEntryWidgetState extends ConsumerState<SetEntryWidget> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    // For timer exercises we store seconds in durationSeconds and reuse reps controller
    if (widget.exerciseType == 'timer') {
      _repsController = TextEditingController(
        text: widget.set.durationSeconds != null ? widget.set.durationSeconds.toString() : '',
      );
    } else {
      _repsController = TextEditingController(
        text: widget.set.reps > 0 ? widget.set.reps.toString() : '',
      );
    }
  }

  @override
  void didUpdateWidget(SetEntryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers only if values changed AND we're not currently editing
    // This prevents the controller from being overwritten while the user is typing
    if (oldWidget.set.weight != widget.set.weight && !_weightController.selection.isValid) {
      _weightController.text = widget.set.weight?.toString() ?? '';
    }
    if (widget.exerciseType == 'timer') {
      if (oldWidget.set.durationSeconds != widget.set.durationSeconds && !_repsController.selection.isValid) {
        _repsController.text = widget.set.durationSeconds != null ? widget.set.durationSeconds.toString() : '';
      }
    } else {
      if (oldWidget.set.reps != widget.set.reps && !_repsController.selection.isValid) {
        _repsController.text = widget.set.reps > 0 ? widget.set.reps.toString() : '';
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = widget.set.isCompleted;

    return Column(
      children: [
        // Header row (only on first set)
        if (widget.isFirstSet)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha((0.6 * 255).round()),
            ),
            child: Row(
              children: [
                // Set number header
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      'SET',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                
                // Previous header
                Expanded(
                  flex: 3,
                  child: Text(
                    'PREVIOUS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 6),
                
                // Weight header
                Expanded(
                  flex: 2,
                  child: Text(
                    'KG',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 6),
                
                // Reps header
                Expanded(
                  flex: 2,
                  child: Text(
                    'REPS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 6),
                
                // Checkmark header
                SizedBox(
                  width: 42,
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: colorScheme.onSurface.withAlpha((0.4 * 255).round()),
                  ),
                ),
              ],
            ),
          ),

        // Set data row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isCompleted
                ? colorScheme.primary.withAlpha((0.12 * 255).round())
                : (widget.setNumber % 2 == 0
                    ? colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).round())
                    : Colors.transparent),
            border: isCompleted
                ? Border.all(
                    color: colorScheme.primary.withAlpha((0.4 * 255).round()),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Set Number / PR Badge
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: widget.set.isPRWeight || widget.set.isPRReps
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.amber.shade700,
                              size: 28,
                            ),
                            if (widget.set.isPRWeight && widget.set.isPRReps)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade700,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '2',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest.withAlpha((0.8 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              widget.setNumber.toString(),
                              style: TextStyle(
                                color: isCompleted
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 6),

              // Previous (weight x reps)
              Expanded(
                flex: 3,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha((0.4 * 255).round()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: widget.previousSet != null
                        ? Text(
                            '${widget.previousSet!.weight?.toStringAsFixed(1) ?? '-'} × ${widget.previousSet!.reps}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            '—',
                            style: TextStyle(
                              color: colorScheme.onSurface.withAlpha((0.3 * 255).round()),
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // If exerciseType == 'timer', show a compact duration input instead of weight/reps
              if (widget.exerciseType == 'timer') ...[
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _repsController, // reuse reps controller to store seconds
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'secs',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withAlpha((0.3 * 255).round())),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final secs = value.isEmpty ? null : int.tryParse(value);
                        _updateSet(durationSeconds: secs);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ] else ...[
                // Weight Input
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '-',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha((0.3 * 255).round()),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withAlpha((0.3 * 255).round()),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withAlpha((0.3 * 255).round()),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final weight = value.isEmpty ? null : double.tryParse(value);
                        _updateSet(weight: weight);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Reps Input
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '-',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha((0.3 * 255).round()),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withAlpha((0.3 * 255).round()),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withAlpha((0.3 * 255).round()),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final reps = value.isEmpty ? 0 : (int.tryParse(value) ?? 0);
                        _updateSet(reps: reps);
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),

              // Complete Button
              SizedBox(
                width: 42,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    final newCompletionState = !isCompleted;
                    _updateSet(isCompleted: newCompletionState);
                    
                    if (newCompletionState) {
                      _startRestTimer();
                    }
                  },
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.outline,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateSet({
    double? weight,
    int? reps,
    int? durationSeconds,
    bool? isCompleted,
  }) {
    final updatedSet = ActiveSet(
      number: widget.set.number,
      weight: weight ?? widget.set.weight,
      reps: reps ?? widget.set.reps,
  durationSeconds: durationSeconds ?? widget.set.durationSeconds,
      rpe: widget.set.rpe,
      isCompleted: isCompleted ?? widget.set.isCompleted,
    );
    widget.onChanged(updatedSet);
  }

  void _startRestTimer() {
    // Get live activity service
    final liveActivityService = ref.read(liveActivityServiceProvider);
    
    // Start rest timer with the exercise's configured duration and context
    ref.read(restTimerProvider.notifier).startTimer(
          widget.restTimerSeconds,
          exerciseName: widget.exerciseName,
          currentSet: widget.setNumber,
          totalSets: widget.totalSets,
          targetReps: widget.set.reps > 0 ? widget.set.reps : null,
          liveActivityService: liveActivityService,
        );
  }
}
