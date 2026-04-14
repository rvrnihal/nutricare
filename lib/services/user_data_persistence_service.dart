import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/models/workout_model.dart';
import '../core/logger.dart';

/// Comprehensive service for persisting all user data across sessions
class UserDataPersistenceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// =============== WORKOUTS ===============
  /// Save a workout to Firestore
  static Future<bool> saveWorkout(WorkoutSession workout) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        AppLogger.warning('Cannot save workout: user not logged in');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(workout.id)
          .set(workout.toMap());

      AppLogger.info('✅ Workout saved: ${workout.type}');
      return true;
    } catch (e, st) {
      AppLogger.error('Error saving workout', e, st);
      return false;
    }
  }

  /// Get all workouts for current user
  static Future<List<WorkoutSession>> getAllWorkouts() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutSession.fromMap(doc.data()))
          .toList();
    } catch (e, st) {
      AppLogger.error('Error fetching workouts', e, st);
      return [];
    }
  }

  /// Stream workouts for real-time updates
  static Stream<List<WorkoutSession>> streamWorkouts() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutSession.fromMap(doc.data()))
            .toList());
  }

  /// =============== FOOD LOGS ===============
  /// Save a food log
  static Future<bool> saveFoodLog(Map<String, dynamic> foodLog) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final docId = foodLog['id'] ?? DateTime.now().millisecondsSinceEpoch;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('food_logs')
          .doc(docId.toString())
          .set({
        ...foodLog,
        'savedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Food log saved');
      return true;
    } catch (e, st) {
      AppLogger.error('Error saving food log', e, st);
      return false;
    }
  }

  /// Get all food logs
  static Future<List<Map<String, dynamic>>> getAllFoodLogs() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('food_logs')
          .orderBy('savedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'docId': doc.id})
          .toList();
    } catch (e, st) {
      AppLogger.error('Error fetching food logs', e, st);
      return [];
    }
  }

  /// =============== CONVERSATIONS ===============
  /// Save chat message
  static Future<bool> saveChatMessage({
    required String message,
    required String sender, // 'user' or 'ai'
    required String conversationId,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'message': message,
        'sender': sender,
        'timestamp': FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Message saved to conversation');
      return true;
    } catch (e, st) {
      AppLogger.error('Error saving chat message', e, st);
      return false;
    }
  }

  /// Get all conversations
  static Future<List<Map<String, dynamic>>> getAllConversations() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e, st) {
      AppLogger.error('Error fetching conversations', e, st);
      return [];
    }
  }

  /// Stream conversation messages
  static Stream<List<Map<String, dynamic>>> streamConversationMessages(
      String conversationId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// =============== DIET PLANS ===============
  /// Save meal plan
  static Future<bool> saveMealPlan(Map<String, dynamic> mealPlan) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final planId = mealPlan['id'] ?? DateTime.now().millisecondsSinceEpoch;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .doc(planId.toString())
          .set({
        ...mealPlan,
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Meal plan saved');
      return true;
    } catch (e, st) {
      AppLogger.error('Error saving meal plan', e, st);
      return false;
    }
  }

  /// Get all meal plans
  static Future<List<Map<String, dynamic>>> getAllMealPlans() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'docId': doc.id})
          .toList();
    } catch (e, st) {
      AppLogger.error('Error fetching meal plans', e, st);
      return [];
    }
  }

  /// =============== MEDICATIONS ===============
  /// Save medication log
  static Future<bool> saveMedicationLog(Map<String, dynamic> medLog) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final docId = medLog['id'] ?? DateTime.now().millisecondsSinceEpoch;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('medication_logs')
          .doc(docId.toString())
          .set({
        ...medLog,
        'loggedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Medication log saved');
      return true;
    } catch (e, st) {
      AppLogger.error('Error saving medication log', e, st);
      return false;
    }
  }

  /// Get all medication logs
  static Future<List<Map<String, dynamic>>> getAllMedicationLogs() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('medication_logs')
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'docId': doc.id})
          .toList();
    } catch (e, st) {
      AppLogger.error('Error fetching medication logs', e, st);
      return [];
    }
  }

  /// =============== HEALTH REPORTS ===============
  /// Save health report
  static Future<bool> saveHealthReport(Map<String, dynamic> report) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final docId = report['id'] ?? DateTime.now().millisecondsSinceEpoch;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_reports')
          .doc(docId.toString())
          .set({
        ...report,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Health report saved');
      return true;
    } catch (e, st) {
      AppLogger.error('Error saving health report', e, st);
      return false;
    }
  }

  /// Get all health reports
  static Future<List<Map<String, dynamic>>> getAllHealthReports() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_reports')
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'docId': doc.id})
          .toList();
    } catch (e, st) {
      AppLogger.error('Error fetching health reports', e, st);
      return [];
    }
  }

  /// =============== USER PROFILE DATA ===============
  /// Save/update user profile
  static Future<bool> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      await _firestore.collection('users').doc(userId).set(
          {...profile, 'lastUpdated': FieldValue.serverTimestamp()},
          SetOptions(merge: true));

      AppLogger.info('✅ User profile saved');
      return true;
    } catch (e, st) {
      AppLogger.error('Error saving user profile', e, st);
      return false;
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e, st) {
      AppLogger.error('Error fetching user profile', e, st);
      return null;
    }
  }

  /// =============== UTILITY METHODS ===============
  /// Get user ID
  static String? getCurrentUserId() => _auth.currentUser?.uid;

  /// Check if user is logged in
  static bool isUserLoggedIn() => _auth.currentUser != null;

  /// Export all user data (for backup/analytics)
  static Future<Map<String, dynamic>> exportAllUserData() async {
    try {
      return {
        'workouts': await getAllWorkouts(),
        'foodLogs': await getAllFoodLogs(),
        'conversations': await getAllConversations(),
        'mealPlans': await getAllMealPlans(),
        'medicationLogs': await getAllMedicationLogs(),
        'healthReports': await getAllHealthReports(),
        'profile': await getUserProfile(),
        'exportedAt': DateTime.now(),
      };
    } catch (e, st) {
      AppLogger.error('Error exporting user data', e, st);
      return {};
    }
  }
}
