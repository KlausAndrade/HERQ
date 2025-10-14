import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/gamification_provider.dart';
import '../../domain/models/achievement.dart';
import 'package:herq/l10n/app_localizations.dart';

class StreakBadge extends ConsumerWidget {
  final double size;
  final bool showText;

  const StreakBadge({
    super.key,
    this.size = 40,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats == null) return const SizedBox.shrink();

        final currentStreak = stats.currentStreak;
        final isActive = currentStreak > 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Colors.deepOrange, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                color: Colors.white,
                size: size * 0.6,
              ),
              if (showText) ...[
                const SizedBox(width: 6),
                Text(
                  '$currentStreak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (currentStreak > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    currentStreak != 1 ? S.of(context)!.days : S.of(context)!.day,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.3,
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class LevelIndicator extends ConsumerWidget {
  final bool showProgress;
  final double size;

  const LevelIndicator({
    super.key,
    this.showProgress = true,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final gamificationService = ref.watch(gamificationServiceProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats == null || gamificationService == null) {
          return const SizedBox.shrink();
        }

        final level = stats.level;
        final totalXp = stats.experiencePoints;
        final progress =
            gamificationService.calculateLevelProgress(totalXp, level);
        final nextLevelXp = gamificationService.xpRequiredForLevel(level + 1);
        final currentLevelXp = gamificationService.xpRequiredForLevel(level);
        final xpIntoLevel = totalXp - currentLevelXp;
        final xpNeeded = nextLevelXp - currentLevelXp;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring
                if (showProgress)
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                // Level badge
                Container(
                  width: size * 0.7,
                  height: size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$level',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showProgress) ...[
              const SizedBox(height: 8),
              Text(
                S.of(context)!.levelN(level),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                S.of(context)!.xpProgress(xpIntoLevel, xpNeeded),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String achievementId;
  final int progress;
  final bool isCompleted;
  final DateTime? unlockedAt;

  const AchievementCard({
    super.key,
    required this.achievementId,
    required this.progress,
    required this.isCompleted,
    this.unlockedAt,
  });

  @override
  Widget build(BuildContext context) {
    final achievement = Achievements.findById(achievementId);
    if (achievement == null) return const SizedBox.shrink();

    return Card(
      elevation: isCompleted ? 4 : 1,
      color: isCompleted ? achievement.color.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isCompleted ? achievement.color : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? achievement.color : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  if (!isCompleted) ...[
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievement.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$progress%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: achievement.color,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Unlocked',
                          style: TextStyle(
                            color: achievement.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (unlockedAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(unlockedAt!, context),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // XP Reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCompleted
                    ? achievement.color.withOpacity(0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color:
                        isCompleted ? achievement.color : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.xpReward}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? achievement.color
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return S.of(context)!.today;
    } else if (difference.inDays == 1) {
      return S.of(context)!.yesterday;
    } else if (difference.inDays < 7) {
      return S.of(context)!.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
