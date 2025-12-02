import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

/// Stone reveal animation with 4 stages:
/// Stage 1: Rough rock with cracks forming
/// Stage 2: Rock shatters into pieces (no gravity)
/// Stage 3: Crystal revealed with glow and sparkles
/// Stage 4: Crystal floats gently
class StoneRevealAnimation extends StatefulWidget {
  final Color stoneColor;
  final Color glowColor;
  final double size;
  final VoidCallback? onComplete;
  final Widget? crystalIcon;

  const StoneRevealAnimation({
    super.key,
    required this.stoneColor,
    required this.glowColor,
    this.size = 200,
    this.onComplete,
    this.crystalIcon,
  });

  @override
  State<StoneRevealAnimation> createState() => _StoneRevealAnimationState();
}

class _StoneRevealAnimationState extends State<StoneRevealAnimation>
    with TickerProviderStateMixin {
  late AnimationController _stageController;
  late AnimationController _floatController;
  late AnimationController _sparkleController;

  int _currentStage = 0;

  @override
  void initState() {
    super.initState();

    // Main stage controller
    _stageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Gentle floating controller
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Sparkle animation controller
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _startAnimation();
  }

  void _startAnimation() {
    // Stage 1: Rough rock (0-1000ms)
    setState(() => _currentStage = 1);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      
      // Stage 2: Rock shatters (1000-2000ms)
      setState(() => _currentStage = 2);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        
        // Stage 3: Crystal revealed (2000-2500ms)
        setState(() => _currentStage = 3);
        _sparkleController.repeat(reverse: true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          
          // Stage 4: Crystal floats (2500ms+)
          setState(() => _currentStage = 4);
          _floatController.repeat(reverse: true);
          widget.onComplete?.call();
        });
      });
    });
  }

  @override
  void dispose() {
    _stageController.dispose();
    _floatController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stage-based rendering
          if (_currentStage == 1) _buildStage1RoughRock(),
          if (_currentStage == 2) _buildStage2Shatter(),
          if (_currentStage >= 3) _buildStage3and4Crystal(),
        ],
      ),
    );
  }

  /// Stage 1: Rough rock with cracks forming
  Widget _buildStage1RoughRock() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade800,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        painter: CracksPainter(
          crackProgress: 1.0,
          color: Colors.grey.shade600,
        ),
      ),
    )
        .animate()
        .scale(
          duration: const Duration(milliseconds: 300),
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
        )
        .shake(
          duration: const Duration(milliseconds: 700),
          delay: const Duration(milliseconds: 300),
          hz: 4,
          rotation: 0.02,
        );
  }

  /// Stage 2: Rock shatters into pieces
  Widget _buildStage2Shatter() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(8, (index) {
        final angle = (index * 45.0) * math.pi / 180;
        final distance = widget.size * 0.8;

        return Transform.translate(
          offset: Offset(
            math.cos(angle) * distance,
            math.sin(angle) * distance,
          ),
          child: Transform.rotate(
            angle: angle + (index * 0.5),
            child: Container(
              width: widget.size * 0.25,
              height: widget.size * 0.25,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeOut(duration: const Duration(milliseconds: 500))
            .scale(
              duration: const Duration(milliseconds: 500),
              end: const Offset(0.5, 0.5),
            );
      }),
    );
  }

  /// Stage 3 & 4: Crystal revealed with glow and sparkles
  Widget _buildStage3and4Crystal() {
    Widget crystal = Container(
      width: widget.size * 0.7,
      height: widget.size * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            widget.stoneColor.withOpacity(0.8),
            widget.stoneColor,
            widget.stoneColor.withOpacity(0.6),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: widget.glowColor.withOpacity(0.3),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: widget.crystalIcon ??
            Icon(
              Icons.auto_awesome,
              size: widget.size * 0.35,
              color: Colors.white.withOpacity(0.9),
            ),
      ),
    );

    // Stage 4: Add floating animation
    if (_currentStage == 4) {
      crystal = AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              math.sin(_floatController.value * 2 * math.pi) * 10,
            ),
            child: child,
          );
        },
        child: crystal,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Sparkles around crystal
        if (_currentStage >= 3) ..._buildSparkles(),
        
        // Main crystal
        crystal
            .animate()
            .scale(
              duration: const Duration(milliseconds: 500),
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: const Duration(milliseconds: 300)),
      ],
    );
  }

  /// Build sparkle effects around crystal
  List<Widget> _buildSparkles() {
    return List.generate(12, (index) {
      final angle = (index * 30.0) * math.pi / 180;
      final distance = widget.size * 0.5;

      return AnimatedBuilder(
        animation: _sparkleController,
        builder: (context, child) {
          final scale = 0.5 + (_sparkleController.value * 0.5);
          final opacity = 0.3 + (_sparkleController.value * 0.7);

          return Transform.translate(
            offset: Offset(
              math.cos(angle) * distance,
              math.sin(angle) * distance,
            ),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.glowColor.withOpacity(opacity),
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(opacity * 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

/// Custom painter for drawing cracks on the rock
class CracksPainter extends CustomPainter {
  final double crackProgress;
  final Color color;

  CracksPainter({
    required this.crackProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw multiple cracks radiating from center
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0) * math.pi / 180;
      final path = Path();

      // Start from center
      path.moveTo(center.dx, center.dy);

      // Create a jagged crack line
      final steps = 5;
      for (int j = 1; j <= steps; j++) {
        final t = j / steps * crackProgress;
        final distance = radius * t;
        final jitter = (j % 2 == 0 ? 10 : -10) * (j / steps);

        final x = center.dx + math.cos(angle) * distance + jitter;
        final y = center.dy + math.sin(angle) * distance + jitter;

        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }

    // Draw circular cracks
    final circleCount = 3;
    for (int i = 1; i <= circleCount; i++) {
      final r = radius * (i / (circleCount + 1)) * crackProgress;
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(CracksPainter oldDelegate) {
    return oldDelegate.crackProgress != crackProgress;
  }
}
