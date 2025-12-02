import 'package:flutter/material.dart';
import 'dart:ui';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final containerChild = Container(
      width: width,
      height: height,
      padding: padding,
      child: child,
    );
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? 
                (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
            width: 1.0,
          ),
          boxShadow: [
            // Subtle shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: blur,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            // Optional glow effect
            if (showGlow && glowColor != null)
              BoxShadow(
                color: glowColor!.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: useBackdropFilter
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.white.withOpacity(opacity * 0.8)
                          : Colors.black.withOpacity(opacity * 0.5),
                    ),
                    child: containerChild,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withOpacity(opacity * 0.8)
                        : Colors.black.withOpacity(opacity * 0.5),
                  ),
                  child: containerChild,
                ),
        ),
      ),
    );
  }
}
