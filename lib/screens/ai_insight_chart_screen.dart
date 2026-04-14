import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AIInsightChartScreen extends StatelessWidget {
  const AIInsightChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Fitness Insights")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "AI Performance Analysis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RadarChart(
                RadarChartData(
                  radarBorderData:
                      const BorderSide(color: Colors.deepPurple),
                  dataSets: [
                    RadarDataSet(
                      fillColor:
                          Colors.deepPurple.withValues(alpha: 0.3),
                      borderColor: Colors.deepPurple,
                      dataEntries: const [
                        RadarEntry(value: 80), // strength
                        RadarEntry(value: 65), // endurance
                        RadarEntry(value: 70), // consistency
                        RadarEntry(value: 60), // recovery
                        RadarEntry(value: 75), // flexibility
                      ],
                    ),
                  ],
                  tickCount: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
