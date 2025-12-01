import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/bad_habit_model.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/quit/panic_button.dart';

class QuitHabitScreen extends StatefulWidget {
  final BadHabitModel badHabit;

  const QuitHabitScreen({
    super.key,
    required this.badHabit,
  });

  @override
  State<QuitHabitScreen> createState() => _QuitHabitScreenState();
}

class _QuitHabitScreenState extends State<QuitHabitScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Update timer every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.badHabit.daysSinceQuitting;
    final hours = widget.badHabit.hoursSinceQuitting % 24;
    final minutes = widget.badHabit.minutesSinceQuitting % 60;
    final seconds = widget.badHabit.secondsSinceQuitting % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quit ${widget.badHabit.name}'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Edit bad habit
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sobriety Timer
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: GlassContainer(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.badHabit.iconEmoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.block,
                          color: AppColors.error,
                          size: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Time Since Quitting',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimeUnit(days.toString(), 'Days'),
                        _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hours'),
                        _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Mins'),
                        _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Secs'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Panic Button
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 100),
              child: PanicButton(badHabit: widget.badHabit),
            ),
            const SizedBox(height: 20),
            // Money Saved
            if (widget.badHabit.moneySavedPerDay > 0)
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        '💰 Money Saved',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          '\$${widget.badHabit.moneySaved.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'At \$${widget.badHabit.moneySavedPerDay.toStringAsFixed(2)}/day',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Milestones
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏆 Milestones',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMilestoneCard(1, days >= 1),
                  const SizedBox(height: 8),
                  _buildMilestoneCard(3, days >= 3),
                  const SizedBox(height: 8),
                  _buildMilestoneCard(7, days >= 7),
                  const SizedBox(height: 8),
                  _buildMilestoneCard(14, days >= 14),
                  const SizedBox(height: 8),
                  _buildMilestoneCard(30, days >= 30),
                  const SizedBox(height: 8),
                  _buildMilestoneCard(90, days >= 90),
                  const SizedBox(height: 8),
                  _buildMilestoneCard(180, days >= 180),
                  const SizedBox(height: 8),
                  _buildMilestoneCard(365, days >= 365),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Health Benefits
            if (widget.badHabit.healthBenefits.isNotEmpty)
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💪 Health Benefits',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.badHabit.healthBenefits.map((benefit) {
                      final isAchieved = benefit.isAchieved(
                        widget.badHabit.hoursSinceQuitting,
                        widget.badHabit.daysSinceQuitting,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                isAchieved
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isAchieved
                                    ? AppColors.accentGreen
                                    : Colors.white38,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      benefit.hours != null
                                          ? 'After ${benefit.hours} hours'
                                          : 'After ${benefit.days} days',
                                      style: TextStyle(
                                        color: isAchieved
                                            ? Colors.white
                                            : Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      benefit.description,
                                      style: TextStyle(
                                        color: isAchieved
                                            ? Colors.white
                                            : Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(int days, bool achieved) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            achieved ? Icons.emoji_events : Icons.lock,
            color: achieved ? AppColors.warning : Colors.white38,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days == 1 ? '1 Day' : '$days Days',
                  style: TextStyle(
                    color: achieved ? Colors.white : Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (achieved)
                  const Text(
                    'Achieved!',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    'Keep going!',
                    style: TextStyle(
                      color: Colors.white.withAlpha(153),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (achieved)
            const Icon(
              Icons.check_circle,
              color: AppColors.accentGreen,
            ),
        ],
      ),
    );
  }
}
