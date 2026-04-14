import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recent_activity_model.dart';
import '../core/logger.dart';

class RecentActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Maximum number of activities to keep per user
  static const int maxActivitiesPerUser = 100;

  /// Get the current user's ID
  String? get _userId => _auth.currentUser?.uid;

  /// Log a new activity for the current user
  Future<void> logActivity({
    required ActivityType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
    String? iconData,
  }) async {
    if (_userId == null) return;

    try {
      final activity = RecentActivity(
        id: '', // Will be set by Firestore
        userId: _userId!,
        type: type,
        title: title,
        description: description,
        metadata: metadata,
        timestamp: DateTime.now(),
        iconData: iconData ?? type.iconName,
      );

      await _db.collection('recent_activities').add(activity.toMap());

      // Clean up old activities if needed
      await _cleanupOldActivities();
    } catch (e, st) {
      AppLogger.error('Error logging activity', e, st);
    }
  }

  /// Log a workout activity
  Future<void> logWorkout({
    required String workoutName,
    int? duration,
    int? caloriesBurned,
    int? exerciseCount,
  }) async {
    await logActivity(
      type: ActivityType.workout,
      title: 'Completed Workout',
      description: workoutName,
      metadata: {
        'workoutName': workoutName,
        'duration': duration,
        'caloriesBurned': caloriesBurned,
        'exerciseCount': exerciseCount,
      },
    );
  }

  /// Log a nutrition activity
  Future<void> logMeal({
    required String mealType,
    required String description,
    int? calories,
    Map<String, dynamic>? nutritionData,
  }) async {
    await logActivity(
      type: ActivityType.nutrition,
      title: 'Logged $mealType',
      description: description,
      metadata: {
        'mealType': mealType,
        'calories': calories,
        'nutrition': nutritionData,
      },
    );
  }

  /// Log medicine taken
  Future<void> logMedicine({
    required String medicineName,
    required String dosage,
    DateTime? takenAt,
  }) async {
    await logActivity(
      type: ActivityType.medicine,
      title: 'Took Medicine',
      description: '$medicineName - $dosage',
      metadata: {
        'medicineName': medicineName,
        'dosage': dosage,
        'takenAt': takenAt?.toIso8601String(),
      },
    );
  }

  /// Log AI chat interaction
  Future<void> logAIChat({
    required String topic,
    int? messageCount,
  }) async {
    await logActivity(
      type: ActivityType.aiChat,
      title: 'AI Chat Session',
      description: topic,
      metadata: {
        'topic': topic,
        'messageCount': messageCount,
      },
    );
  }

  /// Log meal plan creation
  Future<void> logMealPlan({
    required String planName,
    int? days,
    String? goal,
  }) async {
    await logActivity(
      type: ActivityType.mealPlan,
      title: 'Created Meal Plan',
      description: planName,
      metadata: {
        'planName': planName,
        'days': days,
        'goal': goal,
      },
    );
  }

  /// Log progress update
  Future<void> logProgressUpdate({
    required String metric,
    required String value,
    String? previousValue,
  }) async {
    await logActivity(
      type: ActivityType.progressUpdate,
      title: 'Progress Update',
      description: '$metric: $value',
      metadata: {
        'metric': metric,
        'value': value,
        'previousValue': previousValue,
      },
    );
  }

  /// Log achievement
  Future<void> logAchievement({
    required String achievementName,
    String? description,
  }) async {
    await logActivity(
      type: ActivityType.achievement,
      title: 'Achievement Unlocked!',
      description: description ?? achievementName,
      metadata: {
        'achievementName': achievementName,
      },
    );
  }

  /// Log streak milestone
  Future<void> logStreakMilestone({
    required int streakDays,
    required String type,
  }) async {
    await logActivity(
      type: ActivityType.streakMilestone,
      title: '$streakDays Day Streak!',
      description: 'Achieved $streakDays day $type streak',
      metadata: {
        'streakDays': streakDays,
        'streakType': type,
      },
    );
  }

  /// Log weight update
  Future<void> logWeightUpdate({
    required double weight,
    String? unit,
    double? change,
  }) async {
    await logActivity(
      type: ActivityType.weightLog,
      title: 'Weight Updated',
      description: '$weight ${unit ?? "kg"}${change != null ? " (${change > 0 ? "+" : ""}${change.toStringAsFixed(1)} ${unit ?? "kg"})" : ""}',
      metadata: {
        'weight': weight,
        'unit': unit ?? 'kg',
        'change': change,
      },
    );
  }

  /// Log health sync
  Future<void> logHealthSync({
    required String source,
    int? dataPoints,
  }) async {
    await logActivity(
      type: ActivityType.healthSync,
      title: 'Synced Health Data',
      description: 'From $source',
      metadata: {
        'source': source,
        'dataPoints': dataPoints,
      },
    );
  }

  /// Get recent activities for the current user
  Stream<List<RecentActivity>> getRecentActivities({int limit = 20}) {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('recent_activities')
        .where('userId', isEqualTo: _userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecentActivity.fromFirestore(doc))
            .toList());
  }

  /// Get recent activities for a specific user (for admin purposes)
  Stream<List<RecentActivity>> getActivitiesForUser(
    String userId, {
    int limit = 20,
  }) {
    return _db
        .collection('recent_activities')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecentActivity.fromFirestore(doc))
            .toList());
  }

  /// Get activities by type
  Stream<List<RecentActivity>> getActivitiesByType(
    ActivityType type, {
    int limit = 20,
  }) {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('recent_activities')
        .where('userId', isEqualTo: _userId)
        .where('type', isEqualTo: type.name)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecentActivity.fromFirestore(doc))
            .toList());
  }

  /// Get activities within a date range
  Stream<List<RecentActivity>> getActivitiesInRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
  }) {
    if (_userId == null) {
      return Stream.value([]);
    }

    Query query = _db
        .collection('recent_activities')
        .where('userId', isEqualTo: _userId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => RecentActivity.fromFirestore(doc)).toList());
  }

  /// Get activity count by type for statistics
  Future<Map<ActivityType, int>> getActivityStatsByType({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_userId == null) {
      return {};
    }

    Query query = _db
        .collection('recent_activities')
        .where('userId', isEqualTo: _userId);

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query =
          query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    final activities = snapshot.docs
        .map((doc) => RecentActivity.fromFirestore(doc))
        .toList();

    final Map<ActivityType, int> stats = {};
    for (var activity in activities) {
      stats[activity.type] = (stats[activity.type] ?? 0) + 1;
    }

    return stats;
  }

  /// Delete a specific activity
  Future<void> deleteActivity(String activityId) async {
    try {
      await _db.collection('recent_activities').doc(activityId).delete();
    } catch (e, st) {
      AppLogger.error('Error deleting activity', e, st);
    }
  }

  /// Clear all activities for the current user
  Future<void> clearAllActivities() async {
    if (_userId == null) return;

    try {
      final snapshot = await _db
          .collection('recent_activities')
          .where('userId', isEqualTo: _userId)
          .get();

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e, st) {
      AppLogger.error('Error clearing activities', e, st);
    }
  }

  /// Clean up old activities to maintain the limit
  Future<void> _cleanupOldActivities() async {
    if (_userId == null) return;

    try {
      final snapshot = await _db
          .collection('recent_activities')
          .where('userId', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.length > maxActivitiesPerUser) {
        final batch = _db.batch();
        final docsToDelete = snapshot.docs.skip(maxActivitiesPerUser);

        for (var doc in docsToDelete) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }
    } catch (e, st) {
      AppLogger.error('Error cleaning up old activities', e, st);
    }
  }

  /// Get today's activities count
  Future<int> getTodayActivityCount() async {
    if (_userId == null) return 0;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('recent_activities')
        .where('userId', isEqualTo: _userId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.length;
  }

  /// Get this week's activities count
  Future<int> getWeekActivityCount() async {
    if (_userId == null) return 0;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final snapshot = await _db
        .collection('recent_activities')
        .where('userId', isEqualTo: _userId)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeekDay))
        .get();

    return snapshot.docs.length;
  }
}