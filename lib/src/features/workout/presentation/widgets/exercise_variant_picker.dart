import 'package:flutter/material.dart';

/// A compact picker for selecting equipment and variant type for an exercise
class ExerciseVariantPicker extends StatelessWidget {
  final String? currentEquipment;
  final String? currentVariant;
  final Function(String? equipment, String? variant) onChanged;

  const ExerciseVariantPicker({
    super.key,
    this.currentEquipment,
    this.currentVariant,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _getEquipmentIcon(currentEquipment),
        size: 20,
      ),
      tooltip: _getTooltip(),
      onPressed: () => _showPicker(context),
    );
  }

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

  String _formatEquipment(String equipment) {
    return equipment[0].toUpperCase() + equipment.substring(1);
  }

  String _formatVariant(String variant) {
    return variant[0].toUpperCase() + variant.substring(1);
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _VariantPickerSheet(
        currentEquipment: currentEquipment,
        currentVariant: currentVariant,
        onChanged: (equipment, variant) {
          onChanged(equipment, variant);
        },
      ),
    );
  }
}

class _VariantPickerSheet extends StatefulWidget {
  final String? currentEquipment;
  final String? currentVariant;
  final Function(String? equipment, String? variant) onChanged;

  const _VariantPickerSheet({
    this.currentEquipment,
    this.currentVariant,
    required this.onChanged,
  });

  @override
  State<_VariantPickerSheet> createState() => _VariantPickerSheetState();
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

  static const variantOptions = [
    'standard',
    'assisted',
    'weighted',
    'tempo',
    'pause',
  ];

  @override
  void initState() {
    super.initState();
    selectedEquipment = widget.currentEquipment;
    selectedVariant = widget.currentVariant ?? 'standard';
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
                      widget.onChanged(newEquipment, selectedVariant == 'standard' ? null : selectedVariant);
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Variant Type Selection
              Text(
                'Variant Type',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: variantOptions.map((variant) {
                  final isSelected = variant == selectedVariant;
                  return ChoiceChip(
                    label: Text(_formatLabel(variant)),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newVariant = selected ? variant : 'standard';
                      setState(() {
                        selectedVariant = newVariant;
                      });
                      // Apply change immediately
                      widget.onChanged(selectedEquipment, newVariant == 'standard' ? null : newVariant);
                    },
                    selectedColor: theme.colorScheme.secondaryContainer,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLabel(String label) {
    return label.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
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
}

