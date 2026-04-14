import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkoutStatus { initial, active, paused, completed }

class WorkoutSession {
  final String id;
  final String userId;
  final String type;
  final DateTime startTime;
  DateTime? endTime;
  WorkoutStatus status;

  // Metrics
  int durationSeconds;
  double caloriesBurned;
  int steps;
  int heartRate;
  double intensityScore;

  // Lists for charts
  List<int> heartRateHistory;
  List<double> calorieHistory;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.type,
    required this.startTime,
    this.endTime,
    this.status = WorkoutStatus.initial,
    this.durationSeconds = 0,
    this.caloriesBurned = 0.0,
    this.steps = 0,
    this.heartRate = 0,
    this.intensityScore = 0.0,
    this.heartRateHistory = const [],
    this.calorieHistory = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'status': status.toString(),
      'durationSeconds': durationSeconds,
      'caloriesBurned': caloriesBurned,
      'steps': steps,
      'heartRate': heartRate,
      'intensityScore': intensityScore,
      'heartRateHistory': heartRateHistory,
    };
  }

  WorkoutSession copyWith({
    WorkoutStatus? status,
    int? durationSeconds,
    double? caloriesBurned,
    int? steps,
    int? heartRate,
    double? intensityScore,
    DateTime? endTime,
  }) {
    return WorkoutSession(
      id: id,
      userId: userId,
      type: type,
      startTime: startTime,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      intensityScore: intensityScore ?? this.intensityScore,
      endTime: endTime ?? this.endTime,
      heartRateHistory: heartRateHistory,
      calorieHistory: calorieHistory,
    );
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'Unknown',
      startTime: map['startTime'] is Timestamp
          ? (map['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      endTime: map['endTime'] is Timestamp
          ? (map['endTime'] as Timestamp).toDate()
          : null,
      status: map['status'] != null
          ? WorkoutStatus.values.firstWhere(
              (e) => e.toString() == map['status'],
              orElse: () => WorkoutStatus.initial,
            )
          : WorkoutStatus.initial,
      durationSeconds: map['durationSeconds'] ?? 0,
      caloriesBurned: (map['caloriesBurned'] ?? 0.0).toDouble(),
      steps: map['steps'] ?? 0,
      heartRate: map['heartRate'] ?? 0,
      intensityScore: (map['intensityScore'] ?? 0.0).toDouble(),
      heartRateHistory: List<int>.from(map['heartRateHistory'] ?? []),
      calorieHistory: List<double>.from(
        (map['calorieHistory'] ?? []).map<double>((e) => (e as num).toDouble()),
      ),
    );
  }
}
