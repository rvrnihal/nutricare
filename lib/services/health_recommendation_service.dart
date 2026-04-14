import 'package:flutter/material.dart';
import 'package:nuticare/models/health_report_model.dart';
import 'package:nuticare/services/groq_ai_service.dart';

/// Medical recommendations with disclaimers
class MedicalRecommendation {
  final String title;
  final String content;
  final String disclaimer;
  final List<String> keyPoints;
  final bool isUrgent;

  MedicalRecommendation({
    required this.title,
    required this.content,
    required this.disclaimer,
    required this.keyPoints,
    this.isUrgent = false,
  });
}

/// Provides medical-safe recommendations based on detected conditions
class HealthRecommendationService {
  static const String _medicalDisclaimer =
      '''⚠️ MEDICAL DISCLAIMER:
This information is provided for educational purposes only and is NOT a substitute for professional medical advice, diagnosis, or treatment. 

IMPORTANT:
• Consult a certified healthcare professional before making any changes
• Do not self-diagnose or self-medicate based on this analysis
• This app cannot provide medical prescriptions or definitive diagnoses
• Always follow your doctor's advice over app recommendations
• In case of emergency, seek immediate medical attention

For accurate diagnosis and treatment, please consult with:
✓ A licensed physician or medical doctor
✓ A registered dietitian for dietary advice
✓ A certified fitness trainer for exercise programs''';

  /// Generate personalized recommendations
  static Future<Map<String, MedicalRecommendation>>
      generateRecommendations(List<DetectedCondition> conditions) async {
    final recommendations = <String, MedicalRecommendation>{};

    try {
      // Generate condition-specific recommendations
      for (final condition in conditions) {
        final prompt = _buildRecommendationPrompt(condition);
        final response = await GroqAIService.askAI(prompt);

        recommendations[condition.name] = MedicalRecommendation(
          title: 'Recommendations for ${condition.name}',
          content: response,
          disclaimer: _medicalDisclaimer,
          keyPoints: _extractKeyPoints(response),
          isUrgent:
              condition.severity == ConditionSeverity.critical ||
              condition.severity == ConditionSeverity.high,
        );
      }
    } catch (e) {
      debugPrint('Error generating recommendations: $e');
    }

    return recommendations;
  }

  static String _buildRecommendationPrompt(DetectedCondition condition) {
    return '''Based on the detected health condition "${condition.name}", provide:

IMPORTANT: This must include clear disclaimers about medical safety.

1. LIFESTYLE CHANGES:
   - Daily habits to adopt
   - Foods to include
   - Foods to avoid
   - Activity recommendations

2. DIETARY GUIDELINES:
   - Recommended foods
   - Foods to limit or avoid
   - Daily meal examples
   - Hydration tips

3. EXERCISE RECOMMENDATIONS:
   - Safe exercises
   - Exercises to avoid
   - Duration and frequency
   - Intensity level

4. IMPORTANT SAFETY NOTES:
   - When to seek immediate medical help
   - Warning signs to watch for
   - Why professional consultation is needed

5. SUPPLEMENTS & GENERAL WELLNESS:
   - Common supplements (NOT prescriptions)
   - NOTE: Always consult a doctor before taking supplements

CRITICAL: Emphasize that this is informational only and NOT medical advice.
Include disclaimer: "Consult your healthcare provider before making any changes."

Condition Details:
- Name: ${condition.name}
- Severity: ${condition.severity.toString().split('.').last}
- Description: ${condition.description}''';
  }

  /// Extract key points from recommendation text
  static List<String> _extractKeyPoints(String text) {
    final lines = text.split('\n');
    final keyPoints = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('•') ||
          trimmed.startsWith('-') ||
          trimmed.startsWith('✓')) {
        keyPoints.add(trimmed.replaceFirst(RegExp(r'^[•\-✓]\s*'), ''));
      }
    }

    return keyPoints.take(8).toList(); // Limit to 8 key points
  }

  /// Get urgent warnings for critical conditions
  static List<String> getUrgentWarnings(List<DetectedCondition> conditions) {
    final warnings = <String>[];

    for (final condition in conditions) {
      if (condition.severity == ConditionSeverity.critical) {
        warnings.add(
            '🚨 URGENT: ${condition.name} detected. '
            'Seek immediate medical attention.');
      }
    }

    return warnings;
  }

  /// Get general health advisories
  static String getHealthAdvisory(List<DetectedCondition> conditions) {
    if (conditions.isEmpty) {
      return '''✅ GENERAL HEALTH ADVISORY:
Your recent health report shows no major concerns. 

Recommendations:
• Continue regular health checkups
• Maintain balanced diet and exercise
• Stay hydrated
• Get adequate sleep (7-9 hours)
• Manage stress through meditation or exercise
• Limit alcohol and avoid smoking

Next Steps:
☐ Schedule annual health checkup
☐ Maintain health records
☐ Track lifestyle changes over time

Remember: This is for informational purposes. Consult your doctor for personalized advice.
''';
    }

    final risk = _getRiskLevel(conditions);
    final actionItems = _getActionItems(conditions);

    return '''⚠️ HEALTH ADVISORY:

Risk Level: $risk

Detected Conditions: ${conditions.map((c) => c.name).join(', ')}

Immediate Actions:
${actionItems.map((i) => '• $i').join('\n')}

Important Reminders:
✓ This analysis is informational only
✓ Consult your doctor for official diagnosis
✓ Do not delay medical treatment
✓ Follow prescribed medications/treatments
✓ Keep regular doctor appointments

Next Steps:
1. Share this report with your healthcare provider
2. Schedule a consultation appointment
3. Discuss test results and treatment options
4. Follow doctor's recommendations
5. Re-evaluate health after implementing changes
''';
  }

  static String _getRiskLevel(List<DetectedCondition> conditions) {
    final maxSeverity = conditions.fold<ConditionSeverity>(
      ConditionSeverity.low,
      (max, c) {
        if (c.severity.index > max.index) return c.severity;
        return max;
      },
    );

    switch (maxSeverity) {
      case ConditionSeverity.critical:
        return '🔴 CRITICAL - Seek immediate medical attention';
      case ConditionSeverity.high:
        return '🟠 HIGH - Schedule urgent doctor appointment';
      case ConditionSeverity.medium:
        return '🟡 MEDIUM - Schedule doctor appointment soon';
      case ConditionSeverity.low:
        return '🟢 LOW - Monitor and maintain healthy lifestyle';
    }
  }

  static List<String> _getActionItems(List<DetectedCondition> conditions) {
    final items = <String>[
      'Share this report with your healthcare provider',
      'Schedule a doctor appointment',
      'Discuss all detected conditions with your doctor',
    ];

    final criticalCount = conditions.fold<int>(
      0,
      (count, c) =>
          c.severity == ConditionSeverity.critical ? count + 1 : count,
    );

    if (criticalCount > 0) {
      items.insert(0, 'URGENT: Seek medical attention immediately');
    }

    return items;
  }

  /// Medical disclaimer text
  static String getMedicalDisclaimer() => _medicalDisclaimer;

  /// Standard consent message
  static String getConsentMessage() =>
      '''I understand that:
✓ This analysis is for informational purposes only
✓ I must consult a healthcare professional for diagnosis
✓ I will not delay necessary medical treatment
✓ My health data will be encrypted and kept private
✓ I am responsible for my health decisions

I agree to these terms and understand the limitations of this AI analysis.''';

  /// Get personalization recommendations based on medical values
  static List<Map<String, dynamic>> getPersonalizationRecommendations(
      MedicalValues values) {
    final recommendations = <Map<String, dynamic>>[];

    // Nutrition recommendations
    if ((values.totalCholesterol ?? 0) > 200) {
      recommendations.add({
        'title': 'Reduce Cholesterol Intake',
        'description':
            'Include more fiber-rich foods like oats, beans, and vegetables. Limit saturated fats from dairy and meat.',
        'icon': Icons.restaurant,
        'category': 'Nutrition',
      });
    }

    if ((values.glucose ?? 0) > 100) {
      recommendations.add({
        'title': 'Monitor Carbohydrate Intake',
        'description':
            'Choose complex carbohydrates like whole grains over refined sugars. Eat balanced meals with protein.',
        'icon': Icons.food_bank,
        'category': 'Nutrition',
      });
    }

    // Activity recommendations
    if ((values.systolicBP ?? 0) > 130) {
      recommendations.add({
        'title': 'Regular Physical Activity',
        'description':
            'Aim for 150 minutes of moderate-intensity exercise per week. Walking, swimming, or cycling are good options.',
        'icon': Icons.directions_run,
        'category': 'Activity',
      });
    }

    // Hydration
    recommendations.add({
      'title': 'Stay Hydrated',
      'description':
          'Drink 8-10 glasses of water daily. Proper hydration supports kidney function and overall health.',
      'icon': Icons.water_drop,
      'category': 'Hydration',
    });

    // Sleep
    recommendations.add({
      'title': 'Get Quality Sleep',
      'description':
          'Aim for 7-9 hours of quality sleep each night. This supports immune function and metabolic health.',
      'icon': Icons.bedtime,
      'category': 'Sleep',
    });

    // Stress management
    recommendations.add({
      'title': 'Manage Stress',
      'description':
          'Practice meditation, deep breathing, or yoga for 10-15 minutes daily to manage stress and improve wellbeing.',
      'icon': Icons.spa,
      'category': 'Wellness',
    });

    return recommendations.take(6).toList();
  }
}
