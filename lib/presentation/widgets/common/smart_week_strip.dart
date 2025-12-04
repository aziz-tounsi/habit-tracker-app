import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';

class SmartWeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Map<DateTime, double> completionByDate;
  final ValueChanged<DateTime>? onDateSelected;

  const SmartWeekStrip({
    super.key,
    required this.selectedDate,
    required this.completionByDate,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final weekDates = Helpers.getCurrentWeekDates();

    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weekDates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = Helpers.isSameDay(date, selectedDate);
          final isToday = Helpers.isToday(date);
          final progress = completionByDate[date] ?? 0;

          return _DayChip(
            date: date,
            isSelected: isSelected,
            isToday: isToday,
            progress: progress,
            onTap: () => onDateSelected?.call(date),
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final double progress;
  final VoidCallback? onTap;

  const _DayChip({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayAbbrev = _dayLabel(date);
    final dateNumber = date.day.toString();
    final badge = _buildBadge();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: 70,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday ? AppColors.primaryPurple.withOpacity(0.4) : Colors.white.withOpacity(0.05),
            width: isToday ? 1.6 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.25),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayAbbrev,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: AppColors.accentCyan,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              dateNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            badge,
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    if (progress >= 0.999) {
      return _Badge(icon: Icons.check_circle, color: AppColors.accentGreen, label: 'Done');
    }
    if (progress > 0) {
      final pct = (progress * 100).clamp(0, 99).toInt();
      return _Badge(icon: Icons.timelapse, color: AppColors.secondaryPink, label: '$pct%');
    }
    return _Badge(icon: Icons.radio_button_unchecked, color: Colors.white.withOpacity(0.35), label: '');
  }

  String _dayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _Badge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: color),
          if (label.isNotEmpty) ...[
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
        ],
      ),
    );
  }
}
