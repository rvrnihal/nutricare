import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/logger.dart';
import '../core/app_router.dart';
import 'analytics_service.dart';

class MedicineNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service - CALL THIS ON APP START (main.dart)
  static Future<void> init() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      await AnalyticsService.trackEvent(
        'notification_permission_android',
        params: {'granted': granted ?? false},
      );
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await AnalyticsService.trackEvent(
        'notification_permission_ios',
        params: {'granted': granted ?? false},
      );
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    unawaited(_handleNotificationTap(response.payload));
  }

  static Future<void> _handleNotificationTap(String? payload) async {
    AppLogger.debug('Notification tapped: $payload');
    await AnalyticsService.trackEvent(
      'medicine_notification_tapped',
      params: {'payload': payload ?? ''},
    );

    final action = parsePayload(payload);
    if (action.type == 'mark_taken' && action.medicineId != null) {
      await _markMedicineAsTaken(action.medicineId!, action.medicineName);
    }

    AppRouter.openMedicineFromNotification(payload: payload);
  }

  static Future<void> _markMedicineAsTaken(String medicineId, String? medicineName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await AnalyticsService.trackEvent(
          'medicine_mark_taken_failed',
          params: {'reason': 'user_not_authenticated', 'medicineId': medicineId},
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .doc(medicineId)
          .set({
        'takenToday': true,
        'lastTaken': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medicine_logs')
          .add({
        'medicineId': medicineId,
        'medicineName': medicineName ?? 'Unknown',
        'takenAt': FieldValue.serverTimestamp(),
        'source': 'notification_tap',
      });

      await AnalyticsService.trackEvent(
        'medicine_mark_taken_success',
        params: {'medicineId': medicineId},
      );
      AppLogger.info('Marked medicine as taken from notification: $medicineId');
    } catch (e, st) {
      await AnalyticsService.trackEvent(
        'medicine_mark_taken_failed',
        params: {'medicineId': medicineId, 'error': e.toString()},
      );
      AppLogger.error('Failed to mark medicine from notification', e, st);
    }
  }

  @visibleForTesting
  static NotificationTapAction parsePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return const NotificationTapAction(type: 'open_medicine');
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final type = (decoded['action']?.toString() ?? 'open_medicine').trim();
        final medicineId = decoded['medicineId']?.toString();
        final medicineName = decoded['medicineName']?.toString();

        if (type == 'mark_taken' && medicineId != null && medicineId.isNotEmpty) {
          return NotificationTapAction(
            type: type,
            medicineId: medicineId,
            medicineName: medicineName,
          );
        }
      }
    } catch (_) {
      // Fallback to legacy format parsing below.
    }

    if (payload.startsWith('mark_taken:')) {
      final parts = payload.split(':');
      final medicineId = parts.length > 1 ? parts[1] : null;
      final medicineName = parts.length > 2 ? parts.sublist(2).join(':') : null;
      if (medicineId != null && medicineId.isNotEmpty) {
        return NotificationTapAction(
          type: 'mark_taken',
          medicineId: medicineId,
          medicineName: medicineName,
        );
      }
    }

    return const NotificationTapAction(type: 'open_medicine');
  }

  /// Schedule a daily reminder at a specific time
  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      // Create scheduled time
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If scheduled time is in the past, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Daily medicine reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Medicine Reminder',
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      AppLogger.info('Scheduled notification $id for $hour:$minute');
    } catch (e, st) {
      AppLogger.error('Error scheduling notification', e, st);
    }
  }

  /// Cancel all reminders for a specific medicine
  static Future<void> cancelMedicineReminders(String medicineId) async {
    // Cancel notifications with IDs based on medicine ID
    // Since we use medicineId.hashCode + index, we'll cancel a range
    final baseId = medicineId.hashCode;
    for (int i = 0; i < 10; i++) {
      // Max 10 reminders per medicine
      await _notifications.cancel(baseId + i);
    }
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Show an immediate notification (for testing)
  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Daily medicine reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Get pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}

class NotificationTapAction {
  final String type;
  final String? medicineId;
  final String? medicineName;

  const NotificationTapAction({
    required this.type,
    this.medicineId,
    this.medicineName,
  });
}
