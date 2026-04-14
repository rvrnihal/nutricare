import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionLog {
  final String id;
  final String userId;
  final String foodName;
  final int calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final String mealType; // "breakfast", "lunch", "dinner", "snack"
  final DateTime timestamp;
  final String? imageUrl;
  final String? notes;

  NutritionLog({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    required this.timestamp,
    this.imageUrl,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'mealType': mealType,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }

  factory NutritionLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NutritionLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      foodName: data['foodName'] ?? '',
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      protein: (data['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (data['fat'] as num?)?.toDouble() ?? 0.0,
      mealType: data['mealType'] ?? 'snack',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
      notes: data['notes'],
    );
  }

  factory NutritionLog.fromMap(Map<String, dynamic> data, String id) {
    return NutritionLog(
      id: id,
      userId: data['userId'] ?? '',
      foodName: data['foodName'] ?? '',
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      protein: (data['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (data['fat'] as num?)?.toDouble() ?? 0.0,
      mealType: data['mealType'] ?? 'snack',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
      notes: data['notes'],
    );
  }

  // Total macronutrients in calories
  double get proteinCalories => protein * 4;
  double get carbsCalories => carbs * 4;
  double get fatCalories => fat * 9;
}
