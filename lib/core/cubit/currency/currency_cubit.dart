import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_state.dart';

/// Manages app currency with system detection.
class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit() : super(const CurrencyState()) {
    _loadCurrency();
  }

  void setCurrency(String code) async {
    if (!CurrencyData.currencies.containsKey(code)) return;
    emit(state.copyWith(currencyCode: code));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', code);
  }

  String formatAmount(double amount) {
    return '${state.currencySymbol}${amount.toStringAsFixed(2)}';
  }

  String formatAmountWithCode(double amount) {
    return '${amount.toStringAsFixed(2)} ${state.currencyCode}';
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('currency_code');
    if (saved != null && CurrencyData.currencies.containsKey(saved)) {
      emit(state.copyWith(currencyCode: saved));
    } else {
      final detected = _detectSystemCurrency();
      emit(state.copyWith(currencyCode: detected));
      await prefs.setString('currency_code', detected);
    }
  }

  String _detectSystemCurrency() {
    final locale = ui.PlatformDispatcher.instance.locale;
    final country = locale.countryCode?.toUpperCase();

    const countryToCurrency = {
      'SA': 'SAR', 'EG': 'EGP', 'AE': 'AED',
      'JP': 'JPY', 'DE': 'EUR', 'FR': 'EUR',
      'IT': 'EUR', 'ES': 'EUR', 'NL': 'EUR',
      'BE': 'EUR', 'AT': 'EUR', 'PT': 'EUR',
      'FI': 'EUR', 'IE': 'EUR', 'LU': 'EUR',
      'US': 'USD', 'CA': 'USD', 'GB': 'USD',
      'AU': 'USD',
    };

    if (country != null && countryToCurrency.containsKey(country)) {
      return countryToCurrency[country]!;
    }
    if (locale.languageCode.toLowerCase() == 'ar') return 'SAR';
    return 'USD';
  }
}
