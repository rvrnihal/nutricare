import 'package:flutter/material.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/services/daily_nutrition_service.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// Screen to view historical nutrition data and statistics
class NutritionHistoryScreen extends StatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  State<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends State<NutritionHistoryScreen> {
  int _selectedDays = 7; // Default to last 7 days

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        title: Text("Nutrition History",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Range Selector
            Row(
              children: [
                _buildPeriodButton("7 Days", 7),
                const SizedBox(width: 10),
                _buildPeriodButton("14 Days", 14),
                const SizedBox(width: 10),
                _buildPeriodButton("30 Days", 30),
              ],
            ),
            const SizedBox(height: 30),

            // Weekly Summary Card
            _buildWeeklySummaryCard(),
            const SizedBox(height: 20),

            // Historical Data List
            Text("Daily Breakdown",
                style: NutriTheme.textTheme.displayMedium
                    ?.copyWith(fontSize: 18)),
            const SizedBox(height: 15),
            _buildHistoricalDataList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, int days) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDays = days),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? NutriTheme.primary : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? NutriTheme.primary : Colors.grey.shade700,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: DailyNutritionService.getWeeklySummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: NutriTheme.primary));
        }

        final summary = snapshot.data!;
        final daysLogged = summary['daysLogged'] ?? 0;
        final totalCalories = (summary['totalCalories'] ?? 0).toDouble();
        final averageCalories = (summary['averageCalories'] ?? 0).toDouble();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade900, Colors.grey.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Weekly Summary",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildSummaryRow("Days Logged", "$daysLogged days"),
              const SizedBox(height: 12),
              _buildSummaryRow(
                "Total Calories",
                "${totalCalories.toStringAsFixed(0)} kcal",
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                "Average Daily",
                "${averageCalories.toStringAsFixed(0)} kcal",
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                "Total Protein",
                "${(summary['totalProtein'] ?? 0).toStringAsFixed(1)}g",
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                "Total Carbs",
                "${(summary['totalCarbs'] ?? 0).toStringAsFixed(1)}g",
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                "Total Fat",
                "${(summary['totalFat'] ?? 0).toStringAsFixed(1)}g",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoricalDataList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DailyNutritionService.getHistoricalData(days: _selectedDays),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: NutriTheme.primary));
        }

        final historicalData = snapshot.data ?? [];
        if (historicalData.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                "No data available for the selected period",
                style: TextStyle(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: historicalData.map((dayData) {
            return _buildDayCard(dayData);
          }).toList(),
        );
      },
    );
  }

  Widget _buildDayCard(Map<String, dynamic> dayData) {
    final date = dayData['date'] ?? 'Unknown Date';
    final calories = (dayData['totalCalories'] ?? 0).toInt();
    final protein = (dayData['protein'] ?? 0).toDouble();
    final carbs = (dayData['carbs'] ?? 0).toDouble();
    final fat = (dayData['fat'] ?? 0).toDouble();
    final mealCount = dayData['mealCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NutriTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$mealCount meals",
                  style: const TextStyle(
                    color: NutriTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Calorie Progress Bar
          Text(
            "Calories: $calories / 2000 kcal",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            percent: (calories / 2000).clamp(0.0, 1.0),
            progressColor: _getCalorieColor(calories),
            backgroundColor: Colors.grey.shade800,
            lineHeight: 8,
            barRadius: Radius.circular(4),
          ),
          const SizedBox(height: 12),
          // Macros Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroTag("Protein", "${protein.toStringAsFixed(0)}g", Colors.blue),
              _buildMacroTag("Carbs", "${carbs.toStringAsFixed(0)}g", Colors.orange),
              _buildMacroTag("Fat", "${fat.toStringAsFixed(0)}g", Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTag(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Color _getCalorieColor(int calories) {
    if (calories < 1500) return Colors.blue;
    if (calories < 2000) return Colors.green;
    if (calories < 2500) return Colors.orange;
    return Colors.red;
  }
}
