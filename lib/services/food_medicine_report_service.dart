import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for fetching food and medicine reports from AI server
class FoodMedicineReportService {
  static const String _baseUrl = 'http://localhost:5000/api';
  
  // In production, use environment variable or configuration
  static String get baseUrl {
    const String prodUrl = String.fromEnvironment('API_BASE_URL');
    return prodUrl.isNotEmpty ? prodUrl : _baseUrl;
  }

  /// Get detailed food nutrition report
  static Future<Map<String, dynamic>> getFoodReport(String foodName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/food-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'foodName': foodName}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch food report: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error fetching food report: $e'
      };
    }
  }

  /// Get detailed medicine information report
  static Future<Map<String, dynamic>> getMedicineReport(String medicineName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medicine-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'medicineName': medicineName}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch medicine report: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error fetching medicine report: $e'
      };
    }
  }

  /// Search foods
  static Future<List<Map<String, dynamic>>> searchFoods(
    String query, {
    String? type,
    String? region,
    bool lowCalorie = false,
    bool highProtein = false,
  }) async {
    try {
      final params = <String, String>{
        if (query.isNotEmpty) 'query': query,
        if (type != null) 'type': type,
        if (region != null) 'region': region,
        if (lowCalorie) 'lowCalorie': 'true',
        if (highProtein) 'highProtein': 'true',
      };

      final uri = Uri.parse('$baseUrl/foods/search')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['foods'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error searching foods: $e');
      return [];
    }
  }

  /// Search medicines
  static Future<List<Map<String, dynamic>>> searchMedicines(
    String query, {
    String? system,
    String? availability,
  }) async {
    try {
      final params = <String, String>{
        if (query.isNotEmpty) 'query': query,
        if (system != null) 'system': system,
        if (availability != null) 'availability': availability,
      };

      final uri = Uri.parse('$baseUrl/medicines/search')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['medicines'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error searching medicines: $e');
      return [];
    }
  }

  /// Get AI chat response with food/medicine report
  static Future<Map<String, dynamic>> getChatWithReport({
    required String message,
    String? reportType,
    String? reportName,
  }) async {
    try {
      final body = {
        'message': message,
        if (reportType != null) 'reportType': reportType,
        if (reportName != null) 'reportName': reportName,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/ai-chat-with-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'chat_response': 'Failed to get response: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'chat_response': 'Error: $e'
      };
    }
  }
}

/// Widget to display food report in chat
class FoodReportWidget extends StatelessWidget {
  final Map<String, dynamic> report;

  const FoodReportWidget({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (report['status'] != 'success') {
      return _ErrorCard(message: report['message'] ?? 'Could not load food report');
    }

    final food = report['food'] ?? {};
    final nutrition = report['nutrition_per_serving'] ?? {};
    final analysis = report['nutrition_analysis'] ?? {};
    final benefits = (analysis['benefits'] as List?)?.cast<String>() ?? [];
    final considerations =
        (analysis['considerations'] as List?)?.cast<String>() ?? [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.teal.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.restaurant_menu,
                      color: Colors.teal.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food['name'] ?? 'Food',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800,
                              ),
                        ),
                        Text(
                          '${food['type']} • ${food['region']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.teal.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nutrition Score
              _buildNutritionScoreBar(analysis['score'] ?? 0),
              const SizedBox(height: 16),

              // Nutrition Facts
              _buildNutritionGrid(nutrition),
              const SizedBox(height: 16),

              // Benefits
              if (benefits.isNotEmpty) ...[
                _buildSection('Benefits', benefits, Colors.green),
                const SizedBox(height: 12),
              ],

              // Considerations
              if (considerations.isNotEmpty) ...[
                _buildSection('Considerations', considerations, Colors.orange),
                const SizedBox(height: 12),
              ],

              // Dietary Recommendations
              if (report['dietary_recommendations'] != null) ...[
                _buildSection(
                  'Dietary Recommendations',
                  (report['dietary_recommendations'] as List)
                      .map((e) => e.toString())
                      .toList(),
                  Colors.blue,
                ),
                const SizedBox(height: 12),
              ],

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Text(
                  report['medical_disclaimer'] ??
                      '⚠️ For educational purposes only',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionScoreBar(int score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  score > 70 ? Colors.green : score > 50 ? Colors.orange : Colors.red,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$score/100',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          score > 70 ? 'Excellent' : score > 50 ? 'Good' : 'Fair',
          style: TextStyle(
            fontSize: 12,
            color: score > 70 ? Colors.green : score > 50 ? Colors.orange : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionGrid(Map<String, dynamic> nutrition) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildNutrientCard('Calories', '${nutrition['calories']}', 'kcal'),
        _buildNutrientCard('Protein', '${nutrition['protein_g']}', 'g'),
        _buildNutrientCard('Carbs', '${nutrition['carbs_g']}', 'g'),
        _buildNutrientCard('Fat', '${nutrition['fat_g']}', 'g'),
        _buildNutrientCard('Fiber', '${nutrition['fiber_g']}', 'g'),
        _buildNutrientCard('Sugar', '${nutrition['sugar_g']}', 'g'),
      ],
    );
  }

  Widget _buildNutrientCard(String label, String value, String unit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 13,
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }
}

/// Widget to display medicine report in chat
class MedicineReportWidget extends StatelessWidget {
  final Map<String, dynamic> report;

  const MedicineReportWidget({Key? key, required this.report})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (report['status'] != 'success') {
      return _ErrorCard(
          message: report['message'] ?? 'Could not load medicine report');
    }

    final medicine = report['medicine'] ?? {};
    final info = report['therapeutic_info'] ?? {};
    final safety = report['safety_information'] ?? {};
    final notes = (report['important_notes'] as List?)?.cast<String>() ?? [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.red.shade50, Colors.pink.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with danger indicator
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.warning, color: Colors.red.shade700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine['name'] ?? 'Medicine',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                        ),
                        if (medicine['generic'] != null)
                          Text(
                            'Generic: ${medicine['generic']}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.red.shade600,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Risk Level Badge
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRiskColor(safety['risk_level']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: _getRiskColor(safety['risk_level'])
                              .withOpacity(0.5)),
                    ),
                    child: Text(
                      'Risk Level: ${safety['risk_level']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRiskColor(safety['risk_level']),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Uses
              _buildMedSection(context, 'Uses', info['uses'], Icons.check,
                  Colors.blue),
              const SizedBox(height: 12),

              // Dosage
              _buildMedSection(context, 'Dosage', info['dosage'], Icons.scale,
                  Colors.teal),
              const SizedBox(height: 12),

              // Side Effects
              if (info['side_effects'] != null) ...[
                _buildMedListSection(
                  context,
                  'Side Effects',
                  (info['side_effects'] is List
                      ? info['side_effects']
                      : info['side_effects'].split(','))
                      .map((e) => e.toString().trim())
                      .toList(),
                  Icons.error_outline,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
              ],

              // Interactions
              _buildMedSection(context, 'Drug Interactions',
                  info['interactions'], Icons.link, Colors.purple),
              const SizedBox(height: 12),

              // Important Notes
              if (notes.isNotEmpty) ...[
                Text(
                  'IMPORTANT SAFETY NOTES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ...notes
                    .map((note) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            note,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
                const SizedBox(height: 12),
              ],

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  report['medical_disclaimer'] ??
                      '⚠️ CONSULT YOUR HEALTHCARE PROVIDER',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedSection(BuildContext context, String title, String? content,
      IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            content ?? 'Consult healthcare provider',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedListSection(BuildContext context, String title,
      List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              )),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String? riskLevel) {
    switch (riskLevel?.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MODERATE':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

/// Error card widget
class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
