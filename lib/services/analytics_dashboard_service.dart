import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/services/daily_nutrition_service.dart';
import 'package:nuticare/services/bmr_calculation_service.dart';

class AnalyticsDashboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get comprehensive dashboard data
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get today's nutrition data
      final todayData = await DailyNutritionService.getDayData(DateTime.now() as String);
      
      // Get health profile with BMR calcs
      final healthProfile = await BMRCalculationService.getHealthProfile();
      
      // Get recent workouts
      final workouts = await _getRecentWorkouts(user.uid, days: 7);
      
      // Get medicine adherence
      final medicineAdherence = await _getMedicineAdherence(user.uid);
      
      // Calculate progress metrics
      final progressMetrics = _calculateProgressMetrics(
        todayData,
        healthProfile,
        workouts,
      );

      return {
        'today_nutrition': todayData,
        'health_profile': healthProfile,
        'recent_workouts': workouts,
        'medicine_adherence': medicineAdherence,
        'progress_metrics': progressMetrics,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      print('Error getting dashboard data: $e');
      rethrow;
    }
  }

  /// Calculate progress metrics compared to goals
  static Map<String, dynamic> _calculateProgressMetrics(
    Map<String, dynamic>? nutrition,
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>> workouts,
  ) {
    if (nutrition == null || profile == null) {
      return {
        'calorie_progress': 0.0,
        'protein_progress': 0.0,
        'carbs_progress': 0.0,
        'fats_progress': 0.0,
        'workout_progress': 0.0,
        'adherence_score': 0.0,
      };
    }

    final dailyCalories = profile['daily_calories'] ?? 2000;
    final macrosTarget = profile['macros_target'] ?? {};
    
    double calorieProgress = (nutrition['totalCalories'] ?? 0) / dailyCalories;
    double proteinProgress = (nutrition['protein'] ?? 0) / (macrosTarget['protein'] ?? 100);
    double carbsProgress = (nutrition['carbs'] ?? 0) / (macrosTarget['carbs'] ?? 100);
    double fatsProgress = (nutrition['fat'] ?? 0) / (macrosTarget['fats'] ?? 100);

    // Calculate workout progress (7-day average)
    double workoutProgress = workouts.isNotEmpty ? 1.0 : 0.0;

    // Calculate adherence score (0-100)
    double adherenceScore = ((calorieProgress.clamp(0.0, 1.0) +
                proteinProgress.clamp(0.0, 1.0) +
                carbsProgress.clamp(0.0, 1.0) +
                fatsProgress.clamp(0.0, 1.0) +
                workoutProgress) /
            5) *
        100;

    return {
      'calorie_progress': calorieProgress.clamp(0.0, 1.5),
      'protein_progress': proteinProgress.clamp(0.0, 1.5),
      'carbs_progress': carbsProgress.clamp(0.0, 1.5),
      'fats_progress': fatsProgress.clamp(0.0, 1.5),
      'workout_progress': workoutProgress,
      'adherence_score': adherenceScore.clamp(0.0, 100.0),
    };
  }

  /// Get recent workouts for analytics
  static Future<List<Map<String, dynamic>>> _getRecentWorkouts(
    String userId, {
    int days = 7,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      
      final workouts = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('date', descending: true)
          .limit(20)
          .get();

      return workouts.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting recent workouts: $e');
      return [];
    }
  }

  /// Get medicine adherence percentage
  static Future<Map<String, dynamic>> _getMedicineAdherence(String userId) async {
    try {
      final medicines = await _firestore
          .collection('users')
          .doc(userId)
          .collection('medicine_logs')
          .where('date',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime.now().subtract(Duration(days: 7))))
          .get();

      int totalScheduled = 0;
      int totalTaken = 0;

      for (var doc in medicines.docs) {
        totalScheduled++;
        if (doc['status'] == 'taken') {
          totalTaken++;
        }
      }

      double adherencePercentage =
          totalScheduled > 0 ? (totalTaken / totalScheduled) * 100 : 0.0;

      return {
        'total_scheduled': totalScheduled,
        'total_taken': totalTaken,
        'adherence_percentage': adherencePercentage.clamp(0.0, 100.0),
      };
    } catch (e) {
      print('Error getting medicine adherence: $e');
      return {
        'total_scheduled': 0,
        'total_taken': 0,
        'adherence_percentage': 0.0,
      };
    }
  }

  /// Get nutrition trends (last 7/14/30 days)
  static Future<List<Map<String, dynamic>>> getNutritionTrends(int days) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final startDate = DateTime.now().subtract(Duration(days: days));

      final logs = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_nutrition_logs')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('date', descending: true)
          .get();

      return logs.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting nutrition trends: $e');
      return [];
    }
  }

  /// Get fitness trends (last 7/14/30 days)
  static Future<List<Map<String, dynamic>>> getFitnessTrends(int days) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final startDate = DateTime.now().subtract(Duration(days: days));

      final workouts = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('date', descending: true)
          .get();

      return workouts.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting fitness trends: $e');
      return [];
    }
  }

  /// Watch dashboard data in real-time
  static Stream<Map<String, dynamic>> watchDashboardData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .asyncMap((doc) async {
      final data = doc.data();
      if (data == null) {
        return {
          'health_profile': null,
          'today_nutrition': null,
          'workouts': [],
        };
      }

      // Get today's nutrition
      final todayData = await DailyNutritionService.getDayData(DateTime.now().toString());

      return {
        'health_profile': data['health_profile'],
        'today_nutrition': todayData,
        'fitness_goal': data['fitness_goal'],
        'timestamp': DateTime.now(),
      };
    });
  }

  /// Save health score to Firestore for tracking
  static Future<void> saveHealthScore(double score) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('health_scores')
          .add({
            'score': score.clamp(0.0, 100.0),
            'date': FieldValue.serverTimestamp(),
            'timestamp': DateTime.now(),
          });
    } catch (e) {
      print('Error saving health score: $e');
    }
  }

  /// Get health score history
  static Future<List<Map<String, dynamic>>> getHealthScoreHistory(int days) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final startDate = DateTime.now().subtract(Duration(days: days));

      final scores = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('health_scores')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('date', descending: true)
          .get();

      return scores.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting health score history: $e');
      return [];
    }
  }
}
