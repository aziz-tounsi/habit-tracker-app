import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Helpers {
  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateForStorage(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime parseStorageDate(String date) {
    return DateFormat('yyyy-MM-dd').parse(date);
  }

  // Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get week start date (Monday)
  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Get week end date (Sunday)
  static DateTime getWeekEnd(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  // Calculate level from XP
  static int calculateLevel(int totalXP) {
    return totalXP ~/ AppConstants.xpPerLevel;
  }

  // Calculate XP progress within current level
  static double calculateLevelProgress(int totalXP) {
    return (totalXP % AppConstants.xpPerLevel) / AppConstants.xpPerLevel;
  }

  // Calculate XP to next level
  static int xpToNextLevel(int totalXP) {
    return AppConstants.xpPerLevel - (totalXP % AppConstants.xpPerLevel);
  }

  // Calculate streak bonus XP
  static int calculateStreakBonus(int streak) {
    if (streak >= 100) return AppConstants.streakBonus100Days;
    if (streak >= 30) return AppConstants.streakBonus30Days;
    if (streak >= 7) return AppConstants.streakBonus7Days;
    return 0;
  }

  // Calculate completion percentage
  static double calculateCompletionPercentage(int completed, int total) {
    if (total == 0) return 0;
    return (completed / total * 100).clamp(0, 100);
  }

  // Get random motivational quote
  static String getRandomQuote() {
    final random = Random();
    return AppConstants.motivationalQuotes[
        random.nextInt(AppConstants.motivationalQuotes.length)];
  }

  // Get day index (0 = Monday, 6 = Sunday)
  static int getDayIndex(DateTime date) {
    return date.weekday - 1;
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  // Check if date is in past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  // Get dates in range
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = start;
    while (current.isBefore(end) || isSameDay(current, end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  // Get current week dates
  static List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    final weekStart = getWeekStart(now);
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  // Get last N days
  static List<DateTime> getLastNDays(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) => now.subtract(Duration(days: n - 1 - i)));
  }

  // Get month dates for calendar/heatmap
  static List<DateTime> getMonthDates(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return getDateRange(firstDay, lastDay);
  }

  // Animate number for display
  static String animateNumber(double progress, int targetNumber) {
    return (progress * targetNumber).toInt().toString();
  }

  // Get ordinal suffix for number
  static String getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  // Lerp colors for gradients
  static Color lerpGradient(List<Color> colors, double t) {
    if (colors.isEmpty) return Colors.transparent;
    if (colors.length == 1) return colors[0];
    
    final scaledT = t * (colors.length - 1);
    final index = scaledT.floor();
    final localT = scaledT - index;
    
    if (index >= colors.length - 1) return colors.last;
    return Color.lerp(colors[index], colors[index + 1], localT) ?? colors[index];
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(10000).toString();
  }
}
