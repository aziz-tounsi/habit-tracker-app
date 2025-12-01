# Build Instructions

## IMPORTANT: Required Setup After Pulling

After pulling these changes, you **MUST** run the following command to regenerate Hive adapters:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This is required because the `HabitModel` class has been modified with new fields:
- `isQuitHabit` (HiveField 15)
- `quitStartDate` (HiveField 16)
- `moneySavedPerDay` (HiveField 17)
- `relapses` (HiveField 18)

Without running this command, the app will fail to compile or may crash at runtime due to Hive serialization errors.

## New Features Summary

### Complete Quit Habit System
This PR implements a comprehensive bad habit quitting system with:
- **Build vs Quit Toggle**: Choose whether to build a new habit or quit a bad one
- **Live Sobriety Timer**: Real-time countdown showing Days:Hours:Minutes:Seconds clean
- **Panic Button**: Emergency help when experiencing urges
- **Breathing Exercises**: 4-7-8 technique to calm anxiety
- **Motivational Advice**: Habit-specific tips and encouragement
- **Money Saved Tracker**: Calculate savings for habits like smoking
- **Milestone Badges**: Visual rewards for 1 day, 7 days, 30 days, etc.
- **Relapse Tracking**: Record slips and reset timer with encouragement

### Files Created
1. `lib/presentation/widgets/quit/quit_habit_card.dart` - Live timer card widget
2. `lib/presentation/widgets/quit/panic_modal.dart` - Emergency support modal
3. `QUIT_HABIT_GUIDE.md` - Comprehensive user guide

### Files Modified
1. `lib/providers/habit_provider.dart` - Added quit/build habit getters and relapse method
2. `lib/presentation/screens/add_habit/add_habit_screen.dart` - Added toggle and money field
3. `lib/presentation/screens/home/home_screen.dart` - Added quit habits section

## Previous Changes Summary

### 1. Fixed Overflow Errors (Issue 1)
- Reduced padding in habit selection cards from 16px to 8px horizontal, 6px vertical
- Reduced emoji size from 32px to 28px
- Reduced text size from 13px to 11px
- Reduced icon size for selected state from 16px to 14px
- Changed GridView `childAspectRatio` from 1.2 to 1.4 (wider, less tall)
- Added `mainAxisSize: MainAxisSize.min` to prevent expansion

### 2. Onboarding Data Saving (Issue 2)
- Updated `_completeOnboarding()` to create habits from user selections
- Good habits created with `isQuitHabit: false`
- Bad habits created with `isQuitHabit: true`, `quitStartDate: DateTime.now()`, and optional `moneySavedPerDay`
- User data (name, avatar, join date, goals) saved to SharedPreferences

### 3. HabitModel Updates (Issue 3)
- Added `isQuitHabit` field (bool) - distinguishes between building and quitting habits
- Added `quitStartDate` field (DateTime?) - tracks when user started quitting
- Added `moneySavedPerDay` field (double?) - for calculating savings (e.g., smoking)
- Added `relapses` field (List<DateTime>?) - optional tracking of slip-ups
- Updated constructor and `copyWith` method

### 4. Habit Display (Issue 4)
- Updated `habit_card.dart` to show sobriety timer for quit habits
- Displays "X days clean" instead of streak for quit habits
- Green color for sobriety timer vs. orange for regular streaks

### 5. Autocomplete (Issue 5)
- Added Autocomplete widget to habit name field in `add_habit_screen.dart`
- Suggestions from both good and bad habits in `HabitSuggestions`
- Auto-populates category when suggestion selected
- Shows habit type (Build/Quit) in suggestions

### 6. Advice System (Issue 6)
- Created `lib/core/constants/advice.dart` with habit-specific advice
- Contains motivational messages for various habits
- `getRandomAdvice()` function for random tip selection
- Panic button already exists and uses the suggestions system

### 7. Profile Data Loading (Issue 7)
- Updated `ProfileScreen` to be StatefulWidget
- Loads user name, avatar, and join date from SharedPreferences
- Falls back to user model data if SharedPreferences not available
- Displays custom join date if set during onboarding

## Breaking Changes

⚠️ **IMPORTANT**: The HabitModel has new required fields with default values. Existing habits in the database will automatically get:
- `isQuitHabit = false`
- `quitStartDate = null`
- `moneySavedPerDay = null`
- `relapses = null`

This is backward compatible, but regenerating Hive adapters is REQUIRED.
