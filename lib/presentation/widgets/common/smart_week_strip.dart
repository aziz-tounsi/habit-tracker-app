import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';

/// Completion state for a day in the week strip
enum DayCompletionState {
  /// All habits completed (green check)
  complete,
  /// Some habits completed (cyan timelapse)
  partial,
  /// No habits completed or no habits scheduled
  none,
}

/// A smart week strip widget that shows per-day completion status.
/// 
/// Features:
/// - Day abbreviation and date number
/// - Completion badge showing state: complete (green check), partial (cyan timelapse), none (neutral)
/// - Today highlight
/// - Tap-to-select callback
class SmartWeekStrip extends StatelessWidget {
  /// The currently selected date
  final DateTime selectedDate;

  /// Callback when a date is selected
  final ValueChanged<DateTime> onSelect;

  /// List of dates for the week (typically 7 days)
  final List<DateTime> weekDates;

  /// Completion state for each date (keyed by date string in yyyy-MM-dd format)
  final Map<String, DayCompletionState> completionByDate;

  const SmartWeekStrip({
    super.key,
    required this.selectedDate,
    required this.onSelect,
    required this.weekDates,
    required this.completionByDate,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 100),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: weekDates.length,
          itemBuilder: (context, index) {
            final date = weekDates[index];
            return _buildDayItem(context, date, index);
          },
        ),
      ),
    );
  }

  Widget _buildDayItem(BuildContext context, DateTime date, int index) {
    final isSelected = Helpers.isSameDay(date, selectedDate);
    final isToday = Helpers.isToday(date);
    final dateKey = Helpers.formatDateForStorage(date);
    final completionState = completionByDate[dateKey] ?? DayCompletionState.none;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onSelect(date);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isToday && !isSelected
              ? Border.all(
                  color: AppColors.primaryPurple.withAlpha(76),
                  width: 2,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withAlpha(76),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day abbreviation
            Text(
              AppConstants.daysOfWeek[index],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            // Date number
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 6),
            // Completion badge
            _buildCompletionBadge(completionState, isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionBadge(DayCompletionState state, bool isSelected) {
    IconData? icon;
    Color? color;
    Color? bgColor;

    switch (state) {
      case DayCompletionState.complete:
        icon = Icons.check;
        color = isSelected ? Colors.white : AppColors.accentGreen;
        bgColor = isSelected 
            ? Colors.white.withOpacity(0.2) 
            : AppColors.accentGreen.withOpacity(0.15);
        break;
      case DayCompletionState.partial:
        icon = Icons.timelapse;
        color = isSelected ? Colors.white : AppColors.accentCyan;
        bgColor = isSelected 
            ? Colors.white.withOpacity(0.2) 
            : AppColors.accentCyan.withOpacity(0.15);
        break;
      case DayCompletionState.none:
        // Show a subtle neutral indicator
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected 
                ? Colors.white.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
          ),
        );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: Icon(
        icon,
        size: 12,
        color: color,
      ),
    );
  }
}
