import 'package:flutter/material.dart';

class HabitSuggestion {
  final String name;
  final IconData icon;
  final String category;
  final String? description;

  const HabitSuggestion({
    required this.name,
    required this.icon,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'category': category,
      'description': description,
    };
  }
}

class BadHabitSuggestion {
  final String name;
  final IconData icon;
  final String category;
  final String? configType; // References BadHabitConfigs

  const BadHabitSuggestion({
    required this.name,
    required this.icon,
    required this.category,
    this.configType,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'category': category,
      'configType': configType,
    };
  }
}

class HabitSuggestions {
  // 50+ Good Habits organized by category
  static const List<HabitSuggestion> goodHabits = [
    // Health (10)
    HabitSuggestion(
      name: 'Drink 8 Glasses of Water',
      icon: Icons.water_drop,
      category: 'Health',
      description: 'Stay hydrated throughout the day',
    ),
    HabitSuggestion(
      name: 'Take Vitamins',
      icon: Icons.medication,
      category: 'Health',
      description: 'Daily supplement routine',
    ),
    HabitSuggestion(
      name: 'Floss Teeth',
      icon: Icons.clean_hands,
      category: 'Health',
      description: 'Maintain dental hygiene',
    ),
    HabitSuggestion(
      name: 'Skincare Routine',
      icon: Icons.spa,
      category: 'Health',
      description: 'Morning and evening skincare',
    ),
    HabitSuggestion(
      name: 'Cold Shower',
      icon: Icons.shower,
      category: 'Health',
      description: 'Boost circulation and energy',
    ),
    HabitSuggestion(
      name: 'Posture Check',
      icon: Icons.accessibility_new,
      category: 'Health',
      description: 'Maintain good posture',
    ),
    HabitSuggestion(
      name: 'Eye Rest (20-20-20)',
      icon: Icons.visibility,
      category: 'Health',
      description: 'Every 20 min, look 20 feet away for 20 sec',
    ),
    HabitSuggestion(
      name: 'Hand Washing',
      icon: Icons.wash,
      category: 'Health',
      description: 'Regular hand hygiene',
    ),
    HabitSuggestion(
      name: 'Healthy Breakfast',
      icon: Icons.breakfast_dining,
      category: 'Health',
      description: 'Start the day with nutrition',
    ),
    HabitSuggestion(
      name: 'No Late Night Eating',
      icon: Icons.nightlight,
      category: 'Health',
      description: 'Stop eating 3 hours before bed',
    ),

    // Fitness (10)
    HabitSuggestion(
      name: 'Morning Exercise',
      icon: Icons.fitness_center,
      category: 'Fitness',
      description: 'Start your day with movement',
    ),
    HabitSuggestion(
      name: 'Walk 10,000 Steps',
      icon: Icons.directions_walk,
      category: 'Fitness',
      description: 'Daily step goal',
    ),
    HabitSuggestion(
      name: 'Yoga Practice',
      icon: Icons.self_improvement,
      category: 'Fitness',
      description: 'Mind and body flexibility',
    ),
    HabitSuggestion(
      name: 'Stretching',
      icon: Icons.accessibility,
      category: 'Fitness',
      description: 'Improve flexibility',
    ),
    HabitSuggestion(
      name: 'Running',
      icon: Icons.directions_run,
      category: 'Fitness',
      description: 'Cardio workout',
    ),
    HabitSuggestion(
      name: 'Strength Training',
      icon: Icons.sports_gymnastics,
      category: 'Fitness',
      description: 'Build muscle',
    ),
    HabitSuggestion(
      name: 'Swimming',
      icon: Icons.pool,
      category: 'Fitness',
      description: 'Full body workout',
    ),
    HabitSuggestion(
      name: 'Cycling',
      icon: Icons.directions_bike,
      category: 'Fitness',
      description: 'Low impact cardio',
    ),
    HabitSuggestion(
      name: 'Plank Exercise',
      icon: Icons.accessibility_new,
      category: 'Fitness',
      description: 'Core strengthening',
    ),
    HabitSuggestion(
      name: 'Sports Activity',
      icon: Icons.sports_basketball,
      category: 'Fitness',
      description: 'Play your favorite sport',
    ),

    // Mindfulness (8)
    HabitSuggestion(
      name: 'Morning Meditation',
      icon: Icons.spa,
      category: 'Mindfulness',
      description: 'Start peacefully',
    ),
    HabitSuggestion(
      name: 'Gratitude Journal',
      icon: Icons.book,
      category: 'Mindfulness',
      description: 'Write 3 things you\'re grateful for',
    ),
    HabitSuggestion(
      name: 'Evening Reflection',
      icon: Icons.nightlight_round,
      category: 'Mindfulness',
      description: 'Review your day',
    ),
    HabitSuggestion(
      name: 'Deep Breathing',
      icon: Icons.air,
      category: 'Mindfulness',
      description: '5-10 minutes of breathing exercises',
    ),
    HabitSuggestion(
      name: 'Mindful Walking',
      icon: Icons.nature_people,
      category: 'Mindfulness',
      description: 'Walking meditation',
    ),
    HabitSuggestion(
      name: 'Body Scan',
      icon: Icons.psychology,
      category: 'Mindfulness',
      description: 'Mindfulness practice',
    ),
    HabitSuggestion(
      name: 'Positive Affirmations',
      icon: Icons.favorite,
      category: 'Mindfulness',
      description: 'Start with positive self-talk',
    ),
    HabitSuggestion(
      name: 'Practice Patience',
      icon: Icons.self_improvement,
      category: 'Mindfulness',
      description: 'Cultivate patience daily',
    ),

    // Learning (8)
    HabitSuggestion(
      name: 'Read 30 Minutes',
      icon: Icons.menu_book,
      category: 'Learning',
      description: 'Expand knowledge',
    ),
    HabitSuggestion(
      name: 'Learn New Language',
      icon: Icons.translate,
      category: 'Learning',
      description: 'Practice daily',
    ),
    HabitSuggestion(
      name: 'Online Course',
      icon: Icons.school,
      category: 'Learning',
      description: 'Continue education',
    ),
    HabitSuggestion(
      name: 'Practice Coding',
      icon: Icons.code,
      category: 'Learning',
      description: 'Improve programming skills',
    ),
    HabitSuggestion(
      name: 'Watch Educational Video',
      icon: Icons.ondemand_video,
      category: 'Learning',
      description: 'Learn something new',
    ),
    HabitSuggestion(
      name: 'Podcast Listening',
      icon: Icons.headphones,
      category: 'Learning',
      description: 'Listen while commuting',
    ),
    HabitSuggestion(
      name: 'Study Session',
      icon: Icons.school,
      category: 'Learning',
      description: 'Dedicated learning time',
    ),
    HabitSuggestion(
      name: 'Research Topic',
      icon: Icons.search,
      category: 'Learning',
      description: 'Deep dive into a subject',
    ),

    // Productivity (8)
    HabitSuggestion(
      name: 'Plan Your Day',
      icon: Icons.calendar_today,
      category: 'Productivity',
      description: 'Morning planning session',
    ),
    HabitSuggestion(
      name: 'Make Bed',
      icon: Icons.bed,
      category: 'Productivity',
      description: 'Start day with accomplishment',
    ),
    HabitSuggestion(
      name: 'Review Weekly Goals',
      icon: Icons.assignment,
      category: 'Productivity',
      description: 'Track progress',
    ),
    HabitSuggestion(
      name: 'Clear Email Inbox',
      icon: Icons.email,
      category: 'Productivity',
      description: 'Stay organized',
    ),
    HabitSuggestion(
      name: 'Deep Work Session',
      icon: Icons.work,
      category: 'Productivity',
      description: 'Focused work time',
    ),
    HabitSuggestion(
      name: 'Time Blocking',
      icon: Icons.schedule,
      category: 'Productivity',
      description: 'Schedule your tasks',
    ),
    HabitSuggestion(
      name: 'Declutter Space',
      icon: Icons.cleaning_services,
      category: 'Productivity',
      description: 'Organize your environment',
    ),
    HabitSuggestion(
      name: 'Review To-Do List',
      icon: Icons.checklist,
      category: 'Productivity',
      description: 'Update your tasks',
    ),

    // Social (6)
    HabitSuggestion(
      name: 'Call Family',
      icon: Icons.phone,
      category: 'Social',
      description: 'Stay connected',
    ),
    HabitSuggestion(
      name: 'Message Friend',
      icon: Icons.message,
      category: 'Social',
      description: 'Reach out to someone',
    ),
    HabitSuggestion(
      name: 'Quality Time',
      icon: Icons.people,
      category: 'Social',
      description: 'Spend time with loved ones',
    ),
    HabitSuggestion(
      name: 'Acts of Kindness',
      icon: Icons.volunteer_activism,
      category: 'Social',
      description: 'Help someone today',
    ),
    HabitSuggestion(
      name: 'Compliment Someone',
      icon: Icons.sentiment_satisfied_alt,
      category: 'Social',
      description: 'Spread positivity',
    ),
    HabitSuggestion(
      name: 'Network Building',
      icon: Icons.groups,
      category: 'Social',
      description: 'Connect professionally',
    ),

    // Finance (5)
    HabitSuggestion(
      name: 'Track Expenses',
      icon: Icons.receipt_long,
      category: 'Finance',
      description: 'Monitor spending',
    ),
    HabitSuggestion(
      name: 'Save Money',
      icon: Icons.savings,
      category: 'Finance',
      description: 'Daily savings goal',
    ),
    HabitSuggestion(
      name: 'Budget Review',
      icon: Icons.account_balance_wallet,
      category: 'Finance',
      description: 'Check your budget',
    ),
    HabitSuggestion(
      name: 'Investment Research',
      icon: Icons.trending_up,
      category: 'Finance',
      description: 'Learn about investments',
    ),
    HabitSuggestion(
      name: 'No Impulse Buying',
      icon: Icons.block,
      category: 'Finance',
      description: 'Think before purchasing',
    ),

    // Sleep (3)
    HabitSuggestion(
      name: 'Sleep 8 Hours',
      icon: Icons.bedtime,
      category: 'Sleep',
      description: 'Get quality rest',
    ),
    HabitSuggestion(
      name: 'Bedtime Routine',
      icon: Icons.nightlight,
      category: 'Sleep',
      description: 'Consistent sleep schedule',
    ),
    HabitSuggestion(
      name: 'No Screen Before Bed',
      icon: Icons.phone_disabled,
      category: 'Sleep',
      description: 'Better sleep quality',
    ),

    // Creative (5)
    HabitSuggestion(
      name: 'Draw or Paint',
      icon: Icons.brush,
      category: 'Creative',
      description: 'Express creativity',
    ),
    HabitSuggestion(
      name: 'Play Instrument',
      icon: Icons.piano,
      category: 'Creative',
      description: 'Practice music',
    ),
    HabitSuggestion(
      name: 'Write Daily',
      icon: Icons.edit,
      category: 'Creative',
      description: 'Creative writing',
    ),
    HabitSuggestion(
      name: 'Photography',
      icon: Icons.camera_alt,
      category: 'Creative',
      description: 'Capture moments',
    ),
    HabitSuggestion(
      name: 'Crafting',
      icon: Icons.handyman,
      category: 'Creative',
      description: 'Make something with hands',
    ),
  ];

  // 30+ Bad Habits with smart config references
  static const List<BadHabitSuggestion> badHabits = [
    // Smoking related
    BadHabitSuggestion(
      name: 'Smoking',
      icon: Icons.smoking_rooms,
      category: 'Health',
      configType: 'Smoking',
    ),
    BadHabitSuggestion(
      name: 'Vaping',
      icon: Icons.cloud,
      category: 'Health',
      configType: 'Smoking',
    ),
    
    // Alcohol related
    BadHabitSuggestion(
      name: 'Alcohol',
      icon: Icons.local_drink,
      category: 'Health',
      configType: 'Alcohol',
    ),
    BadHabitSuggestion(
      name: 'Binge Drinking',
      icon: Icons.local_bar,
      category: 'Health',
      configType: 'Alcohol',
    ),

    // Junk Food related
    BadHabitSuggestion(
      name: 'Junk Food',
      icon: Icons.fastfood,
      category: 'Health',
      configType: 'Junk Food',
    ),
    BadHabitSuggestion(
      name: 'Fast Food',
      icon: Icons.lunch_dining,
      category: 'Health',
      configType: 'Junk Food',
    ),
    BadHabitSuggestion(
      name: 'Sugar Addiction',
      icon: Icons.cookie,
      category: 'Health',
      configType: 'Junk Food',
    ),
    BadHabitSuggestion(
      name: 'Late Night Snacking',
      icon: Icons.nightlight,
      category: 'Health',
      configType: 'Junk Food',
    ),
    BadHabitSuggestion(
      name: 'Candy Consumption',
      icon: Icons.cake,
      category: 'Health',
      configType: 'Junk Food',
    ),

    // Caffeine related
    BadHabitSuggestion(
      name: 'Excessive Coffee',
      icon: Icons.local_cafe,
      category: 'Health',
      configType: 'Caffeine',
    ),
    BadHabitSuggestion(
      name: 'Energy Drinks',
      icon: Icons.battery_charging_full,
      category: 'Health',
      configType: 'Caffeine',
    ),

    // Gaming related
    BadHabitSuggestion(
      name: 'Gaming Addiction',
      icon: Icons.sports_esports,
      category: 'Digital',
      configType: 'Gaming',
    ),
    BadHabitSuggestion(
      name: 'Mobile Gaming',
      icon: Icons.videogame_asset,
      category: 'Digital',
      configType: 'Gaming',
    ),

    // Social Media related
    BadHabitSuggestion(
      name: 'Social Media Addiction',
      icon: Icons.phone_android,
      category: 'Digital',
      configType: 'Social Media',
    ),
    BadHabitSuggestion(
      name: 'Excessive Instagram',
      icon: Icons.camera,
      category: 'Digital',
      configType: 'Social Media',
    ),
    BadHabitSuggestion(
      name: 'Facebook Scrolling',
      icon: Icons.people,
      category: 'Digital',
      configType: 'Social Media',
    ),
    BadHabitSuggestion(
      name: 'TikTok Addiction',
      icon: Icons.video_library,
      category: 'Digital',
      configType: 'Social Media',
    ),

    // Gambling related
    BadHabitSuggestion(
      name: 'Gambling',
      icon: Icons.casino,
      category: 'Finance',
      configType: 'Gambling',
    ),
    BadHabitSuggestion(
      name: 'Online Betting',
      icon: Icons.sports_score,
      category: 'Finance',
      configType: 'Gambling',
    ),

    // Other bad habits (no specific config)
    BadHabitSuggestion(
      name: 'Nail Biting',
      icon: Icons.pan_tool,
      category: 'Health',
    ),
    BadHabitSuggestion(
      name: 'Hair Pulling',
      icon: Icons.face,
      category: 'Health',
    ),
    BadHabitSuggestion(
      name: 'Skin Picking',
      icon: Icons.healing,
      category: 'Health',
    ),
    BadHabitSuggestion(
      name: 'Procrastination',
      icon: Icons.timer_off,
      category: 'Productivity',
    ),
    BadHabitSuggestion(
      name: 'Oversleeping',
      icon: Icons.snooze,
      category: 'Health',
    ),
    BadHabitSuggestion(
      name: 'Excessive TV',
      icon: Icons.tv,
      category: 'Digital',
    ),
    BadHabitSuggestion(
      name: 'Netflix Binging',
      icon: Icons.movie,
      category: 'Digital',
    ),
    BadHabitSuggestion(
      name: 'Negative Self-Talk',
      icon: Icons.sentiment_dissatisfied,
      category: 'Mental Health',
    ),
    BadHabitSuggestion(
      name: 'Complaining',
      icon: Icons.report_problem,
      category: 'Mental Health',
    ),
    BadHabitSuggestion(
      name: 'Gossiping',
      icon: Icons.chat_bubble,
      category: 'Social',
    ),
    BadHabitSuggestion(
      name: 'Impulse Shopping',
      icon: Icons.shopping_cart,
      category: 'Finance',
    ),
    BadHabitSuggestion(
      name: 'Online Shopping Addiction',
      icon: Icons.shopping_bag,
      category: 'Finance',
    ),
    BadHabitSuggestion(
      name: 'Skipping Meals',
      icon: Icons.no_meals,
      category: 'Health',
    ),
  ];

  /// Suggest top 3 categories based on habit name
  static List<String> suggestCategories(String habitName) {
    final nameLower = habitName.toLowerCase();
    final suggestions = <String>[];

    // Check good habits first
    for (var habit in goodHabits) {
      if (habit.name.toLowerCase().contains(nameLower) ||
          nameLower.contains(habit.name.toLowerCase())) {
        if (!suggestions.contains(habit.category)) {
          suggestions.add(habit.category);
        }
      }
    }

    // Check bad habits
    for (var habit in badHabits) {
      if (habit.name.toLowerCase().contains(nameLower) ||
          nameLower.contains(habit.name.toLowerCase())) {
        if (!suggestions.contains(habit.category)) {
          suggestions.add(habit.category);
        }
      }
    }

    // Add common categories based on keywords
    if (nameLower.contains('exercise') ||
        nameLower.contains('run') ||
        nameLower.contains('workout') ||
        nameLower.contains('gym')) {
      if (!suggestions.contains('Fitness')) suggestions.add('Fitness');
    }
    if (nameLower.contains('meditate') ||
        nameLower.contains('journal') ||
        nameLower.contains('mindful')) {
      if (!suggestions.contains('Mindfulness')) suggestions.add('Mindfulness');
    }
    if (nameLower.contains('read') ||
        nameLower.contains('learn') ||
        nameLower.contains('study')) {
      if (!suggestions.contains('Learning')) suggestions.add('Learning');
    }
    if (nameLower.contains('sleep') || nameLower.contains('rest')) {
      if (!suggestions.contains('Sleep')) suggestions.add('Sleep');
    }
    if (nameLower.contains('money') ||
        nameLower.contains('save') ||
        nameLower.contains('budget')) {
      if (!suggestions.contains('Finance')) suggestions.add('Finance');
    }

    // Return top 3 or add default if less
    if (suggestions.isEmpty) {
      suggestions.add('Health');
    }
    
    return suggestions.take(3).toList();
  }
}
