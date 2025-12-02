import 'package:flutter/material.dart';
import 'smart_blur_container.dart';

/// Glass container with blur effect
/// Now uses SmartBlurContainer internally for enhanced blur effects
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final double blur;
  final double opacity;
  final VoidCallback? onTap;
  final bool useBackdropFilter;
  final bool showGlow;
  final Color? glowColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.borderColor,
    this.blur = 10,
    this.opacity = 0.1,
    this.onTap,
    this.useBackdropFilter = true,
    this.showGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use SmartBlurContainer with shader gloss disabled for backward compatibility
    return SmartBlurContainer(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      borderColor: borderColor,
      baseBlur: blur,
      baseOpacity: opacity,
      onTap: onTap,
      enableBackdropFilter: useBackdropFilter,
      enableShaderGloss: false, // Disabled for backward compatibility
      showGlow: showGlow,
      glowColor: glowColor,
      motionFactor: 0.0, // Static, no motion
      child: child,
    );
  }
}
