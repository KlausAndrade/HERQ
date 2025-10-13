import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../providers/social_providers.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _isPosting = false;

  // Image validation constants
  static const int _maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int _maxDimension = 2048;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final currentUserProfile = ref.watch(userProfileProvider(currentUser?.id ?? ''));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Create Post',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User info
          currentUserProfile.when(
            data: (profile) {
              return Row(
                children: [
                  if (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(profile.avatarUrl!),
                    )
                  else
                    CircleAvatar(
                      radius: 20,
                      child: Text(
                        profile?.displayName?[0].toUpperCase() ?? currentUser?.email?[0].toUpperCase() ?? '?',
                      ),
                    ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.displayName ?? currentUser?.email?.split('@').first ?? 'User',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (profile?.bio != null && profile!.bio!.isNotEmpty)
                        Text(
                          profile.bio!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              );
            },
            loading: () => Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            error: (_, __) => Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(currentUser?.email?[0].toUpperCase() ?? '?'),
                ),
                const SizedBox(width: 12),
                Text(
                  currentUser?.email?.split('@').first ?? 'User',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Caption input
          TextField(
            controller: _captionController,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Image preview
          if (_selectedImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(
                          _selectedImage!.path,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : FutureBuilder<Uint8List>(
                          future: _selectedImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            }
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() => _selectedImage = null);
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _isPosting ? null : _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Add Photo'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isPosting ? null : _createPost,
                child: _isPosting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxDimension.toDouble(),
        maxHeight: _maxDimension.toDouble(),
        imageQuality: 85,
      );

      if (image != null) {
        // Validate image size
        final bytes = await image.readAsBytes();
        final fileSize = bytes.length;
        
        if (fileSize > _maxImageSizeBytes) {
          if (mounted) {
              NotificationService().showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Image too large',
                body: 'Maximum size is 10MB',
              ).catchError((_) {});
            }
          return;
        }

        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Error picking image',
          body: '$e',
        ).catchError((_) {});
      }
    }
  }

  Future<Uint8List> _compressImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 85,
        minWidth: 1080,
        minHeight: 1080,
      );
      
      return result;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return await file.readAsBytes(); // Return original bytes if compression fails
    }
  }

  Future<void> _createPost() async {
    final caption = _captionController.text.trim();
    
      if (caption.isEmpty && _selectedImage == null) {
      NotificationService().showInAppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Empty post',
        body: 'Please add a caption or photo',
      ).catchError((_) {});
      return;
    }

    setState(() => _isPosting = true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Upload image to Supabase Storage if selected
      String? imageUrl;
      if (_selectedImage != null) {
        // Compress image first
        final compressedBytes = await _compressImage(_selectedImage!);
        
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = '${currentUser.id}/$fileName';

        await Supabase.instance.client.storage
            .from('post-images')
            .uploadBinary(path, compressedBytes);

        imageUrl = Supabase.instance.client.storage
            .from('post-images')
            .getPublicUrl(path);
      }

      // Insert post directly into Supabase
      await Supabase.instance.client.from('posts').insert({
        'user_id': currentUser.id,
        'caption': caption,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Refresh the feed
      ref.invalidate(feedPostsProvider);
      ref.invalidate(explorePostsProvider);

      if (mounted) {
        Navigator.pop(context);
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Post created',
          body: '',
        ).catchError((_) {});
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Error creating post',
          body: '$e',
        ).catchError((_) {});
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }
}
