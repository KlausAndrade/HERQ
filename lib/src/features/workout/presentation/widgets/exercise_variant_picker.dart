import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../../l10n/app_localizations.dart';

/// A compact picker for selecting equipment and variant type for an exercise
class ExerciseVariantPicker extends StatelessWidget {
  const ExerciseVariantPicker({
    required this.onChanged,
    super.key,
    this.currentEquipment,
    this.currentVariant,
  });
  final String? currentEquipment;
  final String? currentVariant;
  final Function(String? equipment, String? variant) onChanged;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(
          _getEquipmentIcon(currentEquipment),
          size: 20,
        ),
        tooltip: _getTooltip(context),
        onPressed: () => _showPicker(context),
      );

  IconData _getEquipmentIcon(String? equipment) {
    switch (equipment?.toLowerCase()) {
      case 'barbell':
        return Icons.fitness_center;
      case 'dumbbell':
        return Icons.sports_martial_arts;
      case 'cable':
        return Icons.cable;
      case 'machine':
        return Icons.precision_manufacturing;
      case 'bodyweight':
      case 'none':
        return Icons.accessibility;
      default:
        return Icons.more_horiz;
    }
  }

  String _getTooltip(BuildContext context) {
    final l10n = S.of(context);
    final parts = <String>[];
    if (currentEquipment != null) {
      parts.add(_formatEquipment(currentEquipment!));
    }
    if (currentVariant != null && currentVariant != 'standard') {
      // Parse combined variant (executionType:position)
      final variantParts = currentVariant!.split(':');
      if (variantParts.length == 2) {
        final position = variantParts[1];
        parts.add(_formatPosition(position, l10n));
      } else {
        parts.add(_formatVariant(currentVariant!));
      }
    }
    return parts.isEmpty ? 'Change equipment/variant' : parts.join(' • ');
  }

  String _formatPosition(String position, dynamic l10n) {
    switch (position) {
      case 'inclined':
        return l10n.inclined;
      case 'declined':
        return l10n.declined;
      case 'suspended':
        return l10n.suspended;
      case 'seated':
        return l10n.seated;
      case 'standing':
        return l10n.standing;
      case 'elevated':
        return l10n.elevated;
      case 'deficit':
        return l10n.deficit;
      default:
        return position[0].toUpperCase() + position.substring(1);
    }
  }

  String _formatEquipment(String equipment) =>
      equipment[0].toUpperCase() + equipment.substring(1);

  String _formatVariant(String variant) =>
      variant[0].toUpperCase() + variant.substring(1);

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _VariantPickerSheet(
          currentEquipment: currentEquipment,
          currentVariant: currentVariant,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('currentEquipment', currentEquipment));
    properties.add(StringProperty('currentVariant', currentVariant));
    properties.add(
        ObjectFlagProperty<Function(String? equipment, String? variant)>.has(
            'onChanged', onChanged));
  }
}

class _VariantPickerSheet extends StatefulWidget {
  const _VariantPickerSheet({
    required this.onChanged,
    this.currentEquipment,
    this.currentVariant,
  });
  final String? currentEquipment;
  final String? currentVariant;
  final Function(String? equipment, String? variant) onChanged;

  @override
  State<_VariantPickerSheet> createState() => _VariantPickerSheetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('currentEquipment', currentEquipment));
    properties.add(StringProperty('currentVariant', currentVariant));
    properties.add(
        ObjectFlagProperty<Function(String? equipment, String? variant)>.has(
            'onChanged', onChanged));
  }
}

class _VariantPickerSheetState extends State<_VariantPickerSheet> {
  late String? selectedEquipment;
  late String? selectedVariant;
  late String? selectedPosition;

  static const equipmentOptions = [
    'barbell',
    'dumbbell',
    'cable',
    'machine',
    'bodyweight',
    'resistance_band',
    'kettlebell',
    'none',
  ];

  static const executionTypeOptions = [
    'weight_reps',
    'reps',
    'weighted_bodyweight',
    'assisted_bodyweight',
    'timer',
    'duration_weight',
    'distance_duration',
    'weight_distance',
  ];

  static const positionVariantOptions = [
    'standard',
    'inclined',
    'declined',
    'suspended',
    'seated',
    'standing',
    'elevated',
    'deficit',
  ];

  @override
  void initState() {
    super.initState();
    selectedEquipment = widget.currentEquipment;
    
    // Parse variant: could be "executionType:position" or just "executionType"
    final variant = widget.currentVariant ?? 'weight_reps';
    if (variant.contains(':')) {
      final parts = variant.split(':');
      selectedVariant = parts[0];
      selectedPosition = parts[1];
    } else {
      selectedVariant = variant;
      selectedPosition = 'standard';
    }
  }

  String _combineVariantAndPosition(String executionType, String? position) {
    if (position == null || position == 'standard') {
      return executionType;
    }
    return '$executionType:$position';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header with close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context)?.exerciseVariant ?? 'Exercise Variant',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: S.of(context)?.close ?? 'Close',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Equipment Selection
                    Text(
                      S.of(context)?.equipment ?? 'Equipment',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: equipmentOptions.map((equipment) {
                        final isSelected = equipment == selectedEquipment;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              final selected = !isSelected;
                              final newEquipment = selected ? equipment : null;
                              setState(() {
                                selectedEquipment = newEquipment;
                              });
                              // Apply change immediately
                              final combinedVariant = _combineVariantAndPosition(
                                selectedVariant ?? 'weight_reps',
                                selectedPosition == 'standard' ? null : selectedPosition,
                              );
                              widget.onChanged(
                                newEquipment,
                                combinedVariant == 'weight_reps' ? null : combinedVariant,
                              );
                            },
                            child: FilterChip(
                              label: Text(
                                _formatEquipmentLabel(equipment, context),
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF1B1D21) // herqGraphite - dark almost black
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              avatar: Icon(
                                _getEquipmentIconForType(equipment),
                                size: 16,
                                color: isSelected
                                    ? const Color(0xFF1B1D21) // herqGraphite - dark almost black
                                    : theme.colorScheme.onSurface,
                              ),
                              selected: isSelected,
                              showCheckmark: false,
                              onSelected: null,
                              selectedColor: theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF1B1D21) // herqGraphite - dark almost black
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 6),
                    const Divider(),
                    const SizedBox(height: 6),

                    // Execution Type Selection
                    Text(
                      S.of(context)?.executionType ?? 'Execution Type',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: executionTypeOptions.map((executionType) {
                        final isSelected = executionType == selectedVariant;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              final selected = !isSelected;
                              final newExecutionType =
                                  selected ? executionType : 'weight_reps';
                              setState(() {
                                selectedVariant = newExecutionType;
                              });
                              // Apply change immediately
                              final combinedVariant = _combineVariantAndPosition(
                                newExecutionType,
                                selectedPosition == 'standard' ? null : selectedPosition,
                              );
                              widget.onChanged(
                                selectedEquipment,
                                combinedVariant == 'weight_reps' ? null : combinedVariant,
                              );
                            },
                            child: FilterChip(
                              label: Text(
                                _formatExecutionTypeLabel(executionType, context),
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF1B1D21) // herqGraphite - dark almost black
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              selected: isSelected,
                              showCheckmark: false,
                              onSelected: null,
                              selectedColor: theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF1B1D21) // herqGraphite - dark almost black
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 6),
                    const Divider(),
                    const SizedBox(height: 6),

                    // Position/Angle Selection
                    Text(
                      S.of(context)?.positionAngle ?? 'Position / Angle',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: positionVariantOptions.map((position) {
                        final isSelected = position == selectedPosition;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              final selected = !isSelected;
                              final newPosition = selected ? position : 'standard';
                              setState(() {
                                selectedPosition = newPosition;
                              });
                              // Apply change immediately
                              final combinedVariant = _combineVariantAndPosition(
                                selectedVariant ?? 'weight_reps',
                                newPosition == 'standard' ? null : newPosition,
                              );
                              widget.onChanged(
                                selectedEquipment,
                                combinedVariant == 'weight_reps' ? null : combinedVariant,
                              );
                            },
                            child: FilterChip(
                              label: Text(
                                _formatPositionLabel(position, context),
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF1B1D21) // herqGraphite - dark almost black
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              avatar: Icon(
                                _getPositionIcon(position),
                                size: 16,
                                color: isSelected
                                    ? const Color(0xFF1B1D21) // herqGraphite - dark almost black
                                    : theme.colorScheme.onSurface,
                              ),
                              selected: isSelected,
                              showCheckmark: false,
                              onSelected: null,
                              selectedColor: theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF1B1D21) // herqGraphite - dark almost black
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatEquipmentLabel(String equipment, BuildContext context) {
    final l10n = S.of(context);
    if (l10n == null) {
      return equipment
          .split('_')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }
    switch (equipment.toLowerCase()) {
      case 'barbell':
        return l10n.barbell;
      case 'dumbbell':
        return l10n.dumbbell;
      case 'cable':
        return l10n.cable;
      case 'machine':
        return l10n.machine;
      case 'bodyweight':
        return l10n.bodyweight;
      case 'resistance_band':
        return l10n.resistanceBand;
      case 'kettlebell':
        return l10n.kettlebell;
      case 'none':
        return l10n.none;
      default:
        return equipment
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String _formatExecutionTypeLabel(String executionType, BuildContext context) {
    final l10n = S.of(context);
    if (l10n == null) {
      return _getEnglishExecutionTypeLabel(executionType);
    }
    switch (executionType) {
      case 'weight_reps':
        return l10n.weightReps;
      case 'reps':
        return l10n.bodyweightReps;
      case 'weighted_bodyweight':
        return l10n.weightedBodyweight;
      case 'assisted_bodyweight':
        return l10n.assistedBodyweight;
      case 'timer':
        return l10n.durationOnly;
      case 'duration_weight':
        return l10n.durationWeight;
      case 'distance_duration':
        return l10n.distanceDuration;
      case 'weight_distance':
        return l10n.weightDistance;
      default:
        return executionType[0].toUpperCase() + executionType.substring(1);
    }
  }

  String _getEnglishExecutionTypeLabel(String executionType) {
    switch (executionType) {
      case 'weight_reps':
        return 'Weight & Reps';
      case 'reps':
        return 'Bodyweight Reps';
      case 'weighted_bodyweight':
        return 'Weighted Bodyweight';
      case 'assisted_bodyweight':
        return 'Assisted Bodyweight';
      case 'timer':
        return 'Duration';
      case 'duration_weight':
        return 'Duration & Weight';
      case 'distance_duration':
        return 'Distance & Duration';
      case 'weight_distance':
        return 'Weight & Distance';
      default:
        return executionType[0].toUpperCase() + executionType.substring(1);
    }
  }

  IconData _getEquipmentIconForType(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'barbell':
        return Icons.fitness_center;
      case 'dumbbell':
        return Icons.sports_martial_arts;
      case 'cable':
        return Icons.cable;
      case 'machine':
        return Icons.precision_manufacturing;
      case 'bodyweight':
        return Icons.accessibility;
      case 'resistance_band':
        return Icons.linear_scale;
      case 'kettlebell':
        return Icons.sports_gymnastics;
      case 'none':
        return Icons.not_interested;
      default:
        return Icons.more_horiz;
    }
  }

  String _formatPositionLabel(String position, BuildContext context) {
    final l10n = S.of(context);
    if (l10n == null) {
      // Fallback to English if localization not available
      return _getEnglishPositionLabel(position);
    }
    switch (position) {
      case 'standard':
        return l10n.standard;
      case 'inclined':
        return l10n.inclined;
      case 'declined':
        return l10n.declined;
      case 'suspended':
        return l10n.suspended;
      case 'seated':
        return l10n.seated;
      case 'standing':
        return l10n.standing;
      case 'elevated':
        return l10n.elevated;
      case 'deficit':
        return l10n.deficit;
      default:
        return position[0].toUpperCase() + position.substring(1);
    }
  }

  String _getEnglishPositionLabel(String position) {
    switch (position) {
      case 'standard':
        return 'Standard';
      case 'inclined':
        return 'Inclined';
      case 'declined':
        return 'Declined';
      case 'suspended':
        return 'Suspended';
      case 'seated':
        return 'Seated';
      case 'standing':
        return 'Standing';
      case 'elevated':
        return 'Elevated';
      case 'deficit':
        return 'Deficit';
      default:
        return position[0].toUpperCase() + position.substring(1);
    }
  }

  IconData _getPositionIcon(String position) {
    switch (position) {
      case 'standard':
        return Icons.horizontal_rule;
      case 'inclined':
        return Icons.trending_up;
      case 'declined':
        return Icons.trending_down;
      case 'suspended':
        return Icons.waves;
      case 'seated':
        return Icons.chair;
      case 'standing':
        return Icons.accessibility_new;
      case 'elevated':
        return Icons.arrow_upward;
      case 'deficit':
        return Icons.arrow_downward;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('selectedEquipment', selectedEquipment));
    properties.add(StringProperty('selectedVariant', selectedVariant));
  }
}
