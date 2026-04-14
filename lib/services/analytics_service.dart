import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';

class AnalyticsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> trackEvent(
    String event,
    {Map<String, dynamic>? params}
  ) async {
    try {
      final user = _auth.currentUser;
      final payload = {
        'event': event,
        'params': params ?? <String, dynamic>{},
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'flutter',
      };

      AppLogger.info('Analytics event: $event');

      if (user == null) return;

      await _db
          .collection('users')
          .doc(user.uid)
          .collection('analytics_events')
          .add(payload);
    } catch (e, st) {
      AppLogger.warning('Failed to track analytics event: $event', e);
      AppLogger.debug('Analytics stack trace: $st');
    }
  }
}
