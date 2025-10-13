import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    
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
        future: _loadUserData(db, userId),
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

          final data = snapshot.data as Map<String, dynamic>;
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
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
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
                if (user?.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    user!.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
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
                          stats.totalWorkouts.toString(),
                          'Workouts',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '🏋️',
                          '${stats.totalVolumeLifted.toStringAsFixed(0)} kg',
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
                          '${stats.currentStreak}',
                          'Day Streak',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '⭐',
                          'Level ${stats.level}',
                          '${stats.experiencePoints} XP',
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'No workout data',
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

  String _getDisplayName(dynamic user) {
    if (user == null) return 'User';
    if (user.displayName != null && user.displayName.isNotEmpty) {
      return user.displayName;
    }
    if (user.email != null && user.email.isNotEmpty) {
      return user.email!.split('@').first;
    }
    return 'User';
  }

  Widget _buildStatCard(BuildContext context, String emoji, String value, String label) {
    return Card(
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
  }

  Future<Map<String, dynamic>> _loadUserData(AppDatabase? db, String userId) async {
    if (db == null) throw Exception('Database not available');

    print('👤 Loading user profile for userId: $userId');

    try {
      // Get all users to debug
      final allUsers = await db.select(db.users).get();
      print('  📊 Total users in DB: ${allUsers.length}');
      for (final u in allUsers) {
        print('  👥 User: id=${u.id}, email=${u.email}, displayName=${u.displayName}');
      }
      
      final users = await (db.select(db.users)
            ..where((u) => u.id.equals(userId)))
          .get();
      
      print('  🔍 Found ${users.length} users matching userId: $userId');
      final user = users.isNotEmpty ? users.first : null;
      
      if (user != null) {
        print('  ✅ User found: email=${user.email}, displayName=${user.displayName}');
      } else {
        print('  ⚠️ User not found for userId: $userId');
      }

      final stats = await (db.select(db.userStats)
            ..where((s) => s.userId.equals(userId)))
          .get();
      
      final userStats = stats.isNotEmpty ? stats.first : null;
      print('  📊 Stats found: ${userStats != null}');

      if (user == null) {
        throw Exception('User not found for userId: $userId');
      }

      return {
        'user': user,
        'stats': userStats,
      };
    } catch (e) {
      print('❌ Error loading user: $e');
      rethrow;
    }
  }
}

