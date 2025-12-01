import 'package:flutter/material.dart';

class AppConstants {
  // App info
  static const String appName = 'Habit Tracker';
  static const String appVersion = '1.0.0';

  // XP System
  static const int baseXP = 10;
  static const int streakBonus7Days = 50;
  static const int streakBonus30Days = 200;
  static const int streakBonus100Days = 500;
  static const int xpPerLevel = 100;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 300);

  // Hive box names
  static const String habitsBox = 'habits';
  static const String userBox = 'user';
  static const String achievementsBox = 'achievements';
  static const String completionsBox = 'completions';
  static const String settingsBox = 'settings';

  // Default avatar emojis
  static const List<String> avatarEmojis = [
    '😊', '🚀', '⭐', '🔥', '💪', '🎯', '✨', '🌟',
    '💫', '🌈', '🎨', '🎵', '📚', '💡', '🌿', '🦋',
    '🐱', '🐶', '🦊', '🐼', '🐨', '🦁', '🐯', '🐸',
  ];

  // Habit icons
  static const List<IconData> habitIcons = [
    Icons.fitness_center,
    Icons.book,
    Icons.water_drop,
    Icons.bedtime,
    Icons.restaurant,
    Icons.self_improvement,
    Icons.directions_run,
    Icons.code,
    Icons.music_note,
    Icons.brush,
    Icons.work,
    Icons.school,
    Icons.local_cafe,
    Icons.movie,
    Icons.pets,
    Icons.eco,
    Icons.spa,
    Icons.savings,
    Icons.phone_android,
    Icons.timer,
    Icons.local_florist,
    Icons.psychology,
    Icons.favorite,
    Icons.star,
  ];

  // Days of week
  static const List<String> daysOfWeek = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  static const List<String> fullDaysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  // Habit categories
  static const List<String> habitCategories = [
    'Health',
    'Fitness',
    'Productivity',
    'Learning',
    'Mindfulness',
    'Finance',
    'Social',
    'Creative',
    'Other',
  ];

  // Smart habit suggestions
  static const List<Map<String, dynamic>> habitSuggestions = [
    {'name': 'Drink Water', 'icon': 1, 'category': 'Health', 'description': 'Stay hydrated throughout the day'},
    {'name': 'Morning Exercise', 'icon': 0, 'category': 'Fitness', 'description': 'Start your day with movement'},
    {'name': 'Read 30 Minutes', 'icon': 1, 'category': 'Learning', 'description': 'Expand your knowledge daily'},
    {'name': 'Meditate', 'icon': 5, 'category': 'Mindfulness', 'description': 'Find inner peace'},
    {'name': 'Sleep 8 Hours', 'icon': 3, 'category': 'Health', 'description': 'Rest well for better performance'},
    {'name': 'Practice Coding', 'icon': 7, 'category': 'Learning', 'description': 'Improve your programming skills'},
    {'name': 'Healthy Breakfast', 'icon': 4, 'category': 'Health', 'description': 'Fuel your body right'},
    {'name': 'Journaling', 'icon': 1, 'category': 'Mindfulness', 'description': 'Reflect on your thoughts'},
    {'name': 'No Phone Before Bed', 'icon': 18, 'category': 'Health', 'description': 'Better sleep quality'},
    {'name': 'Save Money', 'icon': 17, 'category': 'Finance', 'description': 'Build financial security'},
  ];

  // Greeting messages based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Motivational quotes
  static const List<String> motivationalQuotes = [
    'Small steps lead to big changes.',
    'Consistency is the key to success.',
    'You are stronger than you think.',
    'Every day is a fresh start.',
    'Believe in yourself and all that you are.',
    'Your habits shape your future.',
    'Progress, not perfection.',
    'One day at a time.',
    'You are capable of amazing things.',
    'Make today count!',
  ];
}
