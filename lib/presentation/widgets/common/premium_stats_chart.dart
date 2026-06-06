import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class PremiumStatsChart extends StatelessWidget {
  final List<double> weekData;
  final String selectedPeriod;

  static const List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  const PremiumStatsChart({
    super.key,
    required this.weekData,
    this.selectedPeriod = 'Week',
  });

  List<String> _getLabels() {
    switch (selectedPeriod) {
      case 'Week':
        return List.generate(weekData.length, (i) => _daysOfWeek[i % 7]);
      case 'Month':
        return List.generate(weekData.length, (i) => '${i + 1}');
      default:
        final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final now = DateTime.now();
        return List.generate(weekData.length, (i) {
          final m = DateTime(now.year, now.month - (weekData.length - 1 - i), 1);
          return months[m.month];
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = _getLabels();
    final maxY = weekData.isEmpty
        ? 1.0
        : weekData.reduce((a, b) => a > b ? a : b).ceilToDouble().clamp(1, double.infinity);
    final isMonth = selectedPeriod == 'Month';

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: weekData.isEmpty || weekData.every((d) => d == 0)
          ? Center(
              child: Text(
                'No activity yet',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              ),
            )
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          final step = isMonth ? 5 : 1;
                          if (selectedPeriod == 'Lifetime' || index % step == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[index],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: isMonth ? 8 : 10,
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1);
                  },
                ),
                barGroups: List.generate(weekData.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: weekData[index],
                        gradient: AppColors.primaryGradient,
                        width: selectedPeriod == 'Week' ? 24 : (isMonth ? 8 : 20),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY * 1.2,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
    );
  }
}

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  static const List<String> _periods = ['Week', 'Month', 'Lifetime'];

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}