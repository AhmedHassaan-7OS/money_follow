import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class HistoryFilterTabs extends StatelessWidget {
  const HistoryFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  static const _filters = ['All', 'Income', 'Expenses', 'Commitments'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => onFilterSelected(filter),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 0.3
                                  : 0.05,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Text(
                  _localizedLabel(filter, l10n),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.getTextPrimary(context),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _localizedLabel(String filter, AppLocalizations l10n) {
    switch (filter) {
      case 'All':
        return l10n.all;
      case 'Income':
        return l10n.income;
      case 'Expenses':
        return l10n.expenses;
      case 'Commitments':
        return l10n.commitments;
      default:
        return filter;
    }
  }
}
