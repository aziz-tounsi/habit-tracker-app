import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
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
  final VoidCallback? onStatsTap;
  // New callbacks for action row
  final VoidCallback? onAddHabit;
  final VoidCallback? onLogToday;
  final VoidCallback? onInsights;
  // Weekly mission data (optional, with safe defaults)
  final int weeklyTargetDays;
  final int weeklyAchievedDays;
  final int weeklyRewardXP;

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
    this.onStatsTap,
    this.onAddHabit,
    this.onLogToday,
    this.onInsights,
    this.weeklyTargetDays = 5,
    this.weeklyAchievedDays = 0,
    this.weeklyRewardXP = 100,
  });

  @override
  State<PremiumProfileHeader> createState() => _PremiumProfileHeaderState();
}

class _PremiumProfileHeaderState extends State<PremiumProfileHeader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fireController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fireAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for avatar ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
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
    _pulseController.dispose();
    _fireController.dispose();
    super.dispose();
  }

  // Feature 1: Mood ring color based on completion
  Color get _moodRingColor {
    if (widget.totalToday == 0) return Colors.grey;
    final progress = widget.completedToday / widget.totalToday;
    if (progress >= 1.0) return const Color(0xFF00E676); // Green - Perfect!
    if (progress >= 0.7) return const Color(0xFF69F0AE); // Light green
    if (progress >= 0.5) return const Color(0xFFFFD54F); // Yellow
    if (progress >= 0.3) return const Color(0xFFFFB74D); // Orange
    return const Color(0xFFFF5252); // Red - Need to work!
  }

  // Feature 5: Daily motivation based on time + performance
  String get _dailyMotivation {
    final hour = DateTime.now().hour;
    final progress = widget.totalToday > 0 
        ? widget.completedToday / widget.totalToday 
        : 0.0;
    
    if (hour < 12) {
      // Morning
      if (progress >= 0.5) return "Great morning start! 🌅";
      return "Fresh day ahead! Let's go! ☀️";
    } else if (hour < 17) {
      // Afternoon
      if (progress >= 1.0) return "All done! Enjoy your day! 🎉";
      if (progress >= 0.5) return "Halfway there! Keep pushing! 💪";
      return "Afternoon focus time! 🎯";
    } else {
      // Evening
      if (progress >= 1.0) return "Perfect day! Rest well! 🌙";
      if (progress >= 0.7) return "Almost there! Finish strong! 🔥";
      return "Evening push! You got this! ⭐";
    }
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Avatar + Info + Quick Stats
          Row(
            children: [
              // Feature 1 & 3: Mood Ring Avatar with XP Arc
              _buildAvatarWithProgress(),
              
              const SizedBox(width: 16),
              
              // User Info
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
                    const SizedBox(height: 4),
                    // Feature 5: Daily Motivation
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _moodRingColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _moodRingColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _dailyMotivation,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _moodRingColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Level + XP
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
          
          // NEW: XP Bar with text showing current XP and "+XP to next level"
          _buildXPProgressBar(),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // NEW: Streak Duo (current vs best) and Weekly Mission Pill
          Row(
            children: [
              // Streak Duo with flame indicator
              Expanded(child: _buildStreakDuo()),
              const SizedBox(width: 12),
              // Weekly Mission Pill
              Expanded(child: _buildWeeklyMissionPill()),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats Row with Feature 2: Animated Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle_outline,
                value: '${widget.completedToday}/${widget.totalToday}',
                label: 'Today',
                color: AppColors.accentGreen,
              ),
              _buildAnimatedStreakStat(),
              _buildStatItem(
                icon: Icons.emoji_events_outlined,
                value: '${widget.user?.unlockedAchievements.length ?? 0}',
                label: 'Badges',
                color: AppColors.goldAccent,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // NEW: Inline Action Row with primary "Add habit", secondary "Log today", tertiary icon "Insights"
          _buildInlineActionRow(),
        ],
      ),
    );
  }

  // NEW: XP Progress Bar with current XP and "+XP to next level" text
  Widget _buildXPProgressBar() {
    final totalXP = widget.user?.totalXP ?? 0;
    final currentLevelXP = totalXP % AppConstants.xpPerLevel;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
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
                    shaderCallback: (bounds) =>
                        AppColors.cyanPurpleGradient.createShader(bounds),
                    child: const Icon(
                      Iconsax.flash_15,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$currentLevelXP XP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Background
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                // Progress with gradient
                FractionallySizedBox(
                  widthFactor: widget.levelProgress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: AppColors.cyanPurpleGradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Streak Duo showing current vs best with flame indicator
  Widget _buildStreakDuo() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showStreakDetails();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orange.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _fireAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.currentStreak > 0 ? _fireAnimation.value : 1.0,
                  child: Icon(
                    Icons.local_fire_department,
                    size: 28,
                    color: widget.currentStreak > 0 ? Colors.orange : Colors.grey,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${widget.currentStreak}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.currentStreak > 0 ? Colors.orange : Colors.grey,
                        ),
                      ),
                      Text(
                        ' / ${widget.longestStreak}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Current / Best',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Weekly Mission Pill with target/achieved days and reward XP
  Widget _buildWeeklyMissionPill() {
    final progress = widget.weeklyTargetDays > 0
        ? (widget.weeklyAchievedDays / widget.weeklyTargetDays).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = widget.weeklyAchievedDays >= widget.weeklyTargetDays;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isComplete
            ? AppColors.greenCyanGradient
            : null,
        color: isComplete ? null : AppColors.primaryPurple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? Colors.transparent
              : AppColors.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Progress chip
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.white : AppColors.accentCyan,
                  ),
                ),
              ),
              Icon(
                isComplete ? Icons.check : Iconsax.cup5,
                size: 14,
                color: isComplete ? Colors.white : AppColors.accentCyan,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.weeklyAchievedDays}/${widget.weeklyTargetDays} days',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.white : Colors.white,
                  ),
                ),
                Text(
                  isComplete ? 'Mission Complete!' : '+${widget.weeklyRewardXP} XP reward',
                  style: TextStyle(
                    fontSize: 10,
                    color: isComplete ? Colors.white.withOpacity(0.8) : AppColors.accentCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Inline Action Row - primary "Add habit", secondary "Log today", tertiary icon "Insights"
  Widget _buildInlineActionRow() {
    return Row(
      children: [
        // Primary: Add Habit (larger, gradient)
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onAddHabit?.call();
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Add Habit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Secondary: Log Today
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onLogToday?.call();
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accentGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.calendar_tick, size: 18, color: AppColors.accentGreen),
                  const SizedBox(width: 6),
                  Text(
                    'Log Today',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Tertiary: Insights (icon only)
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onInsights?.call();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accentCyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Iconsax.chart_2,
              size: 20,
              color: AppColors.accentCyan,
            ),
          ),
        ),
      ],
    );
  }

  // Feature 1 & 3: Avatar with mood ring and XP progress
  Widget _buildAvatarWithProgress() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onAvatarTap?.call();
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  // XP Progress Arc (Feature 3)
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: _XPArcPainter(
                      progress: widget.levelProgress,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  // Mood Ring (Feature 1)
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _moodRingColor,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _moodRingColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryPurple,
                              AppColors.secondaryPink,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.user?.name?.isNotEmpty == true
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
                  ),
                ],
              ),
            ),
          );
        },
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

  // Feature 2: Animated Streak with growing fire
  Widget _buildAnimatedStreakStat() {
    final streakSize = (widget.currentStreak.clamp(0, 30) / 30) * 0.5 + 0.8;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showStreakDetails();
      },
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _fireAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.currentStreak > 0 
                    ? _fireAnimation.value * streakSize 
                    : 1.0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.currentStreak > 0
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: widget.currentStreak > 0
                        ? [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    size: 24,
                    color: widget.currentStreak > 0
                        ? Colors.orange
                        : Colors.grey,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.currentStreak}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.currentStreak > 0 
                  ? Colors.orange 
                  : Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            'Streak',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  void _showStreakDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.local_fire_department,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.currentStreak} Day Streak!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Best: ${widget.longestStreak} days',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            // Streak milestones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMilestone(7, 'Week', widget.currentStreak >= 7),
                _buildMilestone(30, 'Month', widget.currentStreak >= 30),
                _buildMilestone(100, '100!', widget.currentStreak >= 100),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone(int days, String label, bool achieved) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: achieved 
                ? Colors.orange.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: achieved ? Colors.orange : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: achieved
                ? const Icon(Icons.check, color: Colors.orange)
                : Text(
                    '$days',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: achieved ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }
}

// Custom painter for XP arc around avatar
class _XPArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _XPArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    
    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, AppColors.secondaryPink],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress, // Progress angle
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _XPArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
