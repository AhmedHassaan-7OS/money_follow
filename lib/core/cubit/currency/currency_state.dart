class CurrencyState {
  final String currencyCode;

  const CurrencyState({this.currencyCode = 'USD'});

  String get currencySymbol =>
      CurrencyData.currencies[currencyCode]?['symbol'] ?? '\$';

  String get currencyName =>
      CurrencyData.currencies[currencyCode]?['name'] ?? 'US Dollar';

  CurrencyState copyWith({String? currencyCode}) {
    return CurrencyState(
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}

/// Static currency data — separated from state.
class CurrencyData {
  CurrencyData._();

  static const Map<String, Map<String, String>> currencies = {
    'USD': {'name': 'US Dollar', 'symbol': '\$', 'code': 'USD'},
    'EUR': {'name': 'Euro', 'symbol': '€', 'code': 'EUR'},
    'SAR': {'name': 'Saudi Riyal', 'symbol': '﷼', 'code': 'SAR'},
    'EGP': {'name': 'Egyptian Pound', 'symbol': 'E£', 'code': 'EGP'},
    'AED': {'name': 'UAE Dirham', 'symbol': 'د.إ', 'code': 'AED'},
    'JPY': {'name': 'Japanese Yen', 'symbol': '¥', 'code': 'JPY'},
  };

  static List<String> get supportedCurrencies => currencies.keys.toList();

  static Map<String, String> getCurrencyInfo(String code) {
    return currencies[code] ?? currencies['USD']!;
  }
}
