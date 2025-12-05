import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/achievement_model.dart';

/// Achievement data for the carousel
class AchievementCardData {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> gradientColors;
  final double progress; // 0.0 to 1.0
  final bool isUnlocked;
  final String? nextUnlockHint;
  final int? xpReward;

  const AchievementCardData({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradientColors,
    required this.progress,
    this.isUnlocked = false,
    this.nextUnlockHint,
    this.xpReward,
  });

  /// Create from AchievementModel
  factory AchievementCardData.fromModel(
    AchievementModel model, {
    required double progress,
    required bool isUnlocked,
    String? nextUnlockHint,
  }) {
    return AchievementCardData(
      id: model.id,
      name: model.name,
      icon: model.icon,
      gradientColors: model.gradientColors,
      progress: progress,
      isUnlocked: isUnlocked,
      nextUnlockHint: nextUnlockHint,
      xpReward: model.xpReward,
    );
  }
}

/// A horizontal achievements carousel with PageView, parallax/scale animation,
/// progress rings, and "Next unlock" hints.
class AchievementsCarousel extends StatefulWidget {
  /// List of achievement data to display (typically 3 cards)
  final List<AchievementCardData> achievements;

  /// Callback when an achievement card is tapped
  final ValueChanged<AchievementCardData>? onAchievementTap;

  /// Callback when "See all" is tapped
  final VoidCallback? onSeeAllTap;

  const AchievementsCarousel({
    super.key,
    required this.achievements,
    this.onAchievementTap,
    this.onSeeAllTap,
  });

  @override
  State<AchievementsCarousel> createState() => _AchievementsCarouselState();
}

class _AchievementsCarouselState extends State<AchievementsCarousel> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.goldGradient.createShader(bounds),
                    child: const Icon(
                      Iconsax.medal_star5,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (widget.onSeeAllTap != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onSeeAllTap?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Carousel
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.achievements.length,
            itemBuilder: (context, index) {
              final achievement = widget.achievements[index];
              return _buildAchievementCard(achievement, index);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicators
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.achievements.length,
              (index) => _buildPageIndicator(index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(AchievementCardData achievement, int index) {
    // Calculate parallax/scale effect based on distance from current page
    final difference = (index - _currentPage).abs();
    final scale = 1 - (difference * 0.1).clamp(0.0, 0.2);
    final opacity = 1 - (difference * 0.3).clamp(0.0, 0.5);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onAchievementTap?.call(achievement);
      },
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: achievement.isUnlocked
                    ? achievement.gradientColors.first.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: achievement.isUnlocked
                      ? achievement.gradientColors.first.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Badge icon with progress ring
                _buildBadgeWithProgress(achievement),
                const SizedBox(width: 16),
                // Achievement info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Achievement name
                      Text(
                        achievement.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: achievement.isUnlocked
                              ? Colors.white
                              : Colors.white.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Progress text
                      if (!achievement.isUnlocked)
                        Text(
                          '${(achievement.progress * 100).toInt()}% complete',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      if (achievement.isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: achievement.gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Unlocked!',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Next unlock hint or XP reward
                      if (!achievement.isUnlocked &&
                          achievement.nextUnlockHint != null)
                        Row(
                          children: [
                            Icon(
                              Iconsax.lamp_on5,
                              size: 14,
                              color: AppColors.accentCyan.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                achievement.nextUnlockHint!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.accentCyan.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (achievement.xpReward != null)
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.goldGradient.createShader(bounds),
                              child: const Icon(
                                Iconsax.flash_15,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${achievement.xpReward} XP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldAccent,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeWithProgress(AchievementCardData achievement) {
    const size = 72.0;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _AchievementRingPainter(
              progress: achievement.progress,
              gradientColors: achievement.gradientColors,
              strokeWidth: 4,
              isUnlocked: achievement.isUnlocked,
            ),
          ),
          // Badge icon container
          Container(
            width: size - 16,
            height: size - 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: achievement.isUnlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: achievement.gradientColors,
                    )
                  : null,
              color: achievement.isUnlocked
                  ? null
                  : Colors.white.withOpacity(0.1),
              boxShadow: achievement.isUnlocked
                  ? [
                      BoxShadow(
                        color: achievement.gradientColors.first.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              achievement.icon,
              size: 28,
              color: achievement.isUnlocked
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = (_currentPage.round() == index);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: isActive ? AppColors.primaryGradient : null,
        color: isActive ? null : Colors.white.withOpacity(0.2),
      ),
    );
  }
}

/// Custom painter for the achievement progress ring
class _AchievementRingPainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;
  final double strokeWidth;
  final bool isUnlocked;

  _AchievementRingPainter({
    required this.progress,
    required this.gradientColors,
    required this.strokeWidth,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc with gradient
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 2 * math.pi * progress - math.pi / 2,
          colors: [
            gradientColors.first,
            gradientColors.last,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }

    // Glow effect for unlocked achievements
    if (isUnlocked) {
      final glowPaint = Paint()
        ..color = gradientColors.first.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(center, radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AchievementRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isUnlocked != isUnlocked;
  }
}
