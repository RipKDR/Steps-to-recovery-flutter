import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/main.dart';
import 'test_helpers.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await prepareTestState();
    await tester.pumpWidget(const StepsToRecoveryApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('What are you\nworking through?'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
