// Integration Test Example
// End-to-end testing for complete user flows

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:steps_recovery_flutter/main.dart' as app;
import 'package:steps_recovery_flutter/features/auth/ui/login_screen.dart';
import 'package:steps_recovery_flutter/features/home/ui/home_screen.dart';

void main() {
  // Required for integration tests
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Flow Tests', () {
    testWidgets('Full onboarding to home screen flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on bootstrap/loading screen initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // If user is not authenticated, should show login
      expect(find.byType(LoginScreen), findsOneWidget);

      // Tap on login button (example flow)
      final loginButton = find.byKey(const Key('login_button'));
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Navigate to home
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Journal entry creation flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Journal tab
      final journalTab = find.byKey(const Key('nav_journal'));
      if (journalTab.evaluate().isNotEmpty) {
        await tester.tap(journalTab);
        await tester.pumpAndSettle();
      }

      // Tap on FAB to create new entry
      final fab = find.byKey(const Key('journal_fab'));
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pumpAndSettle();

        // Enter title
        await tester.enterText(
          find.byKey(const Key('journal_title_field')),
          'Test Entry',
        );
        await tester.pumpAndSettle();

        // Enter content
        await tester.enterText(
          find.byKey(const Key('journal_content_field')),
          'This is a test journal entry for integration testing.',
        );
        await tester.pumpAndSettle();

        // Save
        final saveButton = find.byKey(const Key('journal_save_button'));
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Verify entry appears in list
          expect(find.text('Test Entry'), findsOneWidget);
        }
      }
    });

    testWidgets('Crisis button flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Home
      final homeTab = find.byKey(const Key('nav_home'));
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
      }

      // Find and tap crisis/emergency card
      final crisisCard = find.byKey(const Key('emergency_card'));
      if (crisisCard.evaluate().isNotEmpty) {
        await tester.tap(crisisCard);
        await tester.pumpAndSettle();

        // Verify emergency screen appears
        expect(find.byType(Scaffold), findsOneWidget);
        
        // Verify emergency contacts or resources are visible
        expect(
          find.byIcon(Icons.emergency),
          findsOneWidget,
        );
      }
    });

    testWidgets('Step tracking flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Steps tab
      final stepsTab = find.byKey(const Key('nav_steps'));
      if (stepsTab.evaluate().isNotEmpty) {
        await tester.tap(stepsTab);
        await tester.pumpAndSettle();
      }

      // Verify step list is visible
      expect(
        find.textContaining('Step'),
        findsWidgets,
      );

      // Tap on first step
      final firstStep = find.byKey(const Key('step_1_card'));
      if (firstStep.evaluate().isNotEmpty) {
        await tester.tap(firstStep);
        await tester.pumpAndSettle();

        // Verify step detail screen
        expect(
          find.textContaining('Step 1'),
          findsOneWidget,
        );
      }
    });
  });

  group('Performance Tests', () {
    testWidgets('App launch performance', (tester) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // App should launch in under 3 seconds
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(3000),
        reason: 'App launch took too long',
      );
    });

    testWidgets('Screen transition performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Navigate to Journal
      final journalTab = find.byKey(const Key('nav_journal'));
      if (journalTab.evaluate().isNotEmpty) {
        await tester.tap(journalTab);
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Screen transition should be under 500ms
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Screen transition too slow',
      );
    });
  });
}

// How to run integration tests:
//
// 1. On connected device/emulator:
//    flutter test integration_test/app_flow_test.dart
//
// 2. With specific device:
//    flutter test -d <device_id> integration_test/app_flow_test.dart
//
// 3. For all integration tests:
//    flutter test integration_test/
//
// Requirements:
// - Physical device or emulator must be connected
// - App must be built for the target platform
// - Tests run on the actual device, not in test environment

// Tips:
// ✅ Use integration tests for critical user flows
// ✅ Keep tests deterministic (avoid random data)
// ✅ Test on multiple device sizes
// ✅ Monitor performance metrics
// ✅ Run before major releases
