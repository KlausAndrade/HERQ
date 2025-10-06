import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredProgress;
  final int xpReward;
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredProgress,
    required this.xpReward,
    required this.category,
  });
}

enum AchievementCategory {
  workouts,
  streaks,
  volume,
  consistency,
  milestones,
}

// Predefined achievements
class Achievements {
  static const List<Achievement> all = [
    // Workout count achievements
    Achievement(
      id: 'first_workout',
      title: 'Getting Started',
      description: 'Complete your first workout',
      icon: Icons.fitness_center,
      color: Colors.blue,
      requiredProgress: 1,
      xpReward: 50,
      category: AchievementCategory.workouts,
    ),
    Achievement(
      id: 'workouts_10',
      title: 'Dedicated',
      description: 'Complete 10 workouts',
      icon: Icons.emoji_events,
      color: Colors.green,
      requiredProgress: 10,
      xpReward: 100,
      category: AchievementCategory.workouts,
    ),
    Achievement(
      id: 'workouts_25',
      title: 'Committed',
      description: 'Complete 25 workouts',
      icon: Icons.military_tech,
      color: Colors.orange,
      requiredProgress: 25,
      xpReward: 200,
      category: AchievementCategory.workouts,
    ),
    Achievement(
      id: 'workouts_50',
      title: 'Warrior',
      description: 'Complete 50 workouts',
      icon: Icons.shield,
      color: Colors.purple,
      requiredProgress: 50,
      xpReward: 500,
      category: AchievementCategory.workouts,
    ),
    Achievement(
      id: 'workouts_100',
      title: 'Centurion',
      description: 'Complete 100 workouts',
      icon: Icons.stars,
      color: Colors.amber,
      requiredProgress: 100,
      xpReward: 1000,
      category: AchievementCategory.workouts,
    ),

    // Streak achievements
    Achievement(
      id: 'streak_3',
      title: '3 Day Streak',
      description: 'Work out 3 days in a row',
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
      requiredProgress: 3,
      xpReward: 75,
      category: AchievementCategory.streaks,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Work out 7 days in a row',
      icon: Icons.whatshot,
      color: Colors.red,
      requiredProgress: 7,
      xpReward: 200,
      category: AchievementCategory.streaks,
    ),
    Achievement(
      id: 'streak_14',
      title: 'Two Week Titan',
      description: 'Work out 14 days in a row',
      icon: Icons.fireplace,
      color: Colors.deepOrange,
      requiredProgress: 14,
      xpReward: 400,
      category: AchievementCategory.streaks,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Monthly Master',
      description: 'Work out 30 days in a row',
      icon: Icons.verified,
      color: Colors.purple,
      requiredProgress: 30,
      xpReward: 1000,
      category: AchievementCategory.streaks,
    ),

    // Volume achievements
    Achievement(
      id: 'volume_1000',
      title: 'Iron Beginner',
      description: 'Lift 1,000kg total volume',
      icon: Icons.fitness_center,
      color: Colors.blueGrey,
      requiredProgress: 1000,
      xpReward: 100,
      category: AchievementCategory.volume,
    ),
    Achievement(
      id: 'volume_10000',
      title: 'Steel Champion',
      description: 'Lift 10,000kg total volume',
      icon: Icons.sports_martial_arts,
      color: Colors.blue,
      requiredProgress: 10000,
      xpReward: 300,
      category: AchievementCategory.volume,
    ),
    Achievement(
      id: 'volume_50000',
      title: 'Titanium Beast',
      description: 'Lift 50,000kg total volume',
      icon: Icons.psychology,
      color: Colors.indigo,
      requiredProgress: 50000,
      xpReward: 800,
      category: AchievementCategory.volume,
    ),

    // Consistency achievements
    Achievement(
      id: 'consistency_3_weeks',
      title: 'Building Habits',
      description: 'Complete at least 3 workouts per week for 3 weeks',
      icon: Icons.calendar_today,
      color: Colors.teal,
      requiredProgress: 9,
      xpReward: 250,
      category: AchievementCategory.consistency,
    ),

    // Milestone achievements
    Achievement(
      id: 'sets_100',
      title: 'Set Master',
      description: 'Complete 100 sets',
      icon: Icons.format_list_numbered,
      color: Colors.cyan,
      requiredProgress: 100,
      xpReward: 150,
      category: AchievementCategory.milestones,
    ),
    Achievement(
      id: 'sets_500',
      title: 'Set Legend',
      description: 'Complete 500 sets',
      icon: Icons.library_books,
      color: Colors.deepPurple,
      requiredProgress: 500,
      xpReward: 500,
      category: AchievementCategory.milestones,
    ),
    Achievement(
      id: 'workout_time_10h',
      title: 'Time Investor',
      description: 'Spend 10 hours working out',
      icon: Icons.access_time,
      color: Colors.brown,
      requiredProgress: 600, // minutes
      xpReward: 300,
      category: AchievementCategory.milestones,
    ),
  ];

  static Achievement? findById(String id) {
    try {
      return all.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }
}
