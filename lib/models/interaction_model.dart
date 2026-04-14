import 'package:cloud_firestore/cloud_firestore.dart';

enum InteractionSeverity {
  mild,
  moderate,
  severe,
  critical,
}

class FoodMedicineInteraction {
  final String id;
  final String medicineName;
  final String foodName;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;
  final List<String> symptoms; // Possible symptoms
  final DateTime? lastChecked; // For cache invalidation

  FoodMedicineInteraction({
    required this.id,
    required this.medicineName,
    required this.foodName,
    required this.severity,
    required this.description,
    required this.recommendation,
    this.symptoms = const [],
    this.lastChecked,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'foodName': foodName,
      'severity': severity.name,
      'description': description,
      'recommendation': recommendation,
      'symptoms': symptoms,
      'lastChecked':
          lastChecked != null ? Timestamp.fromDate(lastChecked!) : null,
    };
  }

  factory FoodMedicineInteraction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodMedicineInteraction(
      id: doc.id,
      medicineName: data['medicineName'] ?? '',
      foodName: data['foodName'] ?? '',
      severity: _parseSeverity(data['severity']),
      description: data['description'] ?? '',
      recommendation: data['recommendation'] ?? '',
      symptoms: List<String>.from(data['symptoms'] ?? []),
      lastChecked: (data['lastChecked'] as Timestamp?)?.toDate(),
    );
  }

  factory FoodMedicineInteraction.fromMap(
      Map<String, dynamic> data, String id) {
    return FoodMedicineInteraction(
      id: id,
      medicineName: data['medicineName'] ?? '',
      foodName: data['foodName'] ?? '',
      severity: _parseSeverity(data['severity']),
      description: data['description'] ?? '',
      recommendation: data['recommendation'] ?? '',
      symptoms: List<String>.from(data['symptoms'] ?? []),
      lastChecked: (data['lastChecked'] as Timestamp?)?.toDate(),
    );
  }

  static InteractionSeverity _parseSeverity(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'mild':
        return InteractionSeverity.mild;
      case 'moderate':
        return InteractionSeverity.moderate;
      case 'severe':
        return InteractionSeverity.severe;
      case 'critical':
        return InteractionSeverity.critical;
      default:
        return InteractionSeverity.mild;
    }
  }

  String get severityLabel {
    switch (severity) {
      case InteractionSeverity.mild:
        return 'Mild';
      case InteractionSeverity.moderate:
        return 'Moderate';
      case InteractionSeverity.severe:
        return 'Severe';
      case InteractionSeverity.critical:
        return 'Critical';
    }
  }

  bool get isCritical =>
      severity == InteractionSeverity.critical ||
      severity == InteractionSeverity.severe;
}

class InteractionCheckResult {
  final bool hasInteraction;
  final List<FoodMedicineInteraction> interactions;
  final String? errorMessage;

  InteractionCheckResult({
    required this.hasInteraction,
    this.interactions = const [],
    this.errorMessage,
  });

  factory InteractionCheckResult.noInteraction() {
    return InteractionCheckResult(hasInteraction: false);
  }

  factory InteractionCheckResult.withInteractions(
      List<FoodMedicineInteraction> interactions) {
    return InteractionCheckResult(
      hasInteraction: interactions.isNotEmpty,
      interactions: interactions,
    );
  }

  factory InteractionCheckResult.error(String message) {
    return InteractionCheckResult(
      hasInteraction: false,
      errorMessage: message,
    );
  }

  bool get hasCriticalInteraction => interactions.any((i) => i.isCritical);
}
