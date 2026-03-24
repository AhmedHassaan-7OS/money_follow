import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_follow/config/app_theme.dart';

class HomeExpenseLineChart extends StatelessWidget {
  const HomeExpenseLineChart({super.key, required this.data, required this.currencySymbol, required this.colors});
  final Map<String, double> data;
  final String currencySymbol;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final keys = data.keys.toList();
    final maxVal = data.values.isEmpty ? 100.0 : data.values.reduce((a, b) => a > b ? a : b);
    
    return LineChart(
      LineChartData(
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
        lineBarsData: [
          LineChartBarData(
            spots: keys.asMap().entries.map((e) => FlSpot(e.key.toDouble(), data[e.value]!)).toList(),
            isCurved: true,
            color: AppTheme.primaryBlue,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryBlue.withOpacity(0.15),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
