import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/habit_model.dart';
import '../../../providers/habit_provider.dart';
import '../common/glass_container.dart';
import 'panic_modal.dart';

class QuitHabitCard extends StatefulWidget {
  final HabitModel habit;

  const QuitHabitCard({
    super.key,
    required this.habit,
  });

  @override
  State<QuitHabitCard> createState() => _QuitHabitCardState();
}

class _QuitHabitCardState extends State<QuitHabitCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update timer every second
    // Note: This triggers a rebuild of the widget every second.
    // For optimization, consider using StreamBuilder or ValueListenable
    // if performance becomes an issue with many quit habits.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.habit.isQuitHabit || widget.habit.quitStartDate == null) {
      return const SizedBox.shrink();
    }

    final timeSinceQuit = DateTime.now().difference(widget.habit.quitStartDate!);
    final days = timeSinceQuit.inDays;
    final hours = timeSinceQuit.inHours % 24;
    final minutes = timeSinceQuit.inMinutes % 60;
    final seconds = timeSinceQuit.inSeconds % 60;

    // Calculate money saved (accounts for partial days)
    final moneySaved = widget.habit.moneySavedPerDay != null
        ? widget.habit.moneySavedPerDay! * (timeSinceQuit.inHours / 24.0)
        : 0.0;

    // Calculate milestones achieved
    final achievedMilestones = AppConstants.quitHabitMilestones
        .where((m) => days >= m)
        .toList();

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with habit name and icon
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.habitGradients[widget.habit.colorIndex],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppConstants.habitIcons[widget.habit.iconIndex],
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Quitting since ${_formatDate(widget.habit.quitStartDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Live timer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentCyan.withAlpha(51),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer,
                      color: AppColors.accentCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Time Clean',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeUnit(days.toString(), 'Days'),
                    _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hrs'),
                    _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Min'),
                    _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Sec'),
                  ],
                ),
              ],
            ),
          ),
          // Money saved (if applicable)
          if (widget.habit.moneySavedPerDay != null && widget.habit.moneySavedPerDay! > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentGreen.withAlpha(51),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.savings,
                    color: AppColors.accentGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Money Saved',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      Text(
                        '\$${moneySaved.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          // Milestones
          if (achievedMilestones.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: achievedMilestones.map((milestone) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.warningGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        milestone == 1 ? '1 Day' : '$milestone Days',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          // Panic button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                _showPanicModal(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emergency, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'I\'m Having an Urge',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.cyanPurpleGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  void _showPanicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PanicModal(habit: widget.habit),
    );
  }
}
