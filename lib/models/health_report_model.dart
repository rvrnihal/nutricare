import 'package:cloud_firestore/cloud_firestore.dart';

/// Medical values extracted from health reports
class MedicalValues {
  final double? glucose; // mg/dL
  final double? totalCholesterol; // mg/dL
  final double? ldl; // mg/dL (bad cholesterol)
  final double? hdl; // mg/dL (good cholesterol)
  final double? triglycerides; // mg/dL
  final double? hemoglobin; // g/dL
  final double? hematocrit; // %
  final double? vitaminD; // ng/mL
  final double? vitaminB12; // pg/mL
  final double? iron; // µg/dL
  final double? systolicBP; // mmHg
  final double? diastolicBP; // mmHg
  final double? bmi; // kg/m²
  final double? thyroidTSH; // mcIU/mL
  final String? bloodType;
  final Map<String, dynamic>? otherValues;

  MedicalValues({
    this.glucose,
    this.totalCholesterol,
    this.ldl,
    this.hdl,
    this.triglycerides,
    this.hemoglobin,
    this.hematocrit,
    this.vitaminD,
    this.vitaminB12,
    this.iron,
    this.systolicBP,
    this.diastolicBP,
    this.bmi,
    this.thyroidTSH,
    this.bloodType,
    this.otherValues,
  });

  factory MedicalValues.fromJson(Map<String, dynamic> json) {
    return MedicalValues(
      glucose: _parseDouble(json['glucose']),
      totalCholesterol: _parseDouble(json['totalCholesterol']),
      ldl: _parseDouble(json['ldl']),
      hdl: _parseDouble(json['hdl']),
      triglycerides: _parseDouble(json['triglycerides']),
      hemoglobin: _parseDouble(json['hemoglobin']),
      hematocrit: _parseDouble(json['hematocrit']),
      vitaminD: _parseDouble(json['vitaminD']),
      vitaminB12: _parseDouble(json['vitaminB12']),
      iron: _parseDouble(json['iron']),
      systolicBP: _parseDouble(json['systolicBP']),
      diastolicBP: _parseDouble(json['diastolicBP']),
      bmi: _parseDouble(json['bmi']),
      thyroidTSH: _parseDouble(json['thyroidTSH']),
      bloodType: json['bloodType'] as String?,
      otherValues: json['otherValues'] as Map<String, dynamic>?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'glucose': glucose,
        'totalCholesterol': totalCholesterol,
        'ldl': ldl,
        'hdl': hdl,
        'triglycerides': triglycerides,
        'hemoglobin': hemoglobin,
        'hematocrit': hematocrit,
        'vitaminD': vitaminD,
        'vitaminB12': vitaminB12,
        'iron': iron,
        'systolicBP': systolicBP,
        'diastolicBP': diastolicBP,
        'bmi': bmi,
        'thyroidTSH': thyroidTSH,
        'bloodType': bloodType,
        'otherValues': otherValues,
      };
}

/// Health report document
class HealthReport {
  final String id;
  final String userId;
  final String fileUrl;
  final String fileName;
  final DateTime uploadedAt;
  final DateTime? reportDate; // Date of the lab report itself
  final MedicalValues values;
  final String? analysisNotes;

  HealthReport({
    required this.id,
    required this.userId,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedAt,
    this.reportDate,
    required this.values,
    this.analysisNotes,
  });

  factory HealthReport.fromJson(Map<String, dynamic> json) {
    return HealthReport(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String,
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
      reportDate: json['reportDate'] != null
          ? (json['reportDate'] as Timestamp).toDate()
          : null,
      values: MedicalValues.fromJson(json['values'] as Map<String, dynamic>),
      analysisNotes: json['analysisNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'uploadedAt': uploadedAt,
        'reportDate': reportDate,
        'values': values.toJson(),
        'analysisNotes': analysisNotes,
      };
}

/// Detected health condition with severity
enum ConditionSeverity { low, medium, high, critical }

class DetectedCondition {
  final String name; // e.g., "Diabetes", "Anemia"
  final ConditionSeverity severity;
  final String description;
  final double confidence; // 0-1 score
  final List<String> indicators; // Which values triggered this

  DetectedCondition({
    required this.name,
    required this.severity,
    required this.description,
    required this.confidence,
    required this.indicators,
  });

  factory DetectedCondition.fromJson(Map<String, dynamic> json) {
    return DetectedCondition(
      name: json['name'] as String,
      severity:
          ConditionSeverity.values[json['severity'] as int],
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      indicators: List<String>.from(json['indicators'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'severity': severity.index,
        'description': description,
        'confidence': confidence,
        'indicators': indicators,
      };
}

/// Health analysis results
class HealthAnalysis {
  final String reportId;
  final DateTime analyzedAt;
  final List<DetectedCondition> detectedConditions;
  final String overallRiskLevel; // low, medium, high, critical
  final String summaryText;
  final Map<String, dynamic>? recommendations;

  HealthAnalysis({
    required this.reportId,
    required this.analyzedAt,
    required this.detectedConditions,
    required this.overallRiskLevel,
    required this.summaryText,
    this.recommendations,
  });

  factory HealthAnalysis.fromJson(Map<String, dynamic> json) {
    return HealthAnalysis(
      reportId: json['reportId'] as String,
      analyzedAt: (json['analyzedAt'] as Timestamp).toDate(),
      detectedConditions: (json['detectedConditions'] as List)
          .map((c) => DetectedCondition.fromJson(c as Map<String, dynamic>))
          .toList(),
      overallRiskLevel: json['overallRiskLevel'] as String,
      summaryText: json['summaryText'] as String,
      recommendations: json['recommendations'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'analyzedAt': analyzedAt,
        'detectedConditions':
            detectedConditions.map((c) => c.toJson()).toList(),
        'overallRiskLevel': overallRiskLevel,
        'summaryText': summaryText,
        'recommendations': recommendations,
      };
}
