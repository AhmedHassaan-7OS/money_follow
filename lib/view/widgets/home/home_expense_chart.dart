import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_follow/config/app_theme.dart';

class HomeExpenseChart extends StatelessWidget {
  const HomeExpenseChart({super.key, required this.data, required this.currencySymbol});
  final Map<String, double> data;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    final colors = [
      AppTheme.primaryBlue, AppTheme.accentGreen,
      AppTheme.warningColor, AppTheme.errorColor, AppTheme.lightBlue,
    ];
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PieChart(PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.entries.map((e) {
          final idx = data.keys.toList().indexOf(e.key);
          return PieChartSectionData(
            color: colors[idx % colors.length],
            value: e.value,
            title: '${e.key}\n$currencySymbol${e.value.toStringAsFixed(0)}',
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          );
        }).toList(),
      )),
    );
  }
}
