import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_recovery_flutter/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StepsRecoveryApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
