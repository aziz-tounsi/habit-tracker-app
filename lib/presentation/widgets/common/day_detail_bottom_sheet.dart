import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/habit_model.dart';

/// Extended day detail bottom sheet with streak impact text and
/// per-habit quick actions (done/skip/snooze/reschedule).
class DayDetailBottomSheet extends StatelessWidget {
  /// The date for which to show details
  final DateTime date;

  /// List of habits for this day
  final List<HabitModel> habits;

  /// Completion states for habits (keyed by habit id)
  final Map<String, bool> completionStates;

  /// Current streak count
  final int currentStreak;

  /// Callback when habit completion is toggled
  final void Function(HabitModel habit, bool completed)? onToggleCompletion;

  /// Callback when a habit is skipped
  final ValueChanged<HabitModel>? onSkip;

  /// Callback when a habit is snoozed
  final ValueChanged<HabitModel>? onSnooze;

  /// Callback when a habit is rescheduled
  final ValueChanged<HabitModel>? onReschedule;

  /// Callback when all habits are completed
  final VoidCallback? onCompleteAll;

  const DayDetailBottomSheet({
    super.key,
    required this.date,
    required this.habits,
    required this.completionStates,
    this.currentStreak = 0,
    this.onToggleCompletion,
    this.onSkip,
    this.onSnooze,
    this.onReschedule,
    this.onCompleteAll,
  });

  int get _completedCount =>
      completionStates.values.where((v) => v).length;
  int get _totalCount => habits.length;
  double get _progress =>
      _totalCount > 0 ? _completedCount / _totalCount : 0.0;
  bool get _isAllComplete => _totalCount > 0 && _completedCount == _totalCount;
  bool get _isToday => Helpers.isToday(date);

  String get _streakImpactText {
    if (_isAllComplete) {
      if (_isToday) {
        return currentStreak > 0
            ? '🔥 You\'re on a ${currentStreak + 1} day streak after today!'
            : '🔥 Start a new streak today!';
      }
      return '✅ Perfect day completed!';
    } else if (_progress > 0) {
      if (_isToday && currentStreak > 0) {
        return '⚠️ Complete all habits to keep your $currentStreak day streak!';
      }
      return '💪 ${_completedCount}/$_totalCount done - keep going!';
    } else {
      if (_isToday && currentStreak > 0) {
        return '🔴 Don\'t break your $currentStreak day streak!';
      }
      return '📋 No habits completed yet';
    }
  }

  /// Show the bottom sheet
  static Future<void> show({
    required BuildContext context,
    required DateTime date,
    required List<HabitModel> habits,
    required Map<String, bool> completionStates,
    int currentStreak = 0,
    void Function(HabitModel habit, bool completed)? onToggleCompletion,
    ValueChanged<HabitModel>? onSkip,
    ValueChanged<HabitModel>? onSnooze,
    ValueChanged<HabitModel>? onReschedule,
    VoidCallback? onCompleteAll,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DayDetailBottomSheet(
        date: date,
        habits: habits,
        completionStates: completionStates,
        currentStreak: currentStreak,
        onToggleCompletion: onToggleCompletion,
        onSkip: onSkip,
        onSnooze: onSnooze,
        onReschedule: onReschedule,
        onCompleteAll: onCompleteAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildHeader(context),
          ),
          // Streak impact banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildStreakImpactBanner(),
          ),
          const SizedBox(height: 16),
          // Complete all button (if not all done and is today)
          if (_isToday && !_isAllComplete && onCompleteAll != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCompleteAllButton(),
            ),
          if (_isToday && !_isAllComplete && onCompleteAll != null)
            const SizedBox(height: 16),
          // Habits list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final isCompleted = completionStates[habit.id] ?? false;
                return _buildHabitItem(context, habit, isCompleted);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Date display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: _isToday ? AppColors.primaryGradient : null,
            color: _isToday ? null : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                AppConstants.daysOfWeek[date.weekday - 1],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isToday ? Colors.white : Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Date info and progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isToday ? 'Today' : Helpers.formatDate(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  // Progress bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isAllComplete
                              ? AppColors.accentGreen
                              : AppColors.accentCyan,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_completedCount/$_totalCount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isAllComplete
                          ? AppColors.accentGreen
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Close button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.close,
              size: 20,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakImpactBanner() {
    Color bannerColor;
    Color bgColor;

    if (_isAllComplete) {
      bannerColor = AppColors.accentGreen;
      bgColor = AppColors.accentGreen.withOpacity(0.15);
    } else if (_progress > 0) {
      bannerColor = AppColors.accentCyan;
      bgColor = AppColors.accentCyan.withOpacity(0.15);
    } else if (_isToday && currentStreak > 0) {
      bannerColor = AppColors.warning;
      bgColor = AppColors.warning.withOpacity(0.15);
    } else {
      bannerColor = Colors.white.withOpacity(0.6);
      bgColor = Colors.white.withOpacity(0.05);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bannerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAllComplete
                ? Icons.local_fire_department
                : _progress > 0
                    ? Icons.trending_up
                    : _isToday && currentStreak > 0
                        ? Icons.warning_amber
                        : Icons.calendar_today,
            size: 20,
            color: bannerColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _streakImpactText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: bannerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteAllButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onCompleteAll?.call();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.greenCyanGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.tick_square5,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Complete All',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItem(
      BuildContext context, HabitModel habit, bool isCompleted) {
    // Get habit color safely
    final habitColorIndex =
        habit.colorIndex.clamp(0, AppColors.habitColors.length - 1);
    final habitColor = AppColors.habitColors[habitColorIndex];
    // Get habit icon safely
    final habitIconIndex =
        habit.iconIndex.clamp(0, AppConstants.habitIcons.length - 1);
    final habitIcon = AppConstants.habitIcons[habitIconIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.accentGreen.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.accentGreen.withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Main habit row
          Row(
            children: [
              // Toggle button with haptics
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onToggleCompletion?.call(habit, !isCompleted);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isCompleted
                        ? LinearGradient(
                            colors: [
                              AppColors.accentGreen,
                              AppColors.accentGreen.withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isCompleted ? null : Colors.white.withOpacity(0.1),
                    border: isCompleted
                        ? null
                        : Border.all(
                            color: habitColor.withOpacity(0.5),
                            width: 2,
                          ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : habitIcon,
                    size: isCompleted ? 22 : 20,
                    color: isCompleted
                        ? Colors.white
                        : habitColor.withOpacity(0.8),
                  ),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (habit.description != null &&
                        habit.description!.isNotEmpty)
                      Text(
                        habit.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    // Streak info
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: habit.currentStreak > 0
                              ? Colors.orange
                              : Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak} day streak',
                          style: TextStyle(
                            fontSize: 11,
                            color: habit.currentStreak > 0
                                ? Colors.orange.withOpacity(0.8)
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Quick actions row (only if not completed and is today)
          if (_isToday && !isCompleted) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: Colors.white.withOpacity(0.08),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  icon: Iconsax.tick_circle5,
                  label: 'Done',
                  color: AppColors.accentGreen,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onToggleCompletion?.call(habit, true);
                  },
                ),
                _buildQuickAction(
                  icon: Iconsax.slash,
                  label: 'Skip',
                  color: Colors.grey,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSkip?.call(habit);
                  },
                ),
                _buildQuickAction(
                  icon: Iconsax.timer5,
                  label: 'Snooze',
                  color: AppColors.accentCyan,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSnooze?.call(habit);
                  },
                ),
                _buildQuickAction(
                  icon: Iconsax.calendar_edit,
                  label: 'Reschedule',
                  color: AppColors.primaryPurple,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onReschedule?.call(habit);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
