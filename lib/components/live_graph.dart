import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nuticare/core/theme.dart';

class LiveGraph extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;

  const LiveGraph({
    super.key,
    required this.spots,
    this.color = NutriTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: 60,
        maxY: 180,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
