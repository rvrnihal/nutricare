import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/services/groq_ai_service.dart';

/// Service for generating personalized diet plans based on health report
class DietSuggestionService {
  static const String _collection = 'users';
  static const String _suggestionsCollection = 'dietSuggestions';

  /// Generate diet plan based on health conditions
  static Future<Map<String, dynamic>> generateDietPlan(
      String healthReport, String fitnessGoal) async {
    try {
      if (healthReport.isEmpty) {
        return {'error': 'Please provide health information'};
      }

      final prompt = '''
Based on the following health conditions and fitness goal, create a personalized 7-day meal plan.

Health Conditions/Report: $healthReport
Fitness Goal: $fitnessGoal

Please provide:
1. Daily calorie target (based on conditions)
2. Macro breakdown (carbs, protein, fats)
3. 7-day meal plan (Breakfast, Lunch, Dinner, Snacks)
4. Foods to AVOID based on health conditions
5. Foods to INCLUDE for optimal health
6. Meal prep tips
7. Hydration guidelines

Format the response clearly with sections and bullet points.
''';

      final response = await GroqAIService.askAI(prompt);

      return {
        'healthReport': healthReport,
        'fitnessGoal': fitnessGoal,
        'mealPlan': response,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error generating diet plan: $e');
      return {'error': 'Failed to generate diet plan: $e'};
    }
  }

  /// Save diet suggestion to Firestore
  static Future<void> saveDietPlan(Map<String, dynamic> plan) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .collection(_suggestionsCollection)
          .add({
        ...plan,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving diet plan: $e');
      rethrow;
    }
  }

  /// Get saved diet plans
  static Future<List<Map<String, dynamic>>> getSavedDietPlans() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .collection(_suggestionsCollection)
          .orderBy('savedAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      debugPrint('Error fetching diet plans: $e');
      return [];
    }
  }

  /// Get latest diet plan
  static Future<Map<String, dynamic>?> getLatestDietPlan() async {
    try {
      final plans = await getSavedDietPlans();
      return plans.isNotEmpty ? plans.first : null;
    } catch (e) {
      debugPrint('Error fetching latest diet plan: $e');
      return null;
    }
  }

  /// Delete a diet plan
  static Future<void> deleteDietPlan(String planId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .collection(_suggestionsCollection)
          .doc(planId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting diet plan: $e');
      rethrow;
    }
  }
}
