import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/habit_provider.dart';
import '../../../data/models/habit_model.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/animated_progress_ring.dart';
import '../../widgets/common/profile_header.dart';
import '../../widgets/common/level_progress.dart';
import '../../widgets/common/motivational_quote_card.dart';
import '../../widgets/habit/habit_list.dart';
import '../../widgets/animations/scale_animation.dart';
import '../add_habit/add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showConfetti() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final user = habitProvider.user;
        final todayHabits = habitProvider.getHabitsForDate(_selectedDate);
        final progress = habitProvider.getTodayProgress();

        // Check for newly unlocked achievements
        if (habitProvider.newlyUnlockedAchievements.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAchievementDialog(context, habitProvider);
          });
        }

        // Check if all habits are completed
        if (habitProvider.isTodayPerfect() && Helpers.isToday(_selectedDate)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showConfetti();
          });
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await habitProvider.init();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Profile Header
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ProfileHeader(
                          user: user,
                          totalHabits: habitProvider.totalHabits,
                          unlockedAchievements: user?.unlockedAchievements.length ?? 0,
                          currentStreak: habitProvider.currentMaxStreak,
                          onTap: () => _showProfileDetails(context, habitProvider),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Date strip
                    _buildDateStrip(context),
                    const SizedBox(height: 24),
                    // Stats row
                    _buildStatsRow(context, habitProvider, progress),
                    const SizedBox(height: 24),
                    // Motivational Quote
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 250),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: MotivationalQuoteCard(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Today's habits title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Helpers.isToday(_selectedDate) 
                                ? "Today's Habits" 
                                : Helpers.formatShortDate(_selectedDate),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${habitProvider.getTodayCompletedCount()}/${todayHabits.length}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Habit list
                    HabitList(
                      habits: todayHabits,
                      date: _selectedDate,
                      onEditHabit: (habit) => _navigateToEditHabit(context, habit),
                    ),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  AppColors.primaryPurple,
                  AppColors.secondaryPink,
                  AppColors.accentCyan,
                  AppColors.accentGreen,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateStrip(BuildContext context) {
    final weekDates = Helpers.getCurrentWeekDates();
    
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 100),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: weekDates.length,
          itemBuilder: (context, index) {
            final date = weekDates[index];
            final isSelected = Helpers.isSameDay(date, _selectedDate);
            final isToday = Helpers.isToday(date);
            
            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
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
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppConstants.daysOfWeek[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, HabitProvider provider, double progress) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Progress ring
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showProgressDetails(context, provider, progress);
                },
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AnimatedProgressRing(
                        progress: progress,
                        size: 60,
                        strokeWidth: 6,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Icon(
                              Icons.touch_app,
                              size: 12,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // XP and Level
            Expanded(
              child: LevelProgressWidget(
                level: provider.level,
                totalXP: provider.totalXP,
                levelProgress: provider.levelProgress,
                onTap: () => _showLevelDetails(context, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditHabit(BuildContext context, HabitModel habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHabitScreen(habitToEdit: habit),
      ),
    );
  }

  void _showAchievementDialog(BuildContext context, HabitProvider provider) {
    final achievements = provider.newlyUnlockedAchievements;
    if (achievements.isEmpty) return;

    provider.clearNewlyUnlockedAchievements();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.primaryGradient.createShader(bounds),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Achievement Unlocked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: achievements.map((id) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                id.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _showProfileDetails(BuildContext context, HabitProvider provider) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Profile Stats',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatRow(context, 'Total Habits', '${provider.totalHabits}', Icons.assignment),
            _buildStatRow(context, 'Total Completions', '${provider.totalCompletions}', Icons.check_circle),
            _buildStatRow(context, 'Current Streak', '${provider.currentMaxStreak} days', Icons.local_fire_department),
            _buildStatRow(context, 'Longest Streak', '${provider.longestStreak} days', Icons.emoji_events),
            _buildStatRow(context, 'Total XP', '${provider.totalXP}', Icons.star),
            _buildStatRow(context, 'Achievements', '${provider.user?.unlockedAchievements.length ?? 0}', Icons.emoji_events),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLevelDetails(BuildContext context, HabitProvider provider) {
    HapticFeedback.mediumImpact();
    
    final xpForNextLevel = AppConstants.xpPerLevel - (provider.totalXP % AppConstants.xpPerLevel);
    final nextLevel = provider.level + 1;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Level icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.cyanPurpleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withAlpha(102),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Colors.white70],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Level ${provider.level}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${provider.totalXP} Total XP',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 24),
            // Progress to next level
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress to Level $nextLevel',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(provider.levelProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: provider.levelProgress,
                      backgroundColor: Theme.of(context).colorScheme.onSurface.withAlpha(25),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.accentCyan,
                      ),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$xpForNextLevel XP until next level',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '💡 Complete habits to earn XP and level up!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showProgressDetails(BuildContext context, HabitProvider provider, double progress) {
    HapticFeedback.mediumImpact();
    
    final todayHabits = provider.getHabitsForDate(_selectedDate);
    final completedCount = provider.getTodayCompletedCount();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Today's Progress",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Progress ring
            AnimatedProgressRing(
              progress: progress,
              size: 120,
              strokeWidth: 12,
            ),
            const SizedBox(height: 24),
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount of ${todayHabits.length} habits completed',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 24),
            if (progress == 1.0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.greenCyanGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.celebration, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      '🎉 Perfect day!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                '💪 Keep going!',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
