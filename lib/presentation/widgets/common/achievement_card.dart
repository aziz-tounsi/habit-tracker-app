import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/achievement_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/premium_icons.dart';
import 'glass_container.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.onTap,
  });

  // Helper to map achievement emoji to icon
  IconData _getAchievementIcon(String emoji) {
    switch (emoji) {
      case '🔥':
        return Iconsax.flame;
      case '⭐':
        return Iconsax.star_1;
      case '💎':
        return Iconsax.medal_star;
      case '🏅':
        return Iconsax.award;
      case '👑':
        return Iconsax.crown_1;
      case '🚀':
        return Iconsax.rocket_1;
      case '🎯':
        return Iconsax.target;
      case '🏆':
        return Iconsax.cup;
      default:
        return Iconsax.award;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(10),
        borderRadius: 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
              // Icon with gradient background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isUnlocked
                      ? LinearGradient(
                          colors: achievement.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.withAlpha(76),
                            Colors.grey.withAlpha(51),
                          ],
                        ),
                  shape: BoxShape.circle,
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: achievement.gradientColors.first.withAlpha(102),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isUnlocked
                      ? Icon(
                          _getAchievementIcon(achievement.iconEmoji),
                          size: 24,
                          color: Colors.white,
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              _getAchievementIcon(achievement.iconEmoji),
                              size: 24,
                              color: Colors.grey,
                            ),
                            Icon(
                              Icons.lock,
                              color: Colors.white.withAlpha(179),
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 6),
              // Name
              Flexible(
                child: Text(
                  achievement.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withAlpha(102),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Description (reduced lines)
              Flexible(
                child: Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // XP reward
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: isUnlocked ? AppColors.greenCyanGradient : null,
                  color: isUnlocked
                      ? null
                      : Theme.of(context).colorScheme.onSurface.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${achievement.xpReward} XP',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface.withAlpha(102),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
