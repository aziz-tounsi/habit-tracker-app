import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Premium icon mappings to replace emojis throughout the app
/// Uses Iconsax for a modern, premium feel
class PremiumIcons {
  // Stone icons - replacing emoji representations
  static const Map<String, IconData> stoneIcons = {
    'starter_crystal': Iconsax.flash_1, // ✨ -> Flash/sparkle
    'amethyst': Iconsax.gemini, // 💜 -> Gemini/gem
    'ruby': Iconsax.heart, // ❤️ -> Heart
    'emerald': Iconsax.tree, // 💚 -> Tree/nature
    'sapphire': Iconsax.drop, // 🔵 -> Water drop/blue
    'topaz': Iconsax.sun_1, // 🧡 -> Sun/warm
    'diamond': Iconsax.medal_star, // 💎 -> Medal/diamond
    'obsidian': Iconsax.shield_tick, // 🖤 -> Shield/protection
    'opal': Iconsax.crown, // 🌈 -> Crown/rainbow
  };

  // Category icons - replacing emoji representations
  static const Map<String, IconData> categoryIcons = {
    'health': Iconsax.heart_circle, // ❤️ -> Heart
    'fitness': Iconsax.chart, // 💪 -> Strong/chart
    'learning': Iconsax.book_1, // 📚 -> Book
    'productivity': Iconsax.flash_circle, // ⚡ -> Lightning
    'mindfulness': Iconsax.candle, // 🧘 -> Meditation/candle
    'social': Iconsax.people, // 👥 -> People
    'finance': Iconsax.dollar_circle, // 💰 -> Money
    'creativity': Iconsax.brush_1, // 🎨 -> Art/brush
  };

  // Challenge icons - replacing emoji representations
  static const Map<String, IconData> challengeIcons = {
    'streak': Iconsax.flash_1, // 🔥 -> Fire/flame
    'strength': Iconsax.chart, // 💪 -> Strength/chart
    'learning': Iconsax.book_1, // 📚 -> Book
    'trophy': Iconsax.cup, // 🏆 -> Trophy/cup
    'star': Iconsax.star_1, // ⭐ -> Star
    'sunrise': Iconsax.sun_1, // 🌅 -> Sun/sunrise
  };

  // Achievement icons - replacing emoji representations  
  static const Map<String, IconData> achievementIcons = {
    'fire': Iconsax.flash_1, // 🔥 -> Fire/flame
    'star': Iconsax.star_1, // ⭐ -> Star
    'diamond': Iconsax.diamonds, // 💎 -> Diamond/medal
    'medal': Iconsax.award, // 🏅 -> Medal/award
    'crown': Iconsax.crown_1, // 👑 -> Crown
    'rocket': Iconsax.send_2, // 🚀 -> Rocket
    'target': Iconsax.arrow, // 🎯 -> Target
    'trophy': Iconsax.cup, // 🏆 -> Trophy
  };

  // UI element icons - replacing various emoji uses
  static const Map<String, IconData> uiIcons = {
    'sparkles': Iconsax.flash_1, // ✨ -> Sparkle/flash
    'star': Iconsax.star_1, // ⭐ -> Star
    'fire': Iconsax.flash_1, // 🔥 -> Fire
    'muscle': Iconsax.chart, // 💪 -> Strength
    'target': Iconsax.arrow, // 🎯 -> Target
    'starCircle': Iconsax.star_1, // 🌟 -> Star in circle
    'magic': Iconsax.magic_star, // 💫 -> Magic/sparkle
    'rainbow': Iconsax.crown, // 🌈 -> Crown (premium)
    'palette': Iconsax.brush_1, // 🎨 -> Brush/palette
    'music': Iconsax.music_circle, // 🎵 -> Music
    'book': Iconsax.book_1, // 📚 -> Book
    'bulb': Iconsax.lamp_1, // 💡 -> Light bulb
    'plant': Iconsax.tree, // 🌿 -> Tree/plant
    'butterfly': Iconsax.magicpen, // 🦋 -> Magic/transformation
    'rocket': Iconsax.send_2, // 🚀 -> Rocket
    'heart': Iconsax.heart, // ❤️ -> Heart
    'trophy': Iconsax.cup, // 🏆 -> Trophy
    'medal': Iconsax.award, // 🏅 -> Medal
  };

  // Completion message icons
  static const List<IconData> completionIcons = [
    Iconsax.cup, // Party/celebration
    Iconsax.chart, // Strength
    Iconsax.star_1, // Star
    Iconsax.flash_1, // Fire
    Iconsax.flash_1, // Sparkle
    Iconsax.crown_1, // Crown/star
    Iconsax.diamonds, // Diamond
    Iconsax.award, // Trophy
    Iconsax.send_2, // Rocket
    Iconsax.heart, // Applause/heart
  ];

  // Avatar icons (non-emoji alternatives)
  static const List<IconData> avatarIcons = [
    Iconsax.user_octagon,
    Iconsax.profile_circle,
    Iconsax.user_square,
    Iconsax.personalcard,
    Iconsax.user_tag,
    Iconsax.user_cirlce_add,
    Iconsax.profile_2user,
    Iconsax.security_user,
  ];

  // Helper method to get stone icon
  static IconData getStoneIcon(String stoneId) {
    return stoneIcons[stoneId] ?? Iconsax.flash_1;
  }

  // Helper method to get category icon
  static IconData getCategoryIcon(String categoryId) {
    return categoryIcons[categoryId] ?? Iconsax.category;
  }

  // Helper method to get challenge icon
  static IconData getChallengeIcon(String challengeType) {
    return challengeIcons[challengeType] ?? Iconsax.cup;
  }

  // Helper method to get achievement icon
  static IconData getAchievementIcon(String achievementType) {
    return achievementIcons[achievementType] ?? Iconsax.award;
  }

  // Helper method to get UI icon
  static IconData getUIIcon(String iconKey) {
    return uiIcons[iconKey] ?? Iconsax.flash_1;
  }

  // Get icon by name/type with fallback
  static IconData getIcon(String type, String key) {
    switch (type) {
      case 'stone':
        return getStoneIcon(key);
      case 'category':
        return getCategoryIcon(key);
      case 'challenge':
        return getChallengeIcon(key);
      case 'achievement':
        return getAchievementIcon(key);
      case 'ui':
        return getUIIcon(key);
      default:
        return Iconsax.flash_1;
    }
  }
}
