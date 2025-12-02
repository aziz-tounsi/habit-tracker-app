import 'package:flutter/material.dart';

/// Dynamic stone theme system
/// Each stone type has its own color palette that changes the app's appearance
class StoneTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final List<Color> gradientColors;
  final Color glowColor;

  const StoneTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.gradientColors,
    required this.glowColor,
  });

  /// Generate gradient from theme colors
  LinearGradient get primaryGradient {
    return LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Generate glow effect color
  Color get glowWithOpacity => glowColor.withOpacity(0.4);
}

/// Stone theme definitions for each stone type
class StoneThemes {
  // Amethyst - Deep Purple Theme
  static const StoneTheme amethyst = StoneTheme(
    id: 'amethyst',
    name: 'Amethyst',
    primaryColor: Color(0xFF7C3AED), // Deep purple
    secondaryColor: Color(0xFF9F7AEA), // Violet
    accentColor: Color(0xFFB794F4), // Light purple
    backgroundColor: Color(0xFF1A0B2E), // Very dark purple
    surfaceColor: Color(0xFF2D1B4E), // Dark purple surface
    gradientColors: [
      Color(0xFF7C3AED),
      Color(0xFF9F7AEA),
      Color(0xFFB794F4),
    ],
    glowColor: Color(0xFF7C3AED),
  );

  // Ruby - Passionate Red Theme
  static const StoneTheme ruby = StoneTheme(
    id: 'ruby',
    name: 'Ruby',
    primaryColor: Color(0xFFDC2626), // Red
    secondaryColor: Color(0xFFEF4444), // Light red
    accentColor: Color(0xFFF87171), // Crimson
    backgroundColor: Color(0xFF1F0A0A), // Very dark red
    surfaceColor: Color(0xFF3F1414), // Dark red surface
    gradientColors: [
      Color(0xFFDC2626),
      Color(0xFFEF4444),
      Color(0xFFF87171),
    ],
    glowColor: Color(0xFFDC2626),
  );

  // Sapphire - Tranquil Blue Theme
  static const StoneTheme sapphire = StoneTheme(
    id: 'sapphire',
    name: 'Sapphire',
    primaryColor: Color(0xFF1E40AF), // Navy
    secondaryColor: Color(0xFF3B82F6), // Blue
    accentColor: Color(0xFF60A5FA), // Light blue
    backgroundColor: Color(0xFF0A1628), // Very dark blue
    surfaceColor: Color(0xFF142642), // Dark blue surface
    gradientColors: [
      Color(0xFF1E40AF),
      Color(0xFF3B82F6),
      Color(0xFF60A5FA),
    ],
    glowColor: Color(0xFF3B82F6),
  );

  // Emerald - Vibrant Green Theme
  static const StoneTheme emerald = StoneTheme(
    id: 'emerald',
    name: 'Emerald',
    primaryColor: Color(0xFF059669), // Green
    secondaryColor: Color(0xFF10B981), // Emerald
    accentColor: Color(0xFF34D399), // Teal
    backgroundColor: Color(0xFF0A2318), // Very dark green
    surfaceColor: Color(0xFF143828), // Dark green surface
    gradientColors: [
      Color(0xFF059669),
      Color(0xFF10B981),
      Color(0xFF34D399),
    ],
    glowColor: Color(0xFF10B981),
  );

  // Diamond - Brilliant Crystal Theme
  static const StoneTheme diamond = StoneTheme(
    id: 'diamond',
    name: 'Diamond',
    primaryColor: Color(0xFFE0F2FE), // Ice blue
    secondaryColor: Color(0xFFFFFFFF), // White
    accentColor: Color(0xFFBAE6FD), // Crystal
    backgroundColor: Color(0xFF0F1419), // Very dark gray
    surfaceColor: Color(0xFF1F2937), // Dark gray surface
    gradientColors: [
      Color(0xFFE0F2FE),
      Color(0xFFFFFFFF),
      Color(0xFFBAE6FD),
    ],
    glowColor: Color(0xFFE0F2FE),
  );

  // Opal - Rainbow Multicolor Theme
  static const StoneTheme opal = StoneTheme(
    id: 'opal',
    name: 'Opal',
    primaryColor: Color(0xFFEC4899), // Pink
    secondaryColor: Color(0xFF8B5CF6), // Purple
    accentColor: Color(0xFF06B6D4), // Cyan
    backgroundColor: Color(0xFF0F0A1F), // Very dark purple-blue
    surfaceColor: Color(0xFF1F1429), // Dark purple surface
    gradientColors: [
      Color(0xFFEC4899), // Pink
      Color(0xFF8B5CF6), // Purple
      Color(0xFF06B6D4), // Cyan
      Color(0xFF10B981), // Green
      Color(0xFFF59E0B), // Amber
    ],
    glowColor: Color(0xFF8B5CF6),
  );

  // Citrine - Golden Amber Theme
  static const StoneTheme citrine = StoneTheme(
    id: 'citrine',
    name: 'Citrine',
    primaryColor: Color(0xFFEA580C), // Orange
    secondaryColor: Color(0xFFF59E0B), // Amber
    accentColor: Color(0xFFFBBF24), // Gold
    backgroundColor: Color(0xFF1F1508), // Very dark amber
    surfaceColor: Color(0xFF3D2A10), // Dark amber surface
    gradientColors: [
      Color(0xFFEA580C),
      Color(0xFFF59E0B),
      Color(0xFFFBBF24),
    ],
    glowColor: Color(0xFFF59E0B),
  );

  // Rose Quartz - Soft Pink Theme
  static const StoneTheme roseQuartz = StoneTheme(
    id: 'rose_quartz',
    name: 'Rose Quartz',
    primaryColor: Color(0xFFF472B6), // Pink
    secondaryColor: Color(0xFFFBBF24), // Gold
    accentColor: Color(0xFFFDE68A), // Light gold
    backgroundColor: Color(0xFF1F0A14), // Very dark pink
    surfaceColor: Color(0xFF3D1428), // Dark pink surface
    gradientColors: [
      Color(0xFFF472B6),
      Color(0xFFFBBF24),
      Color(0xFFFDE68A),
    ],
    glowColor: Color(0xFFF472B6),
  );

  // Starter Crystal - Default Purple/Pink Theme
  static const StoneTheme starterCrystal = StoneTheme(
    id: 'starter_crystal',
    name: 'Starter Crystal',
    primaryColor: Color(0xFF7C3AED), // Primary purple
    secondaryColor: Color(0xFFEC4899), // Secondary pink
    accentColor: Color(0xFF06B6D4), // Accent cyan
    backgroundColor: Color(0xFF0F0A1F), // Very dark purple
    surfaceColor: Color(0xFF1F1429), // Dark purple surface
    gradientColors: [
      Color(0xFF7C3AED),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
    ],
    glowColor: Color(0xFF7C3AED),
  );

  // Obsidian - Dark Resilience Theme
  static const StoneTheme obsidian = StoneTheme(
    id: 'obsidian',
    name: 'Obsidian',
    primaryColor: Color(0xFF18181B), // Black
    secondaryColor: Color(0xFF27272A), // Dark gray
    accentColor: Color(0xFF6B21A8), // Dark purple
    backgroundColor: Color(0xFF000000), // Pure black
    surfaceColor: Color(0xFF18181B), // Very dark surface
    gradientColors: [
      Color(0xFF18181B),
      Color(0xFF27272A),
      Color(0xFF6B21A8),
    ],
    glowColor: Color(0xFF6B21A8),
  );

  // Topaz (alias for Citrine for backward compatibility)
  static const StoneTheme topaz = citrine;

  /// Map of all stone themes by ID
  static const Map<String, StoneTheme> allThemes = {
    'starter_crystal': starterCrystal,
    'amethyst': amethyst,
    'ruby': ruby,
    'sapphire': sapphire,
    'emerald': emerald,
    'diamond': diamond,
    'opal': opal,
    'citrine': citrine,
    'topaz': citrine, // Alias for citrine
    'rose_quartz': roseQuartz,
    'obsidian': obsidian,
  };

  /// Get theme by stone ID
  static StoneTheme getTheme(String stoneId) {
    return allThemes[stoneId] ?? starterCrystal;
  }

  /// Get all unique themes as a list (excluding aliases)
  static List<StoneTheme> getAllThemes() {
    return [
      starterCrystal,
      amethyst,
      ruby,
      sapphire,
      emerald,
      diamond,
      opal,
      citrine,
      roseQuartz,
      obsidian,
    ];
  }
}

/// Extension to apply stone theme to ThemeData
extension StoneThemeExtension on StoneTheme {
  /// Convert stone theme to Material ThemeData
  ThemeData toThemeData({Brightness brightness = Brightness.dark}) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
      ).copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
      ),
    );
  }
}
