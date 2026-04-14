import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';

class StreakProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastActiveDate;
  bool _isLoading = false;
  String? _error;

  // Getters
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  DateTime? get lastActiveDate => _lastActiveDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize streaks
  Future<void> initializeStreaks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('streaks')
          .doc('current')
          .get();

      if (doc.exists) {
        _currentStreak = doc.data()?['currentStreak'] ?? 0;
        _longestStreak = doc.data()?['longestStreak'] ?? 0;
        
        if (doc.data()?['lastActiveDate'] != null) {
          _lastActiveDate = (doc.data()?['lastActiveDate'] as Timestamp).toDate();
        }
      }

      AppLogger.info('Initialized streaks: current=$_currentStreak, longest=$_longestStreak');
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Failed to initialize streaks', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Record activity
  Future<void> recordActivity() async {
    try {
      _error = null;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Check if already recorded today
      if (_lastActiveDate != null) {
        final lastDay = DateTime(_lastActiveDate!.year, _lastActiveDate!.month, _lastActiveDate!.day);
        final isSameDay = lastDay.compareTo(startOfDay) == 0;
        
        if (isSameDay) {
          AppLogger.info('Activity already recorded today');
          return;
        }
      }

      // Increment or reset streak
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      bool isConsecutive = false;

      if (_lastActiveDate != null) {
        final lastDay = DateTime(_lastActiveDate!.year, _lastActiveDate!.month, _lastActiveDate!.day);
        isConsecutive = lastDay.compareTo(yesterday) == 0;
      }

      if (isConsecutive) {
        _currentStreak++;
      } else {
        _currentStreak = 1;
      }

      // Update longest streak
      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
      }

      _lastActiveDate = today;

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('streaks')
          .doc('current')
          .set({
        'currentStreak': _currentStreak,
        'longestStreak': _longestStreak,
        'lastActiveDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Recorded activity. Streak: $_currentStreak');
      notifyListeners();
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Failed to record activity', e, st);
      rethrow;
    }
  }

  // Reset streak (for testing)
  Future<void> resetStreak() async {
    try {
      _error = null;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      _currentStreak = 0;
      _lastActiveDate = null;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('streaks')
          .doc('current')
          .update({
        'currentStreak': 0,
        'lastActiveDate': FieldValue.delete(),
      });

      AppLogger.warning('Streak reset');
      notifyListeners();
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Failed to reset streak', e, st);
      rethrow;
    }
  }

  // Get streak status
  String getStreakStatus() {
    if (_currentStreak == 0) {
      return 'No active streak. Start today!';
    } else if (_currentStreak == 1) {
      return 'You have a 1-day streak! 🔥';
    } else if (_currentStreak < 7) {
      return '$_currentStreak days in a row! Keep it up!';
    } else if (_currentStreak < 30) {
      return '$_currentStreak days! You\'re on fire!!! 🔥🔥';
    } else {
      return '$_currentStreak days! Legendary! 🏆🔥🔥🔥';
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
