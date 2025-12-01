import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int iconIndex;

  @HiveField(4)
  int colorIndex;

  @HiveField(5)
  String category;

  @HiveField(6)
  List<int> scheduledDays; // 0 = Monday, 6 = Sunday

  @HiveField(7)
  int targetDaysPerWeek;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String? reminderTime; // HH:mm format

  @HiveField(10)
  bool isArchived;

  @HiveField(11)
  int currentStreak;

  @HiveField(12)
  int longestStreak;

  @HiveField(13)
  int totalCompletions;

  @HiveField(14)
  List<String> completedDates; // List of yyyy-MM-dd strings

  @HiveField(15)
  bool isQuitHabit; // true = quitting bad habit, false = building good habit

  @HiveField(16)
  DateTime? quitStartDate; // When user started quitting (for timer)

  @HiveField(17)
  double? moneySavedPerDay; // For habits like smoking (optional)

  @HiveField(18)
  List<DateTime>? relapses; // Times user slipped (optional)

  HabitModel({
    required this.id,
    required this.name,
    this.description,
    required this.iconIndex,
    required this.colorIndex,
    required this.category,
    required this.scheduledDays,
    required this.targetDaysPerWeek,
    required this.createdAt,
    this.reminderTime,
    this.isArchived = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    List<String>? completedDates,
    this.isQuitHabit = false,
    this.quitStartDate,
    this.moneySavedPerDay,
    this.relapses,
  }) : completedDates = completedDates ?? [];

  bool isCompletedOn(String dateKey) {
    return completedDates.contains(dateKey);
  }

  bool isScheduledFor(int dayIndex) {
    return scheduledDays.contains(dayIndex);
  }

  void markComplete(String dateKey) {
    if (!completedDates.contains(dateKey)) {
      completedDates.add(dateKey);
      totalCompletions++;
      _updateStreak();
    }
  }

  void markIncomplete(String dateKey) {
    if (completedDates.contains(dateKey)) {
      completedDates.remove(dateKey);
      totalCompletions--;
      _updateStreak();
    }
  }

  void _updateStreak() {
    // Sort dates in descending order
    final sortedDates = List<String>.from(completedDates)..sort((a, b) => b.compareTo(a));
    
    if (sortedDates.isEmpty) {
      currentStreak = 0;
      return;
    }

    int streak = 0;
    var checkDate = DateTime.now();
    final todayKey = _formatDate(checkDate);
    
    // Check if today is completed or if yesterday was the last completion
    if (sortedDates.first != todayKey) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey = _formatDate(yesterday);
      if (sortedDates.first != yesterdayKey) {
        currentStreak = 0;
        return;
      }
      checkDate = yesterday;
    }

    // Count consecutive days
    for (int i = 0; i < sortedDates.length; i++) {
      final expectedDateKey = _formatDate(checkDate.subtract(Duration(days: i)));
      if (sortedDates.contains(expectedDateKey)) {
        streak++;
      } else {
        break;
      }
    }

    currentStreak = streak;
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  double getCompletionRate() {
    if (totalCompletions == 0) return 0;
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays + 1;
    final scheduledDaysCount = _countScheduledDays(daysSinceCreation);
    if (scheduledDaysCount == 0) return 0;
    return (totalCompletions / scheduledDaysCount).clamp(0, 1);
  }

  int _countScheduledDays(int totalDays) {
    int count = 0;
    for (int i = 0; i < totalDays; i++) {
      final date = createdAt.add(Duration(days: i));
      final dayIndex = date.weekday - 1; // 0 = Monday
      if (scheduledDays.contains(dayIndex)) {
        count++;
      }
    }
    return count;
  }

  HabitModel copyWith({
    String? id,
    String? name,
    String? description,
    int? iconIndex,
    int? colorIndex,
    String? category,
    List<int>? scheduledDays,
    int? targetDaysPerWeek,
    DateTime? createdAt,
    String? reminderTime,
    bool? isArchived,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    List<String>? completedDates,
    bool? isQuitHabit,
    DateTime? quitStartDate,
    double? moneySavedPerDay,
    List<DateTime>? relapses,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconIndex: iconIndex ?? this.iconIndex,
      colorIndex: colorIndex ?? this.colorIndex,
      category: category ?? this.category,
      scheduledDays: scheduledDays ?? List.from(this.scheduledDays),
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      isArchived: isArchived ?? this.isArchived,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      completedDates: completedDates ?? List.from(this.completedDates),
      isQuitHabit: isQuitHabit ?? this.isQuitHabit,
      quitStartDate: quitStartDate ?? this.quitStartDate,
      moneySavedPerDay: moneySavedPerDay ?? this.moneySavedPerDay,
      relapses: relapses ?? (this.relapses != null ? List.from(this.relapses!) : null),
    );
  }

  @override
  String toString() {
    return 'HabitModel(id: $id, name: $name, streak: $currentStreak)';
  }
}
