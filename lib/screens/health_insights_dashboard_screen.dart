import 'package:flutter/material.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/models/health_report_model.dart';
import 'package:nuticare/services/health_recommendation_service.dart';

class HealthInsightsDashboardScreen extends StatefulWidget {
  final HealthAnalysis analysis;
  final MedicalValues medicalValues;

  const HealthInsightsDashboardScreen({
    super.key,
    required this.analysis,
    required this.medicalValues,
  });

  @override
  State<HealthInsightsDashboardScreen> createState() =>
      _HealthInsightsDashboardScreenState();
}

class _HealthInsightsDashboardScreenState
    extends State<HealthInsightsDashboardScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getRiskColor(dynamic riskLevel) {
    String level;
    if (riskLevel is ConditionSeverity) {
      level = riskLevel.name;
    } else {
      level = riskLevel.toString().toLowerCase();
    }

    switch (level) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _severityToString(ConditionSeverity severity) {
    return severity.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Health Analysis",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          // Page 1: Overview & Risk Assessment
          _buildOverviewPage(),
          // Page 2: Detailed Conditions
          _buildConditionsPage(),
          // Page 3: Recommendations
          _buildRecommendationsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: NutriTheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed:
                  _currentPage > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
              icon: const Icon(Icons.arrow_back),
              color:
                  _currentPage > 0 ? Colors.white : Colors.grey,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index ? NutriTheme.primary : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed:
                  _currentPage < 2
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
              icon: const Icon(Icons.arrow_forward),
              color:
                  _currentPage < 2 ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewPage() {
    final riskColor = _getRiskColor(widget.analysis.overallRiskLevel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Risk Assessment Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  riskColor.withValues(alpha: 0.3),
                  riskColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: riskColor, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: riskColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _getRiskIcon(widget.analysis.overallRiskLevel),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Overall Risk Level",
                            style: NutriTheme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.analysis.overallRiskLevel.toUpperCase(),
                            style: NutriTheme.textTheme.displayMedium
                                ?.copyWith(
                              fontSize: 24,
                              color: riskColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.analysis.summaryText,
                  style: NutriTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Analyzed Metrics
          Text(
            "Your Metrics",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          _buildMetricsGrid(),

          const SizedBox(height: 24),

          // Key Findings
          Text(
            "Key Findings",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          ...widget.analysis.detectedConditions
              .take(3)
              .map(
                (condition) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NutriTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: _getRiskColor(condition.severity),
                        width: 4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: _getRiskColor(condition.severity),
                        size: 12,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              condition.name,
                              style: NutriTheme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              condition.description,
                              style: NutriTheme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _severityToString(condition.severity),
                        style: NutriTheme.textTheme.bodySmall?.copyWith(
                          color: _getRiskColor(condition.severity),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard("Glucose", "${widget.medicalValues.glucose} mg/dL",
            Icons.favorite),
        _buildMetricCard("Hemoglobin", "${widget.medicalValues.hemoglobin} g/dL",
            Icons.bloodtype_outlined),
        _buildMetricCard("Cholesterol",
            "${widget.medicalValues.totalCholesterol} mg/dL", Icons.trending_up),
        _buildMetricCard(
            "BP",
            "${widget.medicalValues.systolicBP}/${widget.medicalValues.diastolicBP}",
            Icons.favorite),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NutriTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: NutriTheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(label, style: NutriTheme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value,
              style: NutriTheme.textTheme.bodyMedium
                  ?.copyWith(color: NutriTheme.primary)),
        ],
      ),
    );
  }

  Widget _buildConditionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Detected Conditions",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          if (widget.analysis.detectedConditions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: NutriTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 12),
                  Text("No concerning conditions detected",
                      style: NutriTheme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text("Keep up with regular check-ups",
                      style: NutriTheme.textTheme.bodySmall),
                ],
              ),
            )
          else
            ...widget.analysis.detectedConditions
                .map(
                  (condition) => _buildConditionCard(condition),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildConditionCard(DetectedCondition condition) {
    final riskColor = _getRiskColor(condition.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.1),
        border: Border.all(color: riskColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  condition.name,
                  style: NutriTheme.textTheme.displayMedium
                      ?.copyWith(fontSize: 16, color: riskColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _severityToString(condition.severity),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            condition.description,
            style: NutriTheme.textTheme.bodySmall,
          ),
          if (condition.indicators.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: condition.indicators
                  .map(
                    (metric) => Chip(
                      label: Text(
                        metric,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: riskColor.withValues(alpha: 0.2),
                      labelStyle: TextStyle(color: riskColor),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationsPage() {
    final recommendations = HealthRecommendationService
        .getPersonalizationRecommendations(widget.medicalValues)
        .take(5)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Personalized Recommendations",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          ...recommendations
              .asMap()
              .entries
              .map(
                (entry) => _buildRecommendationCard(
                  entry.key + 1,
                  entry.value['title'],
                  entry.value['description'],
                  entry.value['icon'],
                  entry.value['category'],
                ),
              )
              .toList(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Consult with a healthcare professional for personalized medical advice.",
                    style: NutriTheme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(int index, dynamic title, dynamic description,
      dynamic icon, dynamic category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NutriTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: NutriTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon((icon as IconData?) ?? Icons.health_and_safety, color: Colors.black, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title?.toString() ?? 'Recommendation', style: NutriTheme.textTheme.bodyMedium),
                    Text(category?.toString() ?? 'Health',
                        style: NutriTheme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description?.toString() ?? 'No details available', style: NutriTheme.textTheme.bodySmall),
        ],
      ),
    );
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'critical':
        return Icons.priority_high;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}
