class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  @override
  String toString() => '$symbol $code';
}

class Currencies {
  static const List<Currency> all = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'TND', symbol: 'د.ت', name: 'Tunisian Dinar'),
    Currency(code: 'MAD', symbol: 'د.م.', name: 'Moroccan Dirham'),
    Currency(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound'),
    Currency(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
    Currency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  ];

  static Currency getByCode(String code) {
    return all.firstWhere(
      (currency) => currency.code == code,
      orElse: () => all[0], // Default to USD
    );
  }

  static const Currency defaultCurrency = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
  );
}
