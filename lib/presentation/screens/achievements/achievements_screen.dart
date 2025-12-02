import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/premium_icons.dart';
import '../../../core/constants/stones.dart';
import '../../../data/models/achievement_model.dart';
import '../../../providers/habit_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/galaxy_background.dart';
import '../../widgets/common/crystal_stone.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GalaxyBackground(
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final user = habitProvider.user;
          final unlockedStones = user?.unlockedStones ?? [];
          final allStones = StonesConstants.getAllStones();
          final unlockedCount = unlockedStones.length;
          final totalCount = allStones.length;

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
                        'Crystal Stones',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$unlockedCount / $totalCount collected',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
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
                    useBackdropFilter: true,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Collection Progress',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
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
              const SizedBox(height: 32),
              
              // Crystal Stones Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimationLimiter(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: allStones.length,
                    itemBuilder: (context, index) {
                      final stone = allStones[index];
                      final isUnlocked = unlockedStones.contains(stone.id);

                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        columnCount: 3,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: _buildCrystalStoneCard(
                              context,
                              stone,
                              isUnlocked,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    ),
    );
  }

  Widget _buildCrystalStoneCard(
    BuildContext context,
    StoneModel stone,
    bool isUnlocked,
  ) {
    return GestureDetector(
      onTap: () => _showStoneDetails(context, stone, isUnlocked),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        useBackdropFilter: true,
        showGlow: isUnlocked,
        glowColor: isUnlocked ? Color(stone.themeColorValues.first) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CrystalStone(
              stoneType: stone.id,
              size: 70,
              isLocked: !isUnlocked,
              showGlow: isUnlocked,
            ),
            const SizedBox(height: 12),
            Text(
              stone.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _getRarityColor(stone.rarity),
                ),
              ),
            ),
          ],
        ),
      ),
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
        return AppColors.goldAccent;
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

  void _showStoneDetails(BuildContext context, StoneModel stone, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Crystal Stone
            CrystalStone(
              stoneType: stone.id,
              size: 120,
              isLocked: !isUnlocked,
              showGlow: isUnlocked,
            ),
            const SizedBox(height: 24),
            
            // Stone Name
            Text(
              stone.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Rarity Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getRarityColor(stone.rarity).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getRarityColor(stone.rarity).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                _getRarityName(stone.rarity),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getRarityColor(stone.rarity),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              stone.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            
            // Unlock Condition
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUnlocked ? Icons.check_circle : Icons.lock,
                    color: isUnlocked ? Colors.green : Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUnlocked ? 'Unlocked!' : 'Unlock Condition',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stone.unlockCondition,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
