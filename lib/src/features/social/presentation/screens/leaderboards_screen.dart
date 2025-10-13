import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/utils/display_name_sanitizer.dart';
import '../../domain/models/leaderboard_models.dart';
import '../providers/leaderboard_providers.dart';

class LeaderboardsScreen extends HookConsumerWidget {
  const LeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
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
    final selectedPeriod = useState<Period>(Period.monthly);
    
    // Force refresh on first build
    useEffect(() {
      print('🎯 LeaderboardTab mounted for type: $type');
      Future.microtask(() {
        final params = LeaderboardParams(type: type, period: selectedPeriod.value);
        ref.invalidate(leaderboardProvider(params));
      });
      return null;
    }, [type]);

    final params = LeaderboardParams(type: type, period: selectedPeriod.value);
    final leaderboardAsync = ref.watch(leaderboardProvider(params));

    return Column(
      children: [
        _buildPeriodSelector(selectedPeriod),
        Expanded(
          child: leaderboardAsync.when(
            data: (leaderboard) {
              print('📊 UI building with ${leaderboard.entries.length} entries for ${type}');
              return _buildLeaderboard(context, ref, leaderboard, params);
            },
            loading: () {
              print('⏳ Loading leaderboard for ${type}');
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stack) {
              print('❌ Error loading leaderboard for ${type}: $error');
              return Center(
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
                      onPressed: () => ref.invalidate(leaderboardProvider(params)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

  Widget _buildLeaderboard(BuildContext context, WidgetRef ref, Leaderboard leaderboard, LeaderboardParams params) {
    final entries = leaderboard.entries;

    // Empty state: show a scrollable area so RefreshIndicator works
    if (entries.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => await ref.refresh(leaderboardProvider(params)),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
              ),
            ),
          ],
        ),
      );
    }

    // Non-empty: show podium (if present) plus scrollable list with RefreshIndicator
    if (entries.length >= 3) {
      final listCount = 1 + (entries.length - 3); // podium + rest
      return RefreshIndicator(
        onRefresh: () async => await ref.refresh(leaderboardProvider(params)),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: listCount,
          itemBuilder: (context, index) {
            if (index == 0) return _buildPodium(context, entries.take(3).toList());
            final realIndex = index - 1 + 3; // map list index to entries
            final entry = entries[realIndex];
            return _buildLeaderboardEntry(context, entry, false);
          },
        ),
      );
    }

    // 1 or 2 entries (no full podium) — show them directly in a refreshable list
    print('  🎨 Rendering ${entries.length} entries without podium');
    return RefreshIndicator(
      onRefresh: () async => await ref.refresh(leaderboardProvider(params)),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          print('  🎨 Building entry $index: ${entry.displayName} - ${entry.formattedValue}');
          // Don't hide any entries when there's no podium! (< 3 entries)
          return _buildLeaderboardEntry(context, entry, false);
        },
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<LeaderboardEntry> topThree) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place - Equal width
          Expanded(
            child: topThree.length > 1
                ? _buildPodiumPlace(context, topThree[1], 2, 80)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 12),
          // 1st place - Equal width, centered, tallest
          Expanded(
            child: topThree.isNotEmpty
                ? _buildPodiumPlace(context, topThree[0], 1, 110)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 12),
          // 3rd place - Equal width
          Expanded(
            child: topThree.length > 2
                ? _buildPodiumPlace(context, topThree[2], 3, 65)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(BuildContext context, LeaderboardEntry entry, int place, double height) {
    final isCurrentUser = DisplayNameSanitizer.sanitize(entry.displayName) == 'You' || entry.userId.contains('default');
    
    Color podiumColor;
    IconData medalIcon;

    switch (place) {
      case 1:
        podiumColor = const Color(0xFFFFD700); // Gold
        medalIcon = Icons.emoji_events;
        break;
      case 2:
        podiumColor = const Color(0xFFC0C0C0); // Silver
        medalIcon = Icons.emoji_events;
        break;
      case 3:
        podiumColor = const Color(0xFFCD7F32); // Bronze
        medalIcon = Icons.emoji_events;
        break;
      default:
        podiumColor = Colors.grey;
        medalIcon = Icons.emoji_events;
    }

    return InkWell(
      onTap: isCurrentUser ? null : () {
        print('🔍 Navigating to profile from podium:');
        print('  Entry: ${entry.displayName}');
        print('  UserId: ${entry.userId}');
        print('  Full route: /user/${entry.userId}');
        context.push('/user/${entry.userId}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with medal
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: place == 1 ? 30 : 24,
              backgroundColor: podiumColor.withOpacity(0.2),
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(
                      DisplayNameSanitizer.sanitize(entry.displayName)[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: place == 1 ? 20 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: podiumColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: podiumColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  medalIcon,
                  color: Colors.white,
                  size: place == 1 ? 18 : 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Name
        Text(
          DisplayNameSanitizer.sanitize(entry.displayName),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: place == 1 ? 13 : 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Value
        Text(
          entry.formattedValue,
          style: TextStyle(
            fontSize: place == 1 ? 12 : 10,
            fontWeight: FontWeight.w600,
            color: podiumColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Podium base
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 90),
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                podiumColor.withOpacity(0.6),
                podiumColor.withOpacity(0.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(
              color: podiumColor,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              place == 1 ? '🥇' : place == 2 ? '🥈' : '🥉',
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(
      BuildContext context, LeaderboardEntry entry, bool isTopThree) {
    if (isTopThree)
      return const SizedBox.shrink(); // Skip top 3 as they're shown in podium

    final isCurrentUser = DisplayNameSanitizer.sanitize(entry.displayName) == 'You' || entry.userId.contains('default');
    final theme = Theme.of(context);
    
    // Get rank color
    Color rankColor = Colors.grey[600]!;
    if (entry.rank == 1) rankColor = const Color(0xFFFFD700); // Gold
    if (entry.rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
    if (entry.rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze
    if (entry.rank <= 10 && entry.rank > 3) rankColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentUser 
          ? theme.colorScheme.primary.withOpacity(0.08)
          : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser 
            ? theme.colorScheme.primary.withOpacity(0.4)
            : Colors.grey.withOpacity(0.15),
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isCurrentUser ? null : () {
            // Navigate to user profile
            print('🔍 Navigating to profile:');
            print('  Entry: ${entry.displayName}');
            print('  UserId: ${entry.userId}');
            print('  Full route: /user/${entry.userId}');
            context.push('/user/${entry.userId}');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
          children: [
            // Compact rank badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: rankColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${entry.rank}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Compact avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: isCurrentUser 
                ? theme.colorScheme.primary
                : Colors.grey[300],
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(
                      DisplayNameSanitizer.sanitize(entry.displayName)[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? Colors.white : Colors.black54,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            // Name and medal - single line
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      DisplayNameSanitizer.sanitize(entry.displayName),
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                        color: isCurrentUser ? theme.colorScheme.primary : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.rank <= 3) ...[
                    const SizedBox(width: 6),
                    Text(
                      entry.rank == 1 ? '🏆' : entry.rank == 2 ? '🥈' : '🥉',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'YOU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Value - clean and simple
            Text(
              entry.formattedValue,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: rankColor,
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  String _formatPeriod(Period period) {
    switch (period) {
      case Period.daily:
        return 'Day';
      case Period.weekly:
        return 'Week';
      case Period.monthly:
        return 'Month';
      case Period.allTime:
        return 'All Time';
    }
  }
}
