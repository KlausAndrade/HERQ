import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/database/database.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../../workout/presentation/widgets/workout_calendar.dart';
import '../../data/providers/gamification_provider.dart';
import '../../domain/models/achievement.dart';
import '../widgets/gamification_widgets.dart';

class GamificationScreen extends ConsumerStatefulWidget {
  const GamificationScreen({super.key});

  @override
  ConsumerState<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends ConsumerState<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(userStatsProvider);
    final achievementsAsync = ref.watch(userAchievementsProvider);
    final workoutsAsync = ref.watch(workoutSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Achievements', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Stats Tab
          statsAsync.when(
            data: (stats) => stats != null
                ? _buildStatsTab(stats)
                : const Center(
                    child: Text('Start working out to see your stats!'),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(S.of(context)!.error)),
          ),
          // Achievements Tab
          achievementsAsync.when(
            data: _buildAchievementsTab,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(S.of(context)!.error)),
          ),
          // Calendar Tab
          workoutsAsync.when(
            data: (workouts) {
              final completedWorkouts = workouts
                  .where((w) => w.completedAt != null)
                  .toList();
              return completedWorkouts.isNotEmpty
                  ? WorkoutCalendar(
                      workouts: completedWorkouts,
                      onWorkoutTap: (workout) {
                        Navigator.of(context).pop();
                        context.go('/workout/${workout.id}');
                      },
                    )
                  : Center(child: Text(S.of(context)!.noWorkoutHistory));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(S.of(context)!.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(UserStat stats) {
    final gamificationService = ref.watch(gamificationServiceProvider);
    if (gamificationService == null) {
      return Center(child: Text(S.of(context)!.gamificationNotAvailable));
    }

    final level = stats.level;
    final totalXp = stats.experiencePoints;
    final nextLevelXp = gamificationService.xpRequiredForLevel(level + 1);
    final currentLevelXp = gamificationService.xpRequiredForLevel(level);
    final xpIntoLevel = totalXp - currentLevelXp;
    final xpNeeded = nextLevelXp - currentLevelXp;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Level & XP Card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const LevelIndicator(size: 100),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: gamificationService.calculateLevelProgress(
                    totalXp,
                    level,
                  ),
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context)!.xpToLevel(xpIntoLevel, xpNeeded, level + 1),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Streak Card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Workout Streak',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const StreakBadge(size: 50),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.local_fire_department,
                        iconColor: Colors.deepOrange,
                        label: 'Current',
                        value: '${stats.currentStreak}',
                        subtitle: 'days',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.whatshot,
                        iconColor: Colors.red,
                        label: 'Longest',
                        value: '${stats.longestStreak}',
                        subtitle: 'days',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Overall Stats Card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lifetime Stats',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _StatRow(
                  icon: Icons.fitness_center,
                  label: 'Total Workouts',
                  value: '${stats.totalWorkouts}',
                ),
                const Divider(),
                _StatRow(
                  icon: Icons.format_list_numbered,
                  label: 'Total Sets',
                  value: '${stats.totalSetsCompleted}',
                ),
                const Divider(),
                _StatRow(
                  icon: Icons.sports_martial_arts,
                  label: 'Total Volume',
                  value: '${stats.totalVolumeLifted.toStringAsFixed(1)} kg',
                ),
                const Divider(),
                _StatRow(
                  icon: Icons.access_time,
                  label: 'Total Time',
                  value: _formatDuration(stats.totalWorkoutMinutes),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab(List<UserAchievement> userAchievements) {
    // Group achievements by category
    final Map<
      AchievementCategory,
      List<MapEntry<Achievement, UserAchievement?>>
    >
    grouped = {};

    for (final achievement in Achievements.all) {
      final userAchievement = userAchievements
          .where((ua) => ua.achievementId == achievement.id)
          .firstOrNull;

      grouped.putIfAbsent(achievement.category, () => []);
      grouped[achievement.category]!.add(
        MapEntry(achievement, userAchievement),
      );
    }

    // Sort each category: completed last, then by progress
    for (final category in grouped.keys) {
      grouped[category]!.sort((a, b) {
        final aCompleted = a.value?.isCompleted ?? false;
        final bCompleted = b.value?.isCompleted ?? false;

        if (aCompleted != bCompleted) {
          return aCompleted ? 1 : -1; // Completed items last
        }

        final aProgress = a.value?.progress ?? 0;
        final bProgress = b.value?.progress ?? 0;
        return bProgress.compareTo(aProgress); // Higher progress first
      });
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress Summary
        Card(
          elevation: 4,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context)!.achievementProgress,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${userAchievements.where((a) => a.isCompleted).length} / ${Achievements.all.length} ${S.of(context)!.unlocked}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value:
                      userAchievements.where((a) => a.isCompleted).length /
                      Achievements.all.length,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Achievements by category
        for (final category in AchievementCategory.values)
          if (grouped.containsKey(category)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _getCategoryName(category),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ...grouped[category]!.map((entry) {
              final achievement = entry.key;
              final userAchievement = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AchievementCard(
                  achievementId: achievement.id,
                  progress: userAchievement?.progress ?? 0,
                  isCompleted: userAchievement?.isCompleted ?? false,
                  unlockedAt: userAchievement?.unlockedAt,
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
      ],
    );
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.workouts:
        return S.of(context)!.workoutMilestones;
      case AchievementCategory.streaks:
        return S.of(context)!.streakAchievements;
      case AchievementCategory.volume:
        return S.of(context)!.volumeAchievements;
      case AchievementCategory.consistency:
        return S.of(context)!.consistencyAchievements;
      case AchievementCategory.milestones:
        return S.of(context)!.specialMilestones;
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: iconColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ColorProperty('iconColor', iconColor));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('value', value));
    properties.add(StringProperty('subtitle', subtitle));
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('value', value));
  }
}
