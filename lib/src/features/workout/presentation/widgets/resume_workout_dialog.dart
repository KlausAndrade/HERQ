import 'package:flutter/material.dart';

import '../../domain/models/active_workout.dart';
import 'package:herq/l10n/app_localizations.dart';

/// Dialog to prompt user to resume an incomplete workout
class ResumeWorkoutDialog extends StatelessWidget {
  final ActiveWorkout workout;
  final DateTime lastSavedAt;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final VoidCallback onDiscard;

  const ResumeWorkoutDialog({
    super.key,
    required this.workout,
    required this.lastSavedAt,
    required this.onResume,
    required this.onFinish,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate time since last save
    final now = DateTime.now();
    final timeSinceLastSave = now.difference(lastSavedAt);
    final minutesSinceLastSave = timeSinceLastSave.inMinutes;
    
    // Check if workout is fully completed
    final isFullyCompleted = workout.isFullyCompleted();
    
    // Show finish option if >10 minutes OR if workout is complete
    final showFinishOption = minutesSinceLastSave >= 10 || isFullyCompleted;
    
    // Determine dialog style based on completion state
    final isCompleteForgotten = isFullyCompleted && minutesSinceLastSave >= 10;

    // Calculate completion stats
    final completedSets = workout.getCompletedSetsCount();
    final totalSets = workout.getTotalSetsCount();
    final completionPercent = totalSets > 0 ? (completedSets / totalSets * 100).round() : 0;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isCompleteForgotten ? Icons.celebration : Icons.history,
            color: isCompleteForgotten ? colorScheme.secondary : colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child:               Text(
                isCompleteForgotten 
                  ? S.of(context)!.workoutCompleteExclamation
                  : S.of(context)!.resumeWorkoutQuestion,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Text(
                isCompleteForgotten
                ? S.of(context)!.youCompletedAllExercises
                : S.of(context)!.youHaveUnfinishedWorkout,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Workout info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout name
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        workout.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: Icons.check_circle_outline,
                        label: '$completedSets/$totalSets sets',
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatChip(
                        icon: Icons.timer_outlined,
                        label: '${workout.elapsedTime.inMinutes}min',
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                
                // Show time since last save if > 10 minutes OR if workout is complete
                if (showFinishOption && minutesSinceLastSave >= 10) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleteForgotten 
                          ? colorScheme.secondaryContainer.withOpacity(0.3)
                          : colorScheme.errorContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCompleteForgotten
                            ? colorScheme.secondary.withOpacity(0.3)
                            : colorScheme.error.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCompleteForgotten ? Icons.info_outline : Icons.access_time,
                          size: 14,
                          color: isCompleteForgotten ? colorScheme.secondary : colorScheme.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child:                               Text(
                                isCompleteForgotten
                                ? S.of(context)!.finishedTimeAgo(_formatDuration(timeSinceLastSave))
                                : S.of(context)!.pausedTimeAgo(_formatDuration(timeSinceLastSave)),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isCompleteForgotten ? colorScheme.secondary : colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completionPercent% complete',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completedSets / totalSets,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
            Text(
              isCompleteForgotten 
                ? S.of(context)!.tapFinalizeToSave
                : S.of(context)!.wouldYouLikeToContinue,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        // Left side - empty to push content right
        const SizedBox.shrink(),
        // Right side - buttons in column
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Discard button on top right
            TextButton(
              onPressed: onDiscard,
              child: Text(
                S.of(context)!.discard,
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Main action buttons in a row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Resume/Add More button
                if (isCompleteForgotten)
                  OutlinedButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.add),
                    label: Text(S.of(context)!.addMore, textAlign: TextAlign.center),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      minimumSize: const Size(0, 48), // Consistent height
                    ),
                  )
                else if (!showFinishOption)
                  FilledButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(S.of(context)!.resume, textAlign: TextAlign.center),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48), // Consistent height
                    ),
                  ),
                
                // Spacing between buttons
                if (showFinishOption) const SizedBox(width: 12),
                
                // Finalize/Finish button
                if (showFinishOption)
                  FilledButton.icon(
                    onPressed: onFinish,
                    icon: Icon(isCompleteForgotten ? Icons.celebration : Icons.check),
                    label: Text(
                      isCompleteForgotten ? S.of(context)!.finalize : S.of(context)!.finish,
                      textAlign: TextAlign.center,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isCompleteForgotten 
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      minimumSize: const Size(0, 48), // Consistent height
                    ),
                  ),
                
                // Resume button (when finish option is shown but not complete)
                if (showFinishOption && !isCompleteForgotten) ...[
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(S.of(context)!.resume, textAlign: TextAlign.center),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48), // Consistent height
                    ),
                  ),
                ],
              ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? "s" : ""}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? "s" : ""}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? "s" : ""}';
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
