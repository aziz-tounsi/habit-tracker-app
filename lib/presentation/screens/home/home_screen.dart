import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/habit_provider.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/achievement_model.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/premium_profile_header.dart';
import '../../widgets/common/smart_week_strip.dart';
import '../../widgets/common/motivational_quote_card.dart';
import '../../widgets/common/galaxy_background.dart';
import '../../widgets/common/achievements_carousel.dart';
import '../../widgets/common/today_focus_panel.dart';
import '../../widgets/common/day_detail_bottom_sheet.dart';
import '../../widgets/habit/habit_list.dart';
import '../../widgets/quit/quit_habit_card.dart';
import '../add_habit/add_habit_screen.dart';
import '../focus/today_focus_screen.dart';
import '../achievements/dedicated_achievements_screen.dart';
import '../missions/weekly_mission_screen.dart';
import '../calendar/calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _currentWeekDates = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _currentWeekDates = Helpers.getCurrentWeekDates();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showConfetti() {
    _confettiController.play();
  }

  void _goToPreviousWeek() {
    setState(() {
      final firstDayOfCurrentWeek = _currentWeekDates.first;
      final firstDayOfPreviousWeek = firstDayOfCurrentWeek.subtract(const Duration(days: 7));
      _currentWeekDates = List.generate(7, (i) => firstDayOfPreviousWeek.add(Duration(days: i)));
    });
  }

  void _goToNextWeek() {
    setState(() {
      final firstDayOfCurrentWeek = _currentWeekDates.first;
      final firstDayOfNextWeek = firstDayOfCurrentWeek.add(const Duration(days: 7));
      _currentWeekDates = List.generate(7, (i) => firstDayOfNextWeek.add(Duration(days: i)));
    });
  }

  void _goToToday() {
    setState(() {
      _currentWeekDates = Helpers.getCurrentWeekDates();
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final user = habitProvider.user;
        final todayHabits = habitProvider.getHabitsForDate(_selectedDate).where((h) => !h.isQuitHabit).toList();
        final quitHabits = habitProvider.quitHabits;
        final progress = habitProvider.getTodayProgress();
        final weeklyAchievedDays = _computeWeeklyAchievedDays(habitProvider);

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

        return GalaxyBackground(
          child: Stack(
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
                    // Premium Profile Header with enhanced features
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PremiumProfileHeader(
                          user: user,
                          totalHabits: habitProvider.totalHabits,
                          completedToday: habitProvider.getTodayCompletedCount(),
                          totalToday: todayHabits.length,
                          currentStreak: habitProvider.currentMaxStreak,
                          longestStreak: habitProvider.longestStreak,
                          levelProgress: habitProvider.levelProgress,
                          onAvatarTap: () => _showProfileDetails(context, habitProvider),
                          // Weekly mission data
                          weeklyTargetDays: 5,
                          weeklyAchievedDays: weeklyAchievedDays,
                          weeklyRewardXP: 100,
                          // Navigate to weekly mission screen
                          onWeeklyMissionTap: () => _navigateToWeeklyMission(context),
                          // Streak tap opens same sheet as level/progress
                          onStreakTap: () => _showProfileDetails(context, habitProvider),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Enhanced Smart Week Strip with navigation
                    SmartWeekStrip(
                      selectedDate: _selectedDate,
                      onSelect: (date) {
                        setState(() => _selectedDate = date);
                        // Show day detail on long press or double tap - simulated via onSelect for now
                      },
                      weekDates: _currentWeekDates,
                      completionByDate: _computeWeekCompletion(habitProvider),
                      completionProgress: _computeWeekProgress(habitProvider),
                      onPreviousWeek: _goToPreviousWeek,
                      onNextWeek: _goToNextWeek,
                      onTodayTap: _goToToday,
                    ),
                    const SizedBox(height: 24),
                    // NEW: Achievements Carousel
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 150),
                      child: AchievementsCarousel(
                        achievements: _buildAchievementsData(habitProvider),
                        onAchievementTap: (achievement) {
                          // Navigate to dedicated achievements screen
                          HapticFeedback.lightImpact();
                          _navigateToAchievementsPage(context);
                        },
                        onSeeAllTap: () {
                          // Navigate to dedicated achievements screen
                          HapticFeedback.lightImpact();
                          _navigateToAchievementsPage(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // NEW: Today Focus Panel (only shown if there are habits due)
                    if (Helpers.isToday(_selectedDate) && todayHabits.isNotEmpty)
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: TodayFocusPanel(
                          focusHabits: _buildFocusHabitsData(habitProvider, todayHabits),
                          xpReward: 50,
                          onCompleteAll: () => _completeAllHabits(context, habitProvider, todayHabits),
                          onSnooze: () {
                            HapticFeedback.lightImpact();
                            Helpers.showSnackBar(context, 'Snooze feature coming soon!');
                          },
                          onReschedule: () {
                            HapticFeedback.lightImpact();
                            Helpers.showSnackBar(context, 'Reschedule feature coming soon!');
                          },
                          onHabitTap: (habit) => _navigateToEditHabit(context, habit),
                          onHabitToggle: (habit) {
                            habitProvider.toggleHabitCompletion(habit.id, date: _selectedDate);
                          },
                          onHeaderTap: () => _navigateToTodayFocus(context),
                        ),
                      ),
                    if (Helpers.isToday(_selectedDate) && todayHabits.isNotEmpty)
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
                    // Quit Habits Section
                    if (quitHabits.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.block,
                              color: AppColors.error,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Habits I\'m Quitting',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...quitHabits.map((habit) => Padding(
                        padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                        child: QuitHabitCard(habit: habit),
                      )),
                      const SizedBox(height: 24),
                    ],
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
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${habitProvider.getTodayCompletedCount()}/${todayHabits.length}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.6),
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
            // Compact Quick Action Bar for navigation
            Positioned(
              bottom: 16,
              left: 20,
              child: FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 300),
                child: _buildQuickActionBar(context),
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
        ),
      );
      },
    );
  }

  /// Computes completion state for each day in the current week
  Map<String, DayCompletionState> _computeWeekCompletion(HabitProvider habitProvider) {
    final result = <String, DayCompletionState>{};
    
    for (final date in _currentWeekDates) {
      final dateKey = Helpers.formatDateForStorage(date);
      final habitsForDate = habitProvider.getHabitsForDate(date)
          .where((h) => !h.isQuitHabit)
          .toList();
      
      if (habitsForDate.isEmpty) {
        result[dateKey] = DayCompletionState.none;
        continue;
      }
      
      final completedCount = habitsForDate.where((h) => h.isCompletedOn(dateKey)).length;
      
      if (completedCount == habitsForDate.length) {
        result[dateKey] = DayCompletionState.complete;
      } else if (completedCount > 0) {
        result[dateKey] = DayCompletionState.partial;
      } else {
        // Check if day is in past and habits weren't completed
        if (Helpers.isPast(date)) {
          result[dateKey] = DayCompletionState.missed;
        } else {
          result[dateKey] = DayCompletionState.none;
        }
      }
    }
    
    return result;
  }

  /// Computes completion progress (0.0 to 1.0) for each day in the week
  Map<String, double> _computeWeekProgress(HabitProvider habitProvider) {
    final result = <String, double>{};
    
    for (final date in _currentWeekDates) {
      final dateKey = Helpers.formatDateForStorage(date);
      final habitsForDate = habitProvider.getHabitsForDate(date)
          .where((h) => !h.isQuitHabit)
          .toList();
      
      if (habitsForDate.isEmpty) {
        result[dateKey] = 0.0;
        continue;
      }
      
      final completedCount = habitsForDate.where((h) => h.isCompletedOn(dateKey)).length;
      result[dateKey] = completedCount / habitsForDate.length;
    }
    
    return result;
  }

  /// Computes weekly achieved days (days where all habits were completed)
  int _computeWeeklyAchievedDays(HabitProvider habitProvider) {
    int achievedDays = 0;
    
    for (final date in _currentWeekDates) {
      final dateKey = Helpers.formatDateForStorage(date);
      final habitsForDate = habitProvider.getHabitsForDate(date)
          .where((h) => !h.isQuitHabit)
          .toList();
      
      if (habitsForDate.isEmpty) continue;
      
      final completedCount = habitsForDate.where((h) => h.isCompletedOn(dateKey)).length;
      if (completedCount == habitsForDate.length) {
        achievedDays++;
      }
    }
    
    return achievedDays;
  }

  /// Build achievements data for the carousel
  List<AchievementCardData> _buildAchievementsData(HabitProvider habitProvider) {
    final unlockedAchievements = habitProvider.user?.unlockedAchievements ?? [];
    final allAchievements = AchievementModel.allAchievements;
    
    // Get next 3 achievements to show (prioritize in-progress ones)
    final achievementsToShow = <AchievementCardData>[];
    
    for (final achievement in allAchievements.take(5)) {
      final isUnlocked = unlockedAchievements.contains(achievement.id);
      double progress = 0.0;
      String? nextUnlockHint;
      
      // Calculate progress based on achievement type
      if (achievement.requirement != null) {
        switch (achievement.category) {
          case AchievementCategory.streaks:
            progress = (habitProvider.currentMaxStreak / achievement.requirement!).clamp(0.0, 1.0);
            if (!isUnlocked) {
              final remaining = achievement.requirement! - habitProvider.currentMaxStreak;
              nextUnlockHint = '$remaining more days';
            }
            break;
          case AchievementCategory.completions:
            progress = (habitProvider.totalCompletions / achievement.requirement!).clamp(0.0, 1.0);
            if (!isUnlocked) {
              final remaining = achievement.requirement! - habitProvider.totalCompletions;
              nextUnlockHint = '$remaining more completions';
            }
            break;
          case AchievementCategory.habits:
            progress = (habitProvider.totalHabits / achievement.requirement!).clamp(0.0, 1.0);
            if (!isUnlocked) {
              final remaining = achievement.requirement! - habitProvider.totalHabits;
              nextUnlockHint = 'Create $remaining more habits';
            }
            break;
          case AchievementCategory.milestones:
            if (achievement.id.startsWith('level_')) {
              progress = (habitProvider.level / achievement.requirement!).clamp(0.0, 1.0);
              if (!isUnlocked) {
                final remaining = achievement.requirement! - habitProvider.level;
                nextUnlockHint = '$remaining levels to go';
              }
            }
            break;
        }
      } else {
        // For milestones without requirements (like perfect_day)
        if (achievement.id == 'perfect_day') {
          final todayProgress = habitProvider.getTodayProgress();
          progress = todayProgress;
          if (!isUnlocked && progress < 1.0) {
            final remaining = habitProvider.todayHabits.length - habitProvider.getTodayCompletedCount();
            nextUnlockHint = 'Complete $remaining more habits today';
          }
        }
      }
      
      achievementsToShow.add(AchievementCardData(
        id: achievement.id,
        name: achievement.name,
        icon: achievement.icon,
        gradientColors: achievement.gradientColors,
        progress: isUnlocked ? 1.0 : progress,
        isUnlocked: isUnlocked,
        nextUnlockHint: nextUnlockHint,
        xpReward: achievement.xpReward,
      ));
      
      if (achievementsToShow.length >= 3) break;
    }
    
    return achievementsToShow;
  }

  /// Build focus habits data for the Today Focus Panel
  List<FocusHabitData> _buildFocusHabitsData(HabitProvider habitProvider, List<HabitModel> habits) {
    final dateKey = Helpers.formatDateForStorage(_selectedDate);
    final now = DateTime.now();
    
    return habits.map((habit) {
      final isCompleted = habit.isCompletedOn(dateKey);
      
      // Determine urgency (habits with reminders that are overdue)
      bool isUrgent = false;
      String? dueTime;
      
      // Habits are only urgent for today's view
      if (Helpers.isToday(_selectedDate) && habit.reminderTime != null && !isCompleted) {
        try {
          final parts = habit.reminderTime!.split(':');
          final reminderHour = int.parse(parts[0]);
          final reminderMinute = int.parse(parts[1]);
          dueTime = habit.reminderTime;
          
          // If current time is past reminder time, it's urgent
          if (now.hour > reminderHour || 
              (now.hour == reminderHour && now.minute > reminderMinute)) {
            isUrgent = true;
          }
        } catch (e) {
          // Invalid time format, ignore
        }
      }
      
      return FocusHabitData(
        habit: habit,
        isCompleted: isCompleted,
        isUrgent: isUrgent,
        dueTime: dueTime,
      );
    }).toList();
  }

  /// Complete all habits for the day
  void _completeAllHabits(BuildContext context, HabitProvider habitProvider, List<HabitModel> habits) {
    HapticFeedback.heavyImpact();
    
    for (final habit in habits) {
      final dateKey = Helpers.formatDateForStorage(_selectedDate);
      if (!habit.isCompletedOn(dateKey)) {
        habitProvider.toggleHabitCompletion(habit.id, date: _selectedDate);
      }
    }
    
    _showConfetti();
    Helpers.showSnackBar(context, 'All habits completed! 🎉');
  }

  /// Show day details bottom sheet
  void _showDayDetails(BuildContext context, HabitProvider habitProvider) {
    final habits = habitProvider.getHabitsForDate(_selectedDate)
        .where((h) => !h.isQuitHabit)
        .toList();
    final dateKey = Helpers.formatDateForStorage(_selectedDate);
    
    final completionStates = <String, bool>{};
    for (final habit in habits) {
      completionStates[habit.id] = habit.isCompletedOn(dateKey);
    }
    
    DayDetailBottomSheet.show(
      context: context,
      date: _selectedDate,
      habits: habits,
      completionStates: completionStates,
      currentStreak: habitProvider.currentMaxStreak,
      onToggleCompletion: (habit, completed) {
        habitProvider.toggleHabitCompletion(habit.id, date: _selectedDate);
        Navigator.pop(context);
        _showDayDetails(context, habitProvider); // Refresh
      },
      onSkip: (habit) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, 'Skip feature coming soon!');
      },
      onSnooze: (habit) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, 'Snooze feature coming soon!');
      },
      onReschedule: (habit) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, 'Reschedule feature coming soon!');
      },
      onCompleteAll: () {
        for (final habit in habits) {
          if (!completionStates[habit.id]!) {
            habitProvider.toggleHabitCompletion(habit.id, date: _selectedDate);
          }
        }
        Navigator.pop(context);
        _showConfetti();
      },
    );
  }

  /// Build compact floating quick-action bar for navigation
  Widget _buildQuickActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickActionItem(
            icon: Iconsax.task_square5,
            label: 'Focus',
            color: AppColors.primaryPurple,
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to dedicated Today's Focus page
              _navigateToTodayFocus(context);
            },
          ),
          const SizedBox(width: 4),
          _buildQuickActionItem(
            icon: Iconsax.calendar_1,
            label: 'Calendar',
            color: AppColors.accentCyan,
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to Calendar screen
              _navigateToCalendar(context);
            },
          ),
          const SizedBox(width: 4),
          _buildQuickActionItem(
            icon: Iconsax.medal_star5,
            label: 'Awards',
            color: AppColors.goldAccent,
            onTap: () {
              HapticFeedback.lightImpact();
              // Navigate to dedicated achievements page
              _navigateToAchievementsPage(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAchievementsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DedicatedAchievementsScreen(),
      ),
    );
  }

  void _navigateToTodayFocus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TodayFocusScreen(),
      ),
    );
  }

  void _navigateToWeeklyMission(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WeeklyMissionScreen(),
      ),
    );
  }

  void _navigateToCalendar(BuildContext context) {
    // Navigate to calendar - it's also accessible from bottom navigation
    // CalendarScreen has its own header
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarScreen(),
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
                  AppColors.goldGradient.createShader(bounds),
              child: const Icon(
                Icons.stars,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Achievement Unlocked!',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: achievements.map((id) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    id.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
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
        decoration: const BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile Stats',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatRow(context, 'Total Habits', '${provider.totalHabits}', Icons.assignment),
            _buildStatRow(context, 'Total Completions', '${provider.totalCompletions}', Icons.check_circle),
            _buildStatRow(context, 'Current Streak', '${provider.currentMaxStreak} days', Icons.local_fire_department),
            _buildStatRow(context, 'Longest Streak', '${provider.longestStreak} days', Icons.military_tech),
            _buildStatRow(context, 'Total XP', '${provider.totalXP}', Icons.star),
            _buildStatRow(context, 'Achievements', '${provider.user?.unlockedAchievements.length ?? 0}', Icons.stars),
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
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
