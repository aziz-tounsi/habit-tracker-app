import 'package:flutter/material.dart';

/// Configuration for blur effects across the app
class BlurTheme {
  // Base blur values
  static const double minBlur = 5.0;
  static const double maxBlur = 25.0;
  static const double defaultBlur = 10.0;
  
  // Opacity values
  static const double minOpacity = 0.05;
  static const double maxOpacity = 0.2;
  static const double defaultOpacity = 0.1;
  
  // Motion-aware blur ranges
  static const double motionBlurMin = 8.0;
  static const double motionBlurMax = 15.0;
  
  // Animation durations
  static const Duration fastBlurTransition = Duration(milliseconds: 200);
  static const Duration normalBlurTransition = Duration(milliseconds: 300);
  static const Duration slowBlurTransition = Duration(milliseconds: 500);
  
  // Vibrancy colors for light/dark mode
  static Color getVibrancyColor(BuildContext context, {double opacity = 0.1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? Colors.white.withOpacity(opacity * 0.8)
        : Colors.black.withOpacity(opacity * 0.5);
  }
  
  // Border colors for glass effect
  static Color getBorderColor(BuildContext context, {double opacity = 0.1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? Colors.white.withOpacity(opacity)
        : Colors.black.withOpacity(opacity * 0.5);
  }
  
  // Gradient overlay for depth
  static LinearGradient getDepthGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(isDark ? 0.05 : 0.15),
        Colors.white.withOpacity(0.0),
        Colors.black.withOpacity(isDark ? 0.1 : 0.05),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
  
  // Calculate blur sigma based on motion factor (0.0 to 1.0)
  static double calculateBlurSigma(double motionFactor) {
    return motionBlurMin + (motionBlurMax - motionBlurMin) * motionFactor;
  }
  
  // Calculate opacity based on motion factor (0.0 to 1.0)
  static double calculateOpacity(double motionFactor) {
    return minOpacity + (maxOpacity - minOpacity) * (1.0 - motionFactor * 0.5);
  }
}
