import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';

/// ============================================================
/// ConfirmDeleteDialog — Dialog تأكيد الحذف الموحد.
///
/// كان بيتكتب من الصفر في:
///   edit_expense_page / edit_income_page / edit_commitment_page
///
/// دلوقتي:
///   final confirmed = await ConfirmDeleteDialog.show(
///     context,
///     title: 'Delete Expense',
///     message: 'Are you sure? This action cannot be undone.',
///   );
///   if (confirmed) { ... }
/// ============================================================
class ConfirmDeleteDialog {
  ConfirmDeleteDialog._();

  /// يعرض الـ dialog ويرجع true لو المستخدم أكد الحذف.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title, style: AppTheme.getHeadingSmall(context)),
        content: Text(message, style: AppTheme.getBodyMedium(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              cancelLabel,
              style: TextStyle(color: AppTheme.getTextSecondary(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
