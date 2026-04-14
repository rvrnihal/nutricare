import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../core/logger.dart';
import 'analytics_service.dart';

class SmartwatchService {
  static final _health = Health();
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static bool _isConfigured = false;

  static final List<HealthDataType> _healthTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  static final List<HealthDataAccess> _healthPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  static bool get isSupportedMobilePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static String get platformProviderName {
    if (kIsWeb) return 'Web';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Google Health Connect';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'Apple Health';
    return 'Unsupported Platform';
  }

  static Future<void> _ensureConfigured() async {
    if (_isConfigured) return;
    await _health.configure();
    _isConfigured = true;
  }

  /// Requests permissions and connects to Google Fit (Android) or Apple Health (iOS).
  static Future<bool> connectToHealthPlatform() async {
    if (!isSupportedMobilePlatform) {
      AppLogger.warning('Health platform is only supported on Android/iOS mobile');
      await AnalyticsService.trackEvent(
        'watch_connect_failed',
        params: {'reason': 'unsupported_platform'},
      );
      return false;
    }

    try {
      await _ensureConfigured();

      final granted = await _health.requestAuthorization(
        _healthTypes,
        permissions: _healthPermissions,
      );

      if (granted) {
        AppLogger.info('Connected to $platformProviderName');
        await AnalyticsService.trackEvent(
          'watch_connect_success',
          params: {'provider': platformProviderName},
        );
      } else {
        AppLogger.warning('Health permissions denied for $platformProviderName');
        await AnalyticsService.trackEvent(
          'watch_permission_denied',
          params: {'provider': platformProviderName},
        );
      }

      return granted;
    } catch (e, st) {
      AppLogger.error('Failed to connect to $platformProviderName', e, st);
      await AnalyticsService.trackEvent(
        'watch_connect_failed',
        params: {'provider': platformProviderName, 'error': e.toString()},
      );
      return false;
    }
  }

  /// Pulls today's metrics and writes them to Firestore.
  static Future<Map<String, dynamic>?> syncTodayMetrics() async {
    final user = _auth.currentUser;
    if (user == null) {
      AppLogger.warning('Cannot sync health metrics: user not authenticated');
      await AnalyticsService.trackEvent(
        'watch_sync_failed',
        params: {'reason': 'unauthenticated'},
      );
      return null;
    }

    if (!isSupportedMobilePlatform) {
      AppLogger.warning('Skipping health sync on unsupported platform');
      await AnalyticsService.trackEvent(
        'watch_sync_failed',
        params: {'reason': 'unsupported_platform'},
      );
      return null;
    }

    try {
      await _ensureConfigured();

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final steps = await _health.getTotalStepsInInterval(midnight, now) ?? 0;
      final data = await _health.getHealthDataFromTypes(
        types: _healthTypes,
        startTime: midnight,
        endTime: now,
      );

      final heartRateSamples = data
          .where((e) => e.type == HealthDataType.HEART_RATE)
          .map((e) => _extractNumericValue(e.value))
          .whereType<double>()
          .toList();

      final caloriesSamples = data
          .where((e) => e.type == HealthDataType.ACTIVE_ENERGY_BURNED)
          .map((e) => _extractNumericValue(e.value))
          .whereType<double>()
          .toList();

      final avgHeartRate = heartRateSamples.isEmpty
          ? 0
          : (heartRateSamples.reduce((a, b) => a + b) / heartRateSamples.length)
              .round();

      final calories = caloriesSamples.isEmpty
          ? 0
          : caloriesSamples.reduce((a, b) => a + b).round();

      final payload = {
        'date': '${now.year}-${now.month}-${now.day}',
        'steps': steps,
        'avgHeartRate': avgHeartRate,
        'activeCalories': calories,
        'source': platformProviderName,
        'syncedAt': FieldValue.serverTimestamp(),
      };

      await _db
          .collection('users')
          .doc(user.uid)
          .collection('health_logs')
          .add(payload);

      AppLogger.info('Synced health metrics from $platformProviderName');
      await AnalyticsService.trackEvent(
        'watch_sync_success',
        params: {
          'provider': platformProviderName,
          'steps': steps,
          'avgHeartRate': avgHeartRate,
          'activeCalories': calories,
        },
      );
      return payload;
    } catch (e, st) {
      AppLogger.error('Health sync failed for $platformProviderName', e, st);
      await AnalyticsService.trackEvent(
        'watch_sync_failed',
        params: {'provider': platformProviderName, 'error': e.toString()},
      );
      return null;
    }
  }

  static double? _extractNumericValue(dynamic value) {
    if (value is num) return value.toDouble();

    final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(value.toString());
    if (match == null) return null;

    return double.tryParse(match.group(0)!);
  }

  static Future<void> syncSteps() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _ensureConfigured();

      await _health.requestAuthorization(
        [HealthDataType.STEPS, HealthDataType.HEART_RATE],
        permissions: [HealthDataAccess.READ, HealthDataAccess.READ],
      );

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final steps = await _health.getTotalStepsInInterval(midnight, now) ?? 0;
      
      // Sync to Firebase
      await _db.collection('users').doc(uid).collection('health_logs').add({
        'steps': steps,
        'syncedAt': FieldValue.serverTimestamp(),
        'source': platformProviderName,
      });
      
    } catch (e, st) {
      AppLogger.error('Health Sync Error', e, st);
    }
  }

  // Simulate Heart Rate Stream for "Real-time" feel without physical device
  static Stream<int> getHeartRateStream() {
    return Stream.periodic(const Duration(seconds: 3), (count) {
      // Simulate resting HR between 60-100
      return 60 + Random().nextInt(40);
    });
  }
}
