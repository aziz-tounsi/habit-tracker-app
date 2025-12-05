import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../data/models/stone_model.dart';

/// Grayscale color filter matrix for locked stones
/// Uses luminance coefficients (Rec. 709) with reduced opacity
const List<double> _grayscaleLockedMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, // Red channel
  0.2126, 0.7152, 0.0722, 0, 0, // Green channel
  0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
  0, 0, 0, 0.6, 0,              // Alpha channel (60% opacity)
];

/// Cached grayscale ColorFilter to avoid recreating on each build
const ColorFilter _grayscaleColorFilter = ColorFilter.matrix(_grayscaleLockedMatrix);

/// 3D Crystal Stone Widget with PNG assets and magical effects
/// 
/// Performance note: Set `animate: false` (the default) for grid displays
/// to avoid creating animation controllers for each stone. Only enable
/// animation for featured/modal displays where a single stone is highlighted.
class CrystalStone extends StatefulWidget {
  final String stoneType;
  final double size;
  final bool isLocked;
  final bool showGlow;
  final bool animate;
  
  const CrystalStone({
    super.key,
    required this.stoneType,
    this.size = 80,
    this.isLocked = false,
    this.showGlow = true,
    this.animate = false, // Default to false for performance
  });

  @override
  State<CrystalStone> createState() => _CrystalStoneState();
}

class _CrystalStoneState extends State<CrystalStone>
    with TickerProviderStateMixin {
  AnimationController? _floatController;
  AnimationController? _glowController;
  Animation<double>? _floatAnimation;
  Animation<double>? _glowAnimation;

  bool get _shouldAnimate => widget.animate && !widget.isLocked;

  @override
  void initState() {
    super.initState();
    _setupAnimationsIfNeeded();
  }

  void _setupAnimationsIfNeeded() {
    if (_shouldAnimate) {
      // Floating animation
      _floatController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );
      _floatAnimation = Tween<double>(begin: -3, end: 3).animate(
        CurvedAnimation(parent: _floatController!, curve: Curves.easeInOut),
      );
      
      // Glow pulsing animation
      _glowController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
        CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
      );
      
      _floatController!.repeat(reverse: true);
      _glowController!.repeat(reverse: true);
    }
  }

  void _disposeAnimations() {
    _floatController?.dispose();
    _glowController?.dispose();
    _floatController = null;
    _glowController = null;
    _floatAnimation = null;
    _glowAnimation = null;
  }

  @override
  void didUpdateWidget(CrystalStone oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasAnimating = oldWidget.animate && !oldWidget.isLocked;
    final shouldNowAnimate = _shouldAnimate;
    
    if (wasAnimating && !shouldNowAnimate) {
      // Stop and dispose animations
      _disposeAnimations();
    } else if (!wasAnimating && shouldNowAnimate) {
      // Start animations
      _setupAnimationsIfNeeded();
    }
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stone = StoneModel.getById(widget.stoneType);
    
    // Wrap in RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size * 1.4,
        height: widget.size * 1.4,
        child: _shouldAnimate && _floatAnimation != null && _glowAnimation != null
            ? AnimatedBuilder(
                animation: Listenable.merge([_floatAnimation!, _glowAnimation!]),
                builder: (context, child) {
                  return _buildContent(stone);
                },
              )
            : _buildContent(stone),
      ),
    );
  }

  Widget _buildContent(StoneModel? stone) {
    final floatValue = _floatAnimation?.value ?? 0.0;
    final glowValue = _glowAnimation?.value ?? 0.6;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated magical glow background (unlocked only)
        if (!widget.isLocked && widget.showGlow && stone != null)
          _buildMagicalGlow(stone, glowValue),
        
        // Stone with floating effect
        Transform.translate(
          offset: Offset(0, widget.isLocked ? 0 : floatValue),
          child: _buildStoneImage(stone),
        ),
        
        // Lock overlay for locked stones
        if (widget.isLocked)
          _buildLockOverlay(),
      ],
    );
  }

  Widget _buildMagicalGlow(StoneModel stone, double glowValue) {
    return Container(
      width: widget.size * 1.3,
      height: widget.size * 1.3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: stone.glowColor.withOpacity(glowValue * 0.6),
            blurRadius: 25,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: stone.primaryColor.withOpacity(glowValue * 0.4),
            blurRadius: 40,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: stone.secondaryColor.withOpacity(glowValue * 0.3),
            blurRadius: 50,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildStoneImage(StoneModel? stone) {
    if (stone == null) {
      return _buildFallbackStone();
    }

    Widget stoneImage = ClipOval(
      child: Image.asset(
        stone.assetPath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackStone();
        },
      ),
    );

    // Apply grayscale and dark overlay for locked stones
    if (widget.isLocked) {
      stoneImage = ColorFiltered(
        colorFilter: _grayscaleColorFilter,
        child: stoneImage,
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: widget.isLocked
            ? null
            : [
                BoxShadow(
                  color: (stone.primaryColor).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: stoneImage,
    );
  }

  Widget _buildFallbackStone() {
    // Fallback gradient orb if image fails to load
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: widget.isLocked
              ? [
                  const Color(0xFF2C2C2E),
                  const Color(0xFF1C1C1E),
                  const Color(0xFF0D0D0D),
                ]
              : [
                  const Color(0xFF9F7AEA),
                  const Color(0xFF7C3AED),
                  const Color(0xFF5B21B6),
                ],
          stops: const [0.0, 0.6, 1.0],
          center: const Alignment(-0.3, -0.3),
        ),
      ),
    );
  }

  Widget _buildLockOverlay() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.3),
      ),
      child: Icon(
        Icons.lock_outline,
        color: Colors.white.withOpacity(0.5),
        size: widget.size * 0.35,
      ),
    );
  }
}

/// Animated stone with magical background gradient
class AnimatedCrystalStone extends StatefulWidget {
  final String stoneType;
  final double size;
  final bool isLocked;

  const AnimatedCrystalStone({
    super.key,
    required this.stoneType,
    this.size = 80,
    this.isLocked = false,
  });

  @override
  State<AnimatedCrystalStone> createState() => _AnimatedCrystalStoneState();
}

class _AnimatedCrystalStoneState extends State<AnimatedCrystalStone>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    if (!widget.isLocked) {
      _gradientController.repeat();
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stone = StoneModel.getById(widget.stoneType);
    
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          width: widget.size * 1.5,
          height: widget.size * 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size),
            gradient: widget.isLocked
                ? null
                : SweepGradient(
                    center: Alignment.center,
                    startAngle: _gradientController.value * 2 * math.pi,
                    endAngle: (_gradientController.value * 2 * math.pi) + (2 * math.pi),
                    colors: stone != null
                        ? [
                            stone.primaryColor.withOpacity(0.3),
                            stone.secondaryColor.withOpacity(0.2),
                            stone.glowColor.withOpacity(0.3),
                            stone.primaryColor.withOpacity(0.2),
                            stone.primaryColor.withOpacity(0.3),
                          ]
                        : [
                            Colors.purple.withOpacity(0.3),
                            Colors.blue.withOpacity(0.2),
                            Colors.cyan.withOpacity(0.3),
                            Colors.purple.withOpacity(0.2),
                            Colors.purple.withOpacity(0.3),
                          ],
                  ),
          ),
          child: Center(
            child: CrystalStone(
              stoneType: widget.stoneType,
              size: widget.size,
              isLocked: widget.isLocked,
              showGlow: !widget.isLocked,
            ),
          ),
        );
      },
    );
  }
}

/// Small crystal stone for collections/rows
class SmallCrystalStone extends StatelessWidget {
  final String stoneType;
  final bool isLocked;
  
  const SmallCrystalStone({
    super.key,
    required this.stoneType,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return CrystalStone(
      stoneType: stoneType,
      size: 40,
      isLocked: isLocked,
      showGlow: false,
      animate: false,
    );
  }
}
