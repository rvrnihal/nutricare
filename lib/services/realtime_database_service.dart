import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';

/// Service for handling Firebase Realtime Database operations
class RealtimeDatabaseService {
  static final RealtimeDatabaseService _instance =
      RealtimeDatabaseService._internal();

  late FirebaseDatabase _database;

  factory RealtimeDatabaseService() {
    return _instance;
  }

  RealtimeDatabaseService._internal() {
    _database = FirebaseDatabase.instance;
    _database.setPersistenceEnabled(true);
  }

  /// Get a reference to a specific path in the database
  DatabaseReference getRef(String path) {
    return _database.ref(path);
  }

  /// Write data to a specific path
  Future<void> writeData(String path, dynamic data) async {
    try {
      await _database.ref(path).set(data);
      AppLogger.info('Data written to $path');
    } catch (e) {
      AppLogger.error('Error writing data to $path', e);
      rethrow;
    }
  }

  /// Update data at a specific path (shallow update)
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    try {
      await _database.ref(path).update(data);
      AppLogger.info('Data updated at $path');
    } catch (e) {
      AppLogger.error('Error updating data at $path', e);
      rethrow;
    }
  }

  /// Read data once from a specific path
  Future<DataSnapshot> readDataOnce(String path) async {
    try {
      final snapshot = await _database.ref(path).get();
      AppLogger.info('Data read from $path');
      return snapshot;
    } catch (e) {
      AppLogger.error('Error reading data from $path', e);
      rethrow;
    }
  }

  /// Stream data from a specific path
  Stream<DatabaseEvent> streamData(String path) {
    return _database.ref(path).onValue;
  }

  /// Delete data at a specific path
  Future<void> deleteData(String path) async {
    try {
      await _database.ref(path).remove();
      AppLogger.info('Data deleted from $path');
    } catch (e) {
      AppLogger.error('Error deleting data from $path', e);
      rethrow;
    }
  }

  /// Get user-specific data path
  String getUserPath(String? userId) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    return 'users/$uid';
  }

  /// Get user nutrition logs path
  String getUserNutritionPath(String? userId) {
    return '${getUserPath(userId)}/nutrition_logs';
  }

  /// Get user workouts path
  String getUserWorkoutsPath(String? userId) {
    return '${getUserPath(userId)}/workouts';
  }

  /// Get user medicines path
  String getUserMedicinesPath(String? userId) {
    return '${getUserPath(userId)}/medicines';
  }

  /// Get user progress path
  String getUserProgressPath(String? userId) {
    return '${getUserPath(userId)}/progress';
  }

  /// Write nutrition log
  Future<void> writeNutritionLog(
    String logId,
    Map<String, dynamic> logData,
    String? userId,
  ) async {
    final path = '${getUserNutritionPath(userId)}/$logId';
    await writeData(path, logData);
  }

  /// Stream nutrition logs for user
  Stream<DatabaseEvent> streamNutritionLogs(String? userId) {
    return streamData(getUserNutritionPath(userId));
  }

  /// Write workout
  Future<void> writeWorkout(
    String workoutId,
    Map<String, dynamic> workoutData,
    String? userId,
  ) async {
    final path = '${getUserWorkoutsPath(userId)}/$workoutId';
    await writeData(path, workoutData);
  }

  /// Stream workouts for user
  Stream<DatabaseEvent> streamWorkouts(String? userId) {
    return streamData(getUserWorkoutsPath(userId));
  }

  /// Write medicine
  Future<void> writeMedicine(
    String medicineId,
    Map<String, dynamic> medicineData,
    String? userId,
  ) async {
    final path = '${getUserMedicinesPath(userId)}/$medicineId';
    await writeData(path, medicineData);
  }

  /// Stream medicines for user
  Stream<DatabaseEvent> streamMedicines(String? userId) {
    return streamData(getUserMedicinesPath(userId));
  }

  /// Update user progress
  Future<void> updateUserProgress(
    Map<String, dynamic> progressData,
    String? userId,
  ) async {
    await updateData(getUserProgressPath(userId), progressData);
  }

  /// Get reference to user progress
  DatabaseReference getUserProgressRef(String? userId) {
    return _database.ref(getUserProgressPath(userId));
  }
}
