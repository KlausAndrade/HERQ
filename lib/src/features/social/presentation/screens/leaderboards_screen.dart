import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/social_models.dart';
import '../providers/social_providers.dart';

class LeaderboardsScreen extends HookConsumerWidget {
  const LeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboards'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Volume'),
              Tab(text: 'Workouts'),
              Tab(text: 'Streaks'),
              Tab(text: 'PRs'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LeaderboardTab(type: LeaderboardType.totalVolume),
            LeaderboardTab(type: LeaderboardType.workoutCount),
            LeaderboardTab(type: LeaderboardType.streak),
            LeaderboardTab(type: LeaderboardType.prCount),
          ],
        ),
      ),
    );
  }
}

class LeaderboardTab extends HookConsumerWidget {
  const LeaderboardTab({
    super.key,
    required this.type,
  });

  final LeaderboardType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ValueNotifier<Period>(Period.monthly);
    
    return ValueListenableBuilder<Period>(
      valueListenable: selectedPeriod,
      builder: (context, period, child) {
        final params = LeaderboardParams(type: type, period: period);
        final leaderboardAsync = ref.watch(leaderboardProvider(params));

        return Column(
          children: [
            _buildPeriodSelector(selectedPeriod),
            Expanded(
              child: leaderboardAsync.when(
                data: (leaderboard) => _buildLeaderboard(context, leaderboard),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load leaderboard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(leaderboardProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPeriodSelector(ValueNotifier<Period> selectedPeriod) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: Period.values.map((period) {
          final isSelected = selectedPeriod.value == period;
          return GestureDetector(
            onTap: () => selectedPeriod.value = period,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
              child: Text(
                _formatPeriod(period),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, Leaderboard leaderboard) {
    if (leaderboard.entries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Top 3 podium
        if (leaderboard.entries.length >= 3) _buildPodium(leaderboard.entries.take(3).toList()),
        
        // Rest of the leaderboard
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboard.entries.length,
            itemBuilder: (context, index) {
              final entry = leaderboard.entries[index];
              return _buildLeaderboardEntry(context, entry, index < 3);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (topThree.length > 1) _buildPodiumPlace(topThree[1], 2, 80),
          const SizedBox(width: 8),
          // 1st place
          _buildPodiumPlace(topThree[0], 1, 100),
          const SizedBox(width: 8),
          // 3rd place
          if (topThree.length > 2) _buildPodiumPlace(topThree[2], 3, 60),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int place, double height) {
    Color podiumColor;
    IconData medalIcon;
    
    switch (place) {
      case 1:
        podiumColor = Colors.amber;
        medalIcon = Icons.emoji_events;
        break;
      case 2:
        podiumColor = Colors.grey[400]!;
        medalIcon = Icons.emoji_events;
        break;
      case 3:
        podiumColor = Colors.orange[300]!;
        medalIcon = Icons.emoji_events;
        break;
      default:
        podiumColor = Colors.grey;
        medalIcon = Icons.emoji_events;
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(entry.displayName[0].toUpperCase())
                  : null,
            ),
            Positioned(
              bottom: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: podiumColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  medalIcon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _formatScore(entry.score, type),
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: podiumColor.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: podiumColor, width: 2),
          ),
          child: Center(
            child: Text(
              '$place',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: podiumColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardEntry(BuildContext context, LeaderboardEntry entry, bool isTopThree) {
    if (isTopThree) return const SizedBox.shrink(); // Skip top 3 as they're shown in podium

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                '${entry.rank}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(entry.displayName[0].toUpperCase())
                  : null,
            ),
          ],
        ),
        title: Text(
          entry.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: entry.change != null
            ? Row(
                children: [
                  Icon(
                    entry.change! > 0 ? Icons.trending_up : 
                    entry.change! < 0 ? Icons.trending_down : 
                    Icons.remove,
                    size: 16,
                    color: entry.change! > 0 ? Colors.green : 
                           entry.change! < 0 ? Colors.red : 
                           Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.change! == 0 ? 'No change' :
                    '${entry.change!.abs()} ${entry.change! > 0 ? 'up' : 'down'}',
                    style: TextStyle(
                      color: entry.change! > 0 ? Colors.green : 
                             entry.change! < 0 ? Colors.red : 
                             Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatScore(entry.score, type),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              _getScoreUnit(type),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPeriod(Period period) {
    switch (period) {
      case Period.weekly:
        return 'Week';
      case Period.monthly:
        return 'Month';
      case Period.yearly:
        return 'Year';
      case Period.allTime:
        return 'All Time';
    }
  }

  String _formatScore(double score, LeaderboardType type) {
    switch (type) {
      case LeaderboardType.totalVolume:
        if (score >= 1000) {
          return '${(score / 1000).toStringAsFixed(1)}k';
        }
        return score.toStringAsFixed(0);
      case LeaderboardType.workoutCount:
      case LeaderboardType.streak:
      case LeaderboardType.prCount:
        return score.toStringAsFixed(0);
    }
  }

  String _getScoreUnit(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.totalVolume:
        return 'kg';
      case LeaderboardType.workoutCount:
        return 'workouts';
      case LeaderboardType.streak:
        return 'days';
      case LeaderboardType.prCount:
        return 'PRs';
    }
  }
}