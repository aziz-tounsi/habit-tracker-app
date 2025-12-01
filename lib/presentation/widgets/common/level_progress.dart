import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import 'glass_container.dart';

class LevelProgressWidget extends StatelessWidget {
  final int level;
  final int totalXP;
  final double levelProgress;
  final VoidCallback? onTap;

  const LevelProgressWidget({
    super.key,
    required this.level,
    required this.totalXP,
    required this.levelProgress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final xpForNextLevel = AppConstants.xpPerLevel - (totalXP % AppConstants.xpPerLevel);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.mediumImpact();
          onTap!();
        }
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.cyanPurpleGradient.createShader(bounds),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Level $level',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.touch_app,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // XP progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: levelProgress,
                backgroundColor:
                    Theme.of(context).colorScheme.onSurface.withAlpha(25),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accentCyan,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalXP XP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
                Text(
                  '$xpForNextLevel XP to Level ${level + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
