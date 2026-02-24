import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/constants/app_constants.dart'
    show AppConstants;
import 'package:money_follow/view/widgets/app_card.dart' show AppCard;

/// ============================================================
/// DatePickerField — حقل اختيار التاريخ الموحد.
///
/// كان بيتكرر في:
///   expense_page_bloc / edit_expense_page / Income_page /
///   edit_income_page / edit_commitment_page / commitments_page
///
/// دلوقتي:
///   DatePickerField(
///     selectedDate: _selectedDate,
///     onDateChanged: (date) => setState(() => _selectedDate = date),
///   )
///
/// [accentColor]    لون الأيقونة — أزرق / أخضر / برتقالي.
/// [firstDate]      أقدم تاريخ يُسمح باختياره.
/// [lastDate]       أحدث تاريخ يُسمح باختياره.
/// ============================================================
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.accentColor,
    this.firstDate,
    this.lastDate,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final Color? accentColor;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: accentColor ?? AppTheme.primaryBlue,
            brightness: Theme.of(ctx).brightness,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.primaryBlue;

    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              DateFormat(AppConstants.displayDateFormat).format(selectedDate),
              style: AppTheme.getBodyLarge(context),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_right,
              color: AppTheme.getTextSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}
