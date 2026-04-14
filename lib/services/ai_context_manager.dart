import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_data_storage_service.dart';

/// Manages AI context from user's past conversations and data
class AIContextManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _userId => _auth.currentUser!.uid;

  /// Get comprehensive context for AI from user's history
  static Future<String> buildAIContext() async {
    try {
      final userProfile = await UserDataStorageService.getUserProfile();
      final recentConversations = await _getRecentConversations(limit: 5);
      final healthSummary = await _getHealthSummary();
      final activePlans = await _getActivePlans();

      final context = '''
=== USER PROFILE ===
${_formatUserProfile(userProfile)}

=== RECENT CONVERSATIONS (last 5) ===
${_formatConversations(recentConversations)}

=== HEALTH SUMMARY ===
${_formatHealthSummary(healthSummary)}

=== ACTIVE PLANS ===
${_formatActivePlans(activePlans)}

Use this context to provide personalized responses specific to the user's health profile, goals, and history.
''';

      return context.trim();
    } catch (e) {
      return '';
    }
  }

  /// Get recent conversations from user history
  static Future<List<Map<String, dynamic>>> _getRecentConversations(
      {int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ai_conversations')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get health summary from reports
  static Future<Map<String, dynamic>> _getHealthSummary() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('health_reports')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      if (snapshot.docs.isEmpty) {
        return {};
      }

      // Extract key health information from latest reports
      final summaries = <String, dynamic>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        summaries['latestReport'] = data['reportType'];
        if (data['analysis'] != null) {
          summaries['recentAnalysis'] = data['analysis'];
        }
        if (data['detectedValues'] != null) {
          summaries['detectedValues'] = data['detectedValues'];
        }
      }

      return summaries;
    } catch (e) {
      return {};
    }
  }

  /// Get active workout and diet plans
  static Future<Map<String, dynamic>> _getActivePlans() async {
    try {
      final workoutSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_plans')
          .where('isActive', isEqualTo: true)
          .get();

      final dietSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diet_plans')
          .where('isActive', isEqualTo: true)
          .get();

      return {
        'activeWorkoutPlans': workoutSnapshot.docs
            .map((doc) => {
                  'name': doc['planName'],
                  'goal': doc['goal'],
                  'progress': doc['completionPercentage'],
                })
            .toList(),
        'activeDietPlans': dietSnapshot.docs
            .map((doc) => {
                  'name': doc['planName'],
                  'type': doc['dietType'],
                  'dailyCalories': doc['dailyCalories'],
                })
            .toList(),
      };
    } catch (e) {
      return {};
    }
  }

  /// Check if user has relevant past conversations on a topic
  static Future<List<Map<String, dynamic>>> getConversationsByCategory(
      String category) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ai_conversations')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get medicine history for drug interaction checks
  static Future<List<String>> getMedicineHistory() async {
    try {
      final conversationSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ai_conversations')
          .where('category', isEqualTo: 'medicine')
          .get();

      final medicines = <String>{};
      for (var doc in conversationSnapshot.docs) {
        final question = doc['question'] as String? ?? '';
        // Extract medicine names
        if (question.isNotEmpty) {
          medicines.add(question);
        }
      }

      return medicines.toList();
    } catch (e) {
      return [];
    }
  }

  /// Get dietary preferences from user history
  static Future<List<String>> getDietaryPreferences() async {
    try {
      final userProfile = await UserDataStorageService.getUserProfile();
      if (userProfile == null) return [];

      final preferences = <String>[];
      
      if (userProfile['dietaryPreference'] != null) {
        preferences.add(userProfile['dietaryPreference'] as String);
      }

      if (userProfile['allergies'] is List) {
        preferences.addAll(List<String>.from(userProfile['allergies'] as List));
      }

      return preferences;
    } catch (e) {
      return [];
    }
  }

  // ==================== FORMATTING HELPERS ====================

  static String _formatUserProfile(Map<String, dynamic>? profile) {
    if (profile == null) return 'No profile data available';

    return '''
Name: ${profile['name'] ?? 'Unknown'}
Age: ${profile['age'] ?? 'Not set'}
Health Goal: ${profile['healthGoal'] ?? 'Not set'}
Dietary Preference: ${profile['dietaryPreference'] ?? 'Not set'}
Medical Conditions: ${_formatList(profile['medicalConditions'])}
Allergies: ${_formatList(profile['allergies'])}
''';
  }

  static String _formatConversations(List<Map<String, dynamic>> conversations) {
    if (conversations.isEmpty) return 'No past conversations';

    return conversations
        .map((conv) => 
            'Q: ${conv['question'] ?? ''}\nCategory: ${conv['category'] ?? 'general'}\nA: ${_truncate(conv['answer'] ?? '', 100)}')
        .join('\n---\n');
  }

  static String _formatHealthSummary(Map<String, dynamic> summary) {
    if (summary.isEmpty) return 'No health data available';

    final buffer = StringBuffer();
    summary.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString();
  }

  static String _formatActivePlans(Map<String, dynamic> plans) {
    final buffer = StringBuffer();

    if (plans['activeWorkoutPlans'] != null) {
      final workoutPlans = plans['activeWorkoutPlans'] as List;
      if (workoutPlans.isNotEmpty) {
        buffer.writeln('Active Workouts:');
        for (var plan in workoutPlans) {
          buffer.writeln(
              '  - ${plan['name']} (Goal: ${plan['goal']}, Progress: ${plan['progress']}%)');
        }
      }
    }

    if (plans['activeDietPlans'] != null) {
      final dietPlans = plans['activeDietPlans'] as List;
      if (dietPlans.isNotEmpty) {
        buffer.writeln('Active Diet Plans:');
        for (var plan in dietPlans) {
          buffer.writeln(
              '  - ${plan['name']} (Type: ${plan['type']}, ${plan['dailyCalories']} kcal/day)');
        }
      }
    }

    return buffer.isEmpty ? 'No active plans' : buffer.toString();
  }

  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String _formatList(dynamic list) {
    if (list is List && list.isNotEmpty) {
      return list.join(', ');
    }
    return 'None';
  }
}
