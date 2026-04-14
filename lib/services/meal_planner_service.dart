import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'groq_ai_service.dart';

class MealPlannerService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<String> generateWeeklyPlan() async {
    final uid = _auth.currentUser!.uid;

    final result = await GroqAIService.askAI("""
You are a certified nutritionist.
Create a 7-day healthy meal plan.
Include breakfast, lunch, dinner and daily calories.
Keep it concise.
""");

    await _db.collection('meal_plans').doc(uid).set({
      'week': DateTime.now().toIso8601String(),
      'plan': result,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return result;
  }
}
