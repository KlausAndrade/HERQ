import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/active_workout.dart';
import '../providers/active_workout_provider.dart';

class SetEntryWidget extends ConsumerStatefulWidget {
  const SetEntryWidget({
    super.key,
    required this.set,
    required this.setNumber,
    required this.onChanged,
    this.restTimerSeconds = 90,
  });
  final ActiveSet set;
  final int setNumber;
  final ValueChanged<ActiveSet> onChanged;
  final int restTimerSeconds;

  @override
  ConsumerState<SetEntryWidget> createState() => _SetEntryWidgetState();
}

class _SetEntryWidgetState extends ConsumerState<SetEntryWidget> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  int? _selectedRpe;
  bool _showRpe = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps.toString(),
    );
    _selectedRpe = widget.set.rpe;
    _showRpe = widget.set.rpe != null;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.set.isCompleted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
          color: widget.set.isCompleted
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Set Number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.set.isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.setNumber.toString(),
                      style: TextStyle(
                        color: widget.set.isCompleted
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Weight Input
                Expanded(
                  child: _buildNumberInput(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    onChanged: (value) {
                      final weight = double.tryParse(value);
                      _updateSet(weight: weight);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Reps Input
                Expanded(
                  child: _buildNumberInput(
                    controller: _repsController,
                    label: 'Reps',
                    isInteger: true,
                    onChanged: (value) {
                      final reps = int.tryParse(value) ?? 0;
                      _updateSet(reps: reps);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // RPE Button (compact)
                if (widget.set.isCompleted)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedRpe != null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _showRpe = !_showRpe;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedRpe?.toString() ?? '-',
                            style: TextStyle(
                              color: _selectedRpe != null
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'RPE',
                            style: TextStyle(
                              color: _selectedRpe != null
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 8),

                // Complete Button
                IconButton(
                  onPressed: () {
                    _updateSet(isCompleted: !widget.set.isCompleted);
                    if (!widget.set.isCompleted) {
                      _startRestTimer();
                    }
                  },
                  icon: Icon(
                    widget.set.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: widget.set.isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),

            // RPE Selector (expandable)
            if (_showRpe && widget.set.isCompleted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rate of Perceived Exertion',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _showRpe = false;
                            });
                          },
                          icon: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(10, (index) {
                        final rpe = index + 1;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRpe = rpe;
                              });
                              _updateSet(rpe: rpe);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 36,
                              decoration: BoxDecoration(
                                color: _selectedRpe == rpe
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  rpe.toString(),
                                  style: TextStyle(
                                    color: _selectedRpe == rpe
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    bool isInteger = false,
  }) =>
      TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
        inputFormatters: [
          if (isInteger)
            FilteringTextInputFormatter.digitsOnly
          else
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          isDense: true,
        ),
        onChanged: onChanged,
      );

  void _updateSet({
    double? weight,
    int? reps,
    int? rpe,
    bool? isCompleted,
  }) {
    final updatedSet = ActiveSet(
      number: widget.set.number,
      weight: weight ?? widget.set.weight,
      reps: reps ?? widget.set.reps,
      rpe: rpe ?? widget.set.rpe,
      isCompleted: isCompleted ?? widget.set.isCompleted,
    );
    widget.onChanged(updatedSet);
  }

  void _startRestTimer() {
    // Start rest timer with the exercise's configured duration
    ref.read(restTimerProvider.notifier).startTimer(widget.restTimerSeconds);
  }
}
