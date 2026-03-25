import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/home/home_cubit.dart';
import 'package:money_follow/core/cubit/home/home_state.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class HomeChartFilterChips extends StatelessWidget {
  const HomeChartFilterChips({super.key, required this.cubit, required this.state});
  final HomeCubit cubit;
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = ['Week', 'Month', 'Year', 'AllTime'];
    final cats = state.expenses.map((e) => e.category).toSet().toList();
    cats.insert(0, 'All');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...filters.map((f) {
                final isSelected = state.chartTimeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f, style: TextStyle(color: isSelected ? Colors.white : AppTheme.getTextPrimary(context), fontSize: 12)),
                    selected: isSelected,
                    onSelected: (_) => cubit.setChartTimeFilter(f),
                    backgroundColor: AppTheme.getCardColor(context),
                    selectedColor: AppTheme.primaryBlue,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(l10n.customDate, style: TextStyle(color: state.chartTimeFilter == 'Custom' ? Colors.white : AppTheme.getTextPrimary(context), fontSize: 12)),
                  selected: state.chartTimeFilter == 'Custom',
                  onSelected: (_) async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue),
                        ),
                        child: child!,
                      ),
                    );
                    if (range != null) {
                      cubit.setCustomDateRange(range.start, range.end);
                    }
                  },
                  backgroundColor: AppTheme.getCardColor(context),
                  selectedColor: AppTheme.primaryBlue,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cats.map((c) {
              final activeCat = state.filterCategory ?? 'All';
              final isSelected = activeCat == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c == 'All' ? l10n.all : c, style: TextStyle(color: isSelected ? Colors.white : AppTheme.getTextSecondary(context), fontSize: 11)),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (c == 'All') {
                      cubit.setFilterCategory(null);
                    } else {
                      cubit.setFilterCategory(selected ? c : null);
                    }
                  },
                  selectedColor: AppTheme.accentGreen,
                  backgroundColor: AppTheme.getBackgroundColor(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2))),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
