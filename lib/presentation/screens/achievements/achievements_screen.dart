import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/premium_icons.dart';
import '../../../data/models/achievement_model.dart';
import '../../../providers/habit_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/galaxy_background.dart';
import '../../widgets/common/achievement_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

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
    return GalaxyBackground(
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final unlockedIds = habitProvider.user?.unlockedAchievements ?? [];
          final achievements = AchievementModel.allAchievements;
          final unlockedCount = unlockedIds.length;
          final totalCount = achievements.length;

          return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$unlockedCount / $totalCount unlocked',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Progress bar
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Progress',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.primaryGradient.createShader(bounds),
                              child: Text(
                                '${((unlockedCount / totalCount) * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: unlockedCount / totalCount,
                            backgroundColor:
                                Theme.of(context).colorScheme.onSurface.withAlpha(25),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPurple,
                            ),
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Achievement categories
              ...AchievementCategory.values.map((category) {
                final categoryAchievements =
                    AchievementModel.getByCategory(category);
                return _buildCategorySection(
                  context,
                  category,
                  categoryAchievements,
                  unlockedIds,
                );
              }),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    AchievementCategory category,
    List<AchievementModel> achievements,
    List<String> unlockedIds,
  ) {
    final categoryName = _getCategoryName(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            categoryName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AnimationLimiter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final isUnlocked = unlockedIds.contains(achievement.id);

              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 500),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _buildAchievementCard(context, achievement, isUnlocked),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    AchievementModel achievement,
    bool isUnlocked,
  ) {
    final gradient = isUnlocked
        ? AppColors.primaryGradient
        : LinearGradient(
            colors: [
              Colors.grey.withAlpha(76),
              Colors.grey.withAlpha(51),
            ],
          );

    return GestureDetector(
      onTap: () => _showAchievementDetails(context, achievement, isUnlocked),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: AppColors.primaryPurple.withAlpha(76),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isUnlocked ? achievement.icon : Icons.lock,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                achievement.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withAlpha(102),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                achievement.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  void _showAchievementDetails(
    BuildContext context,
    AchievementModel achievement,
    bool isUnlocked,
  ) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Icon
                Container(
                  width: 70,
                  height: 70,
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
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isUnlocked
                        ? Icon(
                            _getAchievementIcon(achievement.iconEmoji),
                            size: 36,
                            color: Colors.white,
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                _getAchievementIcon(achievement.iconEmoji),
                                size: 36,
                                color: Colors.grey,
                              ),
                              Icon(
                                Icons.lock,
                                color: Colors.white.withAlpha(204),
                                size: 24,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  achievement.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // XP reward
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isUnlocked ? AppColors.greenCyanGradient : null,
                    color: isUnlocked
                        ? null
                        : Theme.of(context).colorScheme.onSurface.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: isUnlocked ? Colors.white : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${achievement.xpReward} XP',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface.withAlpha(102),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Status
                Text(
                  isUnlocked ? '✅ Unlocked' : '🔒 Locked',
                  style: TextStyle(
                    fontSize: 13,
                    color: isUnlocked ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.streaks:
        return '🔥 Streaks';
      case AchievementCategory.completions:
        return '✅ Completions';
      case AchievementCategory.habits:
        return '📋 Habits';
      case AchievementCategory.milestones:
        return '🏆 Milestones';
    }
  }
}
