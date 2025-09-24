import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class CurrencyProvider extends ChangeNotifier {
  String _currencyCode = 'USD';
  
  String get currencyCode => _currencyCode;
  String get currencySymbol => currencies[_currencyCode]?['symbol'] ?? '\$';
  String get currencyName => currencies[_currencyCode]?['name'] ?? 'US Dollar';

  CurrencyProvider() {
    _loadCurrency();
  }

  void _loadCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCurrency = prefs.getString('currency_code');
    
    if (savedCurrency != null && currencies.containsKey(savedCurrency)) {
      // User has previously set a currency
      _currencyCode = savedCurrency;
    } else {
      // First time launch - detect system currency based on country
      _currencyCode = _detectSystemCurrency();
      // Save the detected currency
      await prefs.setString('currency_code', _currencyCode);
    }
    notifyListeners();
  }

  String _detectSystemCurrency() {
    // Get system locale with country code
    Locale systemLocale = ui.PlatformDispatcher.instance.locale;
    String? countryCode = systemLocale.countryCode?.toUpperCase();
    
    // Map country codes to currencies
    Map<String, String> countryToCurrency = {
      'SA': 'SAR', // Saudi Arabia
      'EG': 'EGP', // Egypt
      'AE': 'AED', // UAE
      'JP': 'JPY', // Japan
      'DE': 'EUR', // Germany
      'FR': 'EUR', // France
      'IT': 'EUR', // Italy
      'ES': 'EUR', // Spain
      'NL': 'EUR', // Netherlands
      'BE': 'EUR', // Belgium
      'AT': 'EUR', // Austria
      'PT': 'EUR', // Portugal
      'FI': 'EUR', // Finland
      'IE': 'EUR', // Ireland
      'LU': 'EUR', // Luxembourg
      'US': 'USD', // United States
      'CA': 'USD', // Canada (often uses USD in apps)
      'GB': 'USD', // UK (fallback to USD since we don't have GBP)
      'AU': 'USD', // Australia (fallback to USD since we don't have AUD)
    };
    
    if (countryCode != null && countryToCurrency.containsKey(countryCode)) {
      return countryToCurrency[countryCode]!;
    }
    
    // Additional language-based detection for Arabic speakers
    String languageCode = systemLocale.languageCode.toLowerCase();
    if (languageCode == 'ar') {
      // Arabic speakers - default to SAR (most common)
      return 'SAR';
    }
    
    // Fallback to USD
    return 'USD';
  }

  void setCurrency(String currencyCode) async {
    if (!currencies.containsKey(currencyCode)) return;
    
    _currencyCode = currencyCode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', currencyCode);
    notifyListeners();
  }

  String formatAmount(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String formatAmountWithCode(double amount) {
    return '${amount.toStringAsFixed(2)} $_currencyCode';
  }

  static const Map<String, Map<String, String>> currencies = {
    'USD': {
      'name': 'US Dollar',
      'symbol': '\$',
      'code': 'USD',
    },
    'EUR': {
      'name': 'Euro',
      'symbol': '€',
      'code': 'EUR',
    },
    'SAR': {
      'name': 'Saudi Riyal',
      'symbol': '﷼',
      'code': 'SAR',
    },
    'EGP': {
      'name': 'Egyptian Pound',
      'symbol': 'E£',
      'code': 'EGP',
    },
    'AED': {
      'name': 'UAE Dirham',
      'symbol': 'د.إ',
      'code': 'AED',
    },
    'JPY': {
      'name': 'Japanese Yen',
      'symbol': '¥',
      'code': 'JPY',
    },
  };

  List<String> get supportedCurrencies => currencies.keys.toList();
  
  Map<String, String> getCurrencyInfo(String code) {
    return currencies[code] ?? currencies['USD']!;
  }
}
