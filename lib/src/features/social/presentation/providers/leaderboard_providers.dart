import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/leaderboard_service.dart';
import '../../domain/models/leaderboard_models.dart';

// Leaderboard service provider
final leaderboardServiceProvider = Provider<LeaderboardService?>((ref) {
  final db = ref.watch(databaseProvider);
  // Note: Leaderboards need Supabase to work properly across all users
  // Local database only has the current user's data
  // TODO: Implement Supabase-based leaderboard service for real multi-user leaderboards
  if (db == null) return null;
  return LeaderboardService(db);
});

// Leaderboard provider
final leaderboardProvider = FutureProvider.autoDispose
    .family<Leaderboard, LeaderboardParams>((ref, params) async {
  print('🔄 Leaderboard provider called for type: ${params.type}, period: ${params.period}');
  
  final service = ref.watch(leaderboardServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (service == null) {
    print('  ⚠️ Leaderboard service is null');
    // Return empty leaderboard if service unavailable (web platform)
    return Leaderboard(
      type: params.type,
      period: params.period,
      entries: const [],
      currentUserEntry: null,
    );
  }

  print('  ✅ Leaderboard service available, fetching data...');
  final result = await service.getLeaderboard(
    type: params.type,
    period: params.period,
    currentUserId: currentUser?.id,
  );
  
  print('  📊 Leaderboard result: ${result.entries.length} entries');
  return result;
});
