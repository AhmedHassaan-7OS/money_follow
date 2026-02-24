import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/utils/validators.dart';
import 'package:money_follow/view/widgets/app_card.dart' show AppCard;

/// ============================================================
/// AmountInputField — حقل إدخال المبلغ الموحد.
///
/// كان بيتكتب من الصفر في:
///   Expense_page / expense_page_bloc / edit_expense_page /
///   Income_page / edit_income_page / edit_commitment_page
///
/// دلوقتي:
///   AmountInputField(
///     controller: _amountController,
///     currencySymbol: currencyProvider.currencySymbol,
///   )
///
/// [accentColor] يتحكم في لون الرمز — أزرق للمصاريف، أخضر للدخل، إلخ.
/// ============================================================
class AmountInputField extends StatelessWidget {
  const AmountInputField({
    super.key,
    required this.controller,
    required this.currencySymbol,
    this.accentColor,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currencySymbol;

  /// لون رمز العملة — لو null يستخدم textSecondary.
  final Color? accentColor;

  /// لو null يستخدم AppValidators.amount الافتراضي.
  final FormFieldValidator<String>? validator;

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final symbolColor = accentColor ?? AppTheme.getTextSecondary(context);

    return AppCard(
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextPrimary(context),
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '0.00',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              currencySymbol,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: symbolColor,
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator ?? AppValidators.amount,
      ),
    );
  }
}
