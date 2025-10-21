import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';
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
  bool _isPickingImage = false; // Prevent multiple simultaneous picker calls
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
    // Prevent multiple simultaneous picker calls (iOS issue)
    if (_isPickingImage) {
      print('⚠️ Image picker already in progress, ignoring');
      return;
    }

    setState(() => _isPickingImage = true);

    try {
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

        if (mounted) {
          setState(() {
            _imageBytes = Uint8List.fromList(compressed);
          });
        }
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      // Don't show error for user cancellation
      if (!e.toString().contains('Cancelled by a second request') && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
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
        final fileName =
            '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage.from('avatars').uploadBinary(
              '${currentUser.id}/$fileName',
              _imageBytes!,
            );

        avatarUrl = supabase.storage
            .from('avatars')
            .getPublicUrl('${currentUser.id}/$fileName');
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
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: S.of(context)!.profileUpdated,
          body: S.of(context)!.profileUpdatedSuccessfully,
          backgroundColor: Colors.green,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: S.of(context)!.profileUpdateFailed,
          body: '${S.of(context)!.errorUpdatingProfile}: $e',
          backgroundColor: Colors.red,
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
        title: Text(S.of(context)!.editProfile),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
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
              child: Text(S.of(context)!.save),
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
              decoration: InputDecoration(
                labelText: S.of(context)!.displayName,
                hintText: S.of(context)!.enterDisplayName,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.of(context)!.pleaseEnterDisplayName;
                }
                if (value.trim().length < 2) {
                  return S.of(context)!.nameAtLeast2Chars;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: S.of(context)!.bio,
                hintText: S.of(context)!.tellUsAboutYourself,
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 200,
              validator: (value) {
                if (value != null && value.trim().length > 200) {
                  return S.of(context)!.bioMaxLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Email (read-only)
            TextFormField(
              initialValue: currentUser?.email ?? '',
              decoration: InputDecoration(
                labelText: S.of(context)!.email,
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
                enabled: false,
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Settings
            Card(
              child: SwitchListTile(
                title: Text(S.of(context)!.privateAccount),
                subtitle: Text(
                  S.of(context)!.privateAccountDescription,
                ),
                value: _isPrivate,
                onChanged: (value) => setState(() => _isPrivate = value),
                secondary: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Info text
            Text(
              S.of(context)!.emailCannotBeChanged,
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
