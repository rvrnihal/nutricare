import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuticare/screens/login_screen.dart';



void main() {
  testWidgets('Login screen shows a button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    // Assert there's at least one ElevatedButton on the screen
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
