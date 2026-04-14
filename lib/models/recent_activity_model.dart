import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's recent activity in the app
class RecentActivity {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String? iconData; // Store icon name as string

  RecentActivity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.metadata,
    required this.timestamp,
    this.iconData,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'metadata': metadata ?? {},
      'timestamp': Timestamp.fromDate(timestamp),
      'iconData': iconData,
    };
  }

  /// Create from Firestore document
  factory RecentActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecentActivity(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ActivityType.other,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      metadata: data['metadata'] as Map<String, dynamic>?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      iconData: data['iconData'],
    );
  }

  /// Create from map
  factory RecentActivity.fromMap(Map<String, dynamic> map, String id) {
    return RecentActivity(
      id: id,
      userId: map['userId'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.other,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      metadata: map['metadata'] as Map<String, dynamic>?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      iconData: map['iconData'],
    );
  }
}

/// Types of activities that can be tracked
enum ActivityType {
  workout,
  nutrition,
  medicine,
  healthSync,
  aiChat,
  mealPlan,
  progressUpdate,
  achievement,
  streakMilestone,
  weightLog,
  other,
}

/// Extension to get display properties for each activity type
extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.workout:
        return 'Workout';
      case ActivityType.nutrition:
        return 'Nutrition';
      case ActivityType.medicine:
        return 'Medicine';
      case ActivityType.healthSync:
        return 'Health Sync';
      case ActivityType.aiChat:
        return 'AI Chat';
      case ActivityType.mealPlan:
        return 'Meal Plan';
      case ActivityType.progressUpdate:
        return 'Progress Update';
      case ActivityType.achievement:
        return 'Achievement';
      case ActivityType.streakMilestone:
        return 'Streak Milestone';
      case ActivityType.weightLog:
        return 'Weight Log';
      case ActivityType.other:
        return 'Activity';
    }
  }

  String get iconName {
    switch (this) {
      case ActivityType.workout:
        return 'fitness_center';
      case ActivityType.nutrition:
        return 'restaurant';
      case ActivityType.medicine:
        return 'medication';
      case ActivityType.healthSync:
        return 'sync';
      case ActivityType.aiChat:
        return 'chat';
      case ActivityType.mealPlan:
        return 'calendar_today';
      case ActivityType.progressUpdate:
        return 'trending_up';
      case ActivityType.achievement:
        return 'emoji_events';
      case ActivityType.streakMilestone:
        return 'local_fire_department';
      case ActivityType.weightLog:
        return 'monitor_weight';
      case ActivityType.other:
        return 'circle';
    }
  }
}