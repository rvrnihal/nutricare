import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nuticare/models/workout_model.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nuticare/services/smartwatch_service.dart';
import '../core/logger.dart';

class WorkoutProvider extends ChangeNotifier {
  static const List<String> workoutTypes = [
    'Running',
    'Gym',
    'Yoga',
    'Cycling',
    'Swimming',
    'Walking',
    'HIIT',
    'Strength',
  ];

  final String? Function()? _currentUserIdProvider;
  final Future<void> Function(String userId, WorkoutSession session)?
      _saveWorkoutOverride;

  WorkoutProvider({
    String? Function()? currentUserIdProvider,
    Future<void> Function(String userId, WorkoutSession session)? saveWorkoutOverride,
  })  : _currentUserIdProvider = currentUserIdProvider,
        _saveWorkoutOverride = saveWorkoutOverride;

  WorkoutSession? _currentSession;
  WorkoutSession? _lastCompletedSession; // Track the last completed session for navigation
  Timer? _timer;
  final Uuid _uuid = const Uuid();
  List<FlSpot> heartRateHistory = [];
  double _timeCounter = 0;
  bool _isWatchConnected = false;
  bool _isConnectingWatch = false;
  String? _watchProvider;
  String? _watchError;
  DateTime? _lastWatchSyncAt;
  String _selectedWorkoutType = workoutTypes.first;

  // Getters
  bool get isWatchConnected => _isWatchConnected;
  bool get isConnectingWatch => _isConnectingWatch;
  String? get watchProvider => _watchProvider;
  String? get watchError => _watchError;
  DateTime? get lastWatchSyncAt => _lastWatchSyncAt;
  WorkoutSession? get session => _currentSession;
  WorkoutSession? get lastCompletedSession => _lastCompletedSession;
  bool get isActive => _currentSession?.status == WorkoutStatus.active;
  bool get isPaused => _currentSession?.status == WorkoutStatus.paused;
  int get seconds => _currentSession?.durationSeconds ?? 0;
  double get caloriesBurned => _currentSession?.caloriesBurned ?? 0.0;
  int get heartRate => _currentSession?.heartRate ?? 0;
  int get steps => _currentSession?.steps ?? 0;
  String get selectedWorkoutType => _selectedWorkoutType;
  String get currentWorkoutType => _currentSession?.type ?? _selectedWorkoutType;

  String get formattedTime {
    final int duration = seconds;
    final int sec = duration % 60;
    final int min = (duration ~/ 60) % 60;
    final int hr = duration ~/ 3600;
    return hr > 0
        ? "${hr.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}"
        : "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  void setSelectedWorkoutType(String type) {
    if (_currentSession != null || type == _selectedWorkoutType) return;
    _selectedWorkoutType = type;
    notifyListeners();
  }

  // Core Actions
  void startWorkout([String? type]) {
    if (_currentSession != null) return;

    final workoutType = type ?? _selectedWorkoutType;

    final userId = _resolveUserId() ?? 'guest';

    _currentSession = WorkoutSession(
      id: _uuid.v4(),
      userId: userId,
      type: workoutType,
      startTime: DateTime.now(),
      status: WorkoutStatus.active,
    );

    heartRateHistory = [];
    _timeCounter = 0;

    _startTimer();
    notifyListeners();
  }

  void pauseWorkout() {
    if (_currentSession?.status == WorkoutStatus.active) {
      _currentSession?.status = WorkoutStatus.paused;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void resumeWorkout() {
    if (_currentSession?.status == WorkoutStatus.paused) {
      _currentSession?.status = WorkoutStatus.active;
      _startTimer();
      notifyListeners();
    }
  }

  Future<bool> stopWorkout() async {
    _timer?.cancel();
    if (_currentSession == null) {
      return false;
    }

    _currentSession!.endTime = DateTime.now();
    _currentSession!.status = WorkoutStatus.completed;

    // Save the completed session for navigation
    _lastCompletedSession = _currentSession!;

    // Notify listeners about completion status BEFORE saving
    notifyListeners();

    try {
      final userId = _resolveUserId();
      if (userId == null) {
        AppLogger.warning('Cannot save workout history: user not logged in');
        // Reset even if not logged in
        _currentSession = null;
        _timeCounter = 0;
        heartRateHistory = [];
        notifyListeners();
        return false;
      }

      if (_saveWorkoutOverride != null) {
        await _saveWorkoutOverride!(userId, _currentSession!);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('workouts')
            .doc(_currentSession!.id)
            .set(_currentSession!.toMap());
      }

      AppLogger.info('Workout saved to history for user: $userId');

      // Reset active workout state after successful save
      _currentSession = null;
      _timeCounter = 0;
      heartRateHistory = [];
      notifyListeners();

      return true;
    } catch (e, st) {
      AppLogger.error('Error saving workout to history', e, st);
      // Still reset on error to avoid stuck state
      _currentSession = null;
      _timeCounter = 0;
      heartRateHistory = [];
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _timer?.cancel();
    _currentSession = null;
    _lastCompletedSession = null; // Clear completed session on reset
    notifyListeners();
  }

  Future<bool> toggleWatchConnection() async {
    if (_isWatchConnected) {
      disconnectWatch();
      return false;
    }

    return connectWatch();
  }

  Future<bool> connectWatch() async {
    _isConnectingWatch = true;
    _watchError = null;
    notifyListeners();

    try {
      final connected = await SmartwatchService.connectToHealthPlatform();
      if (!connected) {
        _watchError =
            'Permission denied or platform not supported for health connection.';
        _isWatchConnected = false;
        _watchProvider = null;
        return false;
      }

      _isWatchConnected = true;
      _watchProvider = SmartwatchService.platformProviderName;
      await syncWatchData();
      AppLogger.info('Watch connected via $_watchProvider');
      return true;
    } catch (e, st) {
      _watchError = e.toString();
      _isWatchConnected = false;
      _watchProvider = null;
      AppLogger.error('Failed to connect watch', e, st);
      return false;
    } finally {
      _isConnectingWatch = false;
      notifyListeners();
    }
  }

  void disconnectWatch() {
    _isWatchConnected = false;
    _watchProvider = null;
    _watchError = null;
    AppLogger.info('Watch disconnected');
    notifyListeners();
  }

  Future<bool> syncWatchData() async {
    if (!_isWatchConnected) {
      _watchError = 'Watch is not connected';
      notifyListeners();
      return false;
    }

    final payload = await SmartwatchService.syncTodayMetrics();
    if (payload == null) {
      _watchError = 'Failed to sync health data';
      notifyListeners();
      return false;
    }

    _lastWatchSyncAt = DateTime.now();

    if (_currentSession != null) {
      _currentSession!.steps = payload['steps'] as int? ?? _currentSession!.steps;
      _currentSession!.heartRate =
          payload['avgHeartRate'] as int? ?? _currentSession!.heartRate;
    }

    _watchError = null;
    notifyListeners();
    return true;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession == null ||
          _currentSession!.status != WorkoutStatus.active) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final difference = now.difference(_currentSession!.startTime).inSeconds;

      // If paused, we need to track paused duration to subtract it (Simple MVP version: just use diff)
      // For a full production app, we'd store "totalPausedDuration" in the session.
      // For this MVP, we will stick to simple diff for active sessions, assuming no long pauses.

      // Better Logic:
      if (_currentSession!.status == WorkoutStatus.active) {
        _currentSession!.durationSeconds = difference;
        // Simulate Steps (~2 steps/sec if active)
        if (_currentSession!.heartRate > 90) {
          _currentSession!.steps += 2;
        }
      }

      _currentSession!.heartRate = _simulateHeartRate();
      // Calculate Intensity (0-10 based on HR)
      _currentSession!.intensityScore =
          (_currentSession!.heartRate / 20).clamp(0.0, 10.0);

      _currentSession!.caloriesBurned += _calculateCaloriesPerSecond();

      // Update Graph Data
      _timeCounter++;
      heartRateHistory
          .add(FlSpot(_timeCounter, _currentSession!.heartRate.toDouble()));
      if (heartRateHistory.length > 60) {
        heartRateHistory.removeAt(0); // Keep last 60 seconds
      }

      notifyListeners();
    });
  }

  int _simulateHeartRate() {
    // Simple mock variation
    return 80 + (DateTime.now().second % 40);
  }

  double _calculateCaloriesPerSecond() {
    // Basic metabolic calculation approximation
    // METs * 3.5 * weight / 200 / 60
    return 0.15 + (_currentSession!.intensityScore * 0.05);
  }

  /// Log a past workout (for manual entry)
  Future<bool> logPastWorkout({
    required String type,
    required DateTime startTime,
    required int durationSeconds,
    required int calories,
    required int steps,
    required int heartRate,
  }) async {
    try {
      final userId = _resolveUserId();
      if (userId == null) {
        AppLogger.warning('Cannot log workout: user not logged in');
        return false;
      }

      final workout = WorkoutSession(
        id: const Uuid().v4(),
        userId: userId,
        type: type,
        startTime: startTime,
        endTime: startTime.add(Duration(seconds: durationSeconds)),
        durationSeconds: durationSeconds,
        caloriesBurned: calories.toDouble(),
        steps: steps,
        heartRate: heartRate,
        status: WorkoutStatus.completed,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(workout.id)
          .set(workout.toMap());

      AppLogger.info('✅ Past workout logged: $type');
      notifyListeners();
      return true;
    } catch (e, st) {
      AppLogger.error('Error logging past workout', e, st);
      return false;
    }
  }

  String? _resolveUserId() {
    final provided = _currentUserIdProvider?.call();
    if (provided != null && provided.isNotEmpty) return provided;
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
