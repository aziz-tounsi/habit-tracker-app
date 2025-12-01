import 'package:flutter/material.dart';
import '../../../core/utils/helpers.dart';
import '../common/glass_container.dart';

class HeatMap extends StatelessWidget {
  final Map<String, int> completions;
  final DateTime month;
  final int maxHabitsPerDay;

  const HeatMap({
    super.key,
    required this.completions,
    required this.month,
    this.maxHabitsPerDay = 5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final startingWeekday = firstDayOfMonth.weekday - 1; // 0 = Monday

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Heatmap',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                Helpers.formatShortDate(month),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => SizedBox(
                      width: 36,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: startingWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox();
              }

              final day = index - startingWeekday + 1;
              final date = DateTime(month.year, month.month, day);
              final dateKey = Helpers.formatDateForStorage(date);
              final count = completions[dateKey] ?? 0;
              final intensity = maxHabitsPerDay > 0
                  ? (count / maxHabitsPerDay).clamp(0.0, 1.0)
                  : 0.0;

              return _buildDayCell(context, day, intensity, isDark);
            },
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
              ),
              const SizedBox(width: 8),
              for (var i = 0; i <= 4; i++)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _getIntensityColor(i / 4, isDark),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                'More',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
      BuildContext context, int day, double intensity, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _getIntensityColor(intensity, isDark),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: intensity > 0.5
                ? Colors.white
                : (isDark ? Colors.white.withAlpha(153) : Colors.black.withAlpha(153)),
          ),
        ),
      ),
    );
  }

  Color _getIntensityColor(double intensity, bool isDark) {
    if (intensity == 0) {
      return isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(13);
    }

    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF8B85FF),
      Color(0xFFABA6FF),
      Color(0xFFCBC8FF),
    ];

    final index = ((1 - intensity) * (colors.length - 1)).round();
    return colors[index.clamp(0, colors.length - 1)];
  }
}
