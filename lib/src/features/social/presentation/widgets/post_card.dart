import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../workout/presentation/providers/active_workout_provider.dart';
import '../../../workout/presentation/providers/exercise_variant_preferences_provider.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../providers/social_providers.dart';
import 'edit_post_dialog.dart';

class PostCard extends ConsumerWidget {
  const PostCard({
    required this.post,
    required this.currentUserId,
    super.key,
  });

  final SupabasePost post;
  final String currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLikedAsync = ref.watch(hasLikedPostProvider(post.id));
    final likesCountAsync = ref.watch(likesCountProvider(post.id));
    final commentsCountAsync = ref.watch(commentsCountProvider(post.id));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isDark ? 2 : 1,
      color: isDark
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info (more compact)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: post.userAvatar != null
                      ? NetworkImage(post.userAvatar!)
                      : null,
                  child: post.userAvatar == null
                      ? Text(
                          (post.userName ?? post.userId)[0].toUpperCase(),
                          style: const TextStyle(fontSize: 14),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/user/${post.userId}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          post.userName ??
                              'User ${post.userId.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatTimestamp(post.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (currentUserId != post.userId)
                  // Follow button for other users' posts
                  Consumer(
                    builder: (context, ref, _) {
                      final isFollowingAsync =
                          ref.watch(isFollowingProvider(post.userId));
                      return isFollowingAsync.when(
                        data: (isFollowing) => OutlinedButton(
                          onPressed: () =>
                              _toggleFollow(ref, isFollowing, context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            isFollowing ? S.of(context)!.following : 'Follow',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 60,
                          height: 24,
                          child: Center(
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                if (currentUserId == post.userId)
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () => _showPostOptions(context, ref),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          // Image if available
          if (post.imageUrl != null)
            CachedNetworkImage(
              imageUrl: post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.error)),
              ),
            ),

          // Caption (more compact)
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Text(
                post.caption!,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            ),

          // Actions (more compact)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                // Like button
                hasLikedAsync.when(
                  data: (hasLiked) => IconButton(
                    icon: Icon(
                      hasLiked ? Icons.favorite : Icons.favorite_border,
                      color: hasLiked ? Colors.red : null,
                      size: 22,
                    ),
                    onPressed: () => _toggleLike(ref, hasLiked),
                    visualDensity: VisualDensity.compact,
                  ),
                  loading: () => const IconButton(
                    icon: Icon(Icons.favorite_border, size: 22),
                    onPressed: null,
                    visualDensity: VisualDensity.compact,
                  ),
                  error: (_, __) => const IconButton(
                    icon: Icon(Icons.favorite_border, size: 22),
                    onPressed: null,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                likesCountAsync.when(
                  data: (count) =>
                      Text('$count', style: const TextStyle(fontSize: 13)),
                  loading: () =>
                      const Text('...', style: TextStyle(fontSize: 13)),
                  error: (_, __) =>
                      const Text('0', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),

                // Comment button
                IconButton(
                  icon: const Icon(Icons.comment_outlined, size: 22),
                  onPressed: () => _showComments(context),
                  visualDensity: VisualDensity.compact,
                ),
                commentsCountAsync.when(
                  data: (count) =>
                      Text('$count', style: const TextStyle(fontSize: 13)),
                  loading: () =>
                      const Text('...', style: TextStyle(fontSize: 13)),
                  error: (_, __) =>
                      const Text('0', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),

                // View Workout button (if workout post)
                if (_isWorkoutPost())
                  IconButton(
                    icon: const Icon(Icons.fitness_center, size: 22),
                    onPressed: () => _showWorkoutDetails(context, ref),
                    visualDensity: VisualDensity.compact,
                    tooltip: S.of(context)!.viewWorkout,
                  ),

                const Spacer(),

                // Share button
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 22),
                  onPressed: () => _sharePost(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Check if this post is related to a workout (contains workout stats)
  bool _isWorkoutPost() {
    final caption = post.caption?.toLowerCase() ?? '';
    return caption.contains('sets') &&
        (caption.contains('reps') ||
            caption.contains('💪') ||
            caption.contains('🏋'));
  }

  /// Format timestamp to relative time (e.g., "2h ago", "3d ago")
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  Future<void> _toggleFollow(
      WidgetRef ref, bool isFollowing, BuildContext context) async {
    final social = ref.read(supabaseSocialServiceProvider);
    final l10n = S.of(context)!;

    try {
      if (isFollowing) {
        await social.unfollowUser(currentUserId, post.userId);
      } else {
        await social.followUser(currentUserId, post.userId);
      }

      // Refresh providers
      ref.invalidate(isFollowingProvider(post.userId));
      ref.invalidate(feedPostsProvider);

      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: isFollowing ? l10n.unfollowed : l10n.following,
            body: isFollowing
                ? l10n.youUnfollowed(post.userName ?? l10n.thisUser)
                : l10n.youAreNowFollowing(post.userName ?? l10n.thisUser),
          )
          .catchError((_) {});
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: l10n.error,
            body: isFollowing
                ? l10n.failedToUnfollowUser
                : l10n.failedToFollowUser,
          )
          .catchError((_) {});
    }
  }

  Future<void> _toggleLike(WidgetRef ref, bool hasLiked) async {
    final social = ref.read(supabaseSocialServiceProvider);

    try {
      if (hasLiked) {
        await social.unlikePost(post.id, currentUserId);
      } else {
        await social.likePost(post.id, currentUserId);
      }

      // Refresh providers
      ref.invalidate(hasLikedPostProvider(post.id));
      ref.invalidate(likesCountProvider(post.id));
      ref.invalidate(feedPostsProvider);
      ref.invalidate(explorePostsProvider);
    } catch (e) {
      // Handle error silently or show snackbar
      debugPrint('Error toggling like: $e');
    }
  }

  void _showComments(BuildContext context) {
    context.push('/post/${post.id}/comments');
  }

  Future<void> _sharePost(BuildContext context) async {
    try {
      // Create a shareable link to the post
      final webLink = 'https://herq.app/post/${post.id}';

      final l10n = S.of(context)!;
      final String shareText =
          (post.caption != null && post.caption!.isNotEmpty)
              ? '${post.caption}\n\n$webLink'
              : '${l10n.checkOutThisPost(l10n.appTitle)}\n$webLink';

      await Share.share(
        shareText,
        subject: l10n.postFrom(l10n.appTitle),
      );
    } catch (e) {
      if (context.mounted) {
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Failed to share',
              body: '$e',
            )
            .catchError((_) {});
      }
    }
  }

  Future<void> _showWorkoutDetails(BuildContext context, WidgetRef ref) async {
    // Extract workout details from caption
    final caption = post.caption ?? '';
    final workoutData = _parseWorkoutData(caption);

    // If this post has a workout session ID, fetch the actual exercises
    if (post.workoutSessionId != null) {
      try {
        print('🔍 Fetching exercises for session: ${post.workoutSessionId}');
        final exercises =
            await _fetchExercisesFromSession(ref, post.workoutSessionId!);
        if (exercises.isNotEmpty) {
          workoutData['exercises'] = exercises;
          print('✅ Loaded ${exercises.length} exercises from workout session');
        } else {
          print('⚠️ No exercises found in session ${post.workoutSessionId}');
        }
      } catch (e) {
        print('❌ Error fetching exercises from session: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    } else {
      print('⚠️ Post has no workout session ID');
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.fitness_center, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workoutData['workoutName'] ??
                                S.of(context)!.workoutDetails,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          Text(
                            post.userName ?? S.of(context)!.user,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Image if available
              if (post.imageUrl != null)
                ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              // Workout summary stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(
                      context: context,
                      icon: Icons.repeat,
                      label: S.of(context)!.sets,
                      value: workoutData['totalSets'] ?? '0',
                    ),
                    _StatChip(
                      context: context,
                      icon: Icons.fitness_center,
                      label: S.of(context)!.reps,
                      value: workoutData['totalReps'] ?? '0',
                    ),
                    _StatChip(
                      context: context,
                      icon: Icons.timer,
                      label: S.of(context)!.duration,
                      value: workoutData['duration'] ?? '0m',
                    ),
                    _StatChip(
                      context: context,
                      icon: Icons.scale,
                      label: S.of(context)!.totalVolume,
                      value: workoutData['volume'] ?? '0kg',
                    ),
                  ],
                ),
              ),

              // Exercise breakdown
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context)!.exerciseBreakdown,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      if (workoutData['exercises'] != null &&
                          workoutData['exercises'].isNotEmpty)
                        ...workoutData['exercises']
                            .map<Widget>(
                              (exercise) => _ExerciseCard(exercise: exercise),
                            )
                            .toList()
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.fitness_center_outlined,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                S.of(context)!.noExerciseDetailsAvailable,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _saveAsTemplate(context, ref, workoutData),
                        icon: const Icon(Icons.bookmark_border),
                        label: Text(S.of(context)!.saveTemplate),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            _startWorkout(context, ref, workoutData),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(S.of(context)!.startWorkout),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parse workout data from caption text
  Map<String, dynamic> _parseWorkoutData(String caption) {
    final data = <String, dynamic>{};

    // Extract workout name (first line after 💪)
    final workoutNameMatch =
        RegExp('💪 Just finished (.+)').firstMatch(caption);
    data['workoutName'] = workoutNameMatch?.group(1) ?? 'Workout';

    // Extract basic stats using regex patterns
    final setsMatch = RegExp(r'(\d+)\s*sets').firstMatch(caption);
    final repsMatch = RegExp(r'(\d+)\s*reps').firstMatch(caption);
    final durationMatch = RegExp(r'(\d+[hm])').firstMatch(caption);
    final volumeMatch = RegExp(r'(\d+)\s*kg').firstMatch(caption);

    data['totalSets'] = setsMatch?.group(1) ?? '0';
    data['totalReps'] = repsMatch?.group(1) ?? '0';
    data['duration'] = durationMatch?.group(1) ?? '0m';
    data['volume'] = volumeMatch?.group(1) ?? '0kg';

    return data;
  }

  /// Save workout as template
  Future<void> _saveAsTemplate(BuildContext context, WidgetRef ref,
      Map<String, dynamic> workoutData) async {
    Navigator.pop(context);

    // Show dialog to get template name
    final templateName = await _showTemplateNameDialog(context);
    if (templateName == null || templateName.trim().isEmpty) {
      return; // User cancelled or entered empty name
    }

    try {
      // Get the current user
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the database
      final db = ref.read(databaseProvider);
      if (db == null) {
        throw Exception('Database not available');
      }

      // If this post has a workout session ID, fetch the actual exercises
      List<String> exerciseIds = [];
      if (post.workoutSessionId != null) {
        exerciseIds =
            await _fetchExerciseIdsFromSession(ref, post.workoutSessionId!);
      }

      // If no exercises found, use common exercises as fallback
      if (exerciseIds.isEmpty) {
        exerciseIds = await _fetchCommonExercises(ref);
      }

      // Create the template
      final templateId = 'template_${DateTime.now().millisecondsSinceEpoch}';
      await db.into(db.workoutTemplates).insert(
            WorkoutTemplatesCompanion.insert(
              id: templateId,
              name: templateName.trim(),
              userId: Value(currentUser.id),
              description: Value(
                  'Template created from ${post.userName ?? 'user'}\'s workout'),
              category: const Value('Social'),
              exerciseIds: Value(exerciseIds),
              tags: const [],
              estimatedDurationMinutes: const Value(30), // Default estimate
              isDefault: const Value(false),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

      // Show success notification
      if (context.mounted) {
        final l10n = S.of(context)!;
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: l10n.templateSaved,
              body: l10n.templateSavedSuccess(templateName),
            )
            .catchError((_) {});
      }

      print(
          '✅ Template saved: $templateName with ${exerciseIds.length} exercises');
    } catch (e) {
      print('❌ Error saving template: $e');
      if (context.mounted) {
        final l10n = S.of(context)!;
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: l10n.error,
              body: l10n.failedToSaveTemplate,
            )
            .catchError((_) {});
      }
    }
  }

  /// Show dialog to get template name from user
  Future<String?> _showTemplateNameDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l10n = S.of(context)!;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.bookmark_add),
            const SizedBox(width: 12),
            Text(l10n.saveAsTemplate),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.enterTemplateName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.templateName,
                  hintText: l10n.templateNameHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterTemplateName;
                  }
                  if (value.trim().length < 3) {
                    return l10n.templateNameMinLength;
                  }
                  return null;
                },
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  /// Fetch exercise IDs from workout session (from Supabase)
  Future<List<String>> _fetchExerciseIdsFromSession(
      WidgetRef ref, String sessionId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      print('🔍 Querying Supabase for exercise IDs in session: $sessionId');

      // Fetch set entries for this session from Supabase
      final setEntriesData = await supabase
          .from('set_entries')
          .select('exercise_id')
          .eq('workout_session_id', sessionId);

      if (setEntriesData.isEmpty) {
        print('⚠️ No set entries found in Supabase');
        return [];
      }

      // Extract unique exercise IDs
      final exerciseIds = setEntriesData
          .map((entry) => entry['exercise_id'] as String)
          .toSet()
          .toList();

      print('📋 Found ${exerciseIds.length} unique exercises in session');
      return exerciseIds;
    } catch (e) {
      print('⚠️ Error fetching exercise IDs from session: $e');
      return [];
    }
  }

  /// Fetch detailed exercise data from workout session (from Supabase)
  Future<List<Map<String, dynamic>>> _fetchExercisesFromSession(
      WidgetRef ref, String sessionId) async {
    try {
      print('🔍 Fetching exercises for session: $sessionId');

      // Use the new provider to fetch set entries from Supabase
      final setEntriesAsync =
          ref.read(setEntriesBySessionFromSupabaseProvider(sessionId).future);
      final setEntriesData = await setEntriesAsync;

      print('📊 Found ${setEntriesData.length} set entries');

      if (setEntriesData.isEmpty) {
        print('⚠️ No set entries found for session $sessionId');
        return [];
      }

      // Get unique exercise IDs
      final exerciseIds = setEntriesData
          .map((entry) => entry['exercise_id'] as String)
          .toSet()
          .toList();

      print('📋 Found ${exerciseIds.length} unique exercises');

      // Fetch exercise details separately (workaround for FK relationship not in cache)
      final supabase = ref.read(supabaseClientProvider);
      final exercisesData = await supabase
          .from('exercises')
          .select('id, name, exercise_type, equipment, primary_muscle_group')
          .inFilter('id', exerciseIds);

      print('✅ Fetched ${exercisesData.length} exercise details');

      // Create exercise info map
      final Map<String, Map<String, dynamic>> exerciseInfoMap = {
        for (final ex in exercisesData) ex['id'] as String: ex,
      };

      // Group sets by exercise
      final Map<String, List<Map<String, dynamic>>> exerciseSetsMap = {};

      for (final setEntry in setEntriesData) {
        final exerciseId = setEntry['exercise_id'] as String;

        if (!exerciseSetsMap.containsKey(exerciseId)) {
          exerciseSetsMap[exerciseId] = [];
        }
        exerciseSetsMap[exerciseId]!.add(setEntry);
      }

      // Create exercise summaries with sets
      final List<Map<String, dynamic>> exercises = [];

      for (final entry in exerciseSetsMap.entries) {
        final exerciseId = entry.key;
        final sets = entry.value;
        final exerciseInfo = exerciseInfoMap[exerciseId];

        if (exerciseInfo != null) {
          // Calculate totals
          final totalSets = sets.length;
          final totalReps =
              sets.fold<int>(0, (sum, set) => sum + (set['reps'] as int? ?? 0));

          // Handle weight as either int or double from Supabase
          final maxWeight = sets
              .map((set) {
                final weight = set['weight'];
                if (weight == null) return null;
                if (weight is double) return weight;
                if (weight is int) return weight.toDouble();
                return null;
              })
              .whereType<double>()
              .fold<double?>(null,
                  (max, weight) => max == null || weight > max ? weight : max);

          final exerciseName = exerciseInfo['name'] as String;
          print(
              '💪 Creating exercise: $exerciseName ($totalSets sets, $totalReps reps)');

          // Safely extract equipment (handle potential array or string)
          final equipment = exerciseInfo['equipment'];
          final equipmentStr = equipment is String ? equipment : 'bodyweight';

          exercises.add({
            'id': exerciseId,
            'name': exerciseName,
            'sets': totalSets,
            'reps': totalReps,
            'weight': maxWeight != null ? '${maxWeight}kg' : 'Bodyweight',
            'equipment': equipmentStr,
            'sets_detail': sets.map((set) {
              final weight = set['weight'];
              final weightDouble = weight == null
                  ? 0.0
                  : (weight is double ? weight : (weight as int).toDouble());
              return {
                'reps': set['reps'] as int? ?? 0,
                'weight': weightDouble,
                'isCompleted': true,
              };
            }).toList(),
          });
        } else {
          print('⚠️ Skipping exercise $exerciseId - no exercise info found');
        }
      }

      print('✅ Created ${exercises.length} exercise summaries from Supabase');
      return exercises;
    } catch (e) {
      print('❌ Error fetching exercises from session: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Start workout from template
  Future<void> _startWorkout(BuildContext context, WidgetRef ref,
      Map<String, dynamic> workoutData) async {
    // Store the navigator before popping
    final navigator = Navigator.of(context);
    final goRouter = GoRouter.of(context);

    // Close the dialog
    navigator.pop();

    try {
      // Create a new workout from the template
      final workoutName = workoutData['workoutName'] ??
          'Workout from ${post.userName ?? 'User'}';

      // If this post has a workout session ID, fetch the actual workout data
      if (post.workoutSessionId != null) {
        print(
            '🔍 Fetching workout data from session: ${post.workoutSessionId}');
        await _startWorkoutFromSession(
            goRouter, ref, workoutName, post.workoutSessionId!);
      } else {
        // Fallback: Create a basic workout with common exercises
        print('⚠️ No workout session ID, creating basic workout');
        final exerciseIds = await _fetchCommonExercises(ref);

        await ref
            .read(activeWorkoutProvider.notifier)
            .startWorkoutFromExerciseIds(
              workoutName,
              exerciseIds,
            );

        if (context.mounted) {
          final l10n = S.of(context)!;
          context.go('/active-workout');
          NotificationService()
              .showInAppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: l10n.workoutStarted,
                body: l10n.startingWorkout(workoutName, exerciseIds.length),
              )
              .catchError((_) {});
        }
      }
    } catch (e) {
      print('❌ Error starting workout: $e');
      if (context.mounted) {
        final l10n = S.of(context)!;
        NotificationService()
            .showInAppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: l10n.error,
              body: l10n.failedToStartWorkout,
            )
            .catchError((_) {});
      }
    }
  }

  /// Start workout from an existing session (fetch actual exercise data from Supabase)
  Future<void> _startWorkoutFromSession(
    GoRouter goRouter,
    WidgetRef ref,
    String workoutName,
    String sessionId,
  ) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      print('🔍 Fetching workout data from Supabase for session: $sessionId');

      // Fetch set entries for this session (without join)
      final setEntriesData = await supabase
          .from('set_entries')
          .select()
          .eq('workout_session_id', sessionId)
          .order('set_number');

      if (setEntriesData.isEmpty) {
        print('⚠️ No set entries found for session $sessionId');
        throw Exception('No workout data found');
      }

      print('✅ Found ${setEntriesData.length} sets from workout session');

      // Get unique exercise IDs and extract variant info
      final exerciseIds = <String>{};
      final exerciseVariantMap = <String, Map<String, String?>>{};
      
      for (final entry in setEntriesData) {
        final exerciseId = entry['exercise_id'] as String;
        exerciseIds.add(exerciseId);
        
        // Extract variant info from set entries (use most common variant per exercise)
        if (!exerciseVariantMap.containsKey(exerciseId)) {
          final equipmentUsed = entry['equipment_used'] as String?;
          final variantType = entry['variant_type'] as String?;
          
          // Only store if variant info exists
          if (equipmentUsed != null || variantType != null) {
            exerciseVariantMap[exerciseId] = {
              'equipment': equipmentUsed,
              'variant': variantType,
            };
          }
        }
      }

      final exerciseIdsList = exerciseIds.toList();
      print('📋 Found ${exerciseIdsList.length} unique exercises');
      print('📋 Found variant info for ${exerciseVariantMap.length} exercises');

      // Fetch exercise details separately
      final exercisesData = await supabase
          .from('exercises')
          .select('id, name, exercise_type, equipment, primary_muscle_group')
          .inFilter('id', exerciseIdsList);

      print('✅ Fetched ${exercisesData.length} exercise details');

      // Create exercise data map
      final Map<String, Map<String, dynamic>> exerciseDataMap = {
        for (final ex in exercisesData) ex['id'] as String: ex,
      };

      // Ensure exercises exist in local database (copy from Supabase if needed)
      await _ensureExercisesExist(ref, exerciseDataMap);

      // Save variant preferences from the copied workout
      if (exerciseVariantMap.isNotEmpty) {
        print('💾 Saving variant preferences from copied workout...');
        final variantPrefsNotifier = ref.read(exerciseVariantPreferencesProvider.notifier);
        
        for (final entry in exerciseVariantMap.entries) {
          final exerciseId = entry.key;
          final variantInfo = entry.value;
          final equipmentUsed = variantInfo['equipment'];
          final variantType = variantInfo['variant'];
          
          if (equipmentUsed != null) {
            await variantPrefsNotifier.setVariantForExercise(
              exerciseId,
              equipmentUsed,
              variantType,
            );
            print('  ✓ Saved variant for $exerciseId: $equipmentUsed / $variantType');
          }
        }
      }

      print('🏋️ Starting workout with ${exerciseIdsList.length} exercises');

      // Start workout with the fetched exercises
      await ref
          .read(activeWorkoutProvider.notifier)
          .startWorkoutFromExerciseIds(
            workoutName,
            exerciseIdsList,
          );

      // Navigate to active workout screen
      goRouter.go('/active-workout');

      // Note: Can't use context here as dialog is closed, using hardcoded English
      // The notification will use device locale automatically if we had access to l10n
      NotificationService()
          .showInAppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Workout Started',
            body:
                'Starting $workoutName with ${exerciseIds.length} exercises...',
          )
          .catchError((_) {});
    } catch (e) {
      print('❌ Error starting workout from session: $e');
      rethrow;
    }
  }

  /// Ensure exercises exist in local database (copy from Supabase if needed)
  Future<void> _ensureExercisesExist(
    WidgetRef ref,
    Map<String, Map<String, dynamic>> exerciseDataMap,
  ) async {
    final db = ref.read(databaseProvider);
    if (db == null) {
      print('⚠️ Database not available, skipping exercise copy');
      return;
    }

    for (final entry in exerciseDataMap.entries) {
      final exerciseId = entry.key;
      final exerciseData = entry.value;

      try {
        // Check if exercise already exists in local database
        final existingExercise = await (db.select(db.exercises)
              ..where((tbl) => tbl.id.equals(exerciseId)))
            .getSingleOrNull();

        if (existingExercise == null) {
          // Exercise doesn't exist, copy it from Supabase data
          print(
              '📋 Copying exercise to local database: ${exerciseData['name']}');

          await db.into(db.exercises).insert(
                ExercisesCompanion.insert(
                  id: exerciseId,
                  name: exerciseData['name'] as String,
                  primaryMuscleGroup:
                      exerciseData['primary_muscle_group'] as String? ??
                          'other',
                  equipment:
                      exerciseData['equipment'] as String? ?? 'bodyweight',
                  instructions: '',
                  secondaryMuscleGroups: const [],
                  tags: const [],
                  category: const Value('Other'),
                  difficulty: const Value('intermediate'),
                  exerciseType:
                      Value(exerciseData['exercise_type'] as String? ?? 'reps'),
                  userId:
                      const Value(null), // Null means accessible to all users
                ),
                mode: InsertMode.insertOrIgnore,
              );

          print('✅ Exercise copied successfully');
        } else {
          print('✓ Exercise already exists: ${existingExercise.name}');
        }
      } catch (e) {
        print('⚠️ Failed to copy exercise $exerciseId: $e');
        // Continue with other exercises even if one fails
      }
    }
  }

  /// Fetch common exercises from database as fallback
  Future<List<String>> _fetchCommonExercises(WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      if (db == null) {
        print('⚠️ Database not available, returning empty exercise list');
        return [];
      }

      // Fetch popular compound exercises
      final exercises = await (db.select(db.exercises)
            ..where(
              (tbl) => tbl.name.isIn([
                'Squats',
                'Barbell Squats',
                'Back Squats',
                'Romanian Deadlifts',
                'Deadlifts',
                'Bench Press',
                'Barbell Bench Press',
                'Overhead Press',
                'Barbell Row',
                'Pull-ups',
                'Lat Pulldown',
              ]),
            )
            ..limit(5))
          .get();

      if (exercises.isEmpty) {
        // Fallback: Get any 5 exercises
        print('⚠️ No common exercises found, fetching any 5 exercises');
        final anyExercises = await (db.select(db.exercises)..limit(5)).get();
        return anyExercises.map((e) => e.id).toList();
      }

      return exercises.map((e) => e.id).toList();
    } catch (e) {
      print('❌ Error fetching exercises: $e');
      return [];
    }
  }

  void _showPostOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'Post Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Post'),
            onTap: () async {
              Navigator.pop(context);
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => EditPostDialog(
                  postId: post.id,
                  initialCaption: post.caption ?? '',
                ),
              );

              if (result ?? false && context.mounted) {
                ref.invalidate(feedPostsProvider);
                ref.invalidate(explorePostsProvider);
                ref.invalidate(userPostsProvider(currentUserId));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title:
                const Text('Delete Post', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Post'),
                  content:
                      const Text('Are you sure you want to delete this post?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm ?? false && context.mounted) {
                try {
                  final social = ref.read(supabaseSocialServiceProvider);
                  await social.deletePost(post.id);
                  ref.invalidate(feedPostsProvider);
                  ref.invalidate(explorePostsProvider);
                  ref.invalidate(userPostsProvider(currentUserId));

                  if (context.mounted) {
                    NotificationService()
                        .showInAppNotification(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: 'Deleted',
                          body: 'Post deleted successfully',
                        )
                        .catchError((_) {});
                  }
                } catch (e) {
                  if (context.mounted) {
                    NotificationService()
                        .showInAppNotification(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: 'Failed to delete post',
                          body: '$e',
                        )
                        .catchError((_) {});
                  }
                  print('Delete post error: $e');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SupabasePost>('post', post));
    properties.add(StringProperty('currentUserId', currentUserId));
  }
}

/// Stat chip widget for workout summary
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.context,
    required this.icon,
    required this.label,
    required this.value,
  });

  final BuildContext context;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext buildContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(buildContext).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(buildContext).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(buildContext).textTheme.bodySmall?.copyWith(
                  color: Theme.of(buildContext).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      );
}

/// Exercise card widget for workout breakdown
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
  });

  final Map<String, dynamic> exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;

    // Handle both string and int types from database
    final setsRaw = exercise['sets'];
    final repsRaw = exercise['reps'];

    final sets =
        setsRaw is int ? setsRaw : (int.tryParse(setsRaw.toString()) ?? 0);
    final reps =
        repsRaw is int ? repsRaw : (int.tryParse(repsRaw.toString()) ?? 0);
    final weight = exercise['weight'] as String? ?? l10n.bodyweight;
    final name = exercise['name'] as String? ?? l10n.exercise;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.fitness_center,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$sets ${l10n.sets} × $reps ${l10n.reps}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              weight,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
