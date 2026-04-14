import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages daily nutrition data with automatic resets and historical tracking
class DailyNutritionService {
  static const String _collectionPath = 'users';
  static const String _dailyDataSubcollection = 'daily_nutrition_logs';
  static const int _resetHour = 0; // Reset at midnight (00:00)
  static String? _lastError;

  static String? get lastError => _lastError;

  /// Get today's date in YYYY-MM-DD format
  static String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get total calories for today
  static Future<double> getTodayCalories() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final today = _getTodayKey();
      final doc = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .collection(_dailyDataSubcollection)
          .doc(today)
          .get();

      if (doc.exists) {
        return (doc.data()?['totalCalories'] ?? 0).toDouble();
      }
      return 0;
    } catch (e) {
      print('Error getting today calories: $e');
      return 0;
    }
  }

  /// Get today's macros (protein, carbs, fat)
  static Future<Map<String, double>> getTodayMacros() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {'protein': 0, 'carbs': 0, 'fat': 0};

    try {
      final today = _getTodayKey();
      final doc = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .collection(_dailyDataSubcollection)
          .doc(today)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return {
          'protein': (data?['protein'] ?? 0).toDouble(),
          'carbs': (data?['carbs'] ?? 0).toDouble(),
          'fat': (data?['fat'] ?? 0).toDouble(),
        };
      }
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    } catch (e) {
      print('Error getting today macros: $e');
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }
  }

  /// Get today's meals
  static Future<List<Map<String, dynamic>>> getTodayMeals() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final today = _getTodayKey();
      final snapshot = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .collection(_dailyDataSubcollection)
          .doc(today)
          .collection('meals')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting today meals: $e');
      return [];
    }
  }

  /// Add a meal to today's log
  static Future<bool> addMealToday(String mealName, double calories,
      {double protein = 0, double carbs = 0, double fat = 0}) async {
    _lastError = null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _lastError = 'User not authenticated.';
      print('Error: User not authenticated');
      return false;
    }

    try {
      final today = _getTodayKey();
      final firestore = FirebaseFirestore.instance;
      final dailyDocRef = firestore
          .collection(_collectionPath)
          .doc(uid)
          .collection(_dailyDataSubcollection)
          .doc(today);
      final mealDocRef = dailyDocRef.collection('meals').doc();

      final batch = firestore.batch();

      // Merge with increments so this is safe even when the daily document doesn't exist.
      batch.set(
        dailyDocRef,
        {
          'date': today,
          'lastUpdated': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'totalCalories': FieldValue.increment(calories),
          'protein': FieldValue.increment(protein),
          'carbs': FieldValue.increment(carbs),
          'fat': FieldValue.increment(fat),
          'mealCount': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );

      batch.set(mealDocRef, {
        'mealName': mealName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Adding meal (batched): $mealName ($calories cal)');
      await batch.commit();

      print('Meal successfully added!');
      return true;
    } on FirebaseException catch (e) {
      _lastError = '${e.code}: ${e.message ?? 'Unknown Firebase error'}';
      print('Error adding meal: ${_lastError!}');
      return false;
    } catch (e) {
      _lastError = e.toString();
      print('Error adding meal: ${_lastError!}');
      return false;
    }
  }

  /// Reset today's data (or get a fresh start if called before reset)
  static Future<bool> resetTodayData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final today = _getTodayKey();
      await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .collection(_dailyDataSubcollection)
          .doc(today)
          .set({
        'date': today,
        'totalCalories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
        'mealCount': 0,
        'lastReset': FieldValue.serverTimestamp(),
      });

      // Delete meals subcollection
      final meals = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .collection(_dailyDataSubcollection)
          .doc(today)
          .collection('meals')
          .get();

      for (var meal in meals.docs) {
        await meal.reference.delete();
      }

      return true;
    } catch (e) {
      print('Error resetting today data: $e');
      return false;
    }
  }

  /// Get historical data for a specific date
  static Future<Map<String, dynamic>> getDayData(String dateKey) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .collection(_dailyDataSubcollection)
          .doc(dateKey)
          .get();

      return doc.data() ?? {};
    } catch (e) {
      print('Error getting day data: $e');
      return {};
    }
  }

  /// Get last N days of nutrition data
  static Future<List<Map<String, dynamic>>> getHistoricalData(
      {int days = 30}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final snapshot = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .collection(_dailyDataSubcollection)
          .where('date', isGreaterThanOrEqualTo: _formatDateKey(startDate))
          .orderBy('date', descending: true)
          .limit(days)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting historical data: $e');
      return [];
    }
  }

  /// Stream today's data in real-time
  static Stream<Map<String, dynamic>> watchTodayData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value({});
    }

    final today = _getTodayKey();
    return FirebaseFirestore.instance
        .collection(_collectionPath)
        .doc(uid)
        .collection(_dailyDataSubcollection)
        .doc(today)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  /// Stream meals for today in real-time
  static Stream<List<Map<String, dynamic>>> watchTodayMeals() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }

    final today = _getTodayKey();
    return FirebaseFirestore.instance
        .collection(_collectionPath)
        .doc(uid)
        .collection(_dailyDataSubcollection)
        .doc(today)
        .collection('meals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get nutritional goals for the user
  static Future<Map<String, double>> getGoals() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return {'calorieGoal': 2000, 'proteinGoal': 50, 'carbGoal': 300, 'fatGoal': 65};
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .get();

      final data = doc.data();
      return {
        'calorieGoal': ((data?['calorieGoal'] ?? 2000) as num).toDouble(),
        'proteinGoal': ((data?['proteinGoal'] ?? 50) as num).toDouble(),
        'carbGoal': ((data?['carbGoal'] ?? 300) as num).toDouble(),
        'fatGoal': ((data?['fatGoal'] ?? 65) as num).toDouble(),
      };
    } catch (e) {
      print('Error getting goals: $e');
      return {'calorieGoal': 2000, 'proteinGoal': 50, 'carbGoal': 300, 'fatGoal': 65};
    }
  }

  /// Update user's nutritional goals
  static Future<bool> setGoals(double calorieGoal, double proteinGoal,
      double carbGoal, double fatGoal) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .set({
        'calorieGoal': calorieGoal,
        'proteinGoal': proteinGoal,
        'carbGoal': carbGoal,
        'fatGoal': fatGoal,
        'goalsUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error setting goals: $e');
      return false;
    }
  }

  /// Get average daily calories for period
  static Future<double> getAverageDailyCalories({int days = 7}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final snapshot = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(uid)
          .collection(_dailyDataSubcollection)
          .where('date', isGreaterThanOrEqualTo: _formatDateKey(startDate))
          .get();

      if (snapshot.docs.isEmpty) return 0;

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['totalCalories'] ?? 0).toDouble();
      }

      return total / snapshot.docs.length;
    } catch (e) {
      print('Error getting average calories: $e');
      return 0;
    }
  }

  /// Format DateTime to date key string
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get this week's summary
  static Future<Map<String, dynamic>> getWeeklySummary() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};

    try {
      final historicalData = await getHistoricalData(days: 7);
      
      if (historicalData.isEmpty) {
        return {
          'daysLogged': 0,
          'totalCalories': 0,
          'averageCalories': 0,
          'totalProtein': 0,
          'totalCarbs': 0,
          'totalFat': 0,
        };
      }

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      int daysLogged = 0;

      for (var day in historicalData) {
        if ((day['totalCalories'] ?? 0) > 0) {
          daysLogged++;
          totalCalories += (day['totalCalories'] ?? 0).toDouble();
          totalProtein += (day['protein'] ?? 0).toDouble();
          totalCarbs += (day['carbs'] ?? 0).toDouble();
          totalFat += (day['fat'] ?? 0).toDouble();
        }
      }

      return {
        'daysLogged': daysLogged,
        'totalCalories': totalCalories,
        'averageCalories': daysLogged > 0 ? totalCalories / daysLogged : 0,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
      };
    } catch (e) {
      print('Error getting weekly summary: $e');
      return {};
    }
  }
}
