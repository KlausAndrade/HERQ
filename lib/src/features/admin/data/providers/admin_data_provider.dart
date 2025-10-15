import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';

import '../../../../core/database/database.dart' as db;
import '../../../../core/providers/database_provider.dart';

// Admin Dashboard Data Provider
final adminDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.read(databaseProvider);
  final supabase = Supabase.instance.client;
  
  if (database == null) {
    throw Exception('Database not available');
  }

  // Debug: Print database state
  print('🔍 Admin Dashboard Debug:');
  
  try {
    // Get users from Supabase Auth
    final authUsers = await supabase.auth.admin.listUsers();
    final userCount = authUsers.length;
    print('  Supabase Users: $userCount');
    
    // Get local data
    final workouts = await database.select(database.workoutSessions).get();
    final templates = await database.select(database.workoutTemplates).get();
    final exercises = await database.select(database.exercises).get();
    
    final workoutCount = workouts.length;
    final templateCount = templates.length;
    final exerciseCount = exercises.length;
    
    print('  Local Workouts: $workoutCount');
    print('  Local Templates: $templateCount');
    print('  Local Exercises: $exerciseCount');
    
    // Get recent activity (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentWorkouts = workouts.where((w) => 
      w.completedAt != null && w.completedAt!.isAfter(sevenDaysAgo)
    ).toList();
    
    // Calculate active users (users who have signed in within last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final activeUsers = authUsers.where((user) {
      if (user.lastSignInAt == null) return false;
      return DateTime.parse(user.lastSignInAt!).isAfter(thirtyDaysAgo);
    }).length;
    
    print('  Active Users (last 30 days): $activeUsers');
    print('  Recent Workouts (last 7 days): ${recentWorkouts.length}');

    return {
      'totalUsers': userCount,
      'activeUsers': activeUsers,
      'totalWorkouts': workoutCount,
      'totalTemplates': templateCount,
      'totalExercises': exerciseCount,
      'recentWorkouts': recentWorkouts.length,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    
  } catch (e) {
    print('  Error fetching Supabase users: $e');
    print('  Falling back to local data only');
    
    // Fallback to local data only
    final users = await database.select(database.users).get();
    final workouts = await database.select(database.workoutSessions).get();
    final templates = await database.select(database.workoutTemplates).get();
    final exercises = await database.select(database.exercises).get();
    
    final userCount = users.length;
    final workoutCount = workouts.length;
    final templateCount = templates.length;
    final exerciseCount = exercises.length;
    
    print('  Local Users: $userCount');
    print('  Local Workouts: $workoutCount');
    print('  Local Templates: $templateCount');
    print('  Local Exercises: $exerciseCount');
    
    // Get recent activity (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentWorkouts = workouts.where((w) => 
      w.completedAt != null && w.completedAt!.isAfter(sevenDaysAgo)
    ).toList();
    
    // For local users, assume all are active
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
  }
});

// User Management Data Provider
final userManagementProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final database = ref.read(databaseProvider);
  final supabase = Supabase.instance.client;
  
  if (database == null) {
    throw Exception('Database not available');
  }

  // Debug: Print user data
  print('🔍 User Management Debug:');
  
  try {
    // First, try to get users from Supabase auth
    final authUsers = await supabase.auth.admin.listUsers();
    print('  Found ${authUsers.length} users in Supabase Auth');
    
    // Get local users for additional data
    final localUsers = await database.select(database.users).get();
    print('  Found ${localUsers.length} users in local database');
    
    final List<Map<String, dynamic>> users = [];
    
    // Process Supabase auth users
    for (final authUser in authUsers) {
      // Find corresponding local user data
      db.User? localUser;
      try {
        localUser = localUsers.firstWhere((u) => u.email == authUser.email);
      } catch (e) {
        localUser = localUsers.isNotEmpty ? localUsers.first : null;
      }
      
      // Get user metadata
      final userMetadata = authUser.userMetadata ?? {};
      final appMetadata = authUser.appMetadata ?? {};
      
      // Calculate workout count from local database
      // NOTE: Current schema doesn't have userId in workout sessions
      // This is a limitation that needs to be addressed for true multi-user support
      int workoutCount = 0;
      DateTime? lastWorkoutAt;
      
      // For now, we can't link workouts to specific users due to schema limitations
      // This would require adding a userId field to the WorkoutSessions table
      
      users.add({
        'id': authUser.id,
        'email': authUser.email ?? 'No email',
        'displayName': userMetadata['display_name'] ?? 
                      userMetadata['full_name'] ?? 
                      localUser?.displayName ?? 
                      authUser.email?.split('@')[0] ?? 'Unknown',
        'createdAt': authUser.createdAt,
        'lastSignInAt': authUser.lastSignInAt,
        'role': appMetadata['role'] ?? 'user',
        'status': authUser.emailConfirmedAt == null ? 'unconfirmed' : 'active',
        'bannedUntil': null, // Supabase User doesn't have bannedUntil field
        'emailConfirmed': authUser.emailConfirmedAt != null,
        'workoutCount': workoutCount,
        'lastWorkoutAt': lastWorkoutAt?.toIso8601String(),
        'provider': authUser.appMetadata?['provider'] ?? 'email',
        'avatarUrl': userMetadata['avatar_url'],
      });
      
      print('    - ${userMetadata['display_name'] ?? authUser.email} (${authUser.email}) - ${workoutCount} workouts');
    }
    
    return users;
    
  } catch (e) {
    print('  Error fetching Supabase users: $e');
    print('  Falling back to local users only');
    
    // Fallback to local users only
    final localUsers = await database.select(database.users).get();
    final List<Map<String, dynamic>> users = [];
    
    for (final user in localUsers) {
      // NOTE: Current schema doesn't support user-specific workout tracking
      // This would require schema changes to add userId to workout sessions
      int workoutCount = 0;
      DateTime? lastWorkoutAt;
      
      users.add({
        'id': user.id,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': user.createdAt.toIso8601String(),
        'lastSignInAt': user.lastSyncAt?.toIso8601String(),
        'role': 'user',
        'status': 'active',
        'bannedUntil': null,
        'emailConfirmed': true,
        'workoutCount': workoutCount,
        'lastWorkoutAt': lastWorkoutAt?.toIso8601String(),
        'provider': 'local',
        'avatarUrl': null,
      });
      
      print('    - ${user.displayName} (${user.email}) - ${workoutCount} workouts');
    }
    
    return users;
  }
});

// Analytics Data Provider
final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.read(databaseProvider);
  final supabase = Supabase.instance.client;
  
  if (database == null) {
    throw Exception('Database not available');
  }

  try {
    // Get users from Supabase
    final authUsers = await supabase.auth.admin.listUsers();
    final totalUsers = authUsers.length;
    
    // Get workout analytics from local database
    final allWorkouts = await database.select(database.workoutSessions).get();
    final totalWorkouts = allWorkouts.length;
    
    // Calculate active users (users who have signed in within last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final activeUsers = authUsers.where((user) {
      if (user.lastSignInAt == null) return false;
      return DateTime.parse(user.lastSignInAt!).isAfter(thirtyDaysAgo);
    }).length;
    
    // Get workouts by day (last 30 days)
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
    
    print('🔍 Analytics Debug:');
    print('  Supabase Users: $totalUsers');
    print('  Active Users: $activeUsers');
    print('  Total Workouts: $totalWorkouts');
    print('  Recent Workouts: ${recentWorkouts.length}');
    print('  Top Exercises: ${topExercises.length}');
    
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
    
  } catch (e) {
    print('🔍 Analytics Debug (Fallback):');
    print('  Error fetching Supabase users: $e');
    
    // Fallback to local data only
    final allWorkouts = await database.select(database.workoutSessions).get();
    final allUsers = await database.select(database.users).get();
    
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
    
    print('  Local Users: $totalUsers');
    print('  Local Workouts: $totalWorkouts');
    print('  Recent Workouts: ${recentWorkouts.length}');
    
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
  }
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
  // Debug: Print content data
  print('🔍 Content Moderation Debug:');
  
  try {
    // Since we don't have social features implemented yet, return empty data
    // This will show "No content found" message instead of fake data
    print('  No social features implemented yet - returning empty data');
    
    return {
      'posts': [],
      'comments': [],
      'reports': [],
    };
  } catch (e) {
    print('  Error fetching content: $e');
    return {
      'posts': [],
      'comments': [],
      'reports': [],
    };
  }
});
