import 'dart:math';

class HabitAdvice {
  static const Map<String, List<String>> habitAdvice = {
    'Smoking': [
      "The craving will pass in 3-5 minutes. You've got this!",
      "Drink water - it helps flush nicotine faster.",
      "Take 5 deep breaths. Oxygen helps reduce cravings.",
      "Your blood pressure is already improving!",
      "Call a friend or go for a short walk.",
      "Every cigarette you don't smoke is doing you good!",
      "Think about how proud you'll be tomorrow.",
    ],
    'Social Media Addiction': [
      "Put your phone in another room for 30 minutes.",
      "Replace scrolling with a quick 5-minute activity.",
      "Remember: You're rewiring your brain - it takes time!",
      "Try the 5-4-3-2-1 grounding technique.",
      "Ask yourself: What would I do if I didn't have my phone?",
      "Real life is happening right now. Don't miss it.",
      "Your mind deserves this break.",
    ],
    'Sugar/Junk Food': [
      "Drink a glass of water first - thirst often feels like hunger.",
      "Wait 10 minutes. Cravings often pass.",
      "Eat something healthy first, then decide.",
      "Ask yourself: Am I hungry or just bored?",
      "Plan your meals ahead to avoid impulse eating.",
      "Your body deserves nourishment, not punishment.",
      "Think about how you'll feel after vs. before.",
    ],
    'Fast Food': [
      "Drink a glass of water first - thirst often feels like hunger.",
      "Wait 10 minutes. Cravings often pass.",
      "Eat something healthy first, then decide.",
      "Ask yourself: Am I hungry or just bored?",
      "Plan your meals ahead to avoid impulse eating.",
      "Your body deserves nourishment, not punishment.",
      "Think about how you'll feel after vs. before.",
    ],
    'Alcohol': [
      'One day at a time. You\'ve got this.',
      'Your future self will thank you for staying strong.',
      'The urge will pass. Stay present.',
      'You\'re breaking the cycle. That\'s powerful.',
      'Remember why you started this journey.',
      'Call your sponsor or support person.',
      'Drink sparkling water or tea instead.',
    ],
    'Caffeine': [
      "Your energy levels will stabilize naturally.",
      "Drink herbal tea or water instead.",
      "Go for a short walk to boost energy.",
      "Your sleep quality is already improving!",
      "Take deep breaths to increase oxygen flow.",
    ],
    'Gaming Addiction': [
      "Set a timer for 30 minutes of offline time.",
      "Try a real-world hobby you used to enjoy.",
      "Call a friend for a real conversation.",
      "Remember: Real achievements matter more.",
      "Your brain is rewiring for better focus.",
    ],
    'Impulse Shopping': [
      "Wait 24 hours before buying anything.",
      "Check your budget and savings goals.",
      "Ask: Do I need this or just want it?",
      "Think about what you could save for instead.",
      "Delete shopping apps from your phone.",
    ],
    'Procrastination': [
      "Just do 5 minutes - that's all you need to start.",
      "Break it down into tiny, easy steps.",
      "Set a timer and commit to one task.",
      "Remember: Done is better than perfect.",
      "Future you will thank present you.",
    ],
  };

  static String getRandomAdvice(String habitName) {
    final tips = habitAdvice[habitName] ?? habitAdvice['default'] ?? [
      "You've got this! Stay strong.",
      "One day at a time.",
      "Remember why you started.",
      "You're stronger than you think.",
      "This craving will pass.",
      "Believe in yourself. You can do this.",
    ];
    return tips[Random().nextInt(tips.length)];
  }

  static List<String> getAllAdvice(String habitName) {
    return habitAdvice[habitName] ?? habitAdvice['default'] ?? [
      "You've got this! Stay strong.",
      "One day at a time.",
      "Remember why you started.",
    ];
  }
}
