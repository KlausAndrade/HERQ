import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../domain/models/workout_summary.dart';

/// Screen shown before saving a workout, allows user to add notes, photos, and post to social
class WorkoutSaveScreen extends ConsumerStatefulWidget {
  const WorkoutSaveScreen({
    required this.summary,
    required this.onDiscard,
    required this.onSave,
    super.key,
  });
  final WorkoutSummary summary;
  final VoidCallback onDiscard;
  final Function(
    String name,
    String? notes,
    String? photoPath,
    bool postToSocial,
  ) onSave;

  @override
  ConsumerState<WorkoutSaveScreen> createState() => _WorkoutSaveScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<WorkoutSummary>('summary', summary));
    properties
        .add(ObjectFlagProperty<VoidCallback>.has('onDiscard', onDiscard));
    properties.add(ObjectFlagProperty<
        Function(String name, String? notes, String? photoPath,
            bool postToSocial)>.has('onSave', onSave));
  }
}

class _WorkoutSaveScreenState extends ConsumerState<WorkoutSaveScreen> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  String? _photoPath;
  bool _postToSocial = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.summary.workoutName);
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(S.of(context)!.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(S.of(context)!.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removePhoto() {
    setState(() {
      _photoPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)!.saveWorkout),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showDiscardDialog,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.timer_outlined,
                          label: S.of(context)!.duration,
                          value: _formatDuration(widget.summary.duration),
                        ),
                        _StatItem(
                          icon: Icons.fitness_center,
                          label: S.of(context)!.volume,
                          value:
                              '${widget.summary.totalVolume.toStringAsFixed(0)} kg',
                        ),
                        _StatItem(
                          icon: Icons.repeat,
                          label: S.of(context)!.sets,
                          value: widget.summary.totalSets.toString(),
                        ),
                      ],
                    ),
                    if (widget.summary.prs.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.summary.prs.length} ${widget.summary.prs.length > 1 ? S.of(context)!.personalRecords : S.of(context)!.personalRecord}!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Workout Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: S.of(context)!.workoutName,
                hintText: S.of(context)!.enterWorkoutName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),

            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: S.of(context)!.notesOptional,
                hintText: S.of(context)!.notesPlaceholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 16),

            // Photo Section
            if (_photoPath != null)
              _buildPhotoPreview()
            else
              _buildAddPhotoButton(),

            const SizedBox(height: 16),

            // Post to Social Toggle
            Card(
              child: SwitchListTile(
                value: _postToSocial,
                onChanged: (value) => setState(() => _postToSocial = value),
                title: Text(S.of(context)!.shareToSocialFeed),
                subtitle: Text(S.of(context)!.letOthersSee),
                secondary: Icon(
                  Icons.share,
                  color: _postToSocial ? theme.colorScheme.primary : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showDiscardDialog,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(S.of(context)!.discard),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveWorkout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(S.of(context)!.saveWorkout),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() => OutlinedButton.icon(
        onPressed: _showImageSourcePicker,
        icon: const Icon(Icons.add_photo_alternate),
        label: Text(S.of(context)!.addPhoto),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          minimumSize: const Size(double.infinity, 56),
        ),
      );

  Widget _buildPhotoPreview() => Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_photoPath!),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: _removePhoto,
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      );

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void _saveWorkout() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.pleaseEnterWorkoutName)),
      );
      return;
    }

    final notes = _notesController.text.trim();
    widget.onSave(
      name,
      notes.isEmpty ? null : notes,
      _photoPath,
      _postToSocial,
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${S.of(context)!.discardWorkout}?'),
        content: Text(S.of(context)!.workoutNotSaved),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onDiscard();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context)!.discard),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('value', value));
  }
}
