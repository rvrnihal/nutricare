import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/models/user_progress_model.dart';

class ProgressTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  /// Save a progress entry
  Future<void> saveProgressEntry(ProgressEntry entry) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('progress_entries')
        .add(entry.toMap());
  }

  /// Get progress entries for a date range
  Future<List<ProgressEntry>> getProgressEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    Query query = _firestore
        .collection('users')
        .doc(_userId)
        .collection('progress_entries')
        .orderBy('date', descending: true);

    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query =
          query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ProgressEntry.fromFirestore(doc))
        .toList();
  }

  /// Get the full user health history
  Future<UserHealthHistory> getUserHealthHistory({int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final entries = await getProgressEntries(startDate: startDate);

    return UserHealthHistory(
      userId: _userId,
      entries: entries,
    );
  }

  /// Calculate and save today's progress snapshot
  Future<void> saveAutoProgressSnapshot() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if we already have an entry for today
    final existingSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('progress_entries')
        .where('date', isEqualTo: Timestamp.fromDate(today))
        .limit(1)
        .get();

    if (existingSnapshot.docs.isNotEmpty) {
      // Update existing entry
      final docId = existingSnapshot.docs.first.id;
      final stats = await _calculateDailyStats(today);

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('progress_entries')
          .doc(docId)
          .update(stats);
    } else {
      // Create new entry
      final stats = await _calculateDailyStats(today);
      final entry = ProgressEntry(
        id: '',
        userId: _userId,
        date: today,
        workoutMinutes: stats['workoutMinutes'],
        caloriesBurned: stats['caloriesBurned'],
        caloriesConsumed: stats['caloriesConsumed'],
        medicinesTaken: stats['medicinesTaken'],
        medicinesScheduled: stats['medicinesScheduled'],
      );

      await saveProgressEntry(entry);
    }
  }

  /// Calculate daily statistics
  Future<Map<String, dynamic>> _calculateDailyStats(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Workout stats
    final workoutsSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final workoutMinutes = workoutsSnapshot.docs.fold<int>(
      0,
      (sum, doc) => sum + ((doc.data()['durationSeconds'] as int?) ?? 0) ~/ 60,
    );

    final caloriesBurned = workoutsSnapshot.docs.fold<int>(
      0,
      (sum, doc) =>
          sum + ((doc.data()['caloriesBurned'] as num?)?.toInt() ?? 0),
    );

    // Nutrition stats
    final nutritionSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('nutrition_logs')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final caloriesConsumed = nutritionSnapshot.docs.fold<int>(
      0,
      (sum, doc) => sum + ((doc.data()['calories'] as num?)?.toInt() ?? 0),
    );

    // Medicine stats
    final medicineSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicine_logs')
        .where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final medicinesTaken = medicineSnapshot.docs
        .where((doc) => doc.data()['takenTime'] != null)
        .length;
    final medicinesScheduled = medicineSnapshot.docs.length;

    return {
      'workoutMinutes': workoutMinutes,
      'caloriesBurned': caloriesBurned,
      'caloriesConsumed': caloriesConsumed,
      'medicinesTaken': medicinesTaken,
      'medicinesScheduled': medicinesScheduled,
    };
  }

  /// Get weight trend (last N days)
  Future<List<Map<String, dynamic>>> getWeightTrend(int days) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final entries = await getProgressEntries(startDate: startDate);

    return entries
        .where((e) => e.weight != null)
        .map((e) => {
              'date': e.date,
              'weight': e.weight,
            })
        .toList();
  }

  /// Get medicine adherence trend
  Future<List<Map<String, dynamic>>> getMedicineAdherenceTrend(int days) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final entries = await getProgressEntries(startDate: startDate);

    return entries
        .where((e) => e.medicineAdherence != null)
        .map((e) => {
              'date': e.date,
              'adherence': e.medicineAdherence,
            })
        .toList();
  }

  /// Get workout consistency (days with workouts)
  Future<Map<String, dynamic>> getWorkoutConsistency(int days) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final entries = await getProgressEntries(startDate: startDate);

    final daysWithWorkouts = entries
        .where((e) => e.workoutMinutes != null && e.workoutMinutes! > 0)
        .length;

    final totalMinutes = entries.fold<int>(
      0,
      (sum, e) => sum + (e.workoutMinutes ?? 0),
    );

    return {
      'daysWithWorkouts': daysWithWorkouts,
      'totalDays': days,
      'consistencyPercentage': (daysWithWorkouts / days) * 100,
      'totalMinutes': totalMinutes,
      'averageMinutesPerDay': totalMinutes / days,
    };
  }
}
