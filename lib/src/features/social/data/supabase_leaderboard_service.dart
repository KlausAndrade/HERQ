import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/leaderboard_models.dart';

/// Supabase-based leaderboard service for real multi-user leaderboards
class SupabaseLeaderboardService {
  final SupabaseClient _supabase;

  SupabaseLeaderboardService(this._supabase);

  /// Get leaderboard data from Supabase
  Future<Leaderboard> getLeaderboard({
    required LeaderboardType type,
    required Period period,
    String? currentUserId,
  }) async {
    print('🌐 Getting Supabase leaderboard for type: $type');

    try {
      List<LeaderboardEntry> entries;

      switch (type) {
        case LeaderboardType.totalVolume:
          entries = await _getVolumeLeaderboard();
          break;
        case LeaderboardType.workoutCount:
          entries = await _getWorkoutCountLeaderboard();
          break;
        case LeaderboardType.streak:
          entries = await _getStreakLeaderboard();
          break;
        case LeaderboardType.prCount:
          entries = await _getPRCountLeaderboard();
          break;
      }

      // Get current user's entry if available
      LeaderboardEntry? currentUserEntry;
      if (currentUserId != null) {
        currentUserEntry = await _getCurrentUserRank(type, currentUserId);
      }

      print('  ✅ Fetched ${entries.length} leaderboard entries from Supabase');

      return Leaderboard(
        type: type,
        period: period,
        entries: entries,
        currentUserEntry: currentUserEntry,
      );
    } catch (e) {
      print('  ❌ Error fetching Supabase leaderboard: $e');
      
      // Fallback to empty leaderboard
      return Leaderboard(
        type: type,
        period: period,
        entries: const [],
        currentUserEntry: null,
      );
    }
  }

  /// Get volume leaderboard from Supabase view
  Future<List<LeaderboardEntry>> _getVolumeLeaderboard() async {
    final response = await _supabase
        .from('leaderboard_volume')
        .select()
        .limit(100);

    final entries = <LeaderboardEntry>[];
    int rank = 1;

    for (final row in response as List) {
      entries.add(LeaderboardEntry(
        userId: row['user_id'] as String,
        displayName: _getDisplayName(row),
        avatarUrl: row['avatar_url'] as String?,
        value: (row['value'] as num).toDouble(),
        rank: rank++,
        formattedValue: '${(row['value'] as num).toStringAsFixed(0)} kg',
      ));
    }

    return entries;
  }

  /// Get workout count leaderboard from Supabase view
  Future<List<LeaderboardEntry>> _getWorkoutCountLeaderboard() async {
    final response = await _supabase
        .from('leaderboard_workouts')
        .select()
        .limit(100);

    final entries = <LeaderboardEntry>[];
    int rank = 1;

    for (final row in response as List) {
      final count = (row['value'] as num).toInt();
      entries.add(LeaderboardEntry(
        userId: row['user_id'] as String,
        displayName: _getDisplayName(row),
        avatarUrl: row['avatar_url'] as String?,
        value: count.toDouble(),
        rank: rank++,
        formattedValue: '$count ${count == 1 ? "workout" : "workouts"} 🏋️',
      ));
    }

    return entries;
  }

  /// Get streak leaderboard from Supabase view
  Future<List<LeaderboardEntry>> _getStreakLeaderboard() async {
    final response = await _supabase
        .from('leaderboard_streak')
        .select()
        .limit(100);

    final entries = <LeaderboardEntry>[];
    int rank = 1;

    for (final row in response as List) {
      final streak = (row['value'] as num).toInt();
      entries.add(LeaderboardEntry(
        userId: row['user_id'] as String,
        displayName: _getDisplayName(row),
        avatarUrl: row['avatar_url'] as String?,
        value: streak.toDouble(),
        rank: rank++,
        formattedValue: '$streak ${streak == 1 ? "day" : "days"} 🔥',
      ));
    }

    return entries;
  }

  /// Get PR count leaderboard from Supabase
  Future<List<LeaderboardEntry>> _getPRCountLeaderboard() async {
    final response = await _supabase.rpc('get_pr_leaderboard') as List;

    final entries = <LeaderboardEntry>[];
    int rank = 1;

    for (final row in response) {
      final prCount = (row['pr_count'] as num).toInt();
      entries.add(LeaderboardEntry(
        userId: row['user_id'] as String,
        displayName: _getDisplayNameFromRPC(row),
        avatarUrl: row['avatar_url'] as String?,
        value: prCount.toDouble(),
        rank: rank++,
        formattedValue: '$prCount PRs',
      ));
    }

    return entries;
  }

  /// Get current user's rank for a specific leaderboard type
  Future<LeaderboardEntry?> _getCurrentUserRank(
    LeaderboardType type,
    String userId,
  ) async {
    try {
      final statType = _getStatType(type);
      final response = await _supabase
          .rpc('get_user_rank', params: {
            'p_user_id': userId,
            'p_stat_type': statType,
          })
          .maybeSingle();

      if (response == null) return null;

      return LeaderboardEntry(
        userId: userId,
        displayName: 'You',
        avatarUrl: response['avatar_url'] as String?,
        value: (response['value'] as num).toDouble(),
        rank: (response['rank'] as num).toInt(),
        formattedValue: _formatValue(type, (response['value'] as num).toDouble()),
      );
    } catch (e) {
      print('  ⚠️ Could not get user rank: $e');
      return null;
    }
  }

  /// Get display name from row
  String _getDisplayName(Map<String, dynamic> row) {
    final displayName = row['display_name'] as String?;
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    
    // Try to get from profiles if available
    if (row.containsKey('profiles')) {
      final profiles = row['profiles'];
      if (profiles is Map && profiles['display_name'] != null) {
        return profiles['display_name'] as String;
      }
    }
    
    return 'Unknown Athlete';
  }

  /// Get display name from RPC result
  String _getDisplayNameFromRPC(Map<String, dynamic> row) {
    return row['display_name'] as String? ?? 'Athlete';
  }

  /// Convert LeaderboardType to stat type string
  String _getStatType(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.totalVolume:
        return 'volume';
      case LeaderboardType.workoutCount:
        return 'workouts';
      case LeaderboardType.streak:
        return 'streak';
      case LeaderboardType.prCount:
        return 'prs';
    }
  }

  /// Format value based on type
  String _formatValue(LeaderboardType type, double value) {
    switch (type) {
      case LeaderboardType.totalVolume:
        return '${value.toStringAsFixed(0)} kg';
      case LeaderboardType.workoutCount:
        final count = value.toInt();
        return '$count ${count == 1 ? "workout" : "workouts"}';
      case LeaderboardType.streak:
        final days = value.toInt();
        return '$days ${days == 1 ? "day" : "days"}';
      case LeaderboardType.prCount:
        return '${value.toInt()} PRs';
    }
  }
}

