import 'package:flutter/material.dart';
import '../data/models/habit_model.dart';
import '../data/models/user_model.dart';
import '../data/models/achievement_model.dart';
import '../data/repositories/habit_repository.dart';
import '../data/services/notification_service.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  final NotificationService _notificationService = NotificationService();

  List<HabitModel> _habits = [];
  UserModel? _user;
  bool _isLoading = true;
  String? _error;
  List<String> _newlyUnlockedAchievements = [];

  // Getters
  List<HabitModel> get habits => _habits;
  List<HabitModel> get todayHabits => _repository.getHabitsForToday();
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get newlyUnlockedAchievements => _newlyUnlockedAchievements;
  bool get hasCompletedOnboarding => _user?.hasCompletedOnboarding ?? false;

  // Statistics
  int get totalHabits => _habits.length;
  int get totalCompletions => _repository.getTotalCompletions();
  int get longestStreak => _repository.getLongestStreak();
  int get currentMaxStreak => _repository.getCurrentMaxStreak();
  int get totalXP => _user?.totalXP ?? 0;
  int get level => _user?.level ?? 0;
  double get levelProgress => _user?.levelProgress ?? 0;

  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.init();
      await _notificationService.init();

      _user = _repository.getUser();
      if (_user == null) {
        _user = await _repository.createDefaultUser();
      }

      _habits = _repository.getAllHabits();
      _isLoading = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  // User operations
  Future<void> updateUser({
    String? name,
    String? avatarEmoji,
    bool? isDarkMode,
    int? accentColorIndex,
    bool? notificationsEnabled,
  }) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      name: name,
      avatarEmoji: avatarEmoji,
      isDarkMode: isDarkMode,
      accentColorIndex: accentColorIndex,
      notificationsEnabled: notificationsEnabled,
    );

    await _repository.saveUser(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    if (_user == null) return;

    _user = _user!.copyWith(hasCompletedOnboarding: true);
    await _repository.saveUser(_user!);
    notifyListeners();
  }

  // Habit operations
  Future<void> addHabit({
    required String name,
    String? description,
    required int iconIndex,
    required int colorIndex,
    required String category,
    required List<int> scheduledDays,
    required int targetDaysPerWeek,
    String? reminderTime,
  }) async {
    final habit = HabitModel(
      id: Helpers.generateId(),
      name: name,
      description: description,
      iconIndex: iconIndex,
      colorIndex: colorIndex,
      category: category,
      scheduledDays: scheduledDays,
      targetDaysPerWeek: targetDaysPerWeek,
      createdAt: DateTime.now(),
      reminderTime: reminderTime,
    );

    await _repository.addHabit(habit);
    _habits = _repository.getAllHabits();

    // Schedule notification if reminder time is set
    if (reminderTime != null && _user?.notificationsEnabled == true) {
      await _notificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        time: reminderTime,
        days: scheduledDays,
      );
    }

    // Check for new achievements
    await _checkAchievements();
    
    notifyListeners();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _repository.updateHabit(habit);
    _habits = _repository.getAllHabits();

    // Update notification if needed
    if (habit.reminderTime != null && _user?.notificationsEnabled == true) {
      await _notificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        time: habit.reminderTime!,
        days: habit.scheduledDays,
      );
    } else {
      await _notificationService.cancelNotification(habit.id.hashCode);
    }

    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    await _repository.deleteHabit(id);
    _habits = _repository.getAllHabits();
    notifyListeners();
  }

  Future<void> archiveHabit(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    await _repository.archiveHabit(id);
    _habits = _repository.getAllHabits();
    notifyListeners();
  }

  Future<void> toggleHabitCompletion(String habitId, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final dateKey = Helpers.formatDateForStorage(targetDate);
    final habit = _repository.getHabitById(habitId);
    
    if (habit == null) return;

    final wasCompleted = habit.isCompletedOn(dateKey);
    
    await _repository.toggleHabitCompletion(habitId, targetDate);
    _habits = _repository.getAllHabits();

    // Add XP for completion
    if (!wasCompleted) {
      int xpGained = AppConstants.baseXP;
      
      // Check for streak bonus
      final updatedHabit = _repository.getHabitById(habitId);
      if (updatedHabit != null) {
        xpGained += Helpers.calculateStreakBonus(updatedHabit.currentStreak);
      }
      
      await _repository.updateUserXP(xpGained);
      _user = _repository.getUser();
    }

    // Check for new achievements
    await _checkAchievements();

    notifyListeners();
  }

  Future<void> _checkAchievements() async {
    _newlyUnlockedAchievements = await _repository.checkAndUnlockAchievements();
    _user = _repository.getUser();
    
    // Award XP for newly unlocked achievements
    for (var achievementId in _newlyUnlockedAchievements) {
      final achievement = AchievementModel.getById(achievementId);
      if (achievement != null) {
        await _repository.updateUserXP(achievement.xpReward);
      }
    }
    _user = _repository.getUser();
  }

  void clearNewlyUnlockedAchievements() {
    _newlyUnlockedAchievements = [];
    notifyListeners();
  }

  // Statistics
  Map<String, int> getWeeklyCompletions() {
    return _repository.getWeeklyCompletions();
  }

  Map<String, double> getWeeklyCompletionRates() {
    return _repository.getWeeklyCompletionRates();
  }

  List<HabitModel> getBestPerformingHabits({int limit = 5}) {
    return _repository.getBestPerformingHabits(limit: limit);
  }

  Map<String, int> getMonthCompletions(DateTime month) {
    return _repository.getMonthCompletions(month);
  }

  List<HabitModel> getHabitsForDate(DateTime date) {
    return _repository.getHabitsForDate(date);
  }

  // Today's progress
  double getTodayProgress() {
    final todayHabits = this.todayHabits;
    if (todayHabits.isEmpty) return 0;
    
    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    final completed = todayHabits.where((h) => h.isCompletedOn(todayKey)).length;
    return completed / todayHabits.length;
  }

  int getTodayCompletedCount() {
    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    return todayHabits.where((h) => h.isCompletedOn(todayKey)).length;
  }

  // Check if all today's habits are completed
  bool isTodayPerfect() {
    if (todayHabits.isEmpty) return false;
    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    return todayHabits.every((h) => h.isCompletedOn(todayKey));
  }
}
