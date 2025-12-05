import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../data/models/stone_model.dart';
import 'crystal_stone.dart';

/// Premium stone showcase widget for the profile screen
/// Displays unlocked stones in a magical floating carousel
class StoneShowcase extends StatefulWidget {
  final List<String> unlockedStoneIds;
  final Function(StoneModel)? onStoneTap;

  const StoneShowcase({
    super.key,
    required this.unlockedStoneIds,
    this.onStoneTap,
  });

  @override
  State<StoneShowcase> createState() => _StoneShowcaseState();
}

class _StoneShowcaseState extends State<StoneShowcase>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _floatController;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60), // Slowed down from 20s for performance
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pageController = PageController(
      viewportFraction: 0.5,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _floatController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<StoneModel> get _unlockedStones {
    return widget.unlockedStoneIds
        .map((id) => StoneModel.getById(id))
        .whereType<StoneModel>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final stones = _unlockedStones;
    final totalStones = StoneModel.allStones.length;
    
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D0D15),
            const Color(0xFF1A1A2E),
            const Color(0xFF0D0D15),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Animated star background
            _buildStarBackground(),
            
            // Main content
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF9F7AEA), Color(0xFF7C3AED)],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.diamond,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Crystal Collection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stones.length} / $totalStones',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Stones carousel or empty state
                Expanded(
                  child: stones.isEmpty
                      ? _buildEmptyState()
                      : _buildStonesCarousel(stones),
                ),
                
                // Page indicator
                if (stones.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPageIndicator(stones.length),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarBackground() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return CustomPaint(
            painter: _StarBackgroundPainter(
              rotation: _rotationController.value * 2 * math.pi,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No stones collected yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete habits to unlock magical stones!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStonesCarousel(List<StoneModel> stones) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemCount: stones.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = (_pageController.page! - index).abs();
              value = (1 - (value * 0.3)).clamp(0.0, 1.0);
            }
            
            return _buildStoneItem(stones[index], value);
          },
        );
      },
    );
  }

  Widget _buildStoneItem(StoneModel stone, double scale) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * math.pi) * 8;
        
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: 0.7 + (scale * 0.3),
            child: GestureDetector(
              onTap: () => widget.onStoneTap?.call(stone),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glow effect behind stone
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient glow
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: stone.glowColor.withOpacity(0.4 * scale),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: stone.primaryColor.withOpacity(0.3 * scale),
                              blurRadius: 60,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      // The stone
                      CrystalStone(
                        stoneType: stone.id,
                        size: 80,
                        isLocked: false,
                        showGlow: true,
                        animate: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stone name
                  Opacity(
                    opacity: scale,
                    child: Text(
                      stone.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Rarity badge
                  Opacity(
                    opacity: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRarityColor(stone.rarity).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getRarityColor(stone.rarity).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getRarityName(stone.rarity),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: _getRarityColor(stone.rarity),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? Colors.white.withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Color _getRarityColor(StoneRarity rarity) {
    switch (rarity) {
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

  String _getRarityName(StoneRarity rarity) {
    switch (rarity) {
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

class _StarBackgroundPainter extends CustomPainter {
  final double rotation;
  final math.Random _random = math.Random(42); // Fixed seed for consistent stars

  _StarBackgroundPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw static stars (reduced from 30 to 15 for performance)
    for (int i = 0; i < 15; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final starSize = 0.5 + _random.nextDouble() * 1.5;
      final opacity = 0.1 + _random.nextDouble() * 0.3;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
    
    // Draw a subtle nebula effect
    final center = Offset(size.width / 2, size.height / 2);
    final gradient = RadialGradient(
      colors: [
        const Color(0xFF7C3AED).withOpacity(0.1),
        const Color(0xFF6366F1).withOpacity(0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: size.width / 2),
    );
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 0.1);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(center, size.width / 2, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StarBackgroundPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}

/// Compact version of stone showcase for smaller spaces
class CompactStoneShowcase extends StatelessWidget {
  final List<String> unlockedStoneIds;
  final int maxDisplay;
  final VoidCallback? onViewAll;

  const CompactStoneShowcase({
    super.key,
    required this.unlockedStoneIds,
    this.maxDisplay = 5,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final stones = unlockedStoneIds
        .take(maxDisplay)
        .map((id) => StoneModel.getById(id))
        .whereType<StoneModel>()
        .toList();
    
    final totalStones = StoneModel.allStones.length;
    final hasMore = unlockedStoneIds.length > maxDisplay;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF9F7AEA), Color(0xFF7C3AED)],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.diamond,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Crystal Stones',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '${unlockedStoneIds.length} / $totalStones',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...stones.map((stone) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CrystalStone(
                  stoneType: stone.id,
                  size: 36,
                  isLocked: false,
                  showGlow: false,
                  animate: false,
                ),
              )),
              if (hasMore)
                GestureDetector(
                  onTap: onViewAll,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '+${unlockedStoneIds.length - maxDisplay}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
