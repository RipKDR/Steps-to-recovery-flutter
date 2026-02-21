import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/main.dart';

void main() {
  testWidgets('Home shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const StepsRecoveryApp());

    expect(find.text('Steps to Recovery'), findsOneWidget);
    expect(find.text('One next right move at a time.'), findsOneWidget);
  });
}
