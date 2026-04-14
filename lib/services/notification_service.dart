import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    await _fcm.requestPermission();
    await _fcm.getToken();
  }
}
