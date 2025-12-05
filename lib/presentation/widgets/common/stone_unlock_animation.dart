import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../data/models/stone_model.dart';
import 'crystal_stone.dart';

/// Spectacular magical unlock animation for crystal stones
class StoneUnlockAnimation extends StatefulWidget {
  final StoneModel stone;
  final VoidCallback? onComplete;
  final Duration duration;

  const StoneUnlockAnimation({
    super.key,
    required this.stone,
    this.onComplete,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<StoneUnlockAnimation> createState() => _StoneUnlockAnimationState();

  /// Show the unlock animation as an overlay
  static Future<void> show(BuildContext context, StoneModel stone) async {
    HapticFeedback.heavyImpact();
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => StoneUnlockAnimation(
        stone: stone,
        onComplete: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _StoneUnlockAnimationState extends State<StoneUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _runeController;
  
  // Animation phases
  late Animation<double> _energyGatherAnimation;
  late Animation<double> _burstAnimation;
  late Animation<double> _materializeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _runeRotation;

  final List<_Particle> _particles = [];
  final List<_MagicRune> _runes = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _generateRunes();
    _startAnimation();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _runeController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Phase 1: Energy gathering (0.0 - 0.3)
    _energyGatherAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Phase 2: Light burst (0.3 - 0.5)
    _burstAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
      ),
    );

    // Phase 3: Stone materialize (0.4 - 0.7)
    _materializeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Phase 4: Final glow (0.6 - 1.0)
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Scale bounce
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.8),
    ));

    // Rune rotation
    _runeRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _runeController, curve: Curves.linear),
    );
  }

  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(
        angle: _random.nextDouble() * 2 * math.pi,
        speed: 50 + _random.nextDouble() * 100,
        size: 2 + _random.nextDouble() * 4,
        color: _getRandomStoneColor(),
        delay: _random.nextDouble() * 0.3,
      ));
    }
  }

  void _generateRunes() {
    const runeSymbols = ['◇', '✦', '❋', '✧', '⬡', '◈'];
    for (int i = 0; i < 6; i++) {
      _runes.add(_MagicRune(
        symbol: runeSymbols[i],
        angle: (i / 6) * 2 * math.pi,
        radius: 100,
      ));
    }
  }

  Color _getRandomStoneColor() {
    final colors = [
      widget.stone.primaryColor,
      widget.stone.secondaryColor,
      widget.stone.glowColor,
      Colors.white,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    HapticFeedback.mediumImpact();
    _runeController.repeat();
    _particleController.repeat();
    
    await _mainController.forward();
    
    // Final haptic feedback
    HapticFeedback.heavyImpact();
    
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _runeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _particleController, _runeController]),
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Magic circle / runes
              if (_energyGatherAnimation.value > 0)
                _buildMagicCircle(),
              
              // Energy gathering particles
              if (_energyGatherAnimation.value > 0 && _burstAnimation.value < 0.5)
                _buildEnergyParticles(),
              
              // Light burst
              if (_burstAnimation.value > 0)
                _buildLightBurst(),
              
              // Exploding particles
              if (_burstAnimation.value > 0.3)
                _buildExplodingParticles(),
              
              // The stone materializing
              if (_materializeAnimation.value > 0)
                _buildStone(),
              
              // Stone name and details
              if (_glowAnimation.value > 0.5)
                _buildStoneInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMagicCircle() {
    return Transform.rotate(
      angle: _runeRotation.value,
      child: Opacity(
        opacity: (1 - _burstAnimation.value).clamp(0, 1),
        child: Container(
          width: 220 + (_energyGatherAnimation.value * 30),
          height: 220 + (_energyGatherAnimation.value * 30),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.stone.glowColor.withOpacity(0.6 * _energyGatherAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.stone.primaryColor.withOpacity(0.3 * _energyGatherAnimation.value),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner circle
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.stone.secondaryColor.withOpacity(0.4 * _energyGatherAnimation.value),
                    width: 1,
                  ),
                ),
              ),
              // Runes around the circle
              ..._runes.map((rune) => _buildRune(rune)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRune(_MagicRune rune) {
    final x = math.cos(rune.angle) * rune.radius;
    final y = math.sin(rune.angle) * rune.radius;
    
    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.rotate(
        angle: -_runeRotation.value, // Counter-rotate to stay upright
        child: Text(
          rune.symbol,
          style: TextStyle(
            fontSize: 20,
            color: widget.stone.glowColor.withOpacity(0.8 * _energyGatherAnimation.value),
            shadows: [
              Shadow(
                color: widget.stone.primaryColor.withOpacity(0.6),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyParticles() {
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: _EnergyParticlePainter(
          particles: _particles,
          progress: _particleController.value,
          gatherProgress: _energyGatherAnimation.value,
          stoneColor: widget.stone.primaryColor,
        ),
      ),
    );
  }

  Widget _buildLightBurst() {
    final burstSize = 50 + (_burstAnimation.value * 300);
    
    return Container(
      width: burstSize,
      height: burstSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity((1 - _burstAnimation.value) * 0.8),
            widget.stone.glowColor.withOpacity((1 - _burstAnimation.value) * 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildExplodingParticles() {
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: _ExplodingParticlePainter(
          particles: _particles,
          progress: (_mainController.value - 0.3).clamp(0, 1) / 0.7,
          stoneColor: widget.stone.primaryColor,
          glowColor: widget.stone.glowColor,
        ),
      ),
    );
  }

  Widget _buildStone() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Opacity(
        opacity: _materializeAnimation.value,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.stone.glowColor.withOpacity(0.6 * _glowAnimation.value),
                blurRadius: 40 * _glowAnimation.value,
                spreadRadius: 15 * _glowAnimation.value,
              ),
            ],
          ),
          child: CrystalStone(
            stoneType: widget.stone.id,
            size: 120,
            isLocked: false,
            showGlow: true,
            animate: true, // Enable animation for unlock celebration
          ),
        ),
      ),
    );
  }

  Widget _buildStoneInfo() {
    return Opacity(
      opacity: ((_glowAnimation.value - 0.5) * 2).clamp(0, 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 180),
          // Stone name with gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [widget.stone.primaryColor, widget.stone.glowColor],
            ).createShader(bounds),
            child: Text(
              widget.stone.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Rarity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _getRarityColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getRarityColor().withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Text(
              _getRarityName(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getRarityColor(),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // XP reward
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '+${widget.stone.xpReward} XP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Tap to continue
          Text(
            'Tap anywhere to continue',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor() {
    switch (widget.stone.rarity) {
      case StoneRarity.common:
        return const Color(0xFF94A3B8);
      case StoneRarity.rare:
        return const Color(0xFF3B82F6);
      case StoneRarity.epic:
        return const Color(0xFF8B5CF6);
      case StoneRarity.legendary:
        return const Color(0xFFFFD700);
    }
  }

  String _getRarityName() {
    switch (widget.stone.rarity) {
      case StoneRarity.common:
        return 'COMMON';
      case StoneRarity.rare:
        return 'RARE';
      case StoneRarity.epic:
        return 'EPIC';
      case StoneRarity.legendary:
        return 'LEGENDARY';
    }
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double delay;
  // Pre-calculated trigonometric values for performance
  final double cosAngle;
  final double sinAngle;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.delay,
  }) : cosAngle = math.cos(angle),
       sinAngle = math.sin(angle);
}

class _MagicRune {
  final String symbol;
  final double angle;
  final double radius;

  _MagicRune({
    required this.symbol,
    required this.angle,
    required this.radius,
  });
}

class _EnergyParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final double gatherProgress;
  final Color stoneColor;

  _EnergyParticlePainter({
    required this.particles,
    required this.progress,
    required this.gatherProgress,
    required this.stoneColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final particle in particles) {
      if (progress < particle.delay) continue;
      
      final adjustedProgress = ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
      
      // Particles start from outside and move toward center
      const startRadius = 120.0;
      const endRadius = 10.0;
      final currentRadius = startRadius - (startRadius - endRadius) * gatherProgress;
      
      // Use small rotation offset based on progress, using pre-cached cos/sin values
      final rotationOffset = adjustedProgress * 2;
      final cosRotation = math.cos(rotationOffset);
      final sinRotation = math.sin(rotationOffset);
      
      // Apply rotation matrix to the pre-cached direction
      final rotatedCos = particle.cosAngle * cosRotation - particle.sinAngle * sinRotation;
      final rotatedSin = particle.sinAngle * cosRotation + particle.cosAngle * sinRotation;
      
      final x = center.dx + rotatedCos * currentRadius;
      final y = center.dy + rotatedSin * currentRadius;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(0.8 * gatherProgress)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ExplodingParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color stoneColor;
  final Color glowColor;

  _ExplodingParticlePainter({
    required this.particles,
    required this.progress,
    required this.stoneColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final particle in particles) {
      // Particles explode outward - use pre-cached values
      final distance = particle.speed * progress;
      final fadeOut = (1 - progress).clamp(0.0, 1.0);
      
      final x = center.dx + particle.cosAngle * distance;
      final y = center.dy + particle.sinAngle * distance;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(fadeOut * 0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), particle.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
