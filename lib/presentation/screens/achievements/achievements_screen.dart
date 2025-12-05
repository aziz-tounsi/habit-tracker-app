import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/premium_icons.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/models/stone_model.dart';
import '../../../providers/habit_provider.dart';
import '../../widgets/common/smart_blur_container.dart';
import '../../widgets/common/galaxy_background.dart';
import '../../widgets/common/crystal_stone.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GalaxyBackground(
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final user = habitProvider.user;
          final unlockedStones = user?.unlockedStones ?? [];
          final allStones = StoneModel.allStones;
          final unlockedCount = unlockedStones.length;
          final totalCount = allStones.length;

          return SingleChildScrollView(
          controller: _scrollController,
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
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF9F7AEA), Color(0xFF7C3AED)],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.diamond,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Crystal Stones',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$unlockedCount of $totalCount magical stones collected',
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
                  child: SmartBlurContainer(
                    padding: const EdgeInsets.all(20),
                    enableBackdropFilter: true,
                    enableShaderGloss: true,
                    motionFactor: _scrollProgress,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
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
                        const SizedBox(height: 12),
                        // Rarity breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRarityCount(StoneRarity.common, unlockedStones),
                            _buildRarityCount(StoneRarity.rare, unlockedStones),
                            _buildRarityCount(StoneRarity.epic, unlockedStones),
                            _buildRarityCount(StoneRarity.legendary, unlockedStones),
                          ],
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
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
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

  Widget _buildRarityCount(StoneRarity rarity, List<String> unlockedStones) {
    final total = StoneModel.allStones.where((s) => s.rarity == rarity).length;
    final unlocked = StoneModel.allStones
        .where((s) => s.rarity == rarity && unlockedStones.contains(s.id))
        .length;
    
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getRarityColor(rarity),
            boxShadow: [
              BoxShadow(
                color: _getRarityColor(rarity).withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$unlocked/$total',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCrystalStoneCard(
    BuildContext context,
    StoneModel stone,
    bool isUnlocked,
  ) {
    // Static opacity value (no animation for grid performance)
    const staticOpacity = 0.17;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showStoneDetails(context, stone, isUnlocked);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    stone.primaryColor.withOpacity(staticOpacity),
                    stone.secondaryColor.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                  ],
                )
              : null,
          color: isUnlocked ? null : Colors.black.withOpacity(0.5),
          border: Border.all(
            color: isUnlocked
                ? stone.glowColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: stone.glowColor.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grid stones use static (no animation) for performance
            CrystalStone(
              stoneType: stone.id,
              size: 48,
              isLocked: !isUnlocked,
              showGlow: isUnlocked,
              animate: false, // No animation for grid stones
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                stone.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.4),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRarityColor(stone.rarity).withOpacity(isUnlocked ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _getRarityColor(stone.rarity).withOpacity(isUnlocked ? 0.4 : 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                _getRarityName(stone.rarity),
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: _getRarityColor(stone.rarity).withOpacity(isUnlocked ? 1.0 : 0.5),
                  letterSpacing: 0.5,
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
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _StoneDetailsModal(
        stone: stone,
        isUnlocked: isUnlocked,
        getRarityColor: _getRarityColor,
        getRarityName: _getRarityName,
      ),
    );
  }
}

class _StoneDetailsModal extends StatefulWidget {
  final StoneModel stone;
  final bool isUnlocked;
  final Color Function(StoneRarity) getRarityColor;
  final String Function(StoneRarity) getRarityName;

  const _StoneDetailsModal({
    required this.stone,
    required this.isUnlocked,
    required this.getRarityColor,
    required this.getRarityName,
  });

  @override
  State<_StoneDetailsModal> createState() => _StoneDetailsModalState();
}

class _StoneDetailsModalState extends State<_StoneDetailsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    if (widget.isUnlocked) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            AppColors.darkCard,
          ],
        ),
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
          
          // Crystal Stone with animated glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: widget.isUnlocked
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.stone.glowColor.withOpacity(
                              0.3 + 0.2 * _glowController.value,
                            ),
                            blurRadius: 40 + 20 * _glowController.value,
                            spreadRadius: 10 + 5 * _glowController.value,
                          ),
                        ],
                      )
                    : null,
                child: CrystalStone(
                  stoneType: widget.stone.id,
                  size: 120,
                  isLocked: !widget.isUnlocked,
                  showGlow: widget.isUnlocked,
                  animate: widget.isUnlocked, // Animate in modal for featured stone
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Stone Name with gradient
          widget.isUnlocked
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [widget.stone.primaryColor, widget.stone.glowColor],
                  ).createShader(bounds),
                  child: Text(
                    widget.stone.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : Text(
                  widget.stone.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
          const SizedBox(height: 12),
          
          // Rarity Badge with glow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: widget.getRarityColor(widget.stone.rarity).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.getRarityColor(widget.stone.rarity).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: widget.isUnlocked
                  ? [
                      BoxShadow(
                        color: widget.getRarityColor(widget.stone.rarity).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              widget.getRarityName(widget.stone.rarity),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.getRarityColor(widget.stone.rarity),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Description (lore)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.stone.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // XP Reward
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.2),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 22),
                const SizedBox(width: 8),
                Text(
                  '+${widget.stone.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Unlock Condition
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isUnlocked
                    ? Colors.green.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isUnlocked
                        ? Colors.green.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                  ),
                  child: Icon(
                    widget.isUnlocked ? Icons.check_circle : Icons.lock_outline,
                    color: widget.isUnlocked ? Colors.green : Colors.white.withOpacity(0.5),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isUnlocked ? 'Unlocked!' : 'How to unlock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.isUnlocked
                              ? Colors.green
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.stone.unlockCondition,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(widget.isUnlocked ? 0.8 : 0.6),
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
    );
  }
}
