import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/social_providers.dart';
import 'package:herq/src/core/services/notification_service.dart';

class EditPostDialog extends ConsumerStatefulWidget {
  const EditPostDialog({
    super.key,
    required this.postId,
    required this.initialCaption,
  });

  final String postId;
  final String initialCaption;

  @override
  ConsumerState<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends ConsumerState<EditPostDialog> {
  late final TextEditingController _captionController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.initialCaption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    final caption = _captionController.text.trim();
    
    if (caption.isEmpty) {
      NotificationService().showInAppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Empty caption',
        body: 'Caption cannot be empty',
      ).catchError((_) {});
      return;
    }

    setState(() => _isUpdating = true);

    try {
      await ref.read(editPostProvider((postId: widget.postId, caption: caption)).future);
      
      if (mounted) {
        Navigator.pop(context, true);
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Updated',
          body: 'Post updated successfully',
        ).catchError((_) {});
      }
    } catch (e) {
      if (mounted) {
        NotificationService().showInAppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Failed to update post',
          body: '$e',
        ).catchError((_) {});
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Post'),
      content: TextField(
        controller: _captionController,
        maxLines: 5,
        maxLength: 500,
        decoration: const InputDecoration(
          hintText: 'What\'s on your mind?',
          border: OutlineInputBorder(),
        ),
        enabled: !_isUpdating,
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isUpdating ? null : _updatePost,
          child: _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
