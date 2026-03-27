import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/features/crisis/screens/emergency_screen.dart';
import 'package:steps_recovery_flutter/features/crisis/screens/before_you_use_screen.dart';
import 'package:steps_recovery_flutter/features/craving_surf/screens/craving_surf_screen.dart';
import 'package:steps_recovery_flutter/features/emergency/screens/danger_zone_screen.dart';

import 'test_helpers.dart';

void main() {
  group('EmergencyScreen', () {
    testWidgets('renders crisis hotline numbers (988, SAMHSA)', (
      tester,
    ) async {
      await prepareTestState();

      await tester.pumpWidget(
        const MaterialApp(
          home: EmergencyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('988 Suicide & Crisis Lifeline'), findsOneWidget);
      expect(find.text('SAMHSA Helpline'), findsOneWidget);
      expect(find.text('Emergency Hotlines'), findsOneWidget);
    });

    testWidgets('shows emergency contact action buttons', (tester) async {
      await prepareTestState();

      await tester.pumpWidget(
        const MaterialApp(
          home: EmergencyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the support network section and contact cards
      expect(find.text('Safe Dial'), findsOneWidget);
      expect(find.text('Sponsor'), findsOneWidget);
      expect(find.text('Friend'), findsOneWidget);

      // Verify phone icons are present for contact action buttons
      expect(find.byIcon(Icons.phone), findsWidgets);

      // Verify crisis tool cards
      expect(find.text('Crisis Tools'), findsOneWidget);
      expect(find.text('Before You Use'), findsOneWidget);
      expect(find.text('Craving Surf'), findsOneWidget);
      expect(find.text('Danger Zone'), findsOneWidget);
    });
  });

  group('BeforeYouUseScreen', () {
    testWidgets('renders the timer/intervention UI', (tester) async {
      await prepareTestState();

      await tester.pumpWidget(
        const MaterialApp(
          home: BeforeYouUseScreen(),
        ),
      );
      await tester.pump();

      // Timer should show initial 05:00
      expect(find.text('05'), findsOneWidget);
      expect(find.text('00'), findsOneWidget);
      expect(find.text(':'), findsOneWidget);

      // Start Timer button visible
      expect(find.text('Start Timer'), findsOneWidget);

      // Warning/intervention message
      expect(
        find.textContaining('Take 5 minutes'),
        findsOneWidget,
      );
    });

    testWidgets('shows guided reflection prompts', (tester) async {
      await prepareTestState();

      // Use a taller surface to avoid layout overflow in the Column
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: BeforeYouUseScreen(),
        ),
      );
      await tester.pump();

      // Verify the craving wave message
      expect(
        find.textContaining('craving is like a wave'),
        findsOneWidget,
      );

      // Verify action buttons for guided interaction
      expect(find.text("I'm Okay"), findsOneWidget);
      expect(find.text('Call for Help'), findsOneWidget);

      // Tap Start Timer to trigger guided breathing reflection
      await tester.tap(find.text('Start Timer'));
      await tester.pump();

      expect(find.text('Breathe slowly and deeply'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
    });
  });

  group('CravingSurfScreen', () {
    testWidgets('renders the breathing exercise widget', (tester) async {
      await prepareTestState();

      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CravingSurfScreen(),
        ),
      );
      await tester.pump();

      // Header text
      expect(find.text('Ride the wave'), findsOneWidget);
      expect(
        find.textContaining('Cravings are like waves'),
        findsOneWidget,
      );

      // Breathing instruction
      expect(find.text('Breathe In'), findsOneWidget);

      // Breath counter
      expect(find.text('Breath 0'), findsOneWidget);

      // Remember tips section
      expect(find.text('Remember:'), findsOneWidget);
      expect(find.text('This feeling will pass'), findsOneWidget);
      expect(
        find.text("You've survived every craving before"),
        findsOneWidget,
      );
      expect(find.text('Focus on your breath'), findsOneWidget);
      expect(find.text('Reach out if you need support'), findsOneWidget);

      // Complete button
      expect(find.text('I Feel Better'), findsOneWidget);
    });
  });

  group('DangerZoneScreen', () {
    testWidgets('shows warning/confirmation flow for risky contacts', (
      tester,
    ) async {
      await prepareTestState();

      await tester.pumpWidget(
        const MaterialApp(
          home: DangerZoneScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Warning banner
      expect(
        find.textContaining('risky'),
        findsOneWidget,
      );

      // Risky contacts are displayed
      expect(find.text('Using Buddy'), findsOneWidget);
      expect(find.text('Old Dealer'), findsOneWidget);

      // Reasons shown
      expect(find.text('Active user - triggers cravings'), findsOneWidget);
      expect(find.text('Source of substances'), findsOneWidget);

      // Phone numbers shown
      expect(find.text('(555) 111-2222'), findsOneWidget);
      expect(find.text('(555) 333-4444'), findsOneWidget);

      // Delete buttons for each contact
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));

      // Dangerous icon for each contact
      expect(find.byIcon(Icons.dangerous), findsNWidgets(2));

      // FAB to add new risky contact
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
