import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'home_expense_pie_chart.dart';
import 'home_expense_bar_chart.dart';
import 'home_expense_line_chart.dart';

class HomeExpenseChart extends StatelessWidget {
  const HomeExpenseChart({super.key, required this.data, required this.currencySymbol, required this.chartType, required this.onTypeChanged});
  final Map<String, double> data;
  final String currencySymbol;
  final String chartType;
  final Function(String) onTypeChanged;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    final colors = [AppTheme.primaryBlue, AppTheme.accentGreen, AppTheme.warningColor, AppTheme.errorColor, AppTheme.lightBlue];

    return Container(
      height: 380, // Expanded for toggle buttons
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Pie', 'Bar', 'Line'].map((type) {
              final active = chartType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: active ? null : () => onTypeChanged(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: active ? AppTheme.primaryBlue.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(type, style: TextStyle(color: active ? AppTheme.primaryBlue : AppTheme.getTextSecondary(context), fontWeight: FontWeight.bold, fontSize: 12))),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: chartType == 'Pie' ? HomeExpensePieChart(key: const ValueKey('pie'), data: data, currencySymbol: currencySymbol, colors: colors)
                   : chartType == 'Line' ? HomeExpenseLineChart(key: const ValueKey('line'), data: data, currencySymbol: currencySymbol, colors: colors)
                   : HomeExpenseBarChart(key: const ValueKey('bar'), data: data, currencySymbol: currencySymbol, colors: colors),
            ),
          ),
        ],
      ),
    );
  }
}
