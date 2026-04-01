import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/constants/app_constants.dart';
import 'package:steps_recovery_flutter/navigation/app_router.dart';
import 'package:steps_recovery_flutter/main.dart';

import 'test_helpers.dart';

void main() {
  testWidgets(
    'signed-in shell keeps the guided daily hub and dedicated daily routes reachable',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await createSignedInUser();

      await tester.pumpWidget(const StepsToRecoveryApp());
      await _pumpShell(tester);

      expect(find.text("Today's path"), findsOneWidget);
      AppRouter.router.go('/home/morning-intention');
      await _pumpShell(tester);

      expect(find.text('Morning Intention'), findsOneWidget);

      AppRouter.router.go(AppRoutes.home);
      await _pumpShell(tester);

      AppRouter.router.go('/home/evening-pulse');
      await _pumpShell(tester);

      expect(find.text('Evening Pulse'), findsOneWidget);

      AppRouter.router.go(AppRoutes.home);
      await _pumpShell(tester);

      AppRouter.router.go(AppRoutes.journal);
      await _pumpShell(tester);
      await tester.pumpAndSettle();

      final journalSearchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Search titles, content, or tags',
      );
      expect(journalSearchField, findsOneWidget);

      AppRouter.router.go(AppRoutes.meetings);
      await _pumpShell(tester);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.text('Favorites'), findsWidgets);
    },
  );
}

Future<void> _pumpShell(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}
