import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_follow/config/app_theme.dart';

class HomeExpenseBarChart extends StatelessWidget {
  const HomeExpenseBarChart({super.key, required this.data, required this.currencySymbol, required this.colors});
  final Map<String, double> data;
  final String currencySymbol;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final keys = data.keys.toList();
    final maxVal = data.values.isEmpty ? 100.0 : data.values.reduce((a, b) => a > b ? a : b);
    
    return BarChart(
      BarChartData(
        maxY: maxVal * 1.2,
        minY: 0,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (val, meta) {
                if (val.toInt() < 0 || val.toInt() >= keys.length) return const SizedBox();
                final t = keys[val.toInt()];
                return Text(t.length > 5 ? '${t.substring(0,4)}.' : t, style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 10));
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: keys.map((k) {
          final idx = keys.indexOf(k);
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: data[k]!,
                gradient: LinearGradient(
                  colors: [colors[idx % colors.length].withOpacity(0.4), colors[idx % colors.length]],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }
}
