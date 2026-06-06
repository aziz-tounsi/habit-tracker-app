import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/avatars.dart';
import '../../../data/models/user_model.dart';

class PremiumProfileHeader extends StatefulWidget {
  final UserModel? user;
  final int totalHabits;
  final int completedToday;
  final int totalToday;
  final int currentStreak;
  final int longestStreak;
  final double levelProgress;
  final VoidCallback? onAvatarTap;
  // Weekly mission data (optional, with safe defaults)
  final int weeklyTargetDays;
  final int weeklyAchievedDays;
  final int weeklyRewardXP;
  // Navigation callback for weekly mission chip
  final VoidCallback? onWeeklyMissionTap;
  // Callback for streak tap - opens same sheet as level/progress
  final VoidCallback? onStreakTap;

  const PremiumProfileHeader({
    super.key,
    this.user,
    required this.totalHabits,
    required this.completedToday,
    required this.totalToday,
    required this.currentStreak,
    required this.longestStreak,
    required this.levelProgress,
    this.onAvatarTap,
    this.weeklyTargetDays = 5,
    this.weeklyAchievedDays = 0,
    this.weeklyRewardXP = 100,
    this.onWeeklyMissionTap,
    this.onStreakTap,
  });

  @override
  State<PremiumProfileHeader> createState() => _PremiumProfileHeaderState();
}

class _PremiumProfileHeaderState extends State<PremiumProfileHeader>
    with TickerProviderStateMixin {
  late AnimationController _fireController;
  late Animation<double> _fireAnimation;

  @override
  void initState() {
    super.initState();

    // Fire animation for streak
    _fireController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fireAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  // Calculate XP to next level
  int get _xpToNextLevel {
    final totalXP = widget.user?.totalXP ?? 0;
    final remainder = totalXP % AppConstants.xpPerLevel;
    // Handle the case where XP is exactly at a level boundary
    if (remainder == 0 && totalXP > 0) {
      return 0; // Just leveled up
    }
    return AppConstants.xpPerLevel - remainder;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Top Row: Avatar + Info
          Row(
            children: [
              _buildAvatarWithProgress(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildLevelBadge(),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.user?.totalXP ?? 0} XP',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Unified XP Bar with embedded streak and weekly mission
          _buildUnifiedXPBar(),
        ],
      );
  }

  Widget _buildUnifiedXPBar() {
    final totalXP = widget.user?.totalXP ?? 0;
    final currentLevelXP = totalXP % AppConstants.xpPerLevel;
    final missionProgress = widget.weeklyTargetDays > 0
        ? (widget.weeklyAchievedDays / widget.weeklyTargetDays).clamp(0.0, 1.0)
        : 0.0;
    final missionComplete = widget.weeklyAchievedDays >= widget.weeklyTargetDays;

    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Column(
          children: [
            // Row 1: XP text + next level badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.cyanPurpleGradient.createShader(bounds),
                      child: const Icon(Iconsax.flash_15, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$currentLevelXP XP',
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanPurpleGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+$_xpToNextLevel to next level',
                    style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(height: 8, color: Colors.white.withOpacity(0.1)),
                  FractionallySizedBox(
                    widthFactor: widget.levelProgress.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(gradient: AppColors.cyanPurpleGradient),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Row 2: Streak + Weekly Mission merged
            Row(
              children: [
                // Streak (tappable)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onStreakTap?.call();
                    },
                    child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _fireAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: widget.currentStreak > 0 ? _fireAnimation.value : 1.0,
                            child: Icon(
                              Icons.local_fire_department,
                              size: 20,
                              color: widget.currentStreak > 0 ? Colors.orange : Colors.grey,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.currentStreak}',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: widget.currentStreak > 0 ? Colors.orange : Colors.grey,
                        ),
                      ),
                      Text(
                        ' / ${widget.longestStreak}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
              ),
                // Weekly mission
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onWeeklyMissionTap?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: missionComplete ? AppColors.cyanPurpleGradient : null,
                      color: missionComplete ? null : AppColors.primaryPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                value: missionProgress,
                                strokeWidth: 2,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  missionComplete ? Colors.white : AppColors.accentCyan,
                                ),
                              ),
                            ),
                            Icon(
                              missionComplete ? Icons.check : Iconsax.cup5,
                              size: 10,
                              color: missionComplete ? Colors.white : AppColors.accentCyan,
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.weeklyAchievedDays}/${widget.weeklyTargetDays}',
                              style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white,
                              ),
                            ),
                            Text(
                              missionComplete ? 'Done!' : '+${widget.weeklyRewardXP} XP',
                              style: TextStyle(
                                fontSize: 9,
                                color: missionComplete
                                    ? Colors.white.withOpacity(0.8)
                                    : AppColors.accentCyan,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  // Clean avatar without ring (per feedback)
  Widget _buildAvatarWithProgress() {
    final avatarId = widget.user?.avatarEmoji ?? 'avatar_0';
    final avatarPath = ImageAvatars.getAvatarPath(avatarId);
    final hasImageAvatar = avatarPath != null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onAvatarTap?.call();
      },
      child: SizedBox(
        width: 64,
        height: 64,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasImageAvatar
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryPurple, AppColors.secondaryPink],
                  ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: hasImageAvatar
              ? ClipOval(
                  child: Image.asset(
                    avatarPath,
                    fit: BoxFit.cover,
                    width: 64,
                    height: 64,
                  ),
                )
              : Center(
                  child: Text(
                    widget.user?.name.isNotEmpty == true
                        ? widget.user!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Level ${widget.user?.level ?? 0}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

}
