import 'package:flutter/services.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static const MethodChannel _channel = MethodChannel('money_follow/widgets');

  static Future<void> refreshWidgets() async {
    try {
      await _channel.invokeMethod<void>('refreshWidgets');
    } catch (_) {
      // Best-effort refresh: ignore platform errors.
    }
  }

  static Future<void> setQuickWithdrawAmount(double amount) async {
    try {
      await _channel.invokeMethod<void>(
        'setQuickWithdrawAmount',
        <String, dynamic>{'amount': amount},
      );
    } catch (_) {
      // Ignore if platform side is unavailable.
    }
  }
}
