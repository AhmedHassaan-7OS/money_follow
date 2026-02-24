import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/constants/app_constants.dart'
    show AppConstants;
import 'package:money_follow/view/widgets/app_card.dart' show AppCard;

/// ============================================================
/// CategoryDropdown — قائمة اختيار الفئة الموحدة.
///
/// كان بيتكتب من الصفر في:
///   Expense_page / expense_page_bloc / edit_expense_page
///
/// دلوقتي:
///   CategoryDropdown(
///     value: _selectedCategory,
///     onChanged: (cat) => setState(() => _selectedCategory = cat),
///   )
/// ============================================================
class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.categories,
  });

  final String value;
  final ValueChanged<String> onChanged;

  /// لو null يستخدم AppConstants.expenseCategories الافتراضي.
  final List<String>? categories;

  @override
  Widget build(BuildContext context) {
    final cats = categories ?? AppConstants.expenseCategories;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[600]!
            : Colors.grey[300]!,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        dropdownColor: AppTheme.getCardColor(context),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppTheme.getTextSecondary(context),
        ),
        style: AppTheme.getBodyLarge(context),
        items: cats.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    AppConstants.getCategoryIcon(category),
                    size: 18,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(category),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
