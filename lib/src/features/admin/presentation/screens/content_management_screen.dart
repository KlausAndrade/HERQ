import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/auth_provider.dart';

class ContentManagementScreen extends ConsumerStatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  ConsumerState<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends ConsumerState<ContentManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _primaryMuscleGroupController = TextEditingController();
  final _equipmentController = TextEditingController();
  
  String _category = 'strength';
  String _difficulty = 'intermediate';
  String _exerciseType = 'weight_reps';
  bool _isBodyweight = false;
  List<String> _secondaryMuscleGroups = [];
  List<String> _tags = [];
  List<String> _aliases = [];

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _primaryMuscleGroupController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _createExercise() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final supabase = ref.read(supabaseClientProvider);
      
      final exerciseData = {
        'id': _generateExerciseId(_nameController.text),
        'name': _nameController.text,
        'primary_muscle_group': _primaryMuscleGroupController.text,
        'secondary_muscle_groups': _secondaryMuscleGroups,
        'equipment': _equipmentController.text,
        'instructions': _instructionsController.text,
        'tags': _tags,
        'aliases': _aliases,
        'is_bodyweight': _isBodyweight,
        'exercise_type': _exerciseType,
        'category': _category,
        'difficulty': _difficulty,
        'user_id': null, // Global exercise
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('exercises').insert(exerciseData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise created successfully!')),
        );
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating exercise: $e')),
        );
      }
    }
  }

  String _generateExerciseId(String name) {
    return name.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  void _clearForm() {
    _nameController.clear();
    _instructionsController.clear();
    _primaryMuscleGroupController.clear();
    _equipmentController.clear();
    _secondaryMuscleGroups.clear();
    _tags.clear();
    _aliases.clear();
    setState(() {
      _category = 'strength';
      _difficulty = 'intermediate';
      _exerciseType = 'weight_reps';
      _isBodyweight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
        backgroundColor: const Color(0xFF00BFA6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New Exercise',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Exercise Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _primaryMuscleGroupController,
                        decoration: const InputDecoration(
                          labelText: 'Primary Muscle Group',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _equipmentController,
                        decoration: const InputDecoration(
                          labelText: 'Equipment',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _instructionsController,
                        decoration: const InputDecoration(
                          labelText: 'Instructions',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _category,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'strength', child: Text('Strength')),
                                DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                                DropdownMenuItem(value: 'flexibility', child: Text('Flexibility')),
                                DropdownMenuItem(value: 'calisthenics', child: Text('Calisthenics')),
                              ],
                              onChanged: (value) => setState(() => _category = value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _difficulty,
                              decoration: const InputDecoration(
                                labelText: 'Difficulty',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                                DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                                DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                                DropdownMenuItem(value: 'expert', child: Text('Expert')),
                              ],
                              onChanged: (value) => setState(() => _difficulty = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _exerciseType,
                              decoration: const InputDecoration(
                                labelText: 'Exercise Type',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'weight_reps', child: Text('Weight & Reps')),
                                DropdownMenuItem(value: 'body_weight_reps', child: Text('Bodyweight Reps')),
                                DropdownMenuItem(value: 'duration', child: Text('Duration')),
                                DropdownMenuItem(value: 'distance', child: Text('Distance')),
                              ],
                              onChanged: (value) => setState(() => _exerciseType = value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Bodyweight'),
                              value: _isBodyweight,
                              onChanged: (value) => setState(() => _isBodyweight = value ?? false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _createExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Create Exercise'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bulk Operations',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _bulkImportExercises(),
                              icon: const Icon(Icons.upload),
                              label: const Text('Import from CSV'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _exportExercises(),
                              icon: const Icon(Icons.download),
                              label: const Text('Export to CSV'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bulkImportExercises() async {
    // TODO: Implement CSV import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV import coming soon!')),
    );
  }

  Future<void> _exportExercises() async {
    // TODO: Implement CSV export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV export coming soon!')),
    );
  }
}
