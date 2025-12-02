import 'dart:ui';
import 'package:flutter/material.dart';
import 'blur_theme.dart';
import 'shader_gloss_overlay.dart';

/// iOS-inspired multi-layer blur container with motion-aware effects
class SmartBlurContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final double baseBlur;
  final double baseOpacity;
  final VoidCallback? onTap;
  final bool enableBackdropFilter;
  final bool enableShaderGloss;
  final bool showGlow;
  final Color? glowColor;
  final double motionFactor; // 0.0 to 1.0, controls motion-aware blur
  final bool enableVibrancy;

  const SmartBlurContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.borderColor,
    this.baseBlur = 10,
    this.baseOpacity = 0.1,
    this.onTap,
    this.enableBackdropFilter = true,
    this.enableShaderGloss = true,
    this.showGlow = false,
    this.glowColor,
    this.motionFactor = 0.0,
    this.enableVibrancy = true,
  });

  @override
  State<SmartBlurContainer> createState() => _SmartBlurContainerState();
}

class _SmartBlurContainerState extends State<SmartBlurContainer>
    with SingleTickerProviderStateMixin {
  double _hoverFactor = 0.0;
  late AnimationController _interactionController;

  @override
  void initState() {
    super.initState();
    _interactionController = AnimationController(
      vsync: this,
      duration: BlurTheme.normalBlurTransition,
    );
  }

  @override
  void dispose() {
    _interactionController.dispose();
    super.dispose();
  }

  void _onHoverEnter(PointerEvent details) {
    _interactionController.forward();
  }

  void _onHoverExit(PointerEvent details) {
    _interactionController.reverse();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _hoverFactor = 1.0;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _hoverFactor = 0.0;
    });
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() {
      _hoverFactor = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _interactionController,
      builder: (context, child) {
        // Combine motion factor from scroll and interaction
        final combinedMotion = (widget.motionFactor + _interactionController.value * 0.3 + _hoverFactor * 0.2).clamp(0.0, 1.0);
        
        // Calculate dynamic blur and opacity
        final blurSigma = widget.baseBlur + BlurTheme.calculateBlurSigma(combinedMotion);
        final opacity = BlurTheme.calculateOpacity(combinedMotion);

        return MouseRegion(
          onEnter: _onHoverEnter,
          onExit: _onHoverExit,
          child: GestureDetector(
            onTapDown: widget.onTap != null ? _onTapDown : null,
            onTapUp: widget.onTap != null ? _onTapUp : null,
            onTapCancel: widget.onTap != null ? _onTapCancel : null,
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.borderColor ?? BlurTheme.getBorderColor(context),
                  width: 1.0,
                ),
                boxShadow: [
                  // Depth shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1,
                    ),
                    blurRadius: widget.baseBlur + combinedMotion * 5,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  // Optional glow effect
                  if (widget.showGlow && widget.glowColor != null)
                    BoxShadow(
                      color: widget.glowColor!.withOpacity(0.3 + combinedMotion * 0.2),
                      blurRadius: 20 + combinedMotion * 10,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Stack(
                  children: [
                    // Layer 1: Backdrop filter (blur)
                    if (widget.enableBackdropFilter)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: blurSigma,
                            sigmaY: blurSigma,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    
                    // Layer 2: Vibrancy tint
                    if (widget.enableVibrancy)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BlurTheme.getVibrancyColor(
                              context,
                              opacity: widget.baseOpacity + opacity,
                            ),
                          ),
                        ),
                      ),
                    
                    // Layer 3: Gradient overlay for depth
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: BlurTheme.getDepthGradient(context),
                        ),
                      ),
                    ),
                    
                    // Layer 4: Shader gloss overlay
                    if (widget.enableShaderGloss)
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ShaderGlossOverlay(
                              width: constraints.maxWidth.isFinite 
                                  ? constraints.maxWidth 
                                  : 1000, // Reasonable fallback
                              height: constraints.maxHeight.isFinite 
                                  ? constraints.maxHeight 
                                  : 1000, // Reasonable fallback
                              motionFactor: combinedMotion,
                              enabled: widget.enableShaderGloss,
                            );
                          },
                        ),
                      ),
                    
                    // Layer 5: Content
                    if (widget.padding != null)
                      Padding(
                        padding: widget.padding!,
                        child: widget.child,
                      )
                    else
                      widget.child,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
