import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/services/groq_ai_service.dart';

/// Service for generating personalized workout plans based on health report
class WorkoutSuggestionService {
  static const String _collection = 'users';
  static const String _suggestionsCollection = 'workoutSuggestions';

  /// Generate workout plan based on health conditions
  static Future<Map<String, dynamic>> generateWorkoutPlan(
      String healthReport, String fitnessGoal, String experienceLevel) async {
    try {
      if (healthReport.isEmpty) {
        return {'error': 'Please provide health information'};
      }

      final prompt = '''
Create a personalized 7-day workout plan based on the following:

Health Conditions/Report: $healthReport
Fitness Goal: $fitnessGoal
Experience Level: $experienceLevel (Beginner/Intermediate/Advanced)

Please provide:
1. Recommended weekly exercise frequency and total duration
2. Exercises to AVOID based on health conditions
3. Recommended exercise types (cardio, strength, flexibility, etc.)
4. 7-day workout schedule with:
   - Exercise name
   - Duration
   - Sets/Reps/Intensity
   - Rest period
5. Warm-up and cool-down routines
6. Progressive overload strategy
7. Recovery and rest day recommendations
8. Injury prevention tips
9. Signs to stop exercising

Format clearly with sections and make it easy to follow.
''';

      final response = await GroqAIService.askAI(prompt);

      return {
        'healthReport': healthReport,
        'fitnessGoal': fitnessGoal,
        'experienceLevel': experienceLevel,
        'workoutPlan': response,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error generating workout plan: $e');
      return {'error': 'Failed to generate workout plan: $e'};
    }
  }

  /// Save workout plan to Firestore
  static Future<void> saveWorkoutPlan(Map<String, dynamic> plan) async {
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
      debugPrint('Error saving workout plan: $e');
      rethrow;
    }
  }

  /// Get saved workout plans
  static Future<List<Map<String, dynamic>>> getSavedWorkoutPlans() async {
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
      debugPrint('Error fetching workout plans: $e');
      return [];
    }
  }

  /// Get latest workout plan
  static Future<Map<String, dynamic>?> getLatestWorkoutPlan() async {
    try {
      final plans = await getSavedWorkoutPlans();
      return plans.isNotEmpty ? plans.first : null;
    } catch (e) {
      debugPrint('Error fetching latest workout plan: $e');
      return null;
    }
  }

  /// Delete a workout plan
  static Future<void> deleteWorkoutPlan(String planId) async {
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
      debugPrint('Error deleting workout plan: $e');
      rethrow;
    }
  }
}
