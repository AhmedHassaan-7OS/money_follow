import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';

/// ============================================================
/// AppSnackBar — Utility لعرض الـ Snack Bars بشكل موحد.
///
/// كان بيتكتب كده في كل صفحة edit (حوالي 15+ مرة):
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(
///       content: Text(message),
///       backgroundColor: AppTheme.accentGreen,
///       behavior: SnackBarBehavior.floating,
///       shape: RoundedRectangleBorder(
///         borderRadius: BorderRadius.circular(10),
///       ),
///     ),
///   );
///
/// دلوقتي:
///   AppSnackBar.success(context, 'Saved!')
///   AppSnackBar.error(context, 'Something went wrong')
///   AppSnackBar.info(context, 'AI suggests: Food')
/// ============================================================
class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) =>
      _show(context, message, AppTheme.accentGreen);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppTheme.errorColor);

  static void info(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) =>
      _show(context, message, AppTheme.primaryBlue, action: action);

  static void _show(
    BuildContext context,
    String message,
    Color color, {
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          action: action,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }
}
