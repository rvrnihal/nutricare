import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BMRCalculationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Calculate Basal Metabolic Rate using Harris-Benedict equation
  /// Returns calories burned at rest per day
  static double calculateBMR({
    required int ageYears,
    required double heightCm,
    required double weightKg,
    required String gender,
  }) {
    double bmr;

    if (gender.toLowerCase() == 'male') {
      // Harris-Benedict Formula for Men
      bmr = 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * ageYears);
    } else {
      // Harris-Benedict Formula for Women
      bmr = 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * ageYears);
    }

    return bmr;
  }

  /// Calculate Total Daily Energy Expenditure (TDEE)
  /// TDEE = BMR × Activity Factor
  static double calculateTDEE(double bmr, String activityLevel) {
    double activityFactor;

    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityFactor = 1.2; // Little to no exercise
        break;
      case 'lightly_active':
        activityFactor = 1.375; // Light exercise 1-3 days/week
        break;
      case 'moderately_active':
        activityFactor = 1.55; // Moderate exercise 3-5 days/week
        break;
      case 'very_active':
        activityFactor = 1.725; // Hard exercise 6-7 days/week
        break;
      case 'extremely_active':
        activityFactor = 1.9; // Very hard exercise/physical job
        break;
      default:
        activityFactor = 1.55;
    }

    return bmr * activityFactor;
  }

  /// Calculate recommended daily calories based on fitness goal
  static double calculateDailyCalories(
    double tdee,
    String fitnessGoal,
  ) {
    switch (fitnessGoal.toLowerCase()) {
      case 'lose_weight':
        // 500 calorie deficit per day = 0.5 kg weight loss per week
        return tdee - 500;
      case 'gain_muscle':
        // 300-500 calorie surplus for muscle building
        return tdee + 400;
      case 'maintain':
      default:
        return tdee;
    }
  }

  /// Calculate macronutrient targets based on fitness goal
  static Map<String, double> calculateMacros(
    double dailyCalories,
    String fitnessGoal,
    double weightKg,
  ) {
    double proteinGrams;
    double carbsGrams;
    double fatsGrams;

    switch (fitnessGoal.toLowerCase()) {
      case 'gain_muscle':
        // Higher protein for muscle building: 1.6-2.2g per kg
        proteinGrams = weightKg * 1.8;
        carbsGrams = (dailyCalories * 0.45) / 4; // 45% carbs
        fatsGrams = (dailyCalories * 0.25) / 9; // 25% fats
        break;
      case 'lose_weight':
        // Higher protein to preserve muscle: 1.6-2.2g per kg
        proteinGrams = weightKg * 1.8;
        carbsGrams = (dailyCalories * 0.35) / 4; // 35% carbs
        fatsGrams = (dailyCalories * 0.30) / 9; // 30% fats
        break;
      case 'maintain':
      default:
        // Balanced macros
        proteinGrams = (dailyCalories * 0.30) / 4; // 30% protein
        carbsGrams = (dailyCalories * 0.45) / 4; // 45% carbs
        fatsGrams = (dailyCalories * 0.25) / 9; // 25% fats
        break;
    }

    return {
      'protein': proteinGrams,
      'carbs': carbsGrams,
      'fats': fatsGrams,
    };
  }

  /// Save user health profile with BMR calculations
  static Future<void> saveHealthProfile({
    required int ageYears,
    required double heightCm,
    required double weightKg,
    required String gender,
    required String activityLevel,
    required String fitnessGoal,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Calculate metrics
      final bmr = calculateBMR(
        ageYears: ageYears,
        heightCm: heightCm,
        weightKg: weightKg,
        gender: gender,
      );

      final tdee = calculateTDEE(bmr, activityLevel);
      final dailyCalories = calculateDailyCalories(tdee, fitnessGoal);
      final macros = calculateMacros(dailyCalories, fitnessGoal, weightKg);

      // Calculate BMI
      final bmi = weightKg / ((heightCm / 100) * (heightCm / 100));

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'health_profile': {
          'age': ageYears,
          'height_cm': heightCm,
          'weight_kg': weightKg,
          'gender': gender,
          'activity_level': activityLevel,
          'fitness_goal': fitnessGoal,
          'bmi': bmi,
          'bmr': bmr,
          'tdee': tdee,
          'daily_calories': dailyCalories,
          'macros_target': macros,
          'updated_at': FieldValue.serverTimestamp(),
        }
      });
    } catch (e) {
      print('Error saving health profile: $e');
      rethrow;
    }
  }

  /// Get user health profile with calculations
  static Future<Map<String, dynamic>?> getHealthProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['health_profile'];
    } catch (e) {
      print('Error getting health profile: $e');
      return null;
    }
  }

  /// Get BMI category text
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal Weight';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Watch health profile changes in real-time
  static Stream<Map<String, dynamic>?> watchHealthProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data()?['health_profile']);
  }
}
