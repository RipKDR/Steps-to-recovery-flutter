import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/main.dart';

import 'test_helpers.dart';

void main() {
  testWidgets(
    'signed-in shell uses the richer feature home, journal, and meetings screens',
    (tester) async {
      await createSignedInUser();

      await tester.pumpWidget(const StepsToRecoveryApp());
      await _pumpShell(tester);

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Quick Journal'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await _pumpShell(tester);

      expect(
        find.widgetWithText(TextField, 'Search titles, content, or tags'),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.people_outlined));
      await _pumpShell(tester);

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.text('Favorites'), findsWidgets);
    },
  );
}

Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}
