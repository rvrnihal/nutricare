import 'package:flutter_test/flutter_test.dart';
import 'package:nuticare/core/app_router.dart';
import 'package:nuticare/screens/login_screen.dart';
import 'package:nuticare/screens/main_layout.dart';

void main() {
  group('AppRouter notification destination', () {
    test('returns LoginScreen when user is not logged in', () {
      final destination = AppRouter.buildNotificationDestination(false);
      expect(destination, isA<LoginScreen>());
    });

    test('returns MainLayout with medicine tab when user is logged in', () {
      final destination = AppRouter.buildNotificationDestination(true);
      expect(destination, isA<MainLayout>());
      final layout = destination as MainLayout;
      expect(layout.initialIndex, 4);
    });
  });
}
