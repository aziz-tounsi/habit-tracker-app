import 'package:flutter/material.dart';

enum StoneRarity {
  common,
  rare,
  epic,
  legendary,
}

class StoneModel {
  final String id;
  final String name;
  final String description;
  final StoneRarity rarity;
  final Color primaryColor;
  final Color secondaryColor;
  final Color glowColor;
  final int xpReward;

  const StoneModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.primaryColor,
    required this.secondaryColor,
    required this.glowColor,
    required this.xpReward,
  });

  static const List<StoneModel> allStones = [
    StoneModel(
      id: 'amethyst',
      name: 'Amethyst',
      description: 'The stone of peace and calm',
      rarity: StoneRarity.common,
      primaryColor: Color(0xFF9B59B6),
      secondaryColor: Color(0xFF8E44AD),
      glowColor: Color(0xFFD2B4DE),
      xpReward: 50,
    ),
    StoneModel(
      id: 'ruby',
      name: 'Ruby',
      description: 'The stone of passion and energy',
      rarity: StoneRarity.rare,
      primaryColor: Color(0xFFE74C3C),
      secondaryColor: Color(0xFFC0392B),
      glowColor: Color(0xFFF1948A),
      xpReward: 100,
    ),
    StoneModel(
      id: 'sapphire',
      name: 'Sapphire',
      description: 'The stone of focus and wisdom',
      rarity: StoneRarity.rare,
      primaryColor: Color(0xFF3498DB),
      secondaryColor: Color(0xFF2980B9),
      glowColor: Color(0xFF85C1E9),
      xpReward: 100,
    ),
    StoneModel(
      id: 'emerald',
      name: 'Emerald',
      description: 'The stone of growth and renewal',
      rarity: StoneRarity.epic,
      primaryColor: Color(0xFF2ECC71),
      secondaryColor: Color(0xFF27AE60),
      glowColor: Color(0xFFABEBC6),
      xpReward: 200,
    ),
    StoneModel(
      id: 'diamond',
      name: 'Diamond',
      description: 'The ultimate stone of perfection',
      rarity: StoneRarity.legendary,
      primaryColor: Color(0xFFECF0F1),
      secondaryColor: Color(0xFFBDC3C7),
      glowColor: Color(0xFFFFFFFF),
      xpReward: 500,
    ),
    StoneModel(
      id: 'opal',
      name: 'Opal',
      description: 'The mystical shifting stone',
      rarity: StoneRarity.legendary,
      primaryColor: Color(0xFFE8DAEF),
      secondaryColor: Color(0xFFD2B4DE),
      glowColor: Color(0xFFF5EEF8),
      xpReward: 500,
    ),
    StoneModel(
      id: 'citrine',
      name: 'Citrine',
      description: 'The stone of bright energy',
      rarity: StoneRarity.epic,
      primaryColor: Color(0xFFF39C12),
      secondaryColor: Color(0xFFE67E22),
      glowColor: Color(0xFFF9E79F),
      xpReward: 200,
    ),
    StoneModel(
      id: 'rose_quartz',
      name: 'Rose Quartz',
      description: 'The stone of love and compassion',
      rarity: StoneRarity.common,
      primaryColor: Color(0xFFF5B7B1),
      secondaryColor: Color(0xFFF1948A),
      glowColor: Color(0xFFFCE4EC),
      xpReward: 50,
    ),
  ];

  static StoneModel? getById(String id) {
    for (final stone in allStones) {
      if (stone.id == id) return stone;
    }
    return null;
  }
}
