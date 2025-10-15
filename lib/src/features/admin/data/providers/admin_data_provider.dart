import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_provider.dart';

// Admin Dashboard Data Provider
final adminDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.read(databaseProvider);
  final supabase = Supabase.instance.client;
  
  if (database == null) {
    throw Exception('Database not available');
  }

  // Fetch real data from database
  final users = await database.select(database.users).get();
  final workouts = await database.select(database.workoutSessions).get();
  final templates = await database.select(database.workoutTemplates).get();
  final exercises = await database.select(database.exercises).get();
  
  final userCount = users.length;
  final workoutCount = workouts.length;
  final templateCount = templates.length;
  final exerciseCount = exercises.length;
  
  // Debug: Print database state
  print('🔍 Admin Dashboard Debug:');
  print('  Users: $userCount');
  print('  Workouts: $workoutCount');
  print('  Templates: $templateCount');
  print('  Exercises: $exerciseCount');
  
  // Get recent activity (last 7 days)
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
  final allWorkouts = await database.select(database.workoutSessions).get();
  final recentWorkouts = allWorkouts.where((w) => 
    w.completedAt != null && w.completedAt!.isAfter(sevenDaysAgo)
  ).toList();
  
  // For now, assume all users are active since we don't have user-workout relationships
  final activeUsers = userCount;

  return {
    'totalUsers': userCount,
    'activeUsers': activeUsers,
    'totalWorkouts': workoutCount,
    'totalTemplates': templateCount,
    'totalExercises': exerciseCount,
    'recentWorkouts': recentWorkouts.length,
    'lastUpdated': DateTime.now().toIso8601String(),
  };
});

// User Management Data Provider
final userManagementProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final database = ref.read(databaseProvider);
  final supabase = Supabase.instance.client;
  
  if (database == null) {
    throw Exception('Database not available');
  }

  // Get users from local database
  final localUsers = await database.select(database.users).get();
  
  // Debug: Print user data
  print('🔍 User Management Debug:');
  print('  Found ${localUsers.length} users in database');
  for (final user in localUsers) {
    print('    - ${user.displayName} (${user.email})');
  }
  
  // Get user metadata from Supabase if available
  final List<Map<String, dynamic>> users = [];
  
  for (final user in localUsers) {
    try {
      // Try to get additional user data from Supabase
      final supabaseUser = supabase.auth.currentUser;
      final userMetadata = supabaseUser?.userMetadata ?? {};
      
      users.add({
        'id': user.id,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': user.createdAt.toIso8601String(),
        'lastSignInAt': user.lastSyncAt?.toIso8601String(),
        'role': userMetadata['role'] ?? 'user',
        'status': 'active',
        'bannedUntil': null,
        'workoutCount': 0, // No user-workout relationship in current schema
        'lastWorkoutAt': null,
      });
    } catch (e) {
      // Fallback to local data only
      users.add({
        'id': user.id,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': user.createdAt.toIso8601String(),
        'lastSignInAt': user.lastSyncAt?.toIso8601String(),
        'role': 'user',
        'status': 'active',
        'bannedUntil': null,
        'workoutCount': 0,
        'lastWorkoutAt': null,
      });
    }
  }
  
  return users;
});

// Analytics Data Provider
final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.read(databaseProvider);
  
  if (database == null) {
    throw Exception('Database not available');
  }

  // Get workout analytics
  final allWorkouts = await database.select(database.workoutSessions).get();
  final allUsers = await database.select(database.users).get();
  
  // Calculate metrics
  final totalWorkouts = allWorkouts.length;
  final totalUsers = allUsers.length;
  final activeUsers = totalUsers; // Assume all users are active
  
  // Get workouts by day (last 30 days)
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  final recentWorkouts = allWorkouts.where((w) => 
    w.completedAt != null && w.completedAt!.isAfter(thirtyDaysAgo)
  ).toList();
  
  // Calculate daily workout counts
  final Map<String, int> dailyWorkouts = {};
  for (final workout in recentWorkouts) {
    final date = workout.completedAt!.toIso8601String().split('T')[0];
    dailyWorkouts[date] = (dailyWorkouts[date] ?? 0) + 1;
  }
  
  // Get most popular exercises
  final exerciseStats = <String, int>{};
  final allSets = await database.select(database.setEntries).get();
  final allExercises = await database.select(database.exercises).get();
  
  for (final set in allSets) {
    final exercise = allExercises.firstWhere(
      (e) => e.id == set.exerciseId,
      orElse: () => allExercises.first, // Fallback
    );
    
    exerciseStats[exercise.name] = (exerciseStats[exercise.name] ?? 0) + 1;
  }
  
  final topExercises = exerciseStats.entries
      .toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);
  
  return {
    'totalUsers': totalUsers,
    'activeUsers': activeUsers,
    'totalWorkouts': totalWorkouts,
    'recentWorkouts': recentWorkouts.length,
    'dailyWorkouts': dailyWorkouts,
    'topExercises': topExercises.map((e) => {'name': e.key, 'count': e.value}).toList(),
    'averageWorkoutsPerUser': totalUsers > 0 ? (totalWorkouts / totalUsers).toStringAsFixed(1) : '0',
    'lastUpdated': DateTime.now().toIso8601String(),
  };
});

// System Health Provider
final systemHealthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.read(databaseProvider);
  
  if (database == null) {
    throw Exception('Database not available');
  }

  // Get database stats
  final userCount = await database.select(database.users).get().then((users) => users.length);
  final workoutCount = await database.select(database.workoutSessions).get().then((workouts) => workouts.length);
  final templateCount = await database.select(database.workoutTemplates).get().then((templates) => templates.length);
  final exerciseCount = await database.select(database.exercises).get().then((exercises) => exercises.length);
  
  // Calculate database size (approximate)
  final dbSize = (userCount * 0.5 + workoutCount * 2.0 + templateCount * 1.0 + exerciseCount * 0.3);
  
  // Get recent activity
  final last24Hours = DateTime.now().subtract(const Duration(hours: 24));
  final allWorkouts = await database.select(database.workoutSessions).get();
  final recentActivity = allWorkouts.where((w) => 
    w.completedAt != null && w.completedAt!.isAfter(last24Hours)
  ).length;
  
  return {
    'databaseSize': '${dbSize.toStringAsFixed(1)} MB',
    'userCount': userCount,
    'workoutCount': workoutCount,
    'templateCount': templateCount,
    'exerciseCount': exerciseCount,
    'recentActivity': recentActivity,
    'lastUpdated': DateTime.now().toIso8601String(),
    'status': 'healthy',
  };
});

// Content Moderation Provider
final contentModerationProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // For now, return empty data since we don't have social features implemented yet
  // This would be expanded when social features are added
  return {
    'reportedPosts': 0,
    'reportedComments': 0,
    'pendingReviews': 0,
    'moderationActions': 0,
    'lastUpdated': DateTime.now().toIso8601String(),
  };
});
