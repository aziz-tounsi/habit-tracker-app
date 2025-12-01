class QuoteModel {
  final String text;
  final String author;
  final String category;

  const QuoteModel({
    required this.text,
    required this.author,
    this.category = 'Motivation',
  });

  static const List<QuoteModel> motivationalQuotes = [
    QuoteModel(
      text: 'Small steps lead to big changes.',
      author: 'Anonymous',
      category: 'Motivation',
    ),
    QuoteModel(
      text: 'Consistency is the key to success.',
      author: 'Anonymous',
      category: 'Habits',
    ),
    QuoteModel(
      text: 'You are stronger than you think.',
      author: 'A.A. Milne',
      category: 'Motivation',
    ),
    QuoteModel(
      text: 'Every day is a fresh start.',
      author: 'Anonymous',
      category: 'Inspiration',
    ),
    QuoteModel(
      text: 'Believe in yourself and all that you are.',
      author: 'Christian D. Larson',
      category: 'Motivation',
    ),
    QuoteModel(
      text: 'Your habits shape your future.',
      author: 'Anonymous',
      category: 'Habits',
    ),
    QuoteModel(
      text: 'Progress, not perfection.',
      author: 'Anonymous',
      category: 'Growth',
    ),
    QuoteModel(
      text: 'One day at a time.',
      author: 'Anonymous',
      category: 'Mindfulness',
    ),
    QuoteModel(
      text: 'You are capable of amazing things.',
      author: 'Anonymous',
      category: 'Motivation',
    ),
    QuoteModel(
      text: 'Make today count!',
      author: 'Anonymous',
      category: 'Inspiration',
    ),
    QuoteModel(
      text: 'The secret of getting ahead is getting started.',
      author: 'Mark Twain',
      category: 'Action',
    ),
    QuoteModel(
      text: 'Success is the sum of small efforts repeated day in and day out.',
      author: 'Robert Collier',
      category: 'Habits',
    ),
    QuoteModel(
      text: 'Your only limit is you.',
      author: 'Anonymous',
      category: 'Motivation',
    ),
    QuoteModel(
      text: 'Don\'t watch the clock; do what it does. Keep going.',
      author: 'Sam Levenson',
      category: 'Perseverance',
    ),
    QuoteModel(
      text: 'The best time to plant a tree was 20 years ago. The second best time is now.',
      author: 'Chinese Proverb',
      category: 'Action',
    ),
    QuoteModel(
      text: 'You don\'t have to be great to start, but you have to start to be great.',
      author: 'Zig Ziglar',
      category: 'Action',
    ),
    QuoteModel(
      text: 'Excellence is not a destination; it is a continuous journey that never ends.',
      author: 'Brian Tracy',
      category: 'Excellence',
    ),
    QuoteModel(
      text: 'The only way to do great work is to love what you do.',
      author: 'Steve Jobs',
      category: 'Passion',
    ),
    QuoteModel(
      text: 'Motivation is what gets you started. Habit is what keeps you going.',
      author: 'Jim Ryun',
      category: 'Habits',
    ),
    QuoteModel(
      text: 'Fall seven times, stand up eight.',
      author: 'Japanese Proverb',
      category: 'Perseverance',
    ),
  ];

  static QuoteModel getRandomQuote() {
    final now = DateTime.now();
    final index = now.day % motivationalQuotes.length;
    return motivationalQuotes[index];
  }

  static QuoteModel getDailyQuote() {
    return getRandomQuote();
  }

  static List<QuoteModel> getQuotesByCategory(String category) {
    return motivationalQuotes
        .where((quote) => quote.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
