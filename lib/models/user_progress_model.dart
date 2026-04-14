import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressEntry {
  final String id;
  final String userId;
  final DateTime date;
  final double? weight; // kg
  final double? bmi;
  final Map<String, double> measurements; // chest, waist, hips, etc.
  final String? notes;
  final int? workoutMinutes;
  final int? caloriesBurned;
  final int? caloriesConsumed;
  final int? medicinesTaken;
  final int? medicinesScheduled;

  ProgressEntry({
    required this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.bmi,
    this.measurements = const {},
    this.notes,
    this.workoutMinutes,
    this.caloriesBurned,
    this.caloriesConsumed,
    this.medicinesTaken,
    this.medicinesScheduled,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'weight': weight,
      'bmi': bmi,
      'measurements': measurements,
      'notes': notes,
      'workoutMinutes': workoutMinutes,
      'caloriesBurned': caloriesBurned,
      'caloriesConsumed': caloriesConsumed,
      'medicinesTaken': medicinesTaken,
      'medicinesScheduled': medicinesScheduled,
    };
  }

  factory ProgressEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weight: (data['weight'] as num?)?.toDouble(),
      bmi: (data['bmi'] as num?)?.toDouble(),
      measurements: Map<String, double>.from(data['measurements'] ?? {}),
      notes: data['notes'],
      workoutMinutes: data['workoutMinutes'],
      caloriesBurned: data['caloriesBurned'],
      caloriesConsumed: data['caloriesConsumed'],
      medicinesTaken: data['medicinesTaken'],
      medicinesScheduled: data['medicinesScheduled'],
    );
  }

  // Medicine adherence percentage
  double? get medicineAdherence {
    if (medicinesScheduled == null || medicinesScheduled == 0) return null;
    return (medicinesTaken ?? 0) / medicinesScheduled! * 100;
  }

  // Calorie deficit/surplus
  int? get calorieBalance {
    if (caloriesConsumed == null || caloriesBurned == null) return null;
    return caloriesConsumed! - caloriesBurned!;
  }
}

class UserHealthHistory {
  final String userId;
  final List<ProgressEntry> entries;

  UserHealthHistory({
    required this.userId,
    required this.entries,
  });

  // Get entries for a specific date range
  List<ProgressEntry> getEntriesInRange(DateTime start, DateTime end) {
    return entries.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get average weight over the last N days
  double? getAverageWeight(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentEntries =
        entries.where((e) => e.date.isAfter(cutoffDate) && e.weight != null);

    if (recentEntries.isEmpty) return null;

    final totalWeight =
        recentEntries.fold<double>(0, (sum, e) => sum + e.weight!);
    return totalWeight / recentEntries.length;
  }

  // Get average medicine adherence
  double? getAverageMedicineAdherence(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentEntries = entries.where(
        (e) => e.date.isAfter(cutoffDate) && e.medicineAdherence != null);

    if (recentEntries.isEmpty) return null;

    final total =
        recentEntries.fold<double>(0, (sum, e) => sum + e.medicineAdherence!);
    return total / recentEntries.length;
  }

  // Get total workout minutes
  int getTotalWorkoutMinutes(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return entries
        .where((e) => e.date.isAfter(cutoffDate))
        .fold<int>(0, (sum, e) => sum + (e.workoutMinutes ?? 0));
  }
}
