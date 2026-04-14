import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/models/nutrition_log_model.dart';
import 'package:nuticare/models/medicine_model.dart';
import '../core/logger.dart';

class UserHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  // ==================== NUTRITION LOGS ====================

  /// Save a nutrition log
  Future<void> saveNutritionLog(NutritionLog log) async {
    AppLogger.info('Saving nutrition log: ${log.foodName} (${log.calories} kcal)');
    final docRef = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('nutrition_logs')
        .add(log.toMap());
    AppLogger.debug('Saved nutrition log with ID: ${docRef.id}');
  }

  /// Get nutrition logs for a specific date
  Stream<List<NutritionLog>> getNutritionLogsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('nutrition_logs')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NutritionLog.fromFirestore(doc))
            .toList());
  }

  /// Get today's nutrition logs (static method for convenience)
  static Stream<List<NutritionLog>> getTodayNutritionLogs(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('nutrition_logs')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NutritionLog.fromFirestore(doc))
            .toList());
  }

  /// Get nutrition logs for a date range
  Future<List<NutritionLog>> getNutritionLogsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('nutrition_logs')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => NutritionLog.fromFirestore(doc)).toList();
  }

  // ==================== MEDICINE LOGS ====================

  /// Save a medicine log (when user takes medicine)
  Future<void> saveMedicineLog(MedicineLog log) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicine_logs')
        .add(log.toMap());
  }

  /// Get medicine logs for today
  Stream<List<MedicineLog>> getTodaysMedicineLogs() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicine_logs')
        .where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineLog.fromFirestore(doc))
            .toList());
  }

  /// Get medicine logs for a date range
  Future<List<MedicineLog>> getMedicineLogsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medicine_logs')
        .where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('scheduledTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('scheduledTime', descending: true)
        .get();

    return snapshot.docs.map((doc) => MedicineLog.fromFirestore(doc)).toList();
  }

  /// Mark medicine as taken
  Future<void> markMedicineAsTaken(
      String medicineId, String medicineName) async {
    final log = MedicineLog(
      id: '',
      userId: _userId,
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: DateTime.now(),
      takenTime: DateTime.now(),
      skipped: false,
    );

    await saveMedicineLog(log);
  }

  // ==================== WORKOUT HISTORY ====================
  // (Workouts are already being saved, just adding a convenience method)

  /// Get workout history
  Stream<List<Map<String, dynamic>>> getWorkoutHistory() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('workouts')
        .orderBy('startTime', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  // ==================== AGGREGATE DATA ====================

  /// Get daily summary statistics
  Future<Map<String, dynamic>> getDailySummary(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Get nutrition logs
    final nutritionLogs = await getNutritionLogsInRange(startOfDay, endOfDay);
    final totalCalories =
        nutritionLogs.fold<int>(0, (sum, log) => sum + log.calories);
    final totalProtein =
        nutritionLogs.fold<double>(0, (sum, log) => sum + log.protein);
    final totalCarbs =
        nutritionLogs.fold<double>(0, (sum, log) => sum + log.carbs);
    final totalFat = nutritionLogs.fold<double>(0, (sum, log) => sum + log.fat);

    // Get medicine logs
    final medicineLogs = await getMedicineLogsInRange(startOfDay, endOfDay);
    final medicinesTaken = medicineLogs.where((log) => log.isTaken).length;
    final medicinesScheduled = medicineLogs.length;

    // Get workout data
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

    return {
      'date': date,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'medicinesTaken': medicinesTaken,
      'medicinesScheduled': medicinesScheduled,
      'workoutMinutes': workoutMinutes,
      'caloriesBurned': caloriesBurned,
    };
  }
}
