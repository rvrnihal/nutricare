import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/components/glass_card.dart';
import 'package:nuticare/services/analytics_dashboard_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        title: const Text("📊 Progress & Analytics"),
        backgroundColor: NutriTheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Period Selector
          _buildPeriodSelector(),
          const SizedBox(height: 20),

          // Health Score Card
          _buildHealthScoreCard(),
          const SizedBox(height: 20),

          Text("Weight Trend", style: NutriTheme.textTheme.displayMedium),
          const SizedBox(height: 20),
          
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                       FlSpot(0, 80),
                       FlSpot(1, 79.5),
                       FlSpot(2, 79.2),
                       FlSpot(3, 78.8),
                       FlSpot(4, 78.5),
                    ],
                    isCurved: true,
                    color: NutriTheme.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: NutriTheme.primary.withValues(alpha: 0.2)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Nutrition Analytics
          _buildNutritionAnalytics(),
          const SizedBox(height: 20),
          
          // Fitness Analytics
          _buildFitnessAnalytics(),
          const SizedBox(height: 20),
          
          // Progress Metrics
          _buildProgressMetrics(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NutriTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPeriodButton('7 Days', 7),
          _buildPeriodButton('14 Days', 14),
          _buildPeriodButton('30 Days', 30),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, int days) {
    bool isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedDays = days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? NutriTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? NutriTheme.primary : Colors.white30,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: AnalyticsDashboardService.getDashboardData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GlassCard(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: const SizedBox(
                height: 150,
                child: Center(
                  child: CircularProgressIndicator(color: NutriTheme.primary),
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final metrics = data['progress_metrics'] as Map<String, dynamic>;
        final score = (metrics['adherence_score'] ?? 0.0) as double;

        return GlassCard(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '💪 Today\'s Health Score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${score.toStringAsFixed(0)}/100',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      score >= 80
                          ? Colors.greenAccent
                          : score >= 60
                              ? Colors.yellow
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutritionAnalytics() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AnalyticsDashboardService.getNutritionTrends(_selectedDays),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GlassCard(
            child: _buildLoadingPlaceholder(),
          );
        }

        final trends = snapshot.data ?? [];
        if (trends.isEmpty) {
          return GlassCard(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                '🥗 No nutrition data yet. Log some meals!',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        // Calculate averages
        double avgCalories = 0;
        for (var trend in trends) {
          avgCalories += trend['totalCalories'] ?? 0;
        }
        avgCalories /= trends.length;

        return GlassCard(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🥗 Nutrition Trends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Avg Calories per Day',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '${avgCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFitnessAnalytics() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AnalyticsDashboardService.getFitnessTrends(_selectedDays),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GlassCard(
            child: _buildLoadingPlaceholder(),
          );
        }

        final workouts = snapshot.data ?? [];
        double totalCalories = 0;

        for (var workout in workouts) {
          totalCalories += workout['caloriesBurned'] ?? 0;
        }

        return GlassCard(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏃 Fitness Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Workouts',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '${workouts.length}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Calories Burned',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '${totalCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressMetrics() {
    return FutureBuilder<Map<String, dynamic>>(
      future: AnalyticsDashboardService.getDashboardData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GlassCard(
            child: _buildLoadingPlaceholder(),
          );
        }

        final metrics = snapshot.data!['progress_metrics'] as Map<String, dynamic>;

        return GlassCard(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📈 Today\'s Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressBar(
                  'Calories',
                  (metrics['calorie_progress'] as double).clamp(0.0, 1.0),
                  '🔥',
                ),
                _buildProgressBar(
                  'Protein',
                  (metrics['protein_progress'] as double).clamp(0.0, 1.0),
                  '💪',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(String label, double progress, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$emoji $label',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.greenAccent : NutriTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 150,
      child: const Center(
        child: CircularProgressIndicator(color: NutriTheme.primary),
      ),
    );
  }
}
