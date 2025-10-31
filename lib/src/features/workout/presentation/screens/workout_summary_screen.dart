import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/swipe_back_wrapper.dart';
import '../../domain/models/workout_summary.dart';

class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({required this.summary, super.key});

  final WorkoutSummary summary;

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<WorkoutSummary>('summary', summary));
  }
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start animations
    _animationController.forward();

    // Always show confetti - finishing a workout is always an achievement! 🎉
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SwipeBackWrapperWithFeedback(
      onSwipeBack: () => context.go('/'),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => context.go('/'),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _shareWorkout(context),
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          // Celebration icon
                          _buildAnimatedIcon(),

                          const SizedBox(height: 16),

                          // Title
                          _buildTitle(),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            widget.summary.workoutName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          // Main stats cards
                          _buildMainStatsCards(),

                          const SizedBox(height: 24),

                          // PRs section
                          if (widget.summary.prs.isNotEmpty) ...[
                            _buildPRsSection(),
                            const SizedBox(height: 24),
                          ],

                          // Achievements section
                          if (widget
                              .summary
                              .achievements
                              .hasAnyAchievement) ...[
                            _buildAchievementsSection(),
                            const SizedBox(height: 24),
                          ],

                          // Exercise breakdown
                          _buildExerciseBreakdown(),

                          const SizedBox(height: 32),

                          // Action button
                          _buildFinishButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.3,
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                  colorScheme.tertiary,
                  Colors.orange,
                  Colors.green,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() => ScaleTransition(
    scale: CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ),
    child: Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(Icons.emoji_events, size: 64, color: Colors.white),
    ),
  );

  Widget _buildTitle() {
    final hasPRs = widget.summary.prs.isNotEmpty;
    final hasAchievements = widget.summary.achievements.hasAnyAchievement;

    String title;
    if (hasPRs && hasAchievements) {
      title = '🎉 Incredible Workout! 🎉';
    } else if (hasPRs) {
      title = '🔥 New Personal Records! 🔥';
    } else if (hasAchievements) {
      title = '⭐ Great Achievement! ⭐';
    } else {
      title = '💪 Workout Complete! 💪';
    }

    return FadeTransition(
      opacity: _animationController,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMainStatsCards() => SlideTransition(
    position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1, curve: Curves.easeOut),
          ),
        ),
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildStatCard(
          icon: Icons.schedule,
          label: 'Duration',
          value: _formatDuration(widget.summary.duration),
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.fitness_center,
          label: 'Total Sets',
          value: '${widget.summary.totalSets}',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.repeat,
          label: 'Total Reps',
          value: '${widget.summary.totalReps}',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.monitor_weight,
          label: 'Volume',
          value: '${widget.summary.totalVolume.toStringAsFixed(0)} kg',
          color: Colors.purple,
          isHighlight: widget.summary.achievements.isPersonalBest,
        ),
      ],
    ),
  );

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isHighlight = false,
  }) => Container(
    width: 160,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isHighlight
          ? color.withOpacity(0.2)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      border: isHighlight ? Border.all(color: color, width: 2) : null,
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? color : null,
          ),
        ),
      ],
    ),
  );

  Widget _buildPRsSection() => FadeTransition(
    opacity: _animationController,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text(
              'Personal Records',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.summary.prs.map(_buildPRCard),
      ],
    ),
  );

  Widget _buildPRCard(PersonalRecordAchievement pr) {
    final color = _getPRColor(pr.type);
    final icon = _getPRIcon(pr.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.exerciseName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPRDescription(pr),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${pr.value.toStringAsFixed(pr.type == PRType.maxReps ? 0 : 1)} ${pr.unit}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (pr.previousValue != null && pr.improvement > 0)
                Text(
                  '+${pr.improvement.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = <Widget>[];
    final ach = widget.summary.achievements;

    if (ach.perfectCompletion) {
      achievements.add(
        _buildAchievementChip(
          icon: Icons.check_circle,
          label: 'Perfect Completion',
          color: Colors.green,
        ),
      );
    }
    if (ach.isPersonalBest) {
      achievements.add(
        _buildAchievementChip(
          icon: Icons.trending_up,
          label: 'Highest Volume',
          color: Colors.purple,
        ),
      );
    }
    if (ach.isLongestWorkout) {
      achievements.add(
        _buildAchievementChip(
          icon: Icons.timer,
          label: 'Longest Workout',
          color: Colors.blue,
        ),
      );
    }
    if (ach.isMostSets) {
      achievements.add(
        _buildAchievementChip(
          icon: Icons.format_list_numbered,
          label: 'Most Sets',
          color: Colors.orange,
        ),
      );
    }
    if (ach.streak > 1) {
      achievements.add(
        _buildAchievementChip(
          icon: Icons.local_fire_department,
          label: '${ach.streak} Day Streak',
          color: Colors.red,
        ),
      );
    }

    if (achievements.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _animationController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                'Achievements',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: achievements),
        ],
      ),
    );
  }

  Widget _buildAchievementChip({
    required IconData icon,
    required String label,
    required Color color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _buildExerciseBreakdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Exercise Breakdown',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      ...widget.summary.exercises.map(_buildExerciseCard),
    ],
  );

  Widget _buildExerciseCard(ExerciseSummary exercise) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                exercise.exerciseName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (exercise.isNewPR)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildExerciseStat(
              'Sets',
              '${exercise.sets}',
              Icons.fitness_center,
            ),
            const SizedBox(width: 24),
            _buildExerciseStat('Reps', '${exercise.totalReps}', Icons.repeat),
            if (exercise.maxWeight != null) ...[
              const SizedBox(width: 24),
              _buildExerciseStat(
                'Max',
                '${exercise.maxWeight!.toStringAsFixed(1)} kg',
                Icons.trending_up,
              ),
            ],
          ],
        ),
      ],
    ),
  );

  Widget _buildExerciseStat(String label, String value, IconData icon) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 16,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
      ),
      const SizedBox(width: 4),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ],
  );

  Widget _buildFinishButton() => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: () => context.go('/'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Back to Home',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Color _getPRColor(PRType type) {
    switch (type) {
      case PRType.maxWeight:
        return Colors.amber;
      case PRType.totalVolume:
        return Colors.purple;
      case PRType.maxReps:
        return Colors.green;
      case PRType.oneRepMax:
        return Colors.red;
    }
  }

  IconData _getPRIcon(PRType type) {
    switch (type) {
      case PRType.maxWeight:
        return Icons.fitness_center;
      case PRType.totalVolume:
        return Icons.trending_up;
      case PRType.maxReps:
        return Icons.repeat;
      case PRType.oneRepMax:
        return Icons.emoji_events;
    }
  }

  String _getPRDescription(PersonalRecordAchievement pr) {
    switch (pr.type) {
      case PRType.maxWeight:
        return 'New max weight';
      case PRType.totalVolume:
        return 'New total volume';
      case PRType.maxReps:
        return 'New max reps';
      case PRType.oneRepMax:
        return 'New 1RM estimate';
    }
  }

  void _shareWorkout(BuildContext context) {
    final summary = widget.summary;

    // Create a comprehensive workout summary text
    final buffer = StringBuffer();
    buffer.writeln('💪 Workout Complete! 💪');
    buffer.writeln('');
    buffer.writeln('Workout: ${summary.workoutName}');
    buffer.writeln('Duration: ${_formatDuration(summary.duration)}');
    buffer.writeln('Total Sets: ${summary.totalSets}');
    buffer.writeln('Total Reps: ${summary.totalReps}');
    buffer.writeln(
      'Total Volume: ${summary.totalVolume.toStringAsFixed(1)} kg',
    );
    buffer.writeln('');

    if (summary.prs.isNotEmpty) {
      buffer.writeln('🏆 Personal Records:');
      for (final pr in summary.prs) {
        buffer.writeln(
          '• ${pr.exerciseName}: ${pr.value.toStringAsFixed(pr.type == PRType.maxReps ? 0 : 1)} ${pr.unit}',
        );
      }
      buffer.writeln('');
    }

    if (summary.achievements.hasAnyAchievement) {
      buffer.writeln('⭐ Achievements:');
      final ach = summary.achievements;
      if (ach.perfectCompletion) buffer.writeln('• Perfect Completion');
      if (ach.isPersonalBest) buffer.writeln('• Personal Best Volume');
      if (ach.isLongestWorkout) buffer.writeln('• Longest Workout');
      if (ach.isMostSets) buffer.writeln('• Most Sets');
      if (ach.streak > 1) buffer.writeln('• ${ach.streak} Day Streak');
      buffer.writeln('');
    }

    buffer.writeln('Exercises:');
    for (final exercise in summary.exercises) {
      buffer.writeln(
        '• ${exercise.exerciseName}: ${exercise.sets} sets, ${exercise.totalReps} reps',
      );
      if (exercise.maxWeight != null) {
        buffer.writeln(
          '  Max Weight: ${exercise.maxWeight!.toStringAsFixed(1)} kg',
        );
      }
    }

    buffer.writeln('');
    buffer.writeln('Generated by HERQ - Your AI Fitness Coach');

    Share.share(
      buffer.toString(),
      subject: 'My ${summary.workoutName} Workout',
    );
  }
}
