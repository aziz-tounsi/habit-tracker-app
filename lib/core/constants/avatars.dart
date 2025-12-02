import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

/// Premium avatar system replacing emoji avatars
/// Uses DiceBear API for unique avatars and gradient geometric patterns
class AvatarSystem {
  // DiceBear API configuration
  static const String diceBearApiVersion = '7.x';
  static const String diceBearBaseUrl = 'https://api.dicebear.com/$diceBearApiVersion';
  
  // Available DiceBear styles (premium, non-emoji)
  static const List<String> diceBearStyles = [
    'adventurer',
    'adventurer-neutral',
    'avataaars',
    'avataaars-neutral',
    'bottts',
    'bottts-neutral',
    'fun-emoji', // Abstract emoji style
    'icons',
    'identicon',
    'initials',
    'lorelei',
    'lorelei-neutral',
    'micah',
    'miniavs',
    'notionists',
    'notionists-neutral',
    'open-peeps',
    'personas',
    'pixel-art',
    'pixel-art-neutral',
    'shapes',
    'thumbs',
  ];

  /// Generate DiceBear avatar URL
  /// [seed] - Unique identifier for consistent avatar generation
  /// [style] - Avatar style from diceBearStyles
  /// [size] - Size in pixels (default 200)
  static String getDiceBearUrl({
    required String seed,
    String style = 'adventurer',
    int size = 200,
  }) {
    return '$diceBearBaseUrl/$style/svg?seed=$seed&size=$size';
  }

  // Predefined gradient combinations for geometric avatars
  static const List<List<Color>> gradientPresets = [
    // Purple dream
    [Color(0xFF7C3AED), Color(0xFFEC4899)],
    // Ocean blue
    [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    // Sunset orange
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    // Forest green
    [Color(0xFF10B981), Color(0xFF059669)],
    // Royal purple
    [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    // Rose gold
    [Color(0xFFF472B6), Color(0xFFFBBF24)],
    // Teal mint
    [Color(0xFF14B8A6), Color(0xFF22D3EE)],
    // Crimson red
    [Color(0xFFDC2626), Color(0xFFF87171)],
    // Indigo night
    [Color(0xFF4F46E5), Color(0xFF6366F1)],
    // Amber glow
    [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    // Emerald shine
    [Color(0xFF34D399), Color(0xFF10B981)],
    // Pink passion
    [Color(0xFFEC4899), Color(0xFFF472B6)],
    // Sky blue
    [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    // Lime fresh
    [Color(0xFF84CC16), Color(0xFF65A30D)],
    // Violet dream
    [Color(0xFF9F7AEA), Color(0xFF7C3AED)],
  ];

  // Geometric patterns for avatar generation
  static const List<IconData> geometricIcons = [
    Iconsax.user_octagon,
    Iconsax.profile_circle,
    Iconsax.user_square,
    Iconsax.personalcard,
    Iconsax.user_tag,
    Iconsax.security_user,
    Iconsax.medal_star,
    Iconsax.crown_1,
    Iconsax.flash_1,
    Iconsax.heart_circle,
    Iconsax.star_1,
    Iconsax.cup,
  ];

  /// Get a gradient preset by index
  static List<Color> getGradient(int index) {
    return gradientPresets[index % gradientPresets.length];
  }

  /// Generate a unique gradient based on user seed/name
  static List<Color> generateGradientFromSeed(String seed) {
    final hash = seed.hashCode.abs();
    final index = hash % gradientPresets.length;
    return gradientPresets[index];
  }

  /// Get geometric icon by index
  static IconData getGeometricIcon(int index) {
    return geometricIcons[index % geometricIcons.length];
  }

  /// Generate geometric icon from seed
  static IconData generateIconFromSeed(String seed) {
    final hash = seed.hashCode.abs();
    final index = hash % geometricIcons.length;
    return geometricIcons[index];
  }

  /// Avatar type enum
  static const String typeGradient = 'gradient';
  static const String typeDiceBear = 'dicebear';
  static const String typeIcon = 'icon';
}

/// Gradient geometric avatar builder widget
class GradientAvatarBuilder extends StatelessWidget {
  final String seed;
  final double size;
  final List<Color>? gradientColors;
  final IconData? icon;
  final double iconSizeRatio;

  const GradientAvatarBuilder({
    super.key,
    required this.seed,
    this.size = 100,
    this.gradientColors,
    this.icon,
    this.iconSizeRatio = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = gradientColors ?? AvatarSystem.generateGradientFromSeed(seed);
    final avatarIcon = icon ?? AvatarSystem.generateIconFromSeed(seed);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            blurRadius: size * 0.24,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          avatarIcon,
          size: size * iconSizeRatio,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Avatar selection data model
class AvatarOption {
  final String id;
  final String type; // gradient, dicebear, icon
  final String? diceBearStyle;
  final List<Color>? gradientColors;
  final IconData? icon;
  final String displayName;

  const AvatarOption({
    required this.id,
    required this.type,
    this.diceBearStyle,
    this.gradientColors,
    this.icon,
    required this.displayName,
  });

  /// Factory for gradient avatar
  factory AvatarOption.gradient({
    required String id,
    required List<Color> colors,
    required IconData icon,
    required String name,
  }) {
    return AvatarOption(
      id: id,
      type: AvatarSystem.typeGradient,
      gradientColors: colors,
      icon: icon,
      displayName: name,
    );
  }

  /// Factory for DiceBear avatar
  factory AvatarOption.diceBear({
    required String id,
    required String style,
    required String name,
  }) {
    return AvatarOption(
      id: id,
      type: AvatarSystem.typeDiceBear,
      diceBearStyle: style,
      displayName: name,
    );
  }

  /// Factory for icon avatar
  factory AvatarOption.icon({
    required String id,
    required IconData icon,
    required List<Color> colors,
    required String name,
  }) {
    return AvatarOption(
      id: id,
      type: AvatarSystem.typeIcon,
      icon: icon,
      gradientColors: colors,
      displayName: name,
    );
  }
}

/// Predefined premium avatar options
class PremiumAvatars {
  static final List<AvatarOption> options = [
    // Gradient geometric avatars
    AvatarOption.gradient(
      id: 'gradient_purple_star',
      colors: AvatarSystem.gradientPresets[0],
      icon: Iconsax.star_1,
      name: 'Purple Star',
    ),
    AvatarOption.gradient(
      id: 'gradient_ocean_crown',
      colors: AvatarSystem.gradientPresets[1],
      icon: Iconsax.crown_1,
      name: 'Ocean Crown',
    ),
    AvatarOption.gradient(
      id: 'gradient_sunset_fire',
      colors: AvatarSystem.gradientPresets[2],
      icon: Iconsax.flame,
      name: 'Sunset Fire',
    ),
    AvatarOption.gradient(
      id: 'gradient_forest_leaf',
      colors: AvatarSystem.gradientPresets[3],
      icon: Iconsax.tree,
      name: 'Forest Leaf',
    ),
    AvatarOption.gradient(
      id: 'gradient_royal_medal',
      colors: AvatarSystem.gradientPresets[4],
      icon: Iconsax.medal_star,
      name: 'Royal Medal',
    ),
    AvatarOption.gradient(
      id: 'gradient_rose_heart',
      colors: AvatarSystem.gradientPresets[5],
      icon: Iconsax.heart,
      name: 'Rose Heart',
    ),
    AvatarOption.gradient(
      id: 'gradient_teal_flash',
      colors: AvatarSystem.gradientPresets[6],
      icon: Iconsax.flash_1,
      name: 'Teal Flash',
    ),
    AvatarOption.gradient(
      id: 'gradient_crimson_cup',
      colors: AvatarSystem.gradientPresets[7],
      icon: Iconsax.cup,
      name: 'Crimson Cup',
    ),
    
    // Icon-based avatars with gradients
    AvatarOption.icon(
      id: 'icon_user_purple',
      icon: Iconsax.user_octagon,
      colors: AvatarSystem.gradientPresets[0],
      name: 'Purple User',
    ),
    AvatarOption.icon(
      id: 'icon_profile_ocean',
      icon: Iconsax.profile_circle,
      colors: AvatarSystem.gradientPresets[1],
      name: 'Ocean Profile',
    ),
    AvatarOption.icon(
      id: 'icon_square_sunset',
      icon: Iconsax.user_square,
      colors: AvatarSystem.gradientPresets[2],
      name: 'Sunset Square',
    ),
    AvatarOption.icon(
      id: 'icon_shield_forest',
      icon: Iconsax.security_user,
      colors: AvatarSystem.gradientPresets[3],
      name: 'Forest Shield',
    ),
  ];

  /// Get avatar option by ID
  static AvatarOption? getById(String id) {
    return options.cast<AvatarOption?>().firstWhere(
      (opt) => opt?.id == id,
      orElse: () => null,
    );
  }

  /// Generate random avatar from seed
  static AvatarOption generateFromSeed(String seed) {
    final hash = seed.hashCode.abs();
    final index = hash % options.length;
    return options[index];
  }
}
