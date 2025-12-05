import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';

class HabitRepository {
  static const String _habitsBoxName = AppConstants.habitsBox;
  static const String _userBoxName = AppConstants.userBox;

  late Box<HabitModel> _habitsBox;
  late Box<UserModel> _userBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Open boxes
    _habitsBox = await Hive.openBox<HabitModel>(_habitsBoxName);
    _userBox = await Hive.openBox<UserModel>(_userBoxName);
  }

  // User operations
  UserModel? getUser() {
    if (_userBox.isEmpty) return null;
    return _userBox.get('currentUser');
  }

  Future<void> saveUser(UserModel user) async {
    await _userBox.put('currentUser', user);
  }

  Future<UserModel> createDefaultUser() async {
    final user = UserModel(
      id: Helpers.generateId(),
      name: 'User',
      avatarEmoji: '😊',
      hasCompletedOnboarding: false,
    );
    await saveUser(user);
    return user;
  }

  Future<void> updateUserXP(int xpToAdd) async {
    final user = getUser();
    if (user != null) {
      user.addXP(xpToAdd);
      await user.save();
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    final user = getUser();
    if (user != null && !user.hasAchievement(achievementId)) {
      user.unlockAchievement(achievementId);
      await user.save();
    }
  }

  // Habit operations
  List<HabitModel> getAllHabits() {
    return _habitsBox.values.where((h) => !h.isArchived).toList();
  }

  List<HabitModel> getArchivedHabits() {
    return _habitsBox.values.where((h) => h.isArchived).toList();
  }

  List<HabitModel> getHabitsForToday() {
    final today = DateTime.now().weekday - 1; // 0 = Monday
    return getAllHabits().where((h) => h.isScheduledFor(today)).toList();
  }

  List<HabitModel> getHabitsForDate(DateTime date) {
    final dayIndex = date.weekday - 1;
    return getAllHabits().where((h) => h.isScheduledFor(dayIndex)).toList();
  }

  HabitModel? getHabitById(String id) {
    try {
      return _habitsBox.values.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addHabit(HabitModel habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> updateHabit(HabitModel habit) async {
    await habit.save();
  }

  Future<void> deleteHabit(String id) async {
    await _habitsBox.delete(id);
  }

  Future<void> archiveHabit(String id) async {
    final habit = getHabitById(id);
    if (habit != null) {
      habit.isArchived = true;
      await habit.save();
    }
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final habit = getHabitById(habitId);
    if (habit != null) {
      final dateKey = Helpers.formatDateForStorage(date);
      if (habit.isCompletedOn(dateKey)) {
        habit.markIncomplete(dateKey);
      } else {
        habit.markComplete(dateKey);
      }
      await habit.save();
    }
  }

  // Statistics
  int getTotalCompletions() {
    return getAllHabits().fold(0, (sum, h) => sum + h.totalCompletions);
  }

  int getLongestStreak() {
    if (getAllHabits().isEmpty) return 0;
    return getAllHabits().map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
  }

  int getCurrentMaxStreak() {
    if (getAllHabits().isEmpty) return 0;
    return getAllHabits().map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  }

  Map<String, int> getWeeklyCompletions() {
    final weekDates = Helpers.getCurrentWeekDates();
    final completions = <String, int>{};
    
    for (var date in weekDates) {
      final dateKey = Helpers.formatDateForStorage(date);
      int count = 0;
      for (var habit in getAllHabits()) {
        if (habit.isCompletedOn(dateKey)) count++;
      }
      completions[dateKey] = count;
    }
    
    return completions;
  }

  Map<String, double> getWeeklyCompletionRates() {
    final weekDates = Helpers.getCurrentWeekDates();
    final rates = <String, double>{};
    
    for (var date in weekDates) {
      final dateKey = Helpers.formatDateForStorage(date);
      final dayIndex = date.weekday - 1;
      final scheduledHabits = getAllHabits().where((h) => h.isScheduledFor(dayIndex)).toList();
      
      if (scheduledHabits.isEmpty) {
        rates[dateKey] = 0;
      } else {
        int completed = scheduledHabits.where((h) => h.isCompletedOn(dateKey)).length;
        rates[dateKey] = completed / scheduledHabits.length;
      }
    }
    
    return rates;
  }

  List<HabitModel> getBestPerformingHabits({int limit = 5}) {
    final habits = getAllHabits();
    habits.sort((a, b) => b.getCompletionRate().compareTo(a.getCompletionRate()));
    return habits.take(limit).toList();
  }

  // Check achievements
  Future<List<String>> checkAndUnlockAchievements() async {
    final user = getUser();
    if (user == null) return [];

    final newlyUnlocked = <String>[];
    final habits = getAllHabits();
    final totalCompletions = getTotalCompletions();
    final longestStreak = getLongestStreak();

    // First habit
    if (habits.isNotEmpty && !user.hasAchievement('first_habit')) {
      user.unlockAchievement('first_habit');
      newlyUnlocked.add('first_habit');
    }

    // Habit count achievements
    if (habits.length >= 5 && !user.hasAchievement('habits_5')) {
      user.unlockAchievement('habits_5');
      newlyUnlocked.add('habits_5');
    }
    if (habits.length >= 10 && !user.hasAchievement('habits_10')) {
      user.unlockAchievement('habits_10');
      newlyUnlocked.add('habits_10');
    }

    // First completion
    if (totalCompletions >= 1 && !user.hasAchievement('first_completion')) {
      user.unlockAchievement('first_completion');
      newlyUnlocked.add('first_completion');
    }

    // Completion count achievements
    if (totalCompletions >= 10 && !user.hasAchievement('completions_10')) {
      user.unlockAchievement('completions_10');
      newlyUnlocked.add('completions_10');
    }
    if (totalCompletions >= 50 && !user.hasAchievement('completions_50')) {
      user.unlockAchievement('completions_50');
      newlyUnlocked.add('completions_50');
    }
    if (totalCompletions >= 100 && !user.hasAchievement('completions_100')) {
      user.unlockAchievement('completions_100');
      newlyUnlocked.add('completions_100');
    }
    if (totalCompletions >= 500 && !user.hasAchievement('completions_500')) {
      user.unlockAchievement('completions_500');
      newlyUnlocked.add('completions_500');
    }

    // Streak achievements
    if (longestStreak >= 7 && !user.hasAchievement('streak_7')) {
      user.unlockAchievement('streak_7');
      newlyUnlocked.add('streak_7');
    }
    if (longestStreak >= 30 && !user.hasAchievement('streak_30')) {
      user.unlockAchievement('streak_30');
      newlyUnlocked.add('streak_30');
    }
    if (longestStreak >= 100 && !user.hasAchievement('streak_100')) {
      user.unlockAchievement('streak_100');
      newlyUnlocked.add('streak_100');
    }

    // Level achievements
    if (user.level >= 5 && !user.hasAchievement('level_5')) {
      user.unlockAchievement('level_5');
      newlyUnlocked.add('level_5');
    }
    if (user.level >= 10 && !user.hasAchievement('level_10')) {
      user.unlockAchievement('level_10');
      newlyUnlocked.add('level_10');
    }
    if (user.level >= 25 && !user.hasAchievement('level_25')) {
      user.unlockAchievement('level_25');
      newlyUnlocked.add('level_25');
    }

    // Perfect day check
    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    final todayHabits = getHabitsForToday();
    if (todayHabits.isNotEmpty && 
        todayHabits.every((h) => h.isCompletedOn(todayKey)) && 
        !user.hasAchievement('perfect_day')) {
      user.unlockAchievement('perfect_day');
      newlyUnlocked.add('perfect_day');
    }

    if (newlyUnlocked.isNotEmpty) {
      await user.save();
    }

    return newlyUnlocked;
  }

  // Get month completions for heatmap
  Map<String, int> getMonthCompletions(DateTime month) {
    final dates = Helpers.getMonthDates(month);
    final completions = <String, int>{};
    
    for (var date in dates) {
      final dateKey = Helpers.formatDateForStorage(date);
      int count = 0;
      for (var habit in getAllHabits()) {
        if (habit.isCompletedOn(dateKey)) count++;
      }
      completions[dateKey] = count;
    }
    
    return completions;
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _habitsBox.clear();
    await _userBox.clear();
  }
}
