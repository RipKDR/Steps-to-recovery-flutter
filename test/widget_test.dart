import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_recovery_flutter/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StepsToRecoveryApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Steps to Recovery'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
