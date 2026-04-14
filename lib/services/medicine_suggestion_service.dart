import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/services/groq_ai_service.dart';

/// Service for suggesting medicines based on user's health report and conditions
class MedicineSuggestionService {
  static const String _collection = 'users';
  static const String _healthReportField = 'healthReport';
  static const String _suggestionsCollection = 'medicineSuggestions';

  /// Get health conditions from user profile
  static Future<List<String>> getUserHealthConditions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final healthReport = data[_healthReportField] as String? ?? '';
        if (healthReport.isEmpty) return [];
        
        // Split by comma and clean up
        return healthReport
            .split(',')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching health conditions: $e');
      return [];
    }
  }

  /// Save or update health report
  static Future<void> saveHealthReport(String healthReport) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .update({
        _healthReportField: healthReport,
        'healthReportUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving health report: $e');
      rethrow;
    }
  }

  /// Generate medicine suggestions based on health conditions
  static Future<Map<String, dynamic>> generateMedicineSuggestions(
      String conditions) async {
    try {
      if (conditions.isEmpty) {
        return {'error': 'Please provide health conditions'};
      }

      final prompt = '''
Based on the following health conditions/reports, suggest the most commonly prescribed and generally safe medicines that might help. 
IMPORTANT: Always include a disclaimer that this is for informational purposes only and the user MUST consult a licensed healthcare provider before taking any medication.

Health Conditions: $conditions

Please provide:
1. List of commonly suggested medicines (name, typical dosage, when taken)
2. Why each medicine might help
3. Common side effects to watch for
4. Foods or other medicines to avoid
5. Important: Medical Disclaimer

Format as a clear, organized response.
''';

      final response = await GroqAIService.askAI(prompt);
      
      return {
        'conditions': conditions.split(',').map((c) => c.trim()).toList(),
        'suggestions': response,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error generating suggestions: $e');
      return {'error': 'Failed to generate suggestions: $e'};
    }
  }

  /// Save medicine suggestion to user's document
  static Future<void> saveSuggestion(Map<String, dynamic> suggestion) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .collection(_suggestionsCollection)
          .add({
        ...suggestion,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving suggestion: $e');
      rethrow;
    }
  }

  /// Get saved medicine suggestions
  static Future<List<Map<String, dynamic>>> getSavedSuggestions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .collection(_suggestionsCollection)
          .orderBy('savedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      return [];
    }
  }

  /// Get latest suggestion
  static Future<Map<String, dynamic>?> getLatestSuggestion() async {
    try {
      final suggestions = await getSavedSuggestions();
      return suggestions.isNotEmpty ? suggestions.first : null;
    } catch (e) {
      debugPrint('Error fetching latest suggestion: $e');
      return null;
    }
  }

  /// Delete a saved suggestion
  static Future<void> deleteSuggestion(String suggestionId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(user.uid)
          .collection(_suggestionsCollection)
          .doc(suggestionId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting suggestion: $e');
      rethrow;
    }
  }
}
