import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String avatarEmoji;

  @HiveField(3)
  int totalXP;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool hasCompletedOnboarding;

  @HiveField(6)
  bool isDarkMode;

  @HiveField(7)
  int accentColorIndex;

  @HiveField(8)
  bool notificationsEnabled;

  @HiveField(9)
  List<String> unlockedAchievements;

  UserModel({
    required this.id,
    required this.name,
    this.avatarEmoji = '😊',
    this.totalXP = 0,
    DateTime? createdAt,
    this.hasCompletedOnboarding = false,
    this.isDarkMode = true,
    this.accentColorIndex = 0,
    this.notificationsEnabled = true,
    List<String>? unlockedAchievements,
  })  : createdAt = createdAt ?? DateTime.now(),
        unlockedAchievements = unlockedAchievements ?? [];

  int get level => totalXP ~/ 100;

  double get levelProgress => (totalXP % 100) / 100;

  int get xpToNextLevel => 100 - (totalXP % 100);

  void addXP(int xp) {
    totalXP += xp;
  }

  void unlockAchievement(String achievementId) {
    if (!unlockedAchievements.contains(achievementId)) {
      unlockedAchievements.add(achievementId);
    }
  }

  bool hasAchievement(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? avatarEmoji,
    int? totalXP,
    DateTime? createdAt,
    bool? hasCompletedOnboarding,
    bool? isDarkMode,
    int? accentColorIndex,
    bool? notificationsEnabled,
    List<String>? unlockedAchievements,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      totalXP: totalXP ?? this.totalXP,
      createdAt: createdAt ?? this.createdAt,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      unlockedAchievements: unlockedAchievements ?? List.from(this.unlockedAchievements),
    );
  }
}
