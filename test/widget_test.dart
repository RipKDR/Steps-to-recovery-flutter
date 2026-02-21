import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_recovery_flutter/main.dart';

void main() {
  testWidgets('Home shell renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const StepsRecoveryApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Steps to Recovery'), findsOneWidget);
    expect(find.text('One next right move at a time.'), findsOneWidget);
  });
}
