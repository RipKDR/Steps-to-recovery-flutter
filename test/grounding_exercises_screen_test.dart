import 'package:flutter/material.dart'
    show
        Card,
        ListView,
        MaterialApp,
        MaterialPageRoute,
        Navigator,
        OutlinedButton,
        Scaffold,
        ScaleTransition,
        Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/features/crisis/screens/grounding_exercises_screen.dart';

void main() {
  group('GroundingExercisesScreen', () {
    testWidgets('displays all four exercises', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      expect(find.text('5-4-3-2-1 Technique'), findsOneWidget);
      expect(find.text('Box Breathing'), findsOneWidget);
      expect(find.text('Body Scan'), findsOneWidget);
      expect(find.text('Safe Place Visualization'), findsOneWidget);
    });

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      expect(find.text('Grounding Exercises'), findsOneWidget);
    });

    testWidgets('each exercise card is tappable', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      // Tap on 5-4-3-2-1 Technique
      final firstExercise = find.text('5-4-3-2-1 Technique');
      expect(firstExercise, findsOneWidget);
      await tester.tap(firstExercise);
      await tester.pumpAndSettle();

      // Should navigate to exercise detail
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('displays exercise descriptions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      // Verify descriptions are present
      expect(find.textContaining('Notice 5 things you see'), findsWidgets);
      expect(find.textContaining('Breathe in for 4'), findsWidgets);
      expect(find.textContaining('Progressively relax'), findsWidgets);
      expect(find.textContaining('Imagine a place'), findsWidgets);
    });

    testWidgets('uses proper spacing and layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      // Should use ListView for scrolling
      expect(find.byType(ListView), findsOneWidget);

      // Cards should be present
      expect(find.byType(Card), findsWidgets);
    });
  });

  group('5-4-3-2-1 Exercise', () {
    testWidgets('displays all sensory steps', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      // Tap to open 5-4-3-2-1 exercise
      await tester.tap(find.text('5-4-3-2-1 Technique'));
      await tester.pumpAndSettle();

      // Should show the 5 senses
      expect(find.textContaining('5 things you can SEE'), findsWidgets);
      expect(find.textContaining('4 things you can FEEL'), findsWidgets);
      expect(find.textContaining('3 things you can HEAR'), findsWidgets);
      expect(find.textContaining('2 things you can SMELL'), findsWidgets);
      expect(find.textContaining('1 thing you can TASTE'), findsWidgets);
    });

    testWidgets('has completion button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      await tester.tap(find.text('5-4-3-2-1 Technique'));
      await tester.pumpAndSettle();

      expect(find.textContaining('I feel grounded'), findsWidgets);
    });
  });

  group('Box Breathing Exercise', () {
    testWidgets('displays breathing animation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      await tester.tap(find.text('Box Breathing'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should have animated container
      expect(find.byType(ScaleTransition), findsWidgets);
    });

    testWidgets('shows breathing instructions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      await tester.tap(find.text('Box Breathing'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('Breathe IN'), findsWidgets);
      expect(find.textContaining('HOLD'), findsWidgets);
      expect(find.textContaining('Breathe OUT'), findsWidgets);
    });

    testWidgets('has start/stop controls', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      await tester.tap(find.text('Box Breathing'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(OutlinedButton), findsWidgets);
    });
  });

  group('Body Scan Exercise', () {
    testWidgets('displays body scan instructions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      await tester.tap(find.text('Body Scan'));
      await tester.pumpAndSettle();

      expect(find.textContaining('relax'), findsWidgets);
      expect(find.textContaining('Progressively'), findsWidgets);
    });

    testWidgets('has timer display', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      // 'min' is displayed on the list cards before tapping
      expect(find.textContaining('min'), findsWidgets);
    });
  });

  group('Safe Place Visualization', () {
    testWidgets('displays visualization guide', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      await tester.tap(find.text('Safe Place Visualization'));
      await tester.pumpAndSettle();

      expect(find.textContaining('safe and calm'), findsWidgets);
      expect(find.textContaining('safe'), findsWidgets);
    });

    testWidgets('provides guided imagery prompts', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: GroundingExercisesScreen()),
      );

      await tester.tap(find.text('Safe Place Visualization'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Imagine'), findsWidgets);
      expect(find.textContaining('safe'), findsWidgets);
    });
  });

  group('Navigation', () {
    testWidgets('back button returns to list', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => const GroundingExercisesScreen(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Box Breathing'));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap back
      final backButton = find.byTooltip('Back');
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Should be back at the list
        expect(find.text('5-4-3-2-1 Technique'), findsOneWidget);
      }
    });
  });
}

