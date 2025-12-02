import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 3D Crystal Stone Widget with radial gradients and glow effects
class CrystalStone extends StatelessWidget {
  final String stoneType;
  final double size;
  final bool isLocked;
  final bool showGlow;
  
  const CrystalStone({
    super.key,
    required this.stoneType,
    this.size = 80,
    this.isLocked = false,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getStoneColors(stoneType);
    
    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow effect (only if unlocked and showGlow is true)
          if (!isLocked && showGlow)
            Container(
              width: size * 1.4,
              height: size * 1.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: colors[1].withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          
          // Main crystal orb with radial gradient
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isLocked
                    ? [
                        const Color(0xFF2C2C2E),
                        const Color(0xFF1C1C1E),
                        const Color(0xFF0D0D0D),
                      ]
                    : [
                        colors[0],
                        colors[1],
                        colors[2],
                      ],
                stops: const [0.0, 0.6, 1.0],
                center: const Alignment(-0.3, -0.3),
              ),
              boxShadow: [
                if (!isLocked)
                  BoxShadow(
                    color: colors[0].withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Inner glow/shadow for depth
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0),
                        Colors.black.withOpacity(isLocked ? 0.7 : 0.3),
                      ],
                      stops: const [0.5, 1.0],
                      center: const Alignment(0.4, 0.4),
                    ),
                  ),
                ),
                
                // Shine/reflection overlay
                if (!isLocked)
                  Positioned(
                    top: size * 0.15,
                    left: size * 0.15,
                    child: Container(
                      width: size * 0.35,
                      height: size * 0.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.6),
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                
                // Secondary shine for more depth
                if (!isLocked)
                  Positioned(
                    bottom: size * 0.2,
                    right: size * 0.2,
                    child: Container(
                      width: size * 0.2,
                      height: size * 0.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Lock icon for locked stones
          if (isLocked)
            Icon(
              Icons.lock,
              color: Colors.white.withOpacity(0.3),
              size: size * 0.4,
            ),
        ],
      ),
    );
  }

  /// Get colors for each stone type
  List<Color> _getStoneColors(String type) {
    switch (type.toLowerCase()) {
      case 'amethyst':
        return [
          const Color(0xFF9F7AEA), // Light purple
          const Color(0xFF7C3AED), // Deep purple
          const Color(0xFF5B21B6), // Darkest purple
        ];
      case 'ruby':
        return [
          const Color(0xFFF87171), // Light red
          const Color(0xFFEF4444), // Red
          const Color(0xFFDC2626), // Dark red
        ];
      case 'sapphire':
        return [
          const Color(0xFF60A5FA), // Light blue
          const Color(0xFF3B82F6), // Blue
          const Color(0xFF1E40AF), // Dark blue
        ];
      case 'emerald':
        return [
          const Color(0xFF34D399), // Light green
          const Color(0xFF10B981), // Emerald green
          const Color(0xFF059669), // Dark green
        ];
      case 'diamond':
        return [
          const Color(0xFFFFFFFF), // White
          const Color(0xFFE0F2FE), // Ice blue
          const Color(0xFFBAE6FD), // Crystal blue
        ];
      case 'opal':
        return [
          const Color(0xFFEC4899), // Pink
          const Color(0xFF8B5CF6), // Purple
          const Color(0xFF06B6D4), // Cyan
        ];
      case 'citrine':
        return [
          const Color(0xFFFBBF24), // Light yellow
          const Color(0xFFF59E0B), // Amber
          const Color(0xFFEA580C), // Orange
        ];
      case 'rose_quartz':
        return [
          const Color(0xFFFBCAFE), // Light pink
          const Color(0xFFF9A8D4), // Pink
          const Color(0xFFEC4899), // Deep pink
        ];
      case 'topaz':
        return [
          const Color(0xFFFBBF24), // Gold
          const Color(0xFFF59E0B), // Amber
          const Color(0xFFEA580C), // Orange
        ];
      case 'obsidian':
        return [
          const Color(0xFF6B21A8), // Dark purple
          const Color(0xFF27272A), // Dark gray
          const Color(0xFF18181B), // Black
        ];
      default:
        // Default to purple gradient
        return [
          const Color(0xFF9F7AEA),
          const Color(0xFF7C3AED),
          const Color(0xFF5B21B6),
        ];
    }
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
    );
  }
}
