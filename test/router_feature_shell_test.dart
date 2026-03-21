import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/main.dart';

import 'test_helpers.dart';

void main() {
  testWidgets(
    'signed-in shell routes between the home, journal, and meetings screens',
    (tester) async {
      await createSignedInUser();

      await tester.pumpWidget(const StepsToRecoveryApp());
      await _pumpShell(tester);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);

      await tester.tap(find.text('Journal').last);
      await _pumpShell(tester);

      expect(find.text('No journal entries yet'), findsOneWidget);
      expect(find.text('New entry'), findsOneWidget);

      await tester.tap(find.text('Meetings').last);
      await _pumpShell(tester);

      expect(find.text('Morning Serenity Group'), findsOneWidget);
      expect(find.text('Just for Today Online'), findsOneWidget);
    },
  );
}

Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pump();
  await tester.pumpAndSettle();
}
