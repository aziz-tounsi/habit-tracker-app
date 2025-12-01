class BadHabitConfig {
  final String type;
  final List<BadHabitField> fields;
  final double Function(Map<String, dynamic> values) calculate;

  BadHabitConfig({
    required this.type,
    required this.fields,
    required this.calculate,
  });
}

class BadHabitField {
  final String key;
  final String label;
  final String hint;
  final BadHabitFieldType type;
  final List<String>? options; // For dropdown fields

  BadHabitField({
    required this.key,
    required this.label,
    required this.hint,
    required this.type,
    this.options,
  });
}

enum BadHabitFieldType {
  number,
  money,
  dropdown,
}

class BadHabitConfigs {
  static final Map<String, BadHabitConfig> configs = {
    'Smoking': BadHabitConfig(
      type: 'Smoking',
      fields: [
        BadHabitField(
          key: 'cigarettesPerDay',
          label: 'Cigarettes per Day',
          hint: 'e.g., 10',
          type: BadHabitFieldType.number,
        ),
        BadHabitField(
          key: 'pricePerPack',
          label: 'Price per Pack',
          hint: 'e.g., 8.00',
          type: BadHabitFieldType.money,
        ),
        BadHabitField(
          key: 'cigsPerPack',
          label: 'Cigarettes per Pack',
          hint: 'e.g., 20',
          type: BadHabitFieldType.number,
        ),
      ],
      calculate: (values) {
        final cigarettesPerDay = values['cigarettesPerDay'] as double? ?? 0;
        final pricePerPack = values['pricePerPack'] as double? ?? 0;
        final cigsPerPack = values['cigsPerPack'] as double? ?? 20;
        
        if (cigsPerPack == 0) return 0;
        return (cigarettesPerDay / cigsPerPack) * pricePerPack;
      },
    ),
    'Alcohol': BadHabitConfig(
      type: 'Alcohol',
      fields: [
        BadHabitField(
          key: 'drinksPerDay',
          label: 'Drinks per Day',
          hint: 'e.g., 2',
          type: BadHabitFieldType.number,
        ),
        BadHabitField(
          key: 'pricePerDrink',
          label: 'Price per Drink',
          hint: 'e.g., 6.00',
          type: BadHabitFieldType.money,
        ),
        BadHabitField(
          key: 'drinkType',
          label: 'Drink Type',
          hint: 'Select type',
          type: BadHabitFieldType.dropdown,
          options: ['Beer', 'Wine', 'Spirits'],
        ),
      ],
      calculate: (values) {
        final drinksPerDay = values['drinksPerDay'] as double? ?? 0;
        final pricePerDrink = values['pricePerDrink'] as double? ?? 0;
        return drinksPerDay * pricePerDrink;
      },
    ),
    'Junk Food': BadHabitConfig(
      type: 'Junk Food',
      fields: [
        BadHabitField(
          key: 'mealsPerWeek',
          label: 'Meals per Week',
          hint: 'e.g., 5',
          type: BadHabitFieldType.number,
        ),
        BadHabitField(
          key: 'pricePerMeal',
          label: 'Price per Meal',
          hint: 'e.g., 12.00',
          type: BadHabitFieldType.money,
        ),
      ],
      calculate: (values) {
        final mealsPerWeek = values['mealsPerWeek'] as double? ?? 0;
        final pricePerMeal = values['pricePerMeal'] as double? ?? 0;
        return (mealsPerWeek / 7) * pricePerMeal; // Convert to daily cost
      },
    ),
    'Caffeine': BadHabitConfig(
      type: 'Caffeine',
      fields: [
        BadHabitField(
          key: 'cupsPerDay',
          label: 'Cups per Day',
          hint: 'e.g., 3',
          type: BadHabitFieldType.number,
        ),
        BadHabitField(
          key: 'pricePerCup',
          label: 'Price per Cup',
          hint: 'e.g., 4.50',
          type: BadHabitFieldType.money,
        ),
      ],
      calculate: (values) {
        final cupsPerDay = values['cupsPerDay'] as double? ?? 0;
        final pricePerCup = values['pricePerCup'] as double? ?? 0;
        return cupsPerDay * pricePerCup;
      },
    ),
    'Gaming': BadHabitConfig(
      type: 'Gaming',
      fields: [
        BadHabitField(
          key: 'hoursPerDay',
          label: 'Hours per Day',
          hint: 'e.g., 4',
          type: BadHabitFieldType.number,
        ),
      ],
      calculate: (values) {
        return 0; // No money tracking for gaming
      },
    ),
    'Social Media': BadHabitConfig(
      type: 'Social Media',
      fields: [
        BadHabitField(
          key: 'hoursPerDay',
          label: 'Hours per Day',
          hint: 'e.g., 3',
          type: BadHabitFieldType.number,
        ),
      ],
      calculate: (values) {
        return 0; // No money tracking for social media
      },
    ),
    'Gambling': BadHabitConfig(
      type: 'Gambling',
      fields: [
        BadHabitField(
          key: 'amountPerWeek',
          label: 'Amount per Week',
          hint: 'e.g., 100.00',
          type: BadHabitFieldType.money,
        ),
      ],
      calculate: (values) {
        final amountPerWeek = values['amountPerWeek'] as double? ?? 0;
        return amountPerWeek / 7; // Convert to daily cost
      },
    ),
  };

  static BadHabitConfig? getConfig(String habitName) {
    // Try to match the habit name to a config
    for (var entry in configs.entries) {
      if (habitName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
