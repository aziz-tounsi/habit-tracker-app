import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/habit_model.dart';
import '../../../core/utils/helpers.dart';

/// Data for a habit in the focus panel
class FocusHabitData {
  final HabitModel habit;
  final bool isCompleted;
  final bool isUrgent;
  final String? dueTime;

  const FocusHabitData({
    required this.habit,
    this.isCompleted = false,
    this.isUrgent = false,
    this.dueTime,
  });
}

/// Today Focus Panel showing habits due now with urgency coloring,
/// XP reward tag, and quick actions.
class TodayFocusPanel extends StatelessWidget {
  /// List of habits due today
  final List<FocusHabitData> focusHabits;

  /// XP reward for completing all habits today
  final int xpReward;

  /// Callback for "Complete all" action
  final VoidCallback? onCompleteAll;

  /// Callback for "Snooze 2h" action
  final VoidCallback? onSnooze;

  /// Callback for "Reschedule" action
  final VoidCallback? onReschedule;

  /// Callback when a specific habit is tapped
  final ValueChanged<HabitModel>? onHabitTap;

  /// Callback when a habit completion is toggled
  final ValueChanged<HabitModel>? onHabitToggle;

  /// Callback when the header is tapped (to navigate to Today's Focus page)
  final VoidCallback? onHeaderTap;

  const TodayFocusPanel({
    super.key,
    required this.focusHabits,
    this.xpReward = 50,
    this.onCompleteAll,
    this.onSnooze,
    this.onReschedule,
    this.onHabitTap,
    this.onHabitToggle,
    this.onHeaderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (focusHabits.isEmpty) {
      return const SizedBox.shrink();
    }

    // Cache computed values to avoid repeated filtering during rebuilds
    final remainingCount = focusHabits.where((h) => !h.isCompleted).length;
    final urgentCount = focusHabits.where((h) => h.isUrgent && !h.isCompleted).length;
    final allCompleted = focusHabits.isNotEmpty && remainingCount == 0;

    return _TodayFocusPanelContent(
      focusHabits: focusHabits,
      xpReward: xpReward,
      remainingCount: remainingCount,
      urgentCount: urgentCount,
      allCompleted: allCompleted,
      onCompleteAll: onCompleteAll,
      onSnooze: onSnooze,
      onReschedule: onReschedule,
      onHabitTap: onHabitTap,
      onHabitToggle: onHabitToggle,
      onHeaderTap: onHeaderTap,
    );
  }
}

/// Internal stateless widget to render the focus panel content
class _TodayFocusPanelContent extends StatelessWidget {
  final List<FocusHabitData> focusHabits;
  final int xpReward;
  final int remainingCount;
  final int urgentCount;
  final bool allCompleted;
  final VoidCallback? onCompleteAll;
  final VoidCallback? onSnooze;
  final VoidCallback? onReschedule;
  final ValueChanged<HabitModel>? onHabitTap;
  final ValueChanged<HabitModel>? onHabitToggle;
  final VoidCallback? onHeaderTap;

  const _TodayFocusPanelContent({
    required this.focusHabits,
    required this.xpReward,
    required this.remainingCount,
    required this.urgentCount,
    required this.allCompleted,
    this.onCompleteAll,
    this.onSnooze,
    this.onReschedule,
    this.onHabitTap,
    this.onHabitToggle,
    this.onHeaderTap,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          color: urgentCount > 0
              ? AppColors.warning.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: urgentCount > 0
                ? AppColors.warning.withOpacity(0.1)
                : Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 12),
          // Habits due now list (max 3 visible)
          _buildHabitsList(),
          const SizedBox(height: 16),
          // XP Reward tag
          _buildRewardTag(),
          const SizedBox(height: 16),
          // Quick actions row
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: () {
        if (onHeaderTap != null) {
          HapticFeedback.lightImpact();
          onHeaderTap!();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Icon with urgency pulse
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: urgentCount > 0
                  ? AppColors.warningGradient
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: urgentCount > 0
                      ? AppColors.warning.withOpacity(0.3)
                      : AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              urgentCount > 0 ? Iconsax.timer_1 : Iconsax.task_square5,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Today\'s Focus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (onHeaderTap != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ],
                  ],
                ),
                Text(
                  allCompleted
                      ? 'All done! 🎉'
                      : urgentCount > 0
                          ? '$urgentCount urgent, $remainingCount remaining'
                          : '$remainingCount habits remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: urgentCount > 0
                        ? AppColors.warning
                        : Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: allCompleted
                  ? AppColors.accentGreen.withOpacity(0.2)
                  : urgentCount > 0
                      ? AppColors.warning.withOpacity(0.2)
                      : AppColors.accentCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  allCompleted
                      ? Icons.check_circle
                      : urgentCount > 0
                          ? Icons.warning_rounded
                          : Icons.pending,
                  size: 14,
                  color: allCompleted
                      ? AppColors.accentGreen
                      : urgentCount > 0
                          ? AppColors.warning
                          : AppColors.accentCyan,
                ),
                const SizedBox(width: 4),
                Text(
                  allCompleted
                      ? 'Done'
                      : urgentCount > 0
                          ? 'Urgent'
                          : 'In Progress',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: allCompleted
                        ? AppColors.accentGreen
                        : urgentCount > 0
                            ? AppColors.warning
                            : AppColors.accentCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    // Show only incomplete habits first, then completed, max 3 total
    final sortedHabits = List<FocusHabitData>.from(focusHabits)
      ..sort((a, b) {
        // Urgent incomplete first, then incomplete, then completed
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (a.isUrgent != b.isUrgent) {
          return a.isUrgent ? -1 : 1;
        }
        return 0;
      });

    final displayHabits = sortedHabits.take(3).toList();

    return Column(
      children: displayHabits
          .map((focusHabit) => _buildHabitItem(focusHabit))
          .toList(),
    );
  }

  Widget _buildHabitItem(FocusHabitData focusHabit) {
    final habit = focusHabit.habit;
    final isCompleted = focusHabit.isCompleted;
    final isUrgent = focusHabit.isUrgent && !isCompleted;

    // Get habit color safely
    final habitColorIndex = habit.colorIndex.clamp(0, AppColors.habitColors.length - 1);
    final habitColor = AppColors.habitColors[habitColorIndex];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onHabitTap?.call(habit);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.accentGreen.withOpacity(0.1)
              : isUrgent
                  ? AppColors.warning.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColors.accentGreen.withOpacity(0.2)
                : isUrgent
                    ? AppColors.warning.withOpacity(0.3)
                    : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Completion toggle
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onHabitToggle?.call(habit);
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.accentGreen
                      : Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.accentGreen
                        : isUrgent
                            ? AppColors.warning.withOpacity(0.5)
                            : habitColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Habit info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (focusHabit.dueTime != null)
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 12,
                          color: isUrgent
                              ? AppColors.warning
                              : Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          focusHabit.dueTime!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isUrgent
                                ? AppColors.warning
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Urgency indicator
            if (isUrgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardTag() {
    if (allCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.greenCyanGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'Perfect! You earned +$xpReward XP!',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.goldAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.goldGradient.createShader(bounds),
            child: const Icon(
              Iconsax.flash_15,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Earn +$xpReward XP if you finish today',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.goldAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    if (allCompleted) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Complete all button
        Expanded(
          flex: 2,
          child: _buildActionButton(
            label: 'Complete All',
            icon: Iconsax.tick_square5,
            color: AppColors.accentGreen,
            isPrimary: true,
            onTap: onCompleteAll,
          ),
        ),
        const SizedBox(width: 8),
        // Snooze button
        Expanded(
          child: _buildActionButton(
            label: 'Snooze 2h',
            icon: Iconsax.timer5,
            color: AppColors.accentCyan,
            onTap: onSnooze,
          ),
        ),
        const SizedBox(width: 8),
        // Reschedule button
        Expanded(
          child: _buildActionButton(
            label: 'Reschedule',
            icon: Iconsax.calendar_edit,
            color: Colors.grey,
            onTap: onReschedule,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    bool isPrimary = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.mediumImpact();
          onTap();
        }
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                )
              : null,
          color: isPrimary ? null : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
