import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/habit_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/galaxy_background.dart';

enum TrendRange { week, month, lifetime }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  TrendRange _trendRange = TrendRange.week;

  @override
  Widget build(BuildContext context) {
    return GalaxyBackground(
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          final bestHabits = habitProvider.getBestPerformingHabits();
          final trendData = _computeTrendData(habitProvider);

          return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: _buildStatsCards(context, habitProvider),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: _buildTrendSection(trendData),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: _buildBestHabits(context, bestHabits, habitProvider),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    ),
    );
  }

  List<_TrendDataPoint> _computeTrendData(HabitProvider provider) {
    switch (_trendRange) {
      case TrendRange.week:
        final data = provider.getCompletionsForDays(7);
        final now = DateTime.now();
        return List.generate(7, (i) {
          final date = now.subtract(Duration(days: 6 - i));
          final key = Helpers.formatDateForStorage(date);
          return _TrendDataPoint(
            label: AppConstants.daysOfWeek[date.weekday - 1],
            count: data[key] ?? 0,
          );
        });
      case TrendRange.month:
        final data = provider.getMonthCompletions(DateTime.now());
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return List.generate(daysInMonth, (i) {
          final date = DateTime(now.year, now.month, i + 1);
          final key = Helpers.formatDateForStorage(date);
          return _TrendDataPoint(
            label: '${i + 1}',
            count: data[key] ?? 0,
          );
        });
      case TrendRange.lifetime:
        final data = provider.getLifetimeMonthlyCompletions();
        final entries = data.entries.toList();
        return entries.map((e) {
          final parts = e.key.split('-');
          final monthNum = int.parse(parts[1]);
          final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          return _TrendDataPoint(
            label: months[monthNum],
            count: e.value,
          );
        }).toList();
    }
  }

  Widget _buildTrendSection(List<_TrendDataPoint> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = data.fold(0, (sum, d) => sum + d.count);
    final maxY = data.isEmpty ? 1.0 : data.map((d) => d.count).reduce((a, b) => a > b ? a : b).toDouble();

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
                'Activity Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildRangeChip('Week', TrendRange.week, Icons.calendar_view_week),
                    _buildRangeChip('Month', TrendRange.month, Icons.calendar_view_month),
                    _buildRangeChip('Lifetime', TrendRange.lifetime, Icons.history),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$total completions',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: data.isEmpty
              ? Center(
                  child: Text(
                    'No data yet',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                )
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY > 0 ? maxY * 1.15 : 1,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withAlpha(153)
                                    : Colors.black.withAlpha(153),
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              // Show every Nth label to avoid crowding
                              final step = _trendRange == TrendRange.month ? 5 : 1;
                              if (_trendRange == TrendRange.lifetime || index % step == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    data[index].label,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withAlpha(153)
                                          : Colors.black.withAlpha(153),
                                      fontSize: _trendRange == TrendRange.month ? 8 : 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 0 ? (maxY / 4).ceilToDouble().clamp(1, maxY) : 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDark
                              ? Colors.white.withAlpha(25)
                              : Colors.black.withAlpha(25),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(data.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data[index].count.toDouble(),
                            gradient: AppColors.primaryGradient,
                            width: _trendRange == TrendRange.week
                                ? 24
                                : _trendRange == TrendRange.month
                                    ? 10
                                    : 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY > 0 ? maxY * 1.15 : 1,
                              color: isDark
                                  ? Colors.white.withAlpha(25)
                                  : Colors.black.withAlpha(13),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeChip(String label, TrendRange range, IconData icon) {
    final isSelected = _trendRange == range;
    return GestureDetector(
      onTap: () => setState(() => _trendRange = range),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, HabitProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Completions',
                  provider.totalCompletions.toString(),
                  Icons.check_circle,
                  AppColors.primaryGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Longest Streak',
                  '${provider.longestStreak} days',
                  Icons.local_fire_department,
                  AppColors.pinkOrangeGradient,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Habits',
                  provider.totalHabits.toString(),
                  Icons.list_alt,
                  AppColors.cyanPurpleGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Current Level',
                  'Level ${provider.level}',
                  Icons.star,
                  AppColors.greenCyanGradient,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    LinearGradient gradient,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestHabits(
    BuildContext context,
    List habits,
    HabitProvider provider,
  ) {
    if (habits.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best Performing Habits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...habits.map((habit) {
            final gradient = AppColors.habitGradients[
                habit.colorIndex % AppColors.habitGradients.length];
            final icon = AppConstants.habitIcons[
                habit.iconIndex % AppConstants.habitIcons.length];
            final completionRate = (habit.getCompletionRate() * 100).toInt();

            return GlassContainer(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.currentStreak} streak',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(153),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completionRate%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _TrendDataPoint {
  final String label;
  final int count;

  const _TrendDataPoint({required this.label, required this.count});
}
