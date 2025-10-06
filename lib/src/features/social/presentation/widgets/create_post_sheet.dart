import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../../core/providers/auth_provider.dart';
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
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
        final file = File(image.path);
        final fileSize = await file.length();
        
        if (fileSize > _maxImageSizeBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image too large. Maximum size is 10MB'),
              ),
            );
          }
          return;
        }

        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<XFile?> _compressImage(XFile file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        '${file.path}_compressed.jpg',
        quality: 85,
        minWidth: 1080,
        minHeight: 1080,
      );
      
      return result;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  Future<void> _createPost() async {
    final caption = _captionController.text.trim();
    
    if (caption.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a caption or photo')),
      );
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
        final compressed = await _compressImage(_selectedImage!);
        final imageToUpload = compressed ?? _selectedImage!;
        
        final bytes = await imageToUpload.readAsBytes();
        final fileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'posts/$fileName';

        await Supabase.instance.client.storage
            .from('gym-images')
            .uploadBinary(path, bytes);

        imageUrl = Supabase.instance.client.storage
            .from('gym-images')
            .getPublicUrl(path);
      }

      final social = ref.read(socialServiceProvider);
      await social.createPost(
        userId: currentUser.id,
        caption: caption,
        imageUrl: imageUrl,
      );

      // Refresh the feed
      ref.invalidate(feedPostsProvider);
      ref.invalidate(explorePostsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }
}
