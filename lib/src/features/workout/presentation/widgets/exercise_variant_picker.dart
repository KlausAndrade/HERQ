import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
        tooltip: _getTooltip(),
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

  String _getTooltip() {
    final parts = <String>[];
    if (currentEquipment != null) {
      parts.add(_formatEquipment(currentEquipment!));
    }
    if (currentVariant != null && currentVariant != 'standard') {
      parts.add(_formatVariant(currentVariant!));
    }
    return parts.isEmpty ? 'Change equipment/variant' : parts.join(' • ');
  }

  String _formatEquipment(String equipment) =>
      equipment[0].toUpperCase() + equipment.substring(1);

  String _formatVariant(String variant) =>
      variant[0].toUpperCase() + variant.substring(1);

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _VariantPickerSheet(
        currentEquipment: currentEquipment,
        currentVariant: currentVariant,
        onChanged: onChanged,
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

  @override
  void initState() {
    super.initState();
    selectedEquipment = widget.currentEquipment;
    selectedVariant = widget.currentVariant ?? 'weight_reps';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exercise Variant',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Equipment Selection
              Text(
                'Equipment',
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
                  return ChoiceChip(
                    label: Text(_formatLabel(equipment)),
                    avatar: Icon(
                      _getEquipmentIconForType(equipment),
                      size: 16,
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newEquipment = selected ? equipment : null;
                      setState(() {
                        selectedEquipment = newEquipment;
                      });
                      // Apply change immediately
                      widget.onChanged(
                        newEquipment,
                        selectedVariant == 'standard' ? null : selectedVariant,
                      );
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                  );
                }).toList(),
              ),

              const SizedBox(height: 6),
              const Divider(),
              const SizedBox(height: 6),

              // Execution Type Selection
              Text(
                'Execution Type',
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
                  return ChoiceChip(
                    label: Text(_formatExecutionTypeLabel(executionType)),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newExecutionType =
                          selected ? executionType : 'weight_reps';
                      setState(() {
                        selectedVariant = newExecutionType;
                      });
                      // Apply change immediately
                      widget.onChanged(
                        selectedEquipment,
                        newExecutionType,
                      );
                    },
                    selectedColor: theme.colorScheme.secondaryContainer,
                  );
                }).toList(),
              ),

              // Help text for execution types
              if (selectedVariant == 'timer' ||
                  selectedVariant == 'duration_weight' ||
                  selectedVariant == 'distance_duration' ||
                  selectedVariant == 'weight_distance')
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getExecutionTypeHelpTitle(selectedVariant ?? ''),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getExecutionTypeHelpText(selectedVariant ?? ''),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLabel(String label) => label
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');

  String _formatExecutionTypeLabel(String executionType) {
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

  String _getExecutionTypeHelpTitle(String executionType) {
    switch (executionType) {
      case 'timer':
        return 'Duration Training';
      case 'duration_weight':
        return 'Weighted Duration';
      case 'distance_duration':
        return 'Cardio Training';
      case 'weight_distance':
        return 'Weighted Carries';
      default:
        return 'Execution Type';
    }
  }

  String _getExecutionTypeHelpText(String executionType) {
    switch (executionType) {
      case 'timer':
        return 'Time-based exercises like planks, wall sits, or isometric holds. Track duration in seconds.';
      case 'duration_weight':
        return 'Weighted exercises held for time, like farmer\'s carries or weighted planks. Track both weight and duration.';
      case 'distance_duration':
        return 'Cardio exercises like running, cycling, or rowing. Track both distance and time.';
      case 'weight_distance':
        return 'Weighted carries or sled pushes. Track both weight and distance covered.';
      default:
        return 'Select the appropriate execution type for your exercise.';
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('selectedEquipment', selectedEquipment));
    properties.add(StringProperty('selectedVariant', selectedVariant));
  }
}
