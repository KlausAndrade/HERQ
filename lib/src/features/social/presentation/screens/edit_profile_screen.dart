import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../../core/providers/auth_provider.dart';
import '../providers/social_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPrivate = false;
  Uint8List? _imageBytes;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final profile = await ref.read(userProfileProvider(currentUser.id).future);
    if (profile != null) {
      _displayNameController.text = profile.displayName ?? '';
      _bioController.text = profile.bio ?? '';
      _currentAvatarUrl = profile.avatarUrl;
      _isPrivate = profile.isPrivate;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      
      // Compress image
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 512,
        minHeight: 512,
        quality: 85,
      );

      setState(() {
        _imageBytes = Uint8List.fromList(compressed);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      String? avatarUrl = _currentAvatarUrl;

      // Upload new avatar if selected
      if (_imageBytes != null) {
        final supabase = ref.read(supabaseProvider);
        final fileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        await supabase.storage.from('avatars').uploadBinary(
          '${currentUser.id}/$fileName',
          _imageBytes!,
        );

        avatarUrl = supabase.storage.from('avatars').getPublicUrl('${currentUser.id}/$fileName');
      }

      // Update profile
      final socialService = ref.read(supabaseSocialServiceProvider);
      await socialService.updateProfile(
        userId: currentUser.id,
        displayName: _displayNameController.text.trim().isEmpty 
            ? null 
            : _displayNameController.text.trim(),
        avatarUrl: avatarUrl,
        bio: _bioController.text.trim().isEmpty 
            ? null 
            : _bioController.text.trim(),
        isPrivate: _isPrivate,
      );

      // Invalidate profile cache
      ref.invalidate(userProfileProvider(currentUser.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : (_currentAvatarUrl != null
                            ? NetworkImage(_currentAvatarUrl!)
                            : null) as ImageProvider?,
                    child: _imageBytes == null && _currentAvatarUrl == null
                        ? Text(
                            (currentUser?.email ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        color: Colors.white,
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Display Name
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter your display name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a display name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 200,
              validator: (value) {
                if (value != null && value.trim().length > 200) {
                  return 'Bio must be less than 200 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Email (read-only)
            TextFormField(
              initialValue: currentUser?.email ?? '',
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                enabled: false,
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Settings
            Card(
              child: SwitchListTile(
                title: const Text('Private Account'),
                subtitle: const Text(
                  'When your account is private, only followers can see your posts',
                ),
                value: _isPrivate,
                onChanged: (value) => setState(() => _isPrivate = value),
                secondary: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Info text
            Text(
              'Your email cannot be changed. Contact support if you need assistance.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
