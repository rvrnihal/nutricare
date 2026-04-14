import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String type; // tablet, liquid, injection, etc.
  final List<String> reminderTimes; // ["08:00", "14:00", "20:00"]
  final String frequency; // "daily", "twice_daily", "custom"
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> interactions; // Known food/drug interactions
  final String? notes;
  final DateTime createdAt;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    this.type = 'tablet',
    required this.reminderTimes,
    this.frequency = 'daily',
    required this.startDate,
    this.endDate,
    this.interactions = const [],
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'type': type,
      'reminderTimes': reminderTimes,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'interactions': interactions,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicine(
      id: doc.id,
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      type: data['type'] ?? 'tablet',
      reminderTimes: List<String>.from(data['reminderTimes'] ?? []),
      frequency: data['frequency'] ?? 'daily',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      interactions: List<String>.from(data['interactions'] ?? []),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Medicine.fromMap(Map<String, dynamic> data, String id) {
    return Medicine(
      id: id,
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      type: data['type'] ?? 'tablet',
      reminderTimes: List<String>.from(data['reminderTimes'] ?? []),
      frequency: data['frequency'] ?? 'daily',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      interactions: List<String>.from(data['interactions'] ?? []),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Medicine copyWith({
    String? name,
    String? dosage,
    String? type,
    List<String>? reminderTimes,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? interactions,
    String? notes,
  }) {
    return Medicine(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      type: type ?? this.type,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      interactions: interactions ?? this.interactions,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

class MedicineLog {
  final String id;
  final String userId;
  final String medicineId;
  final String medicineName;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool skipped;
  final String? skipReason;

  MedicineLog({
    required this.id,
    required this.userId,
    required this.medicineId,
    required this.medicineName,
    required this.scheduledTime,
    this.takenTime,
    this.skipped = false,
    this.skipReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'skipped': skipped,
      'skipReason': skipReason,
    };
  }

  factory MedicineLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicineLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      medicineId: data['medicineId'] ?? '',
      medicineName: data['medicineName'] ?? '',
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      takenTime: (data['takenTime'] as Timestamp?)?.toDate(),
      skipped: data['skipped'] ?? false,
      skipReason: data['skipReason'],
    );
  }

  bool get isTaken => takenTime != null;
  bool get isPending => !isTaken && !skipped;
}
