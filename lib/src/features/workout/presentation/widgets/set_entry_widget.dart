import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/live_activity_provider.dart';
import '../../../../core/constants/exercise_types.dart';
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
  late TextEditingController _durationController;
  late TextEditingController _distanceController;
  late TextEditingController _assistanceWeightController;
  late TextEditingController _addedWeightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps > 0 ? widget.set.reps.toString() : '',
    );
    _durationController = TextEditingController(
      text: widget.set.durationSeconds?.toString() ?? '',
    );
    _distanceController = TextEditingController(
      text: widget.set.distance?.toString() ?? '',
    );
    _assistanceWeightController = TextEditingController(
      text: widget.set.assistanceWeight?.toString() ?? '',
    );
    _addedWeightController = TextEditingController(
      text: widget.set.addedWeight?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(SetEntryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers only if values changed AND we're not currently editing
    // This prevents the controller from being overwritten while the user is typing
    if (oldWidget.set.weight != widget.set.weight && !_weightController.selection.isValid) {
      _weightController.text = widget.set.weight?.toString() ?? '';
    }
    if (oldWidget.set.reps != widget.set.reps && !_repsController.selection.isValid) {
      _repsController.text = widget.set.reps > 0 ? widget.set.reps.toString() : '';
    }
    if (oldWidget.set.durationSeconds != widget.set.durationSeconds && !_durationController.selection.isValid) {
      _durationController.text = widget.set.durationSeconds?.toString() ?? '';
    }
    if (oldWidget.set.distance != widget.set.distance && !_distanceController.selection.isValid) {
      _distanceController.text = widget.set.distance?.toString() ?? '';
    }
    if (oldWidget.set.assistanceWeight != widget.set.assistanceWeight && !_assistanceWeightController.selection.isValid) {
      _assistanceWeightController.text = widget.set.assistanceWeight?.toString() ?? '';
    }
    if (oldWidget.set.addedWeight != widget.set.addedWeight && !_addedWeightController.selection.isValid) {
      _addedWeightController.text = widget.set.addedWeight?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _assistanceWeightController.dispose();
    _addedWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = widget.set.isCompleted;
    
    // Get exercise type configuration
    final exerciseTypeString = widget.exerciseType ?? 'weight_reps';
    final config = ExerciseTypeConfig.fromString(exerciseTypeString);
    final fields = config.requiredFields;

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
                
                // Dynamic field headers based on exercise type
                ...fields.map((field) => [
                  Expanded(
                    flex: 2,
                    child: Text(
                      field.label,
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
                ]).expand((element) => element).toList(),
                
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

              // Previous set data
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
                            _formatPreviousSet(widget.previousSet!, config),
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

              // Dynamic input fields based on exercise type
              ...fields.map((field) => [
                Expanded(
                  flex: 2,
                  child: _buildInputField(field, colorScheme),
                ),
                const SizedBox(width: 6),
              ]).expand((element) => element).toList(),

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
    double? distance,
    double? assistanceWeight,
    double? addedWeight,
    bool? isCompleted,
  }) {
    final updatedSet = ActiveSet(
      number: widget.set.number,
      weight: weight ?? widget.set.weight,
      reps: reps ?? widget.set.reps,
      durationSeconds: durationSeconds ?? widget.set.durationSeconds,
      distance: distance ?? widget.set.distance,
      assistanceWeight: assistanceWeight ?? widget.set.assistanceWeight,
      addedWeight: addedWeight ?? widget.set.addedWeight,
      rpe: widget.set.rpe,
      isCompleted: isCompleted ?? widget.set.isCompleted,
    );
    widget.onChanged(updatedSet);
  }

  /// Build input field based on exercise field type
  Widget _buildInputField(ExerciseField field, ColorScheme colorScheme) {
    switch (field) {
      case ExerciseField.weight:
        return _buildWeightInput(colorScheme);
      case ExerciseField.reps:
        return _buildRepsInput(colorScheme);
      case ExerciseField.duration:
        return _buildDurationInput(colorScheme);
      case ExerciseField.distance:
        return _buildDistanceInput(colorScheme);
      case ExerciseField.assistanceWeight:
        return _buildAssistedWeightInput(colorScheme);
      case ExerciseField.addedWeight:
        return _buildAddedWeightInput(colorScheme);
    }
  }

  Widget _buildWeightInput(ColorScheme colorScheme) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _weightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: _inputDecoration(colorScheme, 'kg'),
        onChanged: (value) {
          final weight = value.isEmpty ? null : double.tryParse(value);
          _updateSet(weight: weight);
        },
      ),
    );
  }

  Widget _buildRepsInput(ColorScheme colorScheme) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _repsController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: _inputDecoration(colorScheme, 'reps'),
        onChanged: (value) {
          final reps = value.isEmpty ? 0 : (int.tryParse(value) ?? 0);
          _updateSet(reps: reps);
        },
      ),
    );
  }

  Widget _buildDurationInput(ColorScheme colorScheme) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: _inputDecoration(colorScheme, 'secs'),
        onChanged: (value) {
          final secs = value.isEmpty ? null : int.tryParse(value);
          _updateSet(durationSeconds: secs);
        },
      ),
    );
  }

  Widget _buildDistanceInput(ColorScheme colorScheme) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _distanceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: _inputDecoration(colorScheme, 'm'),
        onChanged: (value) {
          final distance = value.isEmpty ? null : double.tryParse(value);
          _updateSet(distance: distance);
        },
      ),
    );
  }

  Widget _buildAssistedWeightInput(ColorScheme colorScheme) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _assistanceWeightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: _inputDecoration(colorScheme, 'kg'),
        onChanged: (value) {
          final assistWeight = value.isEmpty ? null : double.tryParse(value);
          _updateSet(assistanceWeight: assistWeight);
        },
      ),
    );
  }

  Widget _buildAddedWeightInput(ColorScheme colorScheme) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _addedWeightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: _inputDecoration(colorScheme, 'kg'),
        onChanged: (value) {
          final added = value.isEmpty ? null : double.tryParse(value);
          _updateSet(addedWeight: added);
        },
      ),
    );
  }

  /// Common input decoration
  InputDecoration _inputDecoration(ColorScheme colorScheme, String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }

  /// Format previous set data based on exercise type
  String _formatPreviousSet(ActiveSet set, ExerciseTypeConfig config) {
    final fields = config.requiredFields;
    final parts = <String>[];

    for (final field in fields) {
      switch (field) {
        case ExerciseField.weight:
          parts.add('${set.weight?.toStringAsFixed(1) ?? '-'} kg');
          break;
        case ExerciseField.reps:
          parts.add('${set.reps} reps');
          break;
        case ExerciseField.duration:
          if (set.durationSeconds != null) {
            parts.add(set.durationSeconds!.formatDuration());
          } else {
            parts.add('- secs');
          }
          break;
        case ExerciseField.distance:
          if (set.distance != null) {
            parts.add(set.distance!.formatDistance());
          } else {
            parts.add('- m');
          }
          break;
        case ExerciseField.assistanceWeight:
          parts.add('${set.assistanceWeight?.toStringAsFixed(1) ?? '-'} kg');
          break;
        case ExerciseField.addedWeight:
          parts.add('+${set.addedWeight?.toStringAsFixed(1) ?? '-'} kg');
          break;
      }
    }

    return parts.join(' × ');
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
