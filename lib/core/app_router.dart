import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/main_layout.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Widget buildNotificationDestination(bool isLoggedIn) {
    return isLoggedIn ? const MainLayout(initialIndex: 4) : const LoginScreen();
  }

  static void openMedicineFromNotification({String? payload}) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final Widget destination = buildNotificationDestination(isLoggedIn);

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }
}
