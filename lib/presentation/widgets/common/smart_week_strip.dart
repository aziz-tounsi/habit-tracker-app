import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';

/// Completion state for a day in the week strip
enum DayCompletionState {
  /// All habits completed (green check)
  complete,
  /// Some habits completed (cyan timelapse)
  partial,
  /// No habits completed or habits missed
  missed,
  /// No habits completed or no habits scheduled
  none,
}

/// An enhanced smart week strip widget with gradient pills, completion rings,
/// status dots, navigation arrows, and a "Today" chip.
/// 
/// Features:
/// - Larger gradient pill for selected day with 44px touch targets
/// - Inner completion ring showing progress
/// - Small status dots (done/missed/partial)
/// - Previous/next week arrows
/// - "Today" chip for quick navigation
/// - Glassmorphism/neon gradients for visual polish
class SmartWeekStrip extends StatefulWidget {
  /// The currently selected date
  final DateTime selectedDate;

  /// Callback when a date is selected
  final ValueChanged<DateTime> onSelect;

  /// List of dates for the week (typically 7 days)
  final List<DateTime> weekDates;

  /// Completion state for each date (keyed by date string in yyyy-MM-dd format)
  final Map<String, DayCompletionState> completionByDate;

  /// Completion progress for each date (0.0 to 1.0, keyed by date string)
  final Map<String, double>? completionProgress;

  /// Callback for previous week navigation
  final VoidCallback? onPreviousWeek;

  /// Callback for next week navigation
  final VoidCallback? onNextWeek;

  /// Callback for "Today" chip tap
  final VoidCallback? onTodayTap;

  const SmartWeekStrip({
    super.key,
    required this.selectedDate,
    required this.onSelect,
    required this.weekDates,
    required this.completionByDate,
    this.completionProgress,
    this.onPreviousWeek,
    this.onNextWeek,
    this.onTodayTap,
  });

  @override
  State<SmartWeekStrip> createState() => _SmartWeekStripState();
}

class _SmartWeekStripState extends State<SmartWeekStrip>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop animation when app is in background to save battery
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pulseController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _pulseController.repeat(reverse: true);
    }
  }

  bool get _isCurrentWeek {
    final now = DateTime.now();
    return widget.weekDates.any((date) => Helpers.isToday(date));
  }

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 100),
      child: Column(
        children: [
          // Navigation row with arrows and Today chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous week arrow
                _buildNavigationArrow(
                  icon: Iconsax.arrow_left_2,
                  onTap: widget.onPreviousWeek,
                ),
                // Week indicator with Today chip
                Row(
                  children: [
                    Text(
                      _getWeekLabel(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    if (!_isCurrentWeek) ...[
                      const SizedBox(width: 8),
                      _buildTodayChip(),
                    ],
                  ],
                ),
                // Next week arrow
                _buildNavigationArrow(
                  icon: Iconsax.arrow_right_3,
                  onTap: widget.onNextWeek,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Day pills row
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: widget.weekDates.length,
              itemBuilder: (context, index) {
                final date = widget.weekDates[index];
                return _buildEnhancedDayPill(context, date, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekLabel() {
    if (widget.weekDates.isEmpty) return '';
    final start = widget.weekDates.first;
    final end = widget.weekDates.last;
    return '${Helpers.formatShortDate(start)} - ${Helpers.formatShortDate(end)}';
  }

  Widget _buildNavigationArrow({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null
              ? Colors.white.withOpacity(0.8)
              : Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildTodayChip() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTodayTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.calendar_1,
              size: 14,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'Today',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDayPill(BuildContext context, DateTime date, int index) {
    final isSelected = Helpers.isSameDay(date, widget.selectedDate);
    final isToday = Helpers.isToday(date);
    final dateKey = Helpers.formatDateForStorage(date);
    final completionState = widget.completionByDate[dateKey] ?? DayCompletionState.none;
    final progress = widget.completionProgress?[dateKey] ?? 0.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onSelect(date);
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _pulseAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              // 44px min for touch target, larger when selected
              width: isSelected ? 64 : 48,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                // Larger gradient pill for selected day
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryPurple,
                          AppColors.secondaryPink,
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isToday
                        ? Colors.white.withOpacity(0.08)
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(isSelected ? 20 : 16),
                // Neon glow for selected day
                border: !isSelected && isToday
                    ? Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.5),
                        width: 2,
                      )
                    : !isSelected
                        ? Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1,
                          )
                        : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: AppColors.secondaryPink.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
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
                      fontSize: isSelected ? 11 : 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date number with inner completion ring
                  _buildDateWithRing(
                    date: date,
                    isSelected: isSelected,
                    progress: progress,
                    completionState: completionState,
                  ),
                  const SizedBox(height: 4),
                  // Status dot
                  _buildStatusDot(completionState, isSelected),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateWithRing({
    required DateTime date,
    required bool isSelected,
    required double progress,
    required DayCompletionState completionState,
  }) {
    // Larger size when selected for emphasis
    final size = isSelected ? 36.0 : 28.0;
    final ringWidth = isSelected ? 3.0 : 2.0;
    
    Color ringColor;
    switch (completionState) {
      case DayCompletionState.complete:
        ringColor = AppColors.accentGreen;
        break;
      case DayCompletionState.partial:
        ringColor = AppColors.accentCyan;
        break;
      case DayCompletionState.missed:
        ringColor = AppColors.error;
        break;
      case DayCompletionState.none:
        ringColor = Colors.white.withOpacity(0.2);
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Completion ring (progress indicator)
          if (progress > 0 || completionState != DayCompletionState.none)
            CustomPaint(
              size: Size(size, size),
              painter: _CompletionRingPainter(
                progress: completionState == DayCompletionState.complete
                    ? 1.0
                    : progress.clamp(0.0, 1.0),
                color: isSelected ? Colors.white : ringColor,
                strokeWidth: ringWidth,
                backgroundColor: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
          // Date number
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: isSelected ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(DayCompletionState state, bool isSelected) {
    Color dotColor;
    IconData? icon;
    
    switch (state) {
      case DayCompletionState.complete:
        dotColor = isSelected ? Colors.white : AppColors.accentGreen;
        icon = Icons.check;
        break;
      case DayCompletionState.partial:
        dotColor = isSelected ? Colors.white : AppColors.accentCyan;
        icon = null;
        break;
      case DayCompletionState.missed:
        dotColor = isSelected ? Colors.white.withOpacity(0.6) : AppColors.error;
        icon = Icons.close;
        break;
      case DayCompletionState.none:
        // Subtle neutral dot
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        );
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor.withOpacity(isSelected ? 0.3 : 0.15),
        border: Border.all(
          color: dotColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: icon != null
          ? Icon(
              icon,
              size: 10,
              color: dotColor,
            )
          : Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ),
    );
  }
}

/// Custom painter for the completion ring around the date
class _CompletionRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Color backgroundColor;

  _CompletionRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        2 * math.pi * progress, // Progress angle
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompletionRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
