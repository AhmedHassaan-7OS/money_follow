import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeExpensePieChart extends StatelessWidget {
  const HomeExpensePieChart({super.key, required this.data, required this.currencySymbol, required this.colors});
  final Map<String, double> data;
  final String currencySymbol;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: data.entries.map((e) {
                final idx = data.keys.toList().indexOf(e.key);
                return PieChartSectionData(
                  color: colors[idx % colors.length], value: e.value, showTitle: false, radius: 25,
                );
              }).toList(),
            ),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
        const SizedBox(height: 16),
        _Legend(data: data, colors: colors, symbol: currencySymbol),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.data, required this.colors, required this.symbol});
  final Map<String, double> data; final List<Color> colors; final String symbol;

  @override
  Widget build(BuildContext c) {
    return Wrap(
      spacing: 12, runSpacing: 8, alignment: WrapAlignment.center,
      children: data.keys.toList().asMap().entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[e.key % colors.length])),
            const SizedBox(width: 6),
            Text('${e.value} ($symbol${data[e.value]!.toStringAsFixed(0)})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        );
      }).toList(),
    );
  }
}
