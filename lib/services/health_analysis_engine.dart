import 'package:nuticare/models/health_report_model.dart';

/// Health Condition Analysis Engine
/// Detects health conditions based on medical values
class HealthAnalysisEngine {
  /// Detect conditions from medical values
  static List<DetectedCondition> analyzeValues(MedicalValues values) {
    final conditions = <DetectedCondition>[];

    // Diabetes detection
    final diabetesCond = _detectDiabetes(values);
    if (diabetesCond != null) conditions.add(diabetesCond);

    // Anemia detection
    final anemiaCond = _detectAnemia(values);
    if (anemiaCond != null) conditions.add(anemiaCond);

    // High cholesterol detection
    final cholesterolCond = _detectHighCholesterol(values);
    if (cholesterolCond != null) conditions.add(cholesterolCond);

    // Hypertension detection
    final hypertensionCond = _detectHypertension(values);
    if (hypertensionCond != null) conditions.add(hypertensionCond);

    // Vitamin D deficiency
    final vitaminDCond = _detectVitaminDDeficiency(values);
    if (vitaminDCond != null) conditions.add(vitaminDCond);

    // Thyroid issues
    final thyroidCond = _detectThyroidIssues(values);
    if (thyroidCond != null) conditions.add(thyroidCond);

    // Iron deficiency
    final ironCond = _detectIronDeficiency(values);
    if (ironCond != null) conditions.add(ironCond);

    return conditions;
  }

  /// Determine overall risk level
  static String getOverallRiskLevel(List<DetectedCondition> conditions) {
    if (conditions.isEmpty) return 'low';

    final maxSeverity =
        conditions.isEmpty ? ConditionSeverity.low : conditions.first.severity;

    for (final condition in conditions) {
      if (condition.severity == ConditionSeverity.critical) {
        return 'critical';
      }
      if (condition.severity == ConditionSeverity.high) {
        return 'high';
      }
      if (condition.severity == ConditionSeverity.medium &&
          maxSeverity != ConditionSeverity.high) {
        return 'medium';
      }
    }

    return 'low';
  }

  // ===== Detection Methods =====

  static DetectedCondition? _detectDiabetes(MedicalValues values) {
    if (values.glucose == null) return null;

    final glucose = values.glucose!;

    // Fasting glucose: <100 normal, 100-125 prediabetic, >125 diabetic
    if (glucose >= 126) {
      return DetectedCondition(
        name: 'Diabetes Mellitus',
        severity: glucose > 200 ? ConditionSeverity.high : ConditionSeverity.medium,
        description:
            'High fasting glucose level detected. Risk of diabetes is elevated.',
        confidence: _calculateConfidence(glucose, 100, 300),
        indicators: ['High Fasting Glucose (${glucose.toStringAsFixed(1)} mg/dL)'],
      );
    } else if (glucose >= 100) {
      return DetectedCondition(
        name: 'Prediabetes Risk',
        severity: ConditionSeverity.low,
        description: 'Borderline glucose levels. Monitor and lifestyle changes recommended.',
        confidence: 0.7,
        indicators: ['Borderline Glucose (${glucose.toStringAsFixed(1)} mg/dL)'],
      );
    }

    return null;
  }

  static DetectedCondition? _detectAnemia(MedicalValues values) {
    if (values.hemoglobin == null) return null;

    final hgb = values.hemoglobin!;

    // Normal: M >13.5, F >12.0. Mild anemia: 10-12, Moderate: 7-10, Severe: <7
    if (hgb < 10) {
      return DetectedCondition(
        name: 'Anemia',
        severity: hgb < 7 ? ConditionSeverity.critical : ConditionSeverity.high,
        description:
            'Low hemoglobin level detected. May cause fatigue and weakness.',
        confidence: _calculateConfidence(hgb, 13.5, 7),
        indicators: ['Low Hemoglobin (${hgb.toStringAsFixed(1)} g/dL)'],
      );
    } else if (hgb < 12) {
      return DetectedCondition(
        name: 'Mild Anemia',
        severity: ConditionSeverity.medium,
        description: 'Hemoglobin slightly below normal. Iron-rich diet recommended.',
        confidence: 0.75,
        indicators: ['Low-Normal Hemoglobin (${hgb.toStringAsFixed(1)} g/dL)'],
      );
    }

    return null;
  }

  static DetectedCondition? _detectHighCholesterol(MedicalValues values) {
    if (values.totalCholesterol == null) return null;

    final totalChol = values.totalCholesterol!;
    final ldl = values.ldl;

    if (totalChol >= 240 || (ldl != null && ldl >= 160)) {
      return DetectedCondition(
        name: 'High Cholesterol',
        severity: totalChol > 300 ? ConditionSeverity.high : ConditionSeverity.medium,
        description:
            'Elevated cholesterol increases cardiovascular disease risk.',
        confidence: _calculateConfidence(totalChol, 200, 300),
        indicators: [
          'High Total Cholesterol (${totalChol.toStringAsFixed(1)} mg/dL)',
          if (ldl != null) 'High LDL (${ldl.toStringAsFixed(1)} mg/dL)',
        ],
      );
    } else if (totalChol >= 200) {
      return DetectedCondition(
        name: 'Borderline High Cholesterol',
        severity: ConditionSeverity.low,
        description: 'Cholesterol is at borderline levels. Lifestyle changes recommended.',
        confidence: 0.6,
        indicators: ['Borderline Cholesterol (${totalChol.toStringAsFixed(1)} mg/dL)'],
      );
    }

    return null;
  }

  static DetectedCondition? _detectHypertension(MedicalValues values) {
    if (values.systolicBP == null || values.diastolicBP == null) return null;

    final systolic = values.systolicBP!;
    final diastolic = values.diastolicBP!;

    // Normal: <120/<80, Elevated: 120-129/<80, Stage1: 130-139/80-89, Stage2: >=140/>=90
    if (systolic >= 140 || diastolic >= 90) {
      return DetectedCondition(
        name: 'Hypertension (Stage 2)',
        severity: systolic > 160 || diastolic > 100
            ? ConditionSeverity.high
            : ConditionSeverity.medium,
        description:
            'High blood pressure detected. Risk of heart disease and stroke.',
        confidence: _calculateConfidence(systolic, 120, 200),
        indicators: [
          'High BP ($systolic/$diastolic mmHg)',
        ],
      );
    } else if (systolic >= 130 || diastolic >= 80) {
      return DetectedCondition(
        name: 'Hypertension (Stage 1)',
        severity: ConditionSeverity.low,
        description: 'Blood pressure is elevated. Monitor and reduce salt intake.',
        confidence: 0.65,
        indicators: ['Elevated BP ($systolic/$diastolic mmHg)'],
      );
    }

    return null;
  }

  static DetectedCondition? _detectVitaminDDeficiency(MedicalValues values) {
    if (values.vitaminD == null) return null;

    final vitD = values.vitaminD!;

    // <20 deficiency, 20-29 insufficiency, >=30 normal
    if (vitD < 20) {
      return DetectedCondition(
        name: 'Vitamin D Deficiency',
        severity: vitD < 10 ? ConditionSeverity.medium : ConditionSeverity.low,
        description:
            'Low vitamin D levels. Important for bone health and immunity.',
        confidence: 0.85,
        indicators: ['Low Vitamin D (${vitD.toStringAsFixed(1)} ng/mL)'],
      );
    } else if (vitD < 30) {
      return DetectedCondition(
        name: 'Vitamin D Insufficiency',
        severity: ConditionSeverity.low,
        description:
            'Vitamin D is below optimal levels. Sunlight and supplements recommended.',
        confidence: 0.7,
        indicators: ['Low-Normal Vitamin D (${vitD.toStringAsFixed(1)} ng/mL)'],
      );
    }

    return null;
  }

  static DetectedCondition? _detectThyroidIssues(MedicalValues values) {
    if (values.thyroidTSH == null) return null;

    final tsh = values.thyroidTSH!;

    // Normal: 0.4-4.0 mcIU/mL
    if (tsh > 4.0) {
      return DetectedCondition(
        name: 'Hypothyroidism Risk',
        severity: tsh > 10 ? ConditionSeverity.medium : ConditionSeverity.low,
        description:
            'High TSH suggests underactive thyroid. Fatigue and weight gain possible.',
        confidence: 0.8,
        indicators: ['High TSH (${tsh.toStringAsFixed(2)} mcIU/mL)'],
      );
    } else if (tsh < 0.4) {
      return DetectedCondition(
        name: 'Hyperthyroidism Risk',
        severity: tsh < 0.1 ? ConditionSeverity.medium : ConditionSeverity.low,
        description:
            'Low TSH suggests overactive thyroid. Anxiety and rapid heartbeat possible.',
        confidence: 0.8,
        indicators: ['Low TSH (${tsh.toStringAsFixed(2)} mcIU/mL)'],
      );
    }

    return null;
  }

  static DetectedCondition? _detectIronDeficiency(MedicalValues values) {
    if (values.iron == null) return null;

    final iron = values.iron!;

    // Normal: 60-170 µg/dL
    if (iron < 50) {
      return DetectedCondition(
        name: 'Iron Deficiency',
        severity: iron < 30 ? ConditionSeverity.medium : ConditionSeverity.low,
        description:
            'Low iron levels may cause anemia, fatigue, and weakness.',
        confidence: 0.8,
        indicators: ['Low Iron (${iron.toStringAsFixed(1)} µg/dL)'],
      );
    }

    return null;
  }

  // ===== Helper Methods =====

  /// Calculate confidence score (0-1) based on how far value is from normal range
  static double _calculateConfidence(
      double value, double normalMax, double extremeValue) {
    if (value <= normalMax) return 0.0;

    // Normalize between normalMax and extremeValue
    final normalized = (value - normalMax) / (extremeValue - normalMax);
    return (normalized.clamp(0.0, 1.0) * 0.5 + 0.5); // 0.5-1.0 range
  }
}
