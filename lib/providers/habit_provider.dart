import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/habit_model.dart';
import '../data/models/user_model.dart';
import '../data/models/achievement_model.dart';
import '../data/repositories/habit_repository.dart';
import '../data/services/notification_service.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';
import '../data/models/stone_model.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  final NotificationService _notificationService = NotificationService();

  List<HabitModel> _habits = [];
  UserModel? _user;
  bool _isLoading = true;
  String? _error;
  List<String> _newlyUnlockedAchievements = [];
  List<String> _newlyUnlockedStones = [];

  // Getters
  List<HabitModel> get habits => _habits;
  List<HabitModel> get todayHabits => _repository.getHabitsForToday();
  List<HabitModel> get quitHabits =>
      _habits.where((h) => h.isQuitHabit && !h.isArchived).toList();
  List<HabitModel> get buildHabits =>
      _habits.where((h) => !h.isQuitHabit && !h.isArchived).toList();
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get newlyUnlockedAchievements => _newlyUnlockedAchievements;
  List<String> get newlyUnlockedStones => _newlyUnlockedStones;
  bool get hasCompletedOnboarding => _user?.hasCompletedOnboarding ?? false;

  // Statistics
  int get totalHabits => _habits.length;
  int get totalCompletions => _repository.getTotalCompletions();
  int get longestStreak => _repository.getLongestStreak();
  int get currentMaxStreak => _repository.getCurrentMaxStreak();
  int get totalXP => _user?.totalXP ?? 0;
  int get level => _user?.level ?? 0;
  double get levelProgress {
    if (_user?.levelProgress != null) {
      return _user!.levelProgress;
    }
    const xpPerLevel = 100;
    final xp = _user?.totalXP ?? 0;
    final remainder = xp % xpPerLevel;
    return (remainder / xpPerLevel).clamp(0.0, 1.0);
  }

  int get completedTodayCount {
    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    return todayHabits.where((h) => h.isCompletedOn(todayKey)).length;
  }

  int get totalTodayCount => todayHabits.length;

  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.init();
      await _notificationService.init();

      _user = _repository.getUser();
      _user ??= await _repository.createDefaultUser();

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

    // Load user name and avatar from SharedPreferences (saved during onboarding)
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? 'User';
    final userAvatar = prefs.getString('user_avatar') ?? 'avatar_0';

    // Update user with onboarding data and award starter stone
    _user = _user!.copyWith(
      hasCompletedOnboarding: true,
      name: userName,
      avatarEmoji: userAvatar, // Reusing avatarEmoji field to store avatar ID
      unlockedStones: ['celestial_quartz', ..._user!.unlockedStones],
    );
    await _repository.saveUser(_user!);
    _newlyUnlockedStones.add('celestial_quartz');
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
    bool isQuitHabit = false,
    DateTime? quitStartDate,
    double? moneySavedPerDay,
  }) async {
    // Skip if habit with same name already exists
    if (_habits.any((h) => h.name == name && h.isQuitHabit == isQuitHabit)) {
      return;
    }

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
      isQuitHabit: isQuitHabit,
      quitStartDate: quitStartDate,
      moneySavedPerDay: moneySavedPerDay,
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

  // Add habit from model (useful for onboarding)
  Future<void> addHabitFromModel(HabitModel habit) async {
    await _repository.addHabit(habit);
    _habits = _repository.getAllHabits();

    // Schedule notification if reminder time is set
    if (habit.reminderTime != null && _user?.notificationsEnabled == true) {
      await _notificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        time: habit.reminderTime!,
        days: habit.scheduledDays,
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

    // Also check for stone unlocks
    await _checkStones();
  }

  Future<void> _checkStones() async {
    final user = _user;
    if (user == null) return;

    for (final stone in StoneModel.allStones) {
      if (user.hasStone(stone.id)) continue;

      bool shouldUnlock = false;

      switch (stone.id) {
        // Common stones
        case 'celestial_quartz':
          shouldUnlock = user.hasCompletedOnboarding;
        case 'crystal_rose_quartz':
          shouldUnlock = completedTodayCount >= 3;
        case 'spirit_jade':
          shouldUnlock = _habits.length >= 3;
        case 'ancient_amber':
          shouldUnlock = _habits.any((h) => h.currentStreak >= 3);
        case 'nature_peridot':
          shouldUnlock = totalCompletions >= 5;
        case 'earth_jasper':
          shouldUnlock = currentMaxStreak >= 5;
        case 'starlight_pearl':
          shouldUnlock = _checkHabitBefore6AM();
        case 'wisdom_turquoise':
          shouldUnlock = totalCompletions >= 10;
        case 'harmony_malachite':
          shouldUnlock = isTodayPerfect();
        case 'golden_pyrite':
          shouldUnlock = level >= 2;

        // Rare stones
        case 'phoenix_ruby':
          shouldUnlock = currentMaxStreak >= 7;
        case 'frost_sapphire':
          shouldUnlock = level >= 5;
        case 'shadow_amethyst':
          shouldUnlock = totalCompletions >= 25;
        case 'storm_topaz':
          shouldUnlock = currentMaxStreak >= 14;
        case 'ocean_aquamarine':
          shouldUnlock = totalCompletions >= 30;
        case 'solar_citrine':
          shouldUnlock = totalCompletions >= 50;
        case 'inferno_garnet':
          shouldUnlock = level >= 7;
        case 'thunder_lapis':
          shouldUnlock = completedTodayCount >= 5;
        case 'prism_tourmaline':
          shouldUnlock = currentMaxStreak >= 21;
        case 'lunar_selenite':
          shouldUnlock = _checkHabitAfter10PM();

        // Epic stones
        case 'enchanted_emerald':
          shouldUnlock = currentMaxStreak >= 30;
        case 'aurora_crystal':
          shouldUnlock = level >= 10;
        case 'dragons_eye':
          shouldUnlock = totalCompletions >= 100;
        case 'twilight_tanzanite':
          shouldUnlock = currentMaxStreak >= 45;
        case 'royal_alexandrite':
          shouldUnlock = level >= 15;
        case 'dream_labradorite':
          shouldUnlock = totalCompletions >= 150;
        case 'nebula_fluorite':
          shouldUnlock = currentMaxStreak >= 60;
        case 'time_onyx':
          shouldUnlock = _checkPerfectTwoWeeks();

        // Legendary stones
        case 'void_obsidian':
          shouldUnlock = currentMaxStreak >= 100;
        case 'ethereal_moonstone':
          shouldUnlock = level >= 20;
        case 'cosmic_diamond':
          shouldUnlock = currentMaxStreak >= 365;
        case 'mystic_opal':
          shouldUnlock = totalCompletions >= 500;
        case 'zen_bloodstone':
          shouldUnlock = currentMaxStreak >= 200;
      }

      if (shouldUnlock) {
        user.unlockStone(stone.id);
        await _repository.saveUser(user);
        _newlyUnlockedStones.add(stone.id);

        // Award XP for stone unlock
        await _repository.updateUserXP(stone.xpReward);
      }
    }

    _user = _repository.getUser();
    notifyListeners();
  }

  bool _checkHabitBefore6AM() {
    final now = DateTime.now();
    final sixAM = DateTime(now.year, now.month, now.day, 6);
    if (now.isBefore(sixAM)) {
      final todayKey = Helpers.formatDateForStorage(now);
      return todayHabits.any((h) => h.isCompletedOn(todayKey));
    }
    return false;
  }

  bool _checkHabitAfter10PM() {
    final now = DateTime.now();
    final tenPM = DateTime(now.year, now.month, now.day, 22);
    if (now.isAfter(tenPM)) {
      final todayKey = Helpers.formatDateForStorage(now);
      return todayHabits.any((h) => h.isCompletedOn(todayKey));
    }
    return false;
  }

  bool _checkPerfectTwoWeeks() {
    var consecutivePerfectDays = 0;
    for (var i = 0; i < 14; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = Helpers.formatDateForStorage(date);
      final habitsForDate = getHabitsForDate(date).where((h) => !h.isQuitHabit).toList();
      if (habitsForDate.isEmpty) continue;
      final allComplete = habitsForDate.every((h) => h.isCompletedOn(dateKey));
      if (allComplete) {
        consecutivePerfectDays++;
      } else {
        consecutivePerfectDays = 0;
      }
    }
    return consecutivePerfectDays >= 14;
  }

  void clearNewlyUnlockedAchievements() {
    _newlyUnlockedAchievements = [];
    notifyListeners();
  }

  void clearNewlyUnlockedStones() {
    _newlyUnlockedStones = [];
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    await _notificationService.cancelAllNotifications();
    await _repository.clearAllData();

    // Recreate a fresh default user and empty habit list
    _user = await _repository.createDefaultUser();
    _habits = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> requestNotificationPermission() async {
    await _notificationService.init();
    return _notificationService.requestPermissions();
  }

  Future<void> disableAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    await updateUser(notificationsEnabled: false);
  }

  Future<void> rescheduleAllReminders() async {
    if (_user?.notificationsEnabled != true) return;
    await _notificationService.init();

    for (final habit in _habits) {
      if (habit.reminderTime == null) continue;
      await _notificationService.scheduleHabitReminder(
        id: habit.id.hashCode,
        habitName: habit.name,
        time: habit.reminderTime!,
        days: habit.scheduledDays,
      );
    }
  }

  Future<void> restoreFromBackup(
    Map<String, dynamic>? userData,
    List<dynamic> habitsData,
  ) async {
    _isLoading = true;
    notifyListeners();

    await clearAllData();

    if (userData != null) {
      final restoredUser = UserModel(
        id: userData['id'] as String,
        name: userData['name'] as String? ?? 'User',
        avatarEmoji: userData['avatarEmoji'] as String? ?? '',
        totalXP: userData['totalXP'] as int? ?? 0,
        createdAt:
            DateTime.tryParse(userData['createdAt'] ?? '') ?? DateTime.now(),
        hasCompletedOnboarding:
            userData['hasCompletedOnboarding'] as bool? ?? false,
        isDarkMode: userData['isDarkMode'] as bool? ?? true,
        accentColorIndex: userData['accentColorIndex'] as int? ?? 0,
        notificationsEnabled: userData['notificationsEnabled'] as bool? ?? true,
        unlockedAchievements:
            (userData['unlockedAchievements'] as List<dynamic>? ?? [])
                .cast<String>(),
        unlockedStones: (userData['unlockedStones'] as List<dynamic>? ?? [])
            .cast<String>(),
      );
      await _repository.saveUser(restoredUser);
      _user = restoredUser;
    }

    for (final raw in habitsData) {
      final map = raw as Map<String, dynamic>;
      final habit = HabitModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        iconIndex: map['iconIndex'] as int? ?? 0,
        colorIndex: map['colorIndex'] as int? ?? 0,
        category: map['category'] as String? ?? 'General',
        scheduledDays: (map['scheduledDays'] as List<dynamic>? ?? [])
            .cast<int>(),
        targetDaysPerWeek: map['targetDaysPerWeek'] as int? ?? 7,
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        reminderTime: map['reminderTime'] as String?,
        isArchived: map['isArchived'] as bool? ?? false,
        currentStreak: map['currentStreak'] as int? ?? 0,
        longestStreak: map['longestStreak'] as int? ?? 0,
        totalCompletions: map['totalCompletions'] as int? ?? 0,
        completedDates: (map['completedDates'] as List<dynamic>? ?? [])
            .cast<String>(),
        isQuitHabit: map['isQuitHabit'] as bool? ?? false,
        quitStartDate: map['quitStartDate'] != null
            ? DateTime.tryParse(map['quitStartDate'])
            : null,
        moneySavedPerDay: (map['moneySavedPerDay'] as num?)?.toDouble(),
        relapses: (map['relapses'] as List<dynamic>? ?? [])
            .map<DateTime?>((d) => d == null ? null : DateTime.tryParse(d))
            .whereType<DateTime>()
            .toList(),
      );

      await _repository.addHabit(habit);
    }

    _habits = _repository.getAllHabits();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Statistics
  Map<String, int> getCompletionsForDays(int days) {
    return _repository.getCompletionsForDays(days);
  }

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

  Map<String, int> getLifetimeMonthlyCompletions() {
    return _repository.getLifetimeMonthlyCompletions();
  }

  List<HabitModel> getHabitsForDate(DateTime date) {
    return _repository.getHabitsForDate(date);
  }

  // Today's progress
  double getTodayProgress() {
    final todayHabits = this.todayHabits;
    if (todayHabits.isEmpty) return 0;

    final todayKey = Helpers.formatDateForStorage(DateTime.now());
    final completed = todayHabits
        .where((h) => h.isCompletedOn(todayKey))
        .length;
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

  // Record a relapse for a quit habit
  Future<void> recordRelapse(String habitId) async {
    final habit = _repository.getHabitById(habitId);
    if (habit == null || !habit.isQuitHabit) return;

    final updatedRelapses = List<DateTime>.from(habit.relapses ?? []);
    updatedRelapses.add(DateTime.now());

    final updatedHabit = habit.copyWith(
      relapses: updatedRelapses,
      quitStartDate: DateTime.now(), // Reset the quit timer
    );

    await _repository.updateHabit(updatedHabit);
    _habits = _repository.getAllHabits();
    notifyListeners();
  }
}
