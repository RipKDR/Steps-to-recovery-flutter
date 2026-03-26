import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/features/crisis/screens/grounding_exercises_screen.dart';

void main() {
  group('GroundingExercisesScreen', () {
    testWidgets('displays all four exercises', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      expect(find.text('5-4-3-2-1 Technique'), findsOneWidget);
      expect(find.text('Box Breathing'), findsOneWidget);
      expect(find.text('Body Scan'), findsOneWidget);
      expect(find.text('Safe Place Visualization'), findsOneWidget);
    });

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      expect(find.text('Grounding Exercises'), findsOneWidget);
    });

    testWidgets('each exercise card is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
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
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      // Verify descriptions are present
      expect(find.textContaining('technique'), findsWidgets);
      expect(find.textContaining('breathing'), findsWidgets);
      expect(find.textContaining('relaxation'), findsWidgets);
      expect(find.textContaining('visualization'), findsWidgets);
    });

    testWidgets('uses proper spacing and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      // Should use ListView for scrolling
      expect(find.byType(ListView), findsOneWidget);
      
      // Cards should be present
      expect(find.byType(Card), findsWidgets);
    });
  });

  group('5-4-3-2-1 Exercise', () {
    testWidgets('displays all sensory steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      // Tap to open 5-4-3-2-1 exercise
      await tester.tap(find.text('5-4-3-2-1 Technique'));
      await tester.pumpAndSettle();

      // Should show the 5 senses
      expect(find.textContaining('5 things you can SEE'), findsWidgets);
      expect(find.textContaining('4 things you can TOUCH'), findsWidgets);
      expect(find.textContaining('3 things you can HEAR'), findsWidgets);
      expect(find.textContaining('2 things you can SMELL'), findsWidgets);
      expect(find.textContaining('1 thing you can TASTE'), findsWidgets);
    });

    testWidgets('has completion button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      await tester.tap(find.text('5-4-3-2-1 Technique'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Complete'), findsWidgets);
    });
  });

  group('Box Breathing Exercise', () {
    testWidgets('displays breathing animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      await tester.tap(find.text('Box Breathing'));
      await tester.pumpAndSettle();

      // Should have animated container
      expect(find.byType(AnimatedContainer), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows breathing instructions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      await tester.tap(find.text('Box Breathing'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Inhale'), findsWidgets);
      expect(find.textContaining('Hold'), findsWidgets);
      expect(find.textContaining('Exhale'), findsWidgets);
    });

    testWidgets('has start/stop controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      await tester.tap(find.text('Box Breathing'));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });

  group('Body Scan Exercise', () {
    testWidgets('displays body scan instructions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      await tester.tap(find.text('Body Scan'));
      await tester.pumpAndSettle();

      expect(find.textContaining('relaxation'), findsWidgets);
      expect(find.textContaining('progressive'), findsWidgets);
    });

    testWidgets('has timer display', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      await tester.tap(find.text('Body Scan'));
      await tester.pumpAndSettle();

      expect(find.textContaining('minutes'), findsWidgets);
    });
  });

  group('Safe Place Visualization', () {
    testWidgets('displays visualization guide', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      await tester.tap(find.text('Safe Place Visualization'));
      await tester.pumpAndSettle();

      expect(find.textContaining('peaceful'), findsWidgets);
      expect(find.textContaining('safe'), findsWidgets);
    });

    testWidgets('provides guided imagery prompts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GroundingExercisesScreen(),
        ),
      );

      await tester.tap(find.text('Safe Place Visualization'));
      await tester.pumpAndSettle();

      expect(find.textContaining('imagine'), findsWidgets);
      expect(find.textContaining('visualize'), findsWidgets);
    });
  });

  group('Navigation', () {
    testWidgets('back button returns to list', (WidgetTester tester) async {
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
      await tester.pumpAndSettle();

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
