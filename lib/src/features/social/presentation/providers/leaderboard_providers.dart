import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/leaderboard_service.dart';
import '../../data/supabase_leaderboard_service.dart';
import '../../domain/models/leaderboard_models.dart';

// Supabase Leaderboard service provider (MULTI-USER)
final supabaseLeaderboardServiceProvider =
    Provider<SupabaseLeaderboardService?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseLeaderboardService(supabase);
});

// Local Leaderboard service provider (FALLBACK)
final localLeaderboardServiceProvider = Provider<LeaderboardService?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return LeaderboardService(db);
});

// Leaderboard provider - Uses Supabase for multi-user data
final leaderboardProvider = FutureProvider.autoDispose
    .family<Leaderboard, LeaderboardParams>((ref, params) async {
  print(
    '🔄 Leaderboard provider called for type: ${params.type}, period: ${params.period}',
  );

  final supabaseService = ref.watch(supabaseLeaderboardServiceProvider);
  final localService = ref.watch(localLeaderboardServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  // Try Supabase first for real multi-user leaderboards
  if (supabaseService != null) {
    try {
      print('  🌐 Using Supabase leaderboard service (MULTI-USER)');
      final result = await supabaseService.getLeaderboard(
        type: params.type,
        period: params.period,
        currentUserId: currentUser?.id,
      );

      print(
        '  📊 Supabase leaderboard result: ${result.entries.length} entries',
      );
      return result;
    } catch (e) {
      print('  ⚠️ Supabase leaderboard error, falling back to local: $e');
    }
  }

  // Fallback to local database (single-user simulation)
  if (localService != null) {
    print('  💾 Using local leaderboard service (SIMULATED)');
    final result = await localService.getLeaderboard(
      type: params.type,
      period: params.period,
      currentUserId: currentUser?.id,
    );

    print('  📊 Local leaderboard result: ${result.entries.length} entries');
    return result;
  }

  print('  ⚠️ No leaderboard service available');
  // Return empty leaderboard if no service available
  return Leaderboard(
    type: params.type,
    period: params.period,
    entries: const [],
  );
});
