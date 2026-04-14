import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

/// Comprehensive User Data Storage Service
/// Handles: Reports, AI Conversations, Workouts, Diet Plans, User Profile
class UserDataStorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static String get _userId => _auth.currentUser!.uid;
  static String get _userEmail => _auth.currentUser?.email ?? "";

  // ==================== USER PROFILE ====================

  /// Save/Update user profile with comprehensive health data
  static Future<void> saveUserProfile({
    required String name,
    required int age,
    required String gender,
    required String healthGoal,
    required String dietaryPreference,
    required List<String> medicalConditions,
    required List<String> allergies,
  }) async {
    try {
      await _firestore.collection('users').doc(_userId).set({
        'name': name,
        'email': _userEmail,
        'age': age,
        'gender': gender,
        'healthGoal': healthGoal,
        'dietaryPreference': dietaryPreference,
        'medicalConditions': medicalConditions,
        'allergies': allergies,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // ==================== HEALTH REPORTS STORAGE ====================

  /// Save health report with image and analysis
  static Future<String> saveHealthReport({
    required String reportType, // "blood_test", "medical_checkup", "fitness", etc.
    required String filename,
    required Uint8List imageData,
    required Map<String, dynamic> analysis,
  }) async {
    try {
      // Upload image to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'users/$_userId/reports/$reportType/$timestamp/$filename';
      
      final ref = _storage.ref(storagePath);
      await ref.putData(imageData);
      final imageUrl = await ref.getDownloadURL();

      // Save report metadata to Firestore
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('health_reports')
          .add({
        'reportType': reportType,
        'filename': filename,
        'imageUrl': imageUrl,
        'analysis': analysis,
        'detectedValues': analysis['detected_values'] ?? {},
        'healthSummary': analysis['health_summary'] ?? {},
        'suggestedConditions': analysis['suggested_conditions'] ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': timestamp,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save health report: $e');
    }
  }

  /// Get all health reports
  static Stream<List<Map<String, dynamic>>> getHealthReports() {
    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('health_reports')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
    } catch (e) {
      throw Exception('Failed to get health reports: $e');
    }
  }

  /// Get specific health report
  static Future<Map<String, dynamic>?> getHealthReport(String reportId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('health_reports')
          .doc(reportId)
          .get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get health report: $e');
    }
  }

  // ==================== AI CONVERSATION HISTORY ====================

  /// Save AI conversation with context
  static Future<void> saveAIConversation({
    required String question,
    required String answer,
    required String category, // "nutrition", "medicine", "workout", "diet", "general"
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ai_conversations')
          .add({
        'question': question,
        'answer': answer,
        'category': category,
        'metadata': metadata ?? {},
        'source': 'ai_agent', // or 'local_model', 'groq_api', etc.
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save AI conversation: $e');
    }
  }

  /// Get AI conversation history
  static Stream<List<Map<String, dynamic>>> getAIConversationHistory({
    String? category, // Filter by category (optional)
    int limit = 50,
  }) {
    try {
      Query query = _firestore
          .collection('users')
          .doc(_userId)
          .collection('ai_conversations')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      return (query as Query<Map<String, dynamic>>)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
    } catch (e) {
      throw Exception('Failed to get AI conversation history: $e');
    }
  }

  /// Get conversation context for AI (recent relevant conversations)
  static Future<String> getAIContext({int lastNConversations = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ai_conversations')
          .orderBy('createdAt', descending: true)
          .limit(lastNConversations)
          .get();

      if (snapshot.docs.isEmpty) return '';

      final conversations = snapshot.docs
          .map((doc) => {
            'q': doc['question'],
            'a': doc['answer'],
            'cat': doc['category']
          })
          .toList();

      return 'Recent user conversations: ${conversations.toString()}';
    } catch (e) {
      return '';
    }
  }

  // ==================== WORKOUT PLANS ====================

  /// Save workout plan
  static Future<String> saveWorkoutPlan({
    required String planName,
    required String goal, // "weight_loss", "muscle_gain", "endurance", "flexibility"
    required int durationDays,
    required List<Map<String, dynamic>> exercises,
    required String difficulty,
    required String description,
  }) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_plans')
          .add({
        'planName': planName,
        'goal': goal,
        'durationDays': durationDays,
        'exercises': exercises,
        'difficulty': difficulty,
        'description': description,
        'isActive': true,
        'completionPercentage': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save workout plan: $e');
    }
  }

  /// Get all workout plans
  static Stream<List<Map<String, dynamic>>> getWorkoutPlans() {
    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_plans')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
    } catch (e) {
      throw Exception('Failed to get workout plans: $e');
    }
  }

  /// Update workout plan progress
  static Future<void> updateWorkoutProgress(String planId, int completionPercentage) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_plans')
          .doc(planId)
          .update({
        'completionPercentage': completionPercentage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update workout progress: $e');
    }
  }

  // ==================== DIET PLANS ====================

  /// Save diet/meal plan
  static Future<String> saveDietPlan({
    required String planName,
    required String dietType, // "vegan", "vegetarian", "keto", "balanced", etc.
    required int dailyCalories,
    required List<Map<String, dynamic>> meals, // breakfast, lunch, dinner, snacks
    required String goal,
    required int durationDays,
  }) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diet_plans')
          .add({
        'planName': planName,
        'dietType': dietType,
        'dailyCalories': dailyCalories,
        'meals': meals,
        'goal': goal,
        'durationDays': durationDays,
        'isActive': true,
        'adherencePercentage': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save diet plan: $e');
    }
  }

  /// Get all diet plans
  static Stream<List<Map<String, dynamic>>> getDietPlans() {
    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('diet_plans')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
    } catch (e) {
      throw Exception('Failed to get diet plans: $e');
    }
  }

  /// Update diet plan adherence
  static Future<void> updateDietAdherence(String planId, int adherencePercentage) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diet_plans')
          .doc(planId)
          .update({
        'adherencePercentage': adherencePercentage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update diet adherence: $e');
    }
  }

  // ==================== DAILY LOGS & TRACKING ====================

  /// Log daily activity
  static Future<void> logDailyActivity({
    required String activityType, // "workout", "meal", "medicine", "water", "sleep"
    required Map<String, dynamic> details,
  }) async {
    try {
      final now = DateTime.now();
      final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('daily_logs')
          .doc(dateKey)
          .collection(activityType)
          .add({
        ...details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to log daily activity: $e');
    }
  }

  /// Get daily logs
  static Future<Map<String, List<Map<String, dynamic>>>> getDailyLogs(DateTime date) async {
    try {
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final docRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('daily_logs')
          .doc(dateKey);

      final result = <String, List<Map<String, dynamic>>>{};
      
      final activityTypes = ['workout', 'meal', 'medicine', 'water', 'sleep'];
      for (final type in activityTypes) {
        final snapshot = await docRef.collection(type).get();
        result[type] = snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      }

      return result;
    } catch (e) {
      throw Exception('Failed to get daily logs: $e');
    }
  }

  // ==================== MEDICINE TRACKER ====================

  /// Log medicine intake
  static Future<void> logMedicineIntake({
    required String medicineName,
    required String dosage,
    required String time,
    required Map<String, dynamic> details,
  }) async {
    try {
      await logDailyActivity(
        activityType: 'medicine',
        details: {
          'medicineName': medicineName,
          'dosage': dosage,
          'time': time,
          ...details,
        },
      );
    } catch (e) {
      throw Exception('Failed to log medicine intake: $e');
    }
  }

  /// Get medicine history
  static Stream<List<Map<String, dynamic>>> getMedicineHistory() {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30)); // Last 30 days

      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('medicine_logs')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
    } catch (e) {
      throw Exception('Failed to get medicine history: $e');
    }
  }

  // ==================== STATISTICS & ANALYTICS ====================

  /// Get user statistics
  static Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Get report count
      final reportsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('health_reports')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .count()
          .get();

      // Get conversation count
      final conversationsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ai_conversations')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .count()
          .get();

      // Get active plans count
      final plansSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_plans')
          .where('isActive', isEqualTo: true)
          .count()
          .get();

      return {
        'totalReports': reportsSnapshot.count,
        'totalConversations': conversationsSnapshot.count,
        'activePlans': plansSnapshot.count,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      return {};
    }
  }

  // ==================== DATA SYNC & BACKUP ====================

  /// Export all user data as JSON (for backup)
  static Future<Map<String, dynamic>> exportUserData() async {
    try {
      final profile = await getUserProfile();
      
      final reportsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('health_reports')
          .get();

      final conversationsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('ai_conversations')
          .get();

      final workoutPlansSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_plans')
          .get();

      final dietPlansSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('diet_plans')
          .get();

      return {
        'profile': profile,
        'reports': reportsSnapshot.docs.map((doc) => doc.data()).toList(),
        'conversations': conversationsSnapshot.docs.map((doc) => doc.data()).toList(),
        'workoutPlans': workoutPlansSnapshot.docs.map((doc) => doc.data()).toList(),
        'dietPlans': dietPlansSnapshot.docs.map((doc) => doc.data()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to export user data: $e');
    }
  }
}
