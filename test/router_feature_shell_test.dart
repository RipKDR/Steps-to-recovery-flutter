import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/constants/app_constants.dart';
import 'package:steps_recovery_flutter/navigation/app_router.dart';
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

      AppRouter.router.go(AppRoutes.journal);
      await _pumpShell(tester);

      final journalSearchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Search titles, content, or tags',
      );
      expect(journalSearchField, findsOneWidget);

      AppRouter.router.go(AppRoutes.meetings);
      await _pumpShell(tester);

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.text('Favorites'), findsWidgets);
    },
  );
}

Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pump();
  // Pump past entrance animations (longest ~800ms). Cannot use pumpAndSettle
  // because _BreathingGlow uses a looping AnimationController.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 600));
}
