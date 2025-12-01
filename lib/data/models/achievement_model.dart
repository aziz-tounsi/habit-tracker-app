import 'package:flutter/material.dart';

enum AchievementCategory {
  streaks,
  completions,
  habits,
  milestones,
}

class AchievementModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final int? requirement;
  final int xpReward;

  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.requirement,
    required this.xpReward,
  });

  static const List<AchievementModel> allAchievements = [
    // Streak achievements
    AchievementModel(
      id: 'streak_7',
      name: '7-Day Streak',
      description: 'Complete a habit for 7 days in a row',
      icon: Icons.local_fire_department,
      category: AchievementCategory.streaks,
      requirement: 7,
      xpReward: 50,
    ),
    AchievementModel(
      id: 'streak_30',
      name: '30-Day Streak',
      description: 'Complete a habit for 30 days in a row',
      icon: Icons.whatshot,
      category: AchievementCategory.streaks,
      requirement: 30,
      xpReward: 200,
    ),
    AchievementModel(
      id: 'streak_100',
      name: '100-Day Streak',
      description: 'Complete a habit for 100 days in a row',
      icon: Icons.local_fire_department_outlined,
      category: AchievementCategory.streaks,
      requirement: 100,
      xpReward: 500,
    ),

    // Completion achievements
    AchievementModel(
      id: 'first_completion',
      name: 'First Step',
      description: 'Complete your first habit',
      icon: Icons.star,
      category: AchievementCategory.completions,
      requirement: 1,
      xpReward: 10,
    ),
    AchievementModel(
      id: 'completions_10',
      name: 'Getting Started',
      description: 'Complete habits 10 times',
      icon: Icons.star_half,
      category: AchievementCategory.completions,
      requirement: 10,
      xpReward: 25,
    ),
    AchievementModel(
      id: 'completions_50',
      name: 'Habit Builder',
      description: 'Complete habits 50 times',
      icon: Icons.stars,
      category: AchievementCategory.completions,
      requirement: 50,
      xpReward: 100,
    ),
    AchievementModel(
      id: 'completions_100',
      name: 'Habit Master',
      description: 'Complete habits 100 times',
      icon: Icons.emoji_events,
      category: AchievementCategory.completions,
      requirement: 100,
      xpReward: 250,
    ),
    AchievementModel(
      id: 'completions_500',
      name: 'Legendary',
      description: 'Complete habits 500 times',
      icon: Icons.military_tech,
      category: AchievementCategory.completions,
      requirement: 500,
      xpReward: 1000,
    ),

    // Habit achievements
    AchievementModel(
      id: 'first_habit',
      name: 'First Habit',
      description: 'Create your first habit',
      icon: Icons.add_circle,
      category: AchievementCategory.habits,
      requirement: 1,
      xpReward: 10,
    ),
    AchievementModel(
      id: 'habits_5',
      name: 'Habit Collector',
      description: 'Create 5 habits',
      icon: Icons.collections_bookmark,
      category: AchievementCategory.habits,
      requirement: 5,
      xpReward: 50,
    ),
    AchievementModel(
      id: 'habits_10',
      name: 'Habit Enthusiast',
      description: 'Create 10 habits',
      icon: Icons.dashboard,
      category: AchievementCategory.habits,
      requirement: 10,
      xpReward: 100,
    ),

    // Milestone achievements
    AchievementModel(
      id: 'perfect_day',
      name: 'Perfect Day',
      description: 'Complete all habits in a single day',
      icon: Icons.celebration,
      category: AchievementCategory.milestones,
      xpReward: 50,
    ),
    AchievementModel(
      id: 'week_warrior',
      name: 'Week Warrior',
      description: 'Complete all habits for a full week',
      icon: Icons.calendar_today,
      category: AchievementCategory.milestones,
      xpReward: 100,
    ),
    AchievementModel(
      id: 'monthly_master',
      name: 'Monthly Master',
      description: 'Complete all habits for a full month',
      icon: Icons.calendar_month,
      category: AchievementCategory.milestones,
      xpReward: 500,
    ),
    AchievementModel(
      id: 'level_5',
      name: 'Level 5',
      description: 'Reach level 5',
      icon: Icons.leaderboard,
      category: AchievementCategory.milestones,
      requirement: 5,
      xpReward: 100,
    ),
    AchievementModel(
      id: 'level_10',
      name: 'Level 10',
      description: 'Reach level 10',
      icon: Icons.leaderboard,
      category: AchievementCategory.milestones,
      requirement: 10,
      xpReward: 250,
    ),
    AchievementModel(
      id: 'level_25',
      name: 'Level 25',
      description: 'Reach level 25',
      icon: Icons.leaderboard,
      category: AchievementCategory.milestones,
      requirement: 25,
      xpReward: 500,
    ),
  ];

  static AchievementModel? getById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<AchievementModel> getByCategory(AchievementCategory category) {
    return allAchievements.where((a) => a.category == category).toList();
  }
}
