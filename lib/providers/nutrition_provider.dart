import 'package:flutter/material.dart';
import 'package:nuticare/services/groq_ai_service.dart';

class NutritionProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _mealPlan;
  Map<String, dynamic>? _analyzedFood;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get mealPlan => _mealPlan;
  Map<String, dynamic>? get analyzedFood => _analyzedFood;

  // Generate Meal Plan
  Future<void> generateMealPlan({
    required int calories,
    required String dietType,
    required List<String> allergies,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final plan = await GroqAIService.createMealPlan({
        "targetCalories": calories,
        "dietType": dietType,
        "allergies": allergies,
      });
      _mealPlan = plan;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Analyze Food Text
  Future<void> analyzeFood(String foodName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final analysis = await GroqAIService.analyzeFood(foodName);
      _analyzedFood = analysis;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Analyze Food Image
  Future<void> analyzeFoodImage(String base64Image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final foodName = await GroqAIService.analyzeImageFood(base64Image);
      // After getting name, get stats
      await analyzeFood(foodName);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

