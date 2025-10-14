import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/display_name_sanitizer.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({
    required this.userId,
    super.key,
  });
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final supabase = ref.watch(supabaseClientProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // If we can pop, do it, otherwise go to home screen
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: FutureBuilder(
        future: _loadUserData(db, supabase, userId, currentUser?.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // If we can pop, do it, otherwise go to home screen
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final user = data['user'];
          final stats = data['stats'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: _getAvatarUrl(user) != null
                      ? NetworkImage(_getAvatarUrl(user)!)
                      : null,
                  child: _getAvatarUrl(user) == null
                      ? Text(
                          _getDisplayName(user)[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  _getDisplayName(user),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Stats
                if (stats != null) ...[
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '💪',
                          _getStatValue(stats, 'totalWorkouts', 0).toString(),
                          'Workouts',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '🏋️',
                          '${_getStatDoubleValue(stats, 'totalVolumeLifted', 0).toStringAsFixed(0)} kg',
                          'Volume',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '🔥',
                          '${_getStatValue(stats, 'currentStreak', 0)}',
                          'Day Streak',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '⭐',
                          'Level ${_getStatValue(stats, 'level', 1)}',
                          'Athlete',
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'No data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDisplayName(user) {
    if (user == null) return 'Unknown Athlete';

    String? rawDisplayName;

    // Handle both User object (local DB) and Map (Supabase)
    if (user is Map) {
      rawDisplayName = user['displayName'] as String?;
    } else {
      // User object from local DB
      rawDisplayName = user.displayName;
    }

    // Use centralized sanitizer - ensures emails are NEVER shown
    return DisplayNameSanitizer.sanitize(rawDisplayName);
  }

  String? _getAvatarUrl(user) {
    if (user == null) return null;
    if (user is Map) {
      return user['avatarUrl'] as String?;
    }
    return user.avatarUrl;
  }

  int _getStatValue(stats, String key, int defaultValue) {
    if (stats == null) return defaultValue;
    if (stats is Map) {
      return stats[key] as int? ?? defaultValue;
    }
    // Local DB UserStat object
    switch (key) {
      case 'totalWorkouts':
        return stats.totalWorkouts;
      case 'currentStreak':
        return stats.currentStreak;
      case 'level':
        return stats.level;
      default:
        return defaultValue;
    }
  }

  double _getStatDoubleValue(stats, String key, double defaultValue) {
    if (stats == null) return defaultValue;
    if (stats is Map) {
      return stats[key] as double? ?? defaultValue;
    }
    // Local DB UserStat object
    if (key == 'totalVolumeLifted') {
      return stats.totalVolumeLifted;
    }
    return defaultValue;
  }

  Widget _buildStatCard(
    BuildContext context,
    String emoji,
    String value,
    String label,
  ) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Future<Map<String, dynamic>> _loadUserData(
    AppDatabase? db,
    supabase,
    String userId,
    String? currentUserId,
  ) async {
    print('👤 Loading user profile for userId: $userId');
    print('  Current user ID: $currentUserId');

    // If viewing own profile or no Supabase, use local DB
    if (userId == currentUserId || db == null) {
      print('  💾 Loading from local database...');
      return _loadFromLocalDB(db, userId);
    }

    // Try Supabase first for other users
    try {
      print('  🌐 Loading from Supabase...');

      // Get user stats from Supabase
      final statsResponse = await supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (statsResponse == null) {
        print('  ⚠️ No stats found in Supabase, trying local DB...');
        return _loadFromLocalDB(db, userId);
      }

      // Try to get display name from profiles table
      String displayName = 'Unknown Athlete';
      String? email;

      try {
        final profileResponse = await supabase
            .from('profiles')
            .select('display_name, bio, avatar_url')
            .eq('id', userId)
            .maybeSingle();

        if (profileResponse != null &&
            profileResponse['display_name'] != null) {
          displayName = profileResponse['display_name'] as String;
        }
      } catch (e) {
        print('  ⚠️ Could not load profile: $e');
      }

      print('  ✅ Loaded from Supabase: $displayName');

      return {
        'user': {
          'id': userId,
          'displayName': displayName,
          'email': email,
        },
        'stats': {
          'totalWorkouts': statsResponse['total_workouts'] ?? 0,
          'totalVolumeLifted':
              (statsResponse['total_volume'] as num?)?.toDouble() ?? 0.0,
          'currentStreak': statsResponse['current_streak'] ?? 0,
          'level': statsResponse['level'] ?? 1,
        },
      };
    } catch (e) {
      print('  ⚠️ Supabase error: $e, trying local DB...');
      return _loadFromLocalDB(db, userId);
    }
  }

  Future<Map<String, dynamic>> _loadFromLocalDB(
    AppDatabase? db,
    String userId,
  ) async {
    if (db == null) throw Exception('Database not available');

    try {
      final users =
          await (db.select(db.users)..where((u) => u.id.equals(userId))).get();

      final user = users.isNotEmpty ? users.first : null;

      if (user != null) {
        print('  ✅ User found in local DB: ${user.displayName}');
      } else {
        print('  ⚠️ User not found in local DB');
      }

      final stats = await (db.select(db.userStats)
            ..where((s) => s.userId.equals(userId)))
          .get();

      final userStats = stats.isNotEmpty ? stats.first : null;

      if (user == null) {
        throw Exception('User not found');
      }

      return {
        'user': user,
        'stats': userStats,
      };
    } catch (e) {
      print('❌ Error loading from local DB: $e');
      rethrow;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}
