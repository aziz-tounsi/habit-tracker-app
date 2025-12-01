import 'package:flutter/material.dart';

enum HabitCategoryType {
  health,
  fitness,
  learning,
  productivity,
  mindfulness,
  social,
  finance,
  creativity,
}

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String emoji;
  final Color color;
  final HabitCategoryType type;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.emoji,
    required this.color,
    required this.type,
  });

  static const List<CategoryModel> allCategories = [
    CategoryModel(
      id: 'health',
      name: 'Health',
      description: 'Physical and mental well-being',
      icon: Icons.favorite,
      emoji: '❤️',
      color: Color(0xFFFF6B6B),
      type: HabitCategoryType.health,
    ),
    CategoryModel(
      id: 'fitness',
      name: 'Fitness',
      description: 'Exercise and physical activity',
      icon: Icons.fitness_center,
      emoji: '💪',
      color: Color(0xFFFF9A8B),
      type: HabitCategoryType.fitness,
    ),
    CategoryModel(
      id: 'learning',
      name: 'Learning',
      description: 'Education and skill development',
      icon: Icons.school,
      emoji: '📚',
      color: Color(0xFF667EEA),
      type: HabitCategoryType.learning,
    ),
    CategoryModel(
      id: 'productivity',
      name: 'Productivity',
      description: 'Work and task management',
      icon: Icons.work,
      emoji: '⚡',
      color: Color(0xFFFFC857),
      type: HabitCategoryType.productivity,
    ),
    CategoryModel(
      id: 'mindfulness',
      name: 'Mindfulness',
      description: 'Meditation and mental clarity',
      icon: Icons.self_improvement,
      emoji: '🧘',
      color: Color(0xFF4FD1C5),
      type: HabitCategoryType.mindfulness,
    ),
    CategoryModel(
      id: 'social',
      name: 'Social',
      description: 'Relationships and connections',
      icon: Icons.people,
      emoji: '👥',
      color: Color(0xFFE879A9),
      type: HabitCategoryType.social,
    ),
    CategoryModel(
      id: 'finance',
      name: 'Finance',
      description: 'Money management and savings',
      icon: Icons.savings,
      emoji: '💰',
      color: Color(0xFF00E676),
      type: HabitCategoryType.finance,
    ),
    CategoryModel(
      id: 'creativity',
      name: 'Creativity',
      description: 'Art, music, and creative expression',
      icon: Icons.brush,
      emoji: '🎨',
      color: Color(0xFF7B68EE),
      type: HabitCategoryType.creativity,
    ),
  ];

  static CategoryModel? getById(String id) {
    return allCategories.cast<CategoryModel?>().firstWhere(
      (c) => c?.id == id,
      orElse: () => null,
    );
  }

  static CategoryModel? getByType(HabitCategoryType type) {
    return allCategories.cast<CategoryModel?>().firstWhere(
      (c) => c?.type == type,
      orElse: () => null,
    );
  }
}
