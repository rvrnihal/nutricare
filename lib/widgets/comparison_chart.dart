import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ComparisonChart extends StatelessWidget {
  final String label;
  final double value1;
  final double value2;
  final String food1;
  final String food2;

  const ComparisonChart({
    super.key,
    required this.label,
    required this.value1,
    required this.value2,
    required this.food1,
    required this.food2,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [value1, value2].reduce((a, b) => a > b ? a : b) + 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              maxY: maxValue,
              barGroups: [
                _bar(0, value1, Colors.green),
                _bar(1, value2, Colors.blue),
              ],
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      return Text(value.toInt() == 0 ? food1 : food2);
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 30,
          borderRadius: BorderRadius.circular(6),
        )
      ],
    );
  }
}
