import 'package:flutter/material.dart';

enum ChallengeType {
  sevenDay,
  thirtyDay,
  custom,
}

enum ChallengeStatus {
  notStarted,
  inProgress,
  completed,
  failed,
}

class ChallengeModel {
  final String id;
  final String name;
  final String description;
  final ChallengeType type;
  final int targetDays;
  final int targetCompletions;
  final String iconEmoji;
  final List<Color> gradientColors;
  final int xpReward;
  final DateTime? startDate;
  final DateTime? endDate;
  final ChallengeStatus status;
  final int currentProgress;

  const ChallengeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetDays,
    required this.targetCompletions,
    required this.iconEmoji,
    required this.gradientColors,
    required this.xpReward,
    this.startDate,
    this.endDate,
    this.status = ChallengeStatus.notStarted,
    this.currentProgress = 0,
  });

  ChallengeModel copyWith({
    String? id,
    String? name,
    String? description,
    ChallengeType? type,
    int? targetDays,
    int? targetCompletions,
    String? iconEmoji,
    List<Color>? gradientColors,
    int? xpReward,
    DateTime? startDate,
    DateTime? endDate,
    ChallengeStatus? status,
    int? currentProgress,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      targetDays: targetDays ?? this.targetDays,
      targetCompletions: targetCompletions ?? this.targetCompletions,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      gradientColors: gradientColors ?? this.gradientColors,
      xpReward: xpReward ?? this.xpReward,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  double get progressPercentage {
    if (targetCompletions == 0) return 0;
    return (currentProgress / targetCompletions).clamp(0.0, 1.0);
  }

  bool get isActive {
    return status == ChallengeStatus.inProgress;
  }

  bool get isCompleted {
    return status == ChallengeStatus.completed;
  }

  static const List<ChallengeModel> predefinedChallenges = [
    ChallengeModel(
      id: '7_day_streak',
      name: '7-Day Streak Challenge',
      description: 'Complete all your habits for 7 days straight',
      type: ChallengeType.sevenDay,
      targetDays: 7,
      targetCompletions: 7,
      iconEmoji: '🔥',
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFFF4444)],
      xpReward: 100,
    ),
    ChallengeModel(
      id: '30_day_fitness',
      name: '30-Day Fitness Challenge',
      description: 'Complete fitness habits for 30 days',
      type: ChallengeType.thirtyDay,
      targetDays: 30,
      targetCompletions: 30,
      iconEmoji: '💪',
      gradientColors: [Color(0xFFFF9A8B), Color(0xFFFF6B6B)],
      xpReward: 300,
    ),
    ChallengeModel(
      id: '30_day_learning',
      name: '30-Day Learning Challenge',
      description: 'Study or learn something new every day for 30 days',
      type: ChallengeType.thirtyDay,
      targetDays: 30,
      targetCompletions: 30,
      iconEmoji: '📚',
      gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      xpReward: 300,
    ),
    ChallengeModel(
      id: '100_completions',
      name: '100 Completions Challenge',
      description: 'Complete 100 total habit check-ins',
      type: ChallengeType.custom,
      targetDays: 0,
      targetCompletions: 100,
      iconEmoji: '🏆',
      gradientColors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
      xpReward: 500,
    ),
    ChallengeModel(
      id: 'perfect_week',
      name: 'Perfect Week Challenge',
      description: 'Complete all habits every day this week',
      type: ChallengeType.sevenDay,
      targetDays: 7,
      targetCompletions: 7,
      iconEmoji: '⭐',
      gradientColors: [Color(0xFFFFC837), Color(0xFFFF8008)],
      xpReward: 150,
    ),
    ChallengeModel(
      id: 'morning_routine',
      name: 'Morning Routine Challenge',
      description: 'Complete morning habits for 21 days',
      type: ChallengeType.custom,
      targetDays: 21,
      targetCompletions: 21,
      iconEmoji: '🌅',
      gradientColors: [Color(0xFFF7971E), Color(0xFFFFD200)],
      xpReward: 200,
    ),
  ];

  static ChallengeModel? getById(String id) {
    try {
      return predefinedChallenges.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
