# Quit Habit System - User Guide

## Overview
The Habit Tracker app now includes a complete bad habit quitting system with live timers, panic buttons, and motivational support.

## Features Implemented

### 1. Build vs Quit Habit Toggle
When adding a new habit:
- Toggle at the top of the Add Habit screen
- **Build Habit** (Green): For habits you want to develop
- **Quit Habit** (Red): For habits you want to stop

### 2. Money Saved Tracking
For quit habits (e.g., Smoking, Alcohol):
- Optional field to enter money saved per day
- Automatically calculates total savings based on days clean
- Displayed prominently on the quit habit card

### 3. Live Sobriety Timer
Each quit habit displays:
- Days : Hours : Minutes : Seconds since quitting
- Updates every second
- Shows quit start date
- Visual milestone badges (1 day, 3 days, 7 days, etc.)

### 4. Panic Button
When experiencing an urge:
- Orange "I'm Having an Urge" button on each quit habit card
- Opens a full-screen panic modal with:
  - **Breathing Exercise**: 4-7-8 breathing technique
  - **Random Advice**: Habit-specific motivational tips
  - **Progress Reminder**: Shows days clean
  - **Action Buttons**:
    - "I Stayed Strong" (green) - Close modal, celebrate success
    - "I Slipped" (red) - Record relapse, reset timer

### 5. Milestone Badges
Automatically earned badges for:
- 1 day, 3 days, 7 days, 14 days, 30 days
- 60 days, 90 days, 180 days, 365 days
- Displayed as colored chips on quit habit cards

### 6. Relapse Tracking
- Records date and time of relapse
- Resets quit timer to current date/time
- Maintains relapse history for tracking progress
- Shows encouragement message to start fresh

### 7. Separate Home Screen Sections
- **"Habits I'm Quitting"** section (red icon)
  - Shows all active quit habits
  - Live timers update automatically
  - Panic buttons readily accessible
- **"Today's Habits"** section
  - Shows build habits for the selected date
  - Regular completion tracking

## Usage Instructions

### Adding a Quit Habit
1. Tap the + button to add a new habit
2. Select **"Quit Habit"** toggle (red)
3. Enter habit name (e.g., "Smoking", "Social Media")
4. Optionally add money saved per day (e.g., "10.00")
5. Choose icon, color, category
6. Set schedule and reminder
7. Tap "Create Habit"

### Using the Panic Button
1. When experiencing an urge, tap the orange "I'm Having an Urge" button
2. Try the breathing exercise (recommended)
3. Read the motivational advice
4. Remember your progress (days clean)
5. Choose:
   - "I Stayed Strong" if you resisted the urge
   - "I Slipped" if you need to reset the timer

### Viewing Progress
- Open the app to see all quit habits at the top of the home screen
- Watch the live timer count up
- See money saved accumulate
- Earn milestone badges as you progress

## Technical Details

### New Files Created
- `lib/presentation/widgets/quit/quit_habit_card.dart` - Live timer card widget
- `lib/presentation/widgets/quit/panic_modal.dart` - Panic button modal

### Modified Files
- `lib/providers/habit_provider.dart` - Added quit habit getters and relapse tracking
- `lib/presentation/screens/add_habit/add_habit_screen.dart` - Added toggle and money field
- `lib/presentation/screens/home/home_screen.dart` - Added quit habits section

### Data Model
Uses existing `HabitModel` with fields:
- `isQuitHabit: bool` - Identifies quit habits
- `quitStartDate: DateTime?` - When user started quitting
- `moneySavedPerDay: double?` - Optional money tracking
- `relapses: List<DateTime>?` - Relapse history

## Testing Recommendations

### Manual Testing Checklist
1. ✅ Add a new quit habit (e.g., "Smoking")
2. ✅ Verify money saved field appears
3. ✅ Save and check home screen for quit habits section
4. ✅ Verify timer updates every second
5. ✅ Tap panic button and try breathing exercise
6. ✅ Test "I Stayed Strong" button
7. ✅ Test "I Slipped" button and verify timer resets
8. ✅ Check milestone badges appear at correct intervals
9. ✅ Verify money saved calculation is accurate
10. ✅ Edit a quit habit and verify data persists

### Edge Cases to Test
- Creating quit habit without money saved field
- Relapsing multiple times
- Switching between Build and Quit modes while editing
- Having no quit habits (section should not appear)
- Having multiple quit habits

## Known Limitations
- Timer updates require the widget to be visible (rebuilds every second)
- Milestone badges only show achieved milestones (not upcoming ones in detail)
- Relapse history is stored but not displayed in UI (future enhancement)

## Future Enhancements
- Relapse history view
- Charts showing quit progress over time
- Health benefits timeline (like existing BadHabitModel)
- Share achievements on social media
- Support groups/accountability partners

## Support
For issues or questions, please refer to the main repository documentation or create an issue.
